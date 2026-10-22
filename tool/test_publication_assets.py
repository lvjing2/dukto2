import gzip
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import stat
import tarfile
import tempfile
import unittest
import zipfile

spec = importlib.util.spec_from_file_location('publication', Path(__file__).parent / 'ci/prepare_release_assets.py')
publication = importlib.util.module_from_spec(spec)
spec.loader.exec_module(publication)


class PublicationAssetsTest(unittest.TestCase):
    def fixtures(self, root):
        version = '1.2.3-rc.1+4'
        prefix = 'Dukto2-1.2.3-rc.1-build.4-'
        for target, suffix in publication.TARGETS.items():
            artifact = root / (prefix + target + suffix)
            if target == 'android':
                with zipfile.ZipFile(artifact, 'w') as z:
                    z.writestr('assets/flutter_assets/NOTICES.Z', gzip.compress(b'\ndukto2\n\nApache License'))
                    z.writestr('META-INF/CERT.RSA', b'unchanged signature fixture')
            elif target.startswith('linux'):
                with tarfile.open(artifact, 'w:gz') as z:
                    entry = tarfile.TarInfo('bundle/dukto2')
                    entry.mode, entry.size = 0o755, 7
                    z.addfile(entry, io.BytesIO(b'program'))
                    link = tarfile.TarInfo('bundle/current')
                    link.type, link.linkname = tarfile.SYMTYPE, 'dukto2'
                    z.addfile(link)
            else:
                with zipfile.ZipFile(artifact, 'w') as z:
                    entry = zipfile.ZipInfo('app/program')
                    entry.external_attr = (stat.S_IFREG | 0o755) << 16
                    z.writestr(entry, b'program')
                    link = zipfile.ZipInfo('app/current')
                    link.create_system = 3
                    link.external_attr = (stat.S_IFLNK | 0o777) << 16
                    z.writestr(link, b'program')
            info = {'version': version, 'target': target, 'commit': 'a' * 40}
            if target == 'android':
                info['androidSigning'] = {'playEquivalentApkVerified': True, 'artifacts': {'apk': publication.digest(artifact)}}
            (root / (prefix + target + '.json')).write_text(json.dumps(info))
            (root / (artifact.name + '.sha256')).write_text(publication.digest(artifact) + '  ' + artifact.name + '\n')
        # Developer/store artifacts must not leak into the user download list.
        (root / 'extra-play.aab').write_bytes(b'store upload')
        (root / 'promotion.zip').write_bytes(b'promotion')
        return version

    def test_one_asset_per_platform_and_apk_signature_bytes_unchanged(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            version = self.fixtures(root)
            outputs = publication.prepare(root, root / 'publish', version)
            self.assertEqual(len(outputs), 8)
            self.assertFalse(any('ios' in p.name for p in outputs))
            self.assertFalse(any(p.suffix == '.aab' for p in outputs))
            self.assertIn('Dukto2 1.2.3-rc.1', (root / 'publish/INSTALL.md').read_text())
            sums = (root / 'publish/SHA256SUMS.txt').read_text().splitlines()
            self.assertEqual(len(sums), 7)
            for line in sums:
                expected, name = line.split('  ', 1)
                self.assertEqual(publication.digest(root / 'publish' / name), expected)
            apk = next(p for p in outputs if p.suffix == '.apk')
            self.assertEqual(apk.read_bytes(), (root / apk.name).read_bytes())
            for archive in (p for p in outputs if p.suffix == '.zip'):
                with zipfile.ZipFile(archive) as z, zipfile.ZipFile(root / archive.name) as original:
                    self.assertIn('RELEASE-INFO.json', z.namelist())
                    sums = z.read('SHA256SUMS.txt').decode()
                    self.assertIn(hashlib.sha256(b'program').hexdigest() + '  app/program', sums)
                    self.assertNotIn('app/current', sums)
                    for entry in original.infolist():
                        self.assertEqual(z.read(entry.filename), original.read(entry))
                        self.assertEqual(z.getinfo(entry.filename).external_attr, entry.external_attr)
            with tarfile.open(next(p for p in outputs if p.name.endswith('.tar.gz'))) as z:
                self.assertEqual(z.getmember('bundle/dukto2').mode, 0o755)
                self.assertEqual(z.getmember('bundle/current').linkname, 'dukto2')
                self.assertIn('RELEASE-INFO.json', z.getnames())
                self.assertIn('SHA256SUMS.txt', z.getnames())

    def test_unsigned_ios_artifacts_are_not_required_for_public_downloads(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            version = self.fixtures(root)
            for path in root.glob('*ios*'):
                path.unlink()
            outputs = publication.prepare(root, root / 'publish', version)
            self.assertEqual(len(outputs), 8)
            self.assertFalse(any('ios' in path.name for path in outputs))

    def test_changed_payload_or_mixed_source_is_rejected_before_output(self):
        for corrupt_payload in (True, False):
            with tempfile.TemporaryDirectory() as temp:
                root = Path(temp)
                version = self.fixtures(root)
                if corrupt_payload:
                    next(root.glob('*windows-x64.zip')).write_bytes(b'changed')
                else:
                    path = next(root.glob('*windows.json'))
                    info = json.loads(path.read_text()); info['commit'] = 'b' * 40
                    path.write_text(json.dumps(info))
                with self.assertRaises(ValueError):
                    publication.prepare(root, root / 'publish', version)
                self.assertFalse((root / 'publish').exists())


if __name__ == '__main__':
    unittest.main()
