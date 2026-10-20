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


def pe_imports(path):
    data = path.read_bytes()
    offset = struct.unpack_from('<I', data, 60)[0]
    sections, optional_size = struct.unpack_from('<H', data, offset + 6)[0], struct.unpack_from('<H', data, offset + 20)[0]
    optional = offset + 24
    if optional_size == 0:
        return set()
    if struct.unpack_from('<H', data, optional)[0] != 0x20b:
        raise ValueError('Expected PE32+ binary: ' + str(path))
    import_rva = struct.unpack_from('<I', data, optional + 120)[0]
    if import_rva == 0:
        return set()

    def file_offset(rva):
        for index in range(sections):
            section = optional + optional_size + index * 40
            size, address, raw_size, raw = struct.unpack_from('<IIII', data, section + 8)
            if address <= rva < address + max(size, raw_size):
                return raw + rva - address
        raise ValueError('Invalid PE import address: ' + str(path))

    cursor = file_offset(import_rva)
    names = set()
    while any(data[cursor:cursor + 20]):
        name = file_offset(struct.unpack_from('<I', data, cursor + 12)[0])
        names.add(data[name:data.index(b'\0', name)].decode('ascii').lower())
        cursor += 20
    return names


def verify_bundle(system, arch, bundle):
    executable = bundle / ('Dukto2.exe' if system == 'windows' else 'dukto2')
    paths = [executable, *bundle.rglob('*.dll' if system == 'windows' else '*.so')]
    for path in paths:
        actual = architecture(path)
        if system == 'windows' and arch == 'arm64' and 'vcruntime140_1.dll' in pe_imports(path):
            raise ValueError('Native ARM64 payload unexpectedly imports excluded x64 EH helper: ' + str(path))
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
