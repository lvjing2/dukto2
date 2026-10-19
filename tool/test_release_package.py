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


if __name__ == '__main__':
    unittest.main()
