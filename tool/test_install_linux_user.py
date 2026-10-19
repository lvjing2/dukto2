import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location(
    "dukto2_installer", Path(__file__).with_name("install_linux_user.py")
)
installer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(installer)


class InstallerTest(unittest.TestCase):
    def test_user_entry_uses_actual_bundle_and_registers_notifications(self):
        with tempfile.TemporaryDirectory(prefix="dukto2-desktop-") as temp:
            root = Path(temp)
            bundle = root / "Dukto2 100% 中文"
            bundle.mkdir()
            executable = bundle / "dukto2"
            executable.write_text("test fixture")
            executable.chmod(0o700)
            icon = bundle / "data/flutter_assets/assets/branding/dukto2.png"
            icon.parent.mkdir(parents=True)
            icon.write_bytes(b"fixture icon")
            data_home = root / "user-data"
            entry = installer.install(bundle, data_home)
            text = entry.read_text()
            self.assertEqual(entry.name, installer.APP_ID + ".desktop")
            self.assertIn(f'Exec="{str(executable.resolve()).replace("%", "%%")}"', text)
            self.assertIn("X-GNOME-UsesNotifications=true", text)
            self.assertIn("Icon=" + installer.APP_ID, text)
            saved = data_home / "icons/hicolor/192x192/apps" / (installer.APP_ID + ".png")
            self.assertEqual(saved.read_bytes(), icon.read_bytes())
            # Re-registering another bundle is an update; no old bundle is removed.
            entry.write_text("old entry")
            installer.install(bundle, data_home)
            self.assertIn("TryExec=", entry.read_text())
            self.assertTrue(executable.exists())

    def test_incomplete_bundle_does_not_create_a_broken_launcher(self):
        with tempfile.TemporaryDirectory(prefix="dukto2-desktop-") as temp:
            bundle = Path(temp)
            data = bundle / "data-home"
            with self.assertRaises(ValueError):
                installer.install(bundle, data)
            self.assertFalse(data.exists())


if __name__ == "__main__":
    unittest.main()
