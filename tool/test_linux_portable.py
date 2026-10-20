import importlib.util
from pathlib import Path
import struct
import sys
import tempfile
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET

sys.path.insert(0, str(Path(__file__).parent / 'ci'))
spec = importlib.util.spec_from_file_location('portable', Path(__file__).parent / 'ci/package_linux_portable.py')
portable = importlib.util.module_from_spec(spec)
spec.loader.exec_module(portable)


class PortablePackagingTest(unittest.TestCase):
    def bundle(self, root):
        header = bytearray(64)
        header[:6] = b'\x7fELF\x02\x01'
        struct.pack_into('<H', header, 18, 62)
        for name in portable.REQUIRED:
            path = root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(header if name == 'dukto2' or name.endswith('.so') else b'data')

    def test_rejects_newer_engine_or_plugin_glibc(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self.bundle(root)
            with patch.object(portable.subprocess, 'check_output', return_value='Name: GLIBC_2.35'):
                self.assertEqual(len(portable.audit(root, 'x64')), 3)
            def readelf(command, **kwargs):
                return 'GLIBC_2.38' if command[-1].endswith('libapp.so') else 'GLIBC_2.35'
            with patch.object(portable.subprocess, 'check_output', side_effect=readelf):
                with self.assertRaisesRegex(ValueError, 'exceeds baseline'):
                    portable.audit(root, 'x64')

    def test_requires_complete_bundle(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self.bundle(root)
            (root / 'data/icudtl.dat').unlink()
            with self.assertRaisesRegex(ValueError, 'Incomplete Flutter bundle'):
                portable.audit(root, 'x64')

    def test_rejects_escaping_symlinks(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            source = root / 'source'
            source.mkdir()
            (source / 'escape').symlink_to(root / 'outside')
            with self.assertRaisesRegex(ValueError, 'escapes source'):
                portable.checked_copy(source, root / 'dest')

    def test_launcher_is_relocatable_and_metadata_matches(self):
        with tempfile.TemporaryDirectory(prefix='with space ') as temp:
            root = Path(temp)
            self.bundle(root / 'bundle')
            with patch.object(portable, 'run'):
                portable.populate(root / 'prefix', root / 'bundle')
            prefix = root / 'prefix'
            self.assertTrue((prefix / 'lib/dukto2/data/icudtl.dat').is_file())
            self.assertIn('"$HERE/lib/dukto2/dukto2" "$@"', (prefix / 'bin/dukto2').read_text())
            metadata = ET.parse(prefix / 'share/metainfo' / (portable.APP_ID + '.metainfo.xml'))
            self.assertEqual(metadata.findtext('id'), portable.APP_ID)
            self.assertEqual(metadata.findtext('project_license'), 'Apache-2.0')
            self.assertEqual(metadata.find('releases/release').get('version'), portable.version())

    def test_cached_tool_is_never_executed_after_digest_mismatch(self):
        with tempfile.TemporaryDirectory() as temp:
            cache = Path(temp)
            sha = portable.CONFIG['tools']['linuxdeploy']['x64']['sha256']
            (cache / ('linuxdeploy-' + sha)).write_text('tampered')
            with patch.object(portable.urllib.request, 'urlopen') as network:
                with self.assertRaisesRegex(ValueError, 'checksum mismatch'):
                    portable.tool('linuxdeploy', 'x64', cache)
                network.assert_not_called()

    def test_numeric_glibc_versions(self):
        self.assertEqual(max(portable.glibc_versions('GLIBC_2.9 GLIBC_2.35 GLIBC_PRIVATE GLIBC_2.3.4')), (2, 35))


if __name__ == '__main__':
    unittest.main()
