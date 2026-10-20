from pathlib import Path
import json
import tempfile
import unittest

from sync_project_version import ASSET, project_metadata, sync


class ProjectVersionTest(unittest.TestCase):
    def test_prerelease_is_preserved_and_stale_assets_fail_without_rewriting(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            manifest = root / 'pubspec.yaml'
            manifest.write_text('name: dukto2\nversion: 1.2.3-rc.4+27\n')
            sync(root)
            self.assertEqual(json.loads((root / ASSET).read_text()),
                             {'version': '1.2.3-rc.4', 'buildNumber': '27'})
            sync(root, check=True)
            manifest.write_text('name: dukto2\nversion: 1.2.3+28\n')
            previous = (root / ASSET).read_bytes()
            with self.assertRaisesRegex(ValueError, 'stale'):
                sync(root, check=True)
            self.assertEqual((root / ASSET).read_bytes(), previous)
            sync(root)
            self.assertEqual(project_metadata(root), {'version': '1.2.3', 'buildNumber': '28'})
            sync(root, check=True)


if __name__ == '__main__':
    unittest.main()
