#!/usr/bin/env python3
"""Register an existing Dukto2 bundle in the current user's desktop session."""

import argparse
import os
from pathlib import Path
import shutil
import subprocess
import sys

APP_ID = "dev.dukto2.dukto2"


def desktop_value(value):
    return str(value).replace("\\", "\\\\").replace("\n", "\\n").replace("\r", "\\r")


def exec_argument(value):
    # Desktop Entry quoting, followed by the key-file's separate escape layer.
    text = str(value).replace("%", "%%")
    for character in ("\\", '"', "`", "$"):
        text = text.replace(character, "\\" + character)
    return desktop_value('"' + text + '"')


def install(bundle, data_home):
    bundle = Path(bundle).resolve(strict=True)
    executable = bundle / "dukto2"
    icon = bundle / "data/flutter_assets/assets/branding/dukto2.png"
    if not executable.is_file() or not os.access(executable, os.X_OK):
        raise ValueError("Expected an executable dukto2 in the bundle")
    if not icon.is_file():
        raise ValueError("The bundle is missing the Dukto2 brand icon")
    data_home = Path(data_home).expanduser().resolve()
    applications = data_home / "applications"
    icon_folder = data_home / "icons/hicolor/192x192/apps"
    applications.mkdir(parents=True, exist_ok=True)
    icon_folder.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(icon, icon_folder / (APP_ID + ".png"))
    entry = applications / (APP_ID + ".desktop")
    content = (
        "[Desktop Entry]\nType=Application\nName=Dukto2\n"
        "Comment=Share files and text on your local network\n"
        f"Exec={exec_argument(executable)}\n"
        f"TryExec={desktop_value(executable)}\n"
        f"Icon={APP_ID}\nTerminal=false\nCategories=Network;FileTransfer;\n"
        f"StartupWMClass={APP_ID}\nX-GNOME-UsesNotifications=true\n"
    )
    temporary = entry.with_suffix(".desktop.tmp")
    temporary.write_text(content, encoding="utf-8")
    temporary.replace(entry)
    return entry


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("bundle", help="Absolute or relative path to the complete bundle")
    args = parser.parse_args()
    if not sys.platform.startswith("linux"):
        parser.error("Run this on the Linux desktop that will use Dukto2")
    data_home = Path(os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local/share")))
    if not data_home.is_absolute():
        parser.error("XDG_DATA_HOME must be an absolute path")
    entry = install(args.bundle, data_home)
    update = shutil.which("update-desktop-database")
    if update:
        subprocess.run([update, str(entry.parent)], check=False)
    print(f"Desktop entry: {entry}")
    print("Keep the bundle at this location; rerun after moving or updating it.")


if __name__ == "__main__":
    main()
