import 'dart:io';

import 'package:dukto2/src/desktop_receive_folders.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  late Directory downloads;
  late Directory support;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('dukto2-desktop-folders-');
    downloads = Directory(p.join(root.path, '下载', 'Dukto2'));
    support = Directory(p.join(root.path, 'support'));
  });
  tearDown(() => root.delete(recursive: true));

  DesktopReceiveFolders folders() => DesktopReceiveFolders(support, downloads);

  test(
    'default uses downloads and chosen folder survives restart and reset',
    () async {
      final initial = await folders().location();
      expect(initial['path'], downloads.path);
      expect(initial['available'], true);
      final custom = await Directory(p.join(root.path, '自选 接收')).create();
      final original = File(p.join(custom.path, '已有文件.txt'));
      await original.writeAsString('preserve');
      expect((await folders().choose(custom.path))['custom'], true);
      expect((await folders().location())['path'], custom.path);
      await folders().reset();
      final restored = await folders().location();
      expect(restored['path'], downloads.path);
      expect(restored['custom'], false);
      expect(restored['roots'], contains(custom.path));
      expect(await original.readAsString(), 'preserve');
    },
  );

  test(
    'missing chosen drive never silently falls back or recreates it',
    () async {
      final external = await Directory(p.join(root.path, 'external')).create();
      await folders().choose(external.path);
      await external.delete();
      final location = await folders().location();
      expect(location['available'], false);
      expect(location['path'], external.path);
      expect(location['roots'], contains(external.path));
      expect(await external.exists(), false);
      await folders().reset();
      expect((await folders().location())['path'], downloads.path);
    },
  );

  test(
    'corrupt settings require explicit recovery and reject relative paths',
    () async {
      await support.create();
      final store = folders();
      for (final bad in [
        '{bad',
        '{"path":"../elsewhere"}',
        '{"roots":"bad"}',
      ]) {
        await store.file.writeAsString(bad);
        expect((await store.location())['available'], false);
        await store.reset();
        expect((await folders().location())['available'], true);
      }
      await expectLater(
        store.choose('relative'),
        throwsA(isA<FileSystemException>()),
      );
    },
  );
}
