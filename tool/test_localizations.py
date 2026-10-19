"""Catalog consistency and native resource parity; gen-l10n validates ICU syntax."""
import json
import re
import unittest
from pathlib import Path
from sync_native_localizations import LOCALES, ROOT, resources


class CatalogTests(unittest.TestCase):
    def test_all_ten_languages_translate_every_message_with_matching_arguments(self):
        template = json.loads((ROOT / 'lib/l10n/app_en.arb').read_text())
        keys = {key for key in template if not key.startswith('@')}
        self.assertEqual(len(LOCALES), 10)
        self.assertGreater(len(keys), 200)
        for locale in LOCALES:
            with self.subTest(locale=locale):
                data = json.loads((ROOT / f'lib/l10n/app_{locale}.arb').read_text())
                self.assertEqual({key for key in data if not key.startswith('@')}, keys)
                for key in keys:
                    self.assertTrue(data[key].strip(), (locale, key))
                    self.assertEqual(set(re.findall(r'\{(arg\d+)[},]', data[key])),
                                     set(re.findall(r'\{(arg\d+)[},]', template[key])), (locale, key))

    def test_os_permission_resources_match_catalogs(self):
        for path, expected in resources():
            self.assertEqual(path.read_text(), expected, str(path))

    def test_regional_fallbacks_have_matching_keys_and_arguments(self):
        for base, regional in [('zh', 'zh_Hans'), ('pt', 'pt_BR')]:
            basic = json.loads((ROOT / f'lib/l10n/app_{base}.arb').read_text())
            region = json.loads((ROOT / f'lib/l10n/app_{regional}.arb').read_text())
            basic.pop('@@locale'); region.pop('@@locale')
            self.assertEqual(set(basic), set(region))
            # Regional wording may differ; key and argument contracts must agree.
            for key in basic:
                self.assertEqual(set(re.findall(r'\{(arg\d+)[},]', basic[key])),
                                 set(re.findall(r'\{(arg\d+)[},]', region[key])), key)
