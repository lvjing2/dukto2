"""Reject mislabeled native SDKs and desktop bundles before publication."""
import argparse
from pathlib import Path
import platform
import shutil
import struct


def architecture(path):
    with path.open('rb') as stream:
        header = stream.read(64)
        if header[:2] == b'MZ':
            offset = struct.unpack_from('<I', header, 60)[0]
            stream.seek(offset)
            signature = stream.read(6)
            if signature[:4] != b'PE\0\0':
                raise ValueError('Invalid PE signature: ' + str(path))
            machine = struct.unpack_from('<H', signature, 4)[0]
            return {0x8664: 'x64', 0xaa64: 'arm64'}.get(machine, hex(machine))
        if header[:4] == b'\x7fELF':
            endian = '<' if header[5] == 1 else '>'
            machine = struct.unpack_from(endian + 'H', header, 18)[0]
            return {62: 'x64', 183: 'arm64'}.get(machine, str(machine))
    raise ValueError('Unsupported native binary: ' + str(path))


def verify_bundle(system, arch, bundle):
    executable = bundle / ('Dukto2.exe' if system == 'windows' else 'dukto2')
    paths = [executable, *bundle.rglob('*.dll' if system == 'windows' else '*.so')]
    for path in paths:
        actual = architecture(path)
        if actual != arch:
            raise ValueError(f'{path}: expected {arch}, got {actual}')
    print(f'Verified {system} {arch}: {len(paths)} native binaries')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('system', choices=['sdk', 'windows', 'linux'])
    parser.add_argument('arch', nargs='?', choices=['x64', 'arm64'])
    parser.add_argument('bundle', nargs='?', type=Path)
    args = parser.parse_args()
    if args.system == 'sdk':
        if platform.system() == 'Darwin':
            return  # Official macOS archive already selects the native SDK.
        arch = 'arm64' if platform.machine().lower() in ('arm64', 'aarch64') else 'x64'
        flutter = Path(shutil.which('flutter') or shutil.which('flutter.bat'))
        dart = flutter.parent / 'cache/dart-sdk/bin' / ('dart.exe' if platform.system() == 'Windows' else 'dart')
        if architecture(dart) != arch:
            raise ValueError('Flutter bootstrapped a non-native Dart SDK; refusing architecture fallback')
        print('Verified native Dart SDK:', arch)
    else:
        if not args.arch or args.bundle is None:
            parser.error('Desktop verification requires architecture and bundle')
        verify_bundle(args.system, args.arch, args.bundle)


if __name__ == '__main__':
    main()
