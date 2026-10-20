import importlib.util
from pathlib import Path
import struct
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('native', Path(__file__).parent / 'ci/verify_native.py')
native = importlib.util.module_from_spec(spec)
spec.loader.exec_module(native)


class NativeArchitectureTest(unittest.TestCase):
    def pe(self, machine):
        header = bytearray(128)
        header[:2] = b'MZ'
        struct.pack_into('<I', header, 60, 64)
        header[64:68] = b'PE\0\0'
        struct.pack_into('<H', header, 68, machine)
        return header

    def test_windows_rejects_x64_runtime_in_arm64_bundle(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root / 'Dukto2.exe').write_bytes(self.pe(0xaa64))
            (root / 'runtime.dll').write_bytes(self.pe(0x8664))
            with self.assertRaisesRegex(ValueError, 'expected arm64, got x64'):
                native.verify_bundle('windows', 'arm64', root)
            (root / 'runtime.dll').write_bytes(self.pe(0xaa64))
            native.verify_bundle('windows', 'arm64', root)

    def test_elf_headers_distinguish_arm64_from_x64(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / 'dukto2'
            for machine, expected in [(183, 'arm64'), (62, 'x64')]:
                header = bytearray(64)
                header[:6] = b'\x7fELF\x02\x01'
                struct.pack_into('<H', header, 18, machine)
                path.write_bytes(header)
                self.assertEqual(native.architecture(path), expected)


if __name__ == '__main__':
    unittest.main()
