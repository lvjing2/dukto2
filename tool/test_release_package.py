import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest import mock

spec = importlib.util.spec_from_file_location(
    'release_package', Path(__file__).parent / 'ci/package_release.py'
)
package = importlib.util.module_from_spec(spec)
spec.loader.exec_module(package)


class ReleasePackageTest(unittest.TestCase):
    def test_manual_platform_selection_and_tag_builds(self):
        self.assertEqual(package.release_matrix('refs/heads/main', 'android')['include'], [{'target': 'android', 'runner': 'ubuntu-24.04'}])
        self.assertEqual(len(package.release_matrix('refs/tags/v1.2.3', 'android')['include']), 7)
        with self.assertRaises(ValueError):
            package.release_matrix('refs/heads/unreviewed', 'android')
        with self.assertRaises(ValueError):
            package.release_matrix('refs/heads/main', 'unknown')

    def test_native_apple_bundle_layouts_are_distinct(self):
        with tempfile.TemporaryDirectory() as temp:
            app = Path(temp) / 'Dukto2.app'
            (app / 'Contents').mkdir(parents=True)
            (app / 'Contents/Info.plist').write_text('<plist/>')
            package.validate_apple_bundle(app, 'macos')
            with self.assertRaises(ValueError):
                package.validate_apple_bundle(app, 'ios')
            (app / 'Contents/Info.plist').unlink()
            (app / 'Info.plist').write_text('<plist/>')
            package.validate_apple_bundle(app, 'ios')
            with self.assertRaises(ValueError):
                package.validate_apple_bundle(app, 'macos')

    def test_release_tag_cannot_mislabel_the_source_version(self):
        with mock.patch.object(package, 'version', return_value='1.2.3+4'):
            package.check_tag('refs/heads/main')
            package.check_tag('refs/tags/v1.2.3')
            package.check_tag('refs/tags/v1.2.3+4')
            with self.assertRaises(ValueError):
                package.check_tag('refs/tags/v1.2.4')
            with self.assertRaises(ValueError):
                package.check_tag('refs/tags/v1.2.3+5')

    def test_candidate_tag_preserves_prerelease_and_build_number(self):
        with mock.patch.object(package, 'version', return_value='0.1.6-rc.1+8'):
            package.check_tag('refs/tags/v0.1.6-rc.1')
            package.check_tag('refs/tags/v0.1.6-rc.1+8')
            for ref in ('refs/tags/v0.1.6', 'refs/tags/v0.1.6-rc.2', 'refs/tags/v0.1.6-rc.1+7'):
                with self.assertRaises(ValueError):
                    package.check_tag(ref)


if __name__ == '__main__':
    unittest.main()
