import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


class LinuxInstallEntryTest(unittest.TestCase):
    def test_dependencies_are_checked_before_registering_desktop(self):
        for missing in (False, True):
            with self.subTest(missing=missing), tempfile.TemporaryDirectory() as temp:
                root = Path(temp)
                bundle = root / 'Dukto2 中文 100%'
                bundle.mkdir()
                tool = Path(__file__).parent
                shutil.copy2(tool / 'install-linux.sh', bundle / 'install.sh')
                shutil.copy2(tool / 'install_linux_user.py', bundle / 'install_linux_user.py')
                executable = bundle / 'dukto2'
                executable.write_text('#!/bin/sh\nexit 0\n')
                executable.chmod(0o755)
                icon = bundle / 'data/flutter_assets/assets/branding/dukto2.png'
                icon.parent.mkdir(parents=True)
                icon.write_bytes(b'fixture')
                # Mock only the platform/dependency boundary; run the real entry
                # registration in an isolated user-data folder, even on macOS.
                commands = root / 'bin'
                commands.mkdir()
                for name, body in {'uname': 'echo Linux', 'ldd': 'echo "libgtk.so => not found"' if missing else 'echo "libgtk.so => /lib/libgtk.so"', 'python3': 'exec "' + os.sys.executable + '" -c \'import runpy,sys; sys.platform="linux"; p=sys.argv.pop(1); runpy.run_path(p,run_name="__main__")\' "$@"', 'update-desktop-database': 'exit 0'}.items():
                    path = commands / name
                    path.write_text('#!/bin/sh\n' + body + '\n')
                    path.chmod(0o755)
                data = root / 'user-data'
                env = dict(os.environ, PATH=str(commands) + os.pathsep + os.environ['PATH'], XDG_DATA_HOME=str(data))
                result = subprocess.run(['bash', str(bundle / 'install.sh')], env=env, capture_output=True, text=True)
                entry = data / 'applications/dev.dukto2.dukto2.desktop'
                if missing:
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn('Missing runtime dependencies', result.stderr)
                    self.assertFalse(entry.exists())
                else:
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertIn('Dukto2 中文 100%%', entry.read_text())


if __name__ == '__main__':
    unittest.main()
