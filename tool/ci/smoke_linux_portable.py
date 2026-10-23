"""Verify a visible GTK window under Xvfb; this is not a physical LAN test."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import time


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', required=True, type=Path)
    parser.add_argument('command', nargs=argparse.REMAINDER)
    args = parser.parse_args()
    command = args.command
    if command[:1] == ['--']:
        command = command[1:]
    if not command:
        parser.error('A launch command is required')
    env = dict(os.environ, LIBGL_ALWAYS_SOFTWARE='1', APPIMAGE_EXTRACT_AND_RUN='1')
    log = args.report.with_suffix('.log')
    args.report.parent.mkdir(parents=True, exist_ok=True)
    with log.open('w') as stream:
        process = subprocess.Popen(command, env=env, stdout=stream, stderr=subprocess.STDOUT,
                                   start_new_session=True)
        try:
            for _ in range(80):
                if process.poll() is not None:
                    raise RuntimeError('Application exited before window validation: ' + log.read_text())
                found = subprocess.run(['xdotool', 'search', '--onlyvisible', '--name', 'Dukto2'],
                                       capture_output=True, text=True)
                if found.returncode == 0 and found.stdout.strip():
                    # Let Flutter initialize its first frame, then ensure it stays alive.
                    time.sleep(3)
                    if process.poll() is not None:
                        raise RuntimeError('Application exited during initialization: ' + log.read_text())
                    args.report.write_text(json.dumps({'visibleWindow': True, 'launchCommand': command,
                        'scope': 'Xvfb startup only; no portal, discovery or file transfer acceptance.'}, indent=2) + '\n')
                    return
                time.sleep(0.5)
            raise RuntimeError('No visible Dukto2 window within 40 seconds: ' + log.read_text())
        finally:
            if process.poll() is None:
                import signal
                os.killpg(process.pid, signal.SIGTERM)
                try:
                    process.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    os.killpg(process.pid, signal.SIGKILL)
                    process.wait(timeout=5)


if __name__ == '__main__':
    main()
