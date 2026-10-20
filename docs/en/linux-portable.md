# Portable Linux packages (candidates)

English | [Simplified Chinese](../linux-portable.md)

Flatpak and AppImage candidates target native x86_64 and ARM64. Their separate CI workflow does not publish releases or Flathub entries and does not replace the existing tar.gz release workflow.

| Format | Purpose | Requirements |
| --- | --- | --- |
| Flatpak | Desktop installation with a shared runtime and file authorization | Flatpak support; access to the GNOME 49 runtime on Flathub for the first installation |
| AppImage | Portable execution without a system installation | 64-bit Linux, glibc 2.35 or newer, compatible desktop, drivers and system services |
| tar.gz | Manual deployment and troubleshooting | Compatible GTK3 and system dependencies |

Flatpak does not remove kernel, driver, portal or network differences. AppImage does not replace system glibc. Building on Ubuntu 22.04 is a compatibility baseline, not evidence of testing every older distribution. These candidates do not target 32-bit systems or musl environments.

## Build and verify

On native Ubuntu 22.04 of the target architecture, install the existing Linux build dependencies plus `binutils patchelf file squashfs-tools desktop-file-utils appstream flatpak`. Use the repository's pinned Flutter SDK:

```sh
./tool/linux.sh
# Use arm64 instead of x64 on native ARM64 hosts.
python3 tool/ci/package_linux_portable.py appimage --arch x64 --bundle build/linux/x64/release/bundle
python3 tool/ci/package_linux_portable.py flatpak --arch x64 --bundle build/linux/x64/release/bundle
(cd dist && sha256sum --check *.sha256)
```

`.github/workflows/linux-portable.yml` builds both architectures natively in Ubuntu 22.04 containers. Packaging verifies the complete Flutter bundle, native ELF architecture and GLIBC symbol requirements of every ELF, including newly bundled AppImage dependencies. Requirements above GLIBC 2.35 fail the build. Official packaging tools have pinned SHA-256 checksums verified before execution; review updates to `linux/packaging/portable/toolchain.json` when upstream continuous artifacts change.

Each package includes a `.sha256` and `.json` sidecar recording source commit, version, architecture, baseline, native files and Flatpak permissions. Private CI artifacts expire after 14 days. This workflow creates no release, tag, store listing or public download.

CI also checks a visible window and process survival under Xvfb; Flatpak installs and starts on a host runner with its declared sandbox permissions. This is a startup check, not acceptance of portals, desktop integration or physical LAN transfers.

## Install a candidate

Replace the example version and architecture with the downloaded filename:

```sh
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --user ./Dukto2-VERSION-linux-x64.flatpak
flatpak run dev.dukto2.dukto2

chmod +x ./Dukto2-VERSION-linux-x64.AppImage
./Dukto2-VERSION-linux-x64.AppImage
# Without FUSE:
./Dukto2-VERSION-linux-x64.AppImage --appimage-extract-and-run
```

Adding Flathub provides the runtime, not a Dukto2 store listing. Install a newer bundle to update; offline bundles do not provide automatic store updates. Uninstall with `flatpak uninstall --user dev.dukto2.dukto2`; omit `--delete-data` to preserve application settings.

## Permissions and acceptance

Flatpak grants network, graphics and access to Downloads/Dukto2. Other files and folders use desktop file-selection portals. It does not grant the whole home directory, all devices or unrestricted session-bus access. Flatpak settings live in its private application directory and can differ from the ordinary installation; select the receiving folder again when migrating.

Discovery uses UDP 45878 and transfers default to TCP 45879. Firewalls, routing, AP isolation and VPN policies still apply. QR connection requires direct IP reachability; separate subnets do not guarantee automatic discovery.

Before publication, record installations on Ubuntu 22.04/24.04, Debian, Fedora and intended Mint/deepin/UOS releases, covering GNOME/KDE, Wayland/X11, send/receive file authorization, default/custom receiving folders, notifications, sleep inhibition and large-file transfers in both directions. ARM64 requires physical hardware testing too. Consult the specific CI run for current candidate results; the planned matrix is not a verified support list.
