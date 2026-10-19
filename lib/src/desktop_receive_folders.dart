import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Windows and Linux use filesystem paths; no mobile storage grants or Apple
/// security bookmarks are involved. Keep old roots for existing history only.
class DesktopReceiveFolders {
  final File file;
  final Directory defaultDirectory;
  DesktopReceiveFolders(Directory support, this.defaultDirectory)
    : file = File(p.join(support.path, 'receive-folders.json'));

  Future<Map<String, dynamic>> _read() async {
    try {
      if (await file.length() > 512 * 1024) {
        throw const FormatException('Receive folder settings too large');
      }
      final value = jsonDecode(await file.readAsString());
      if (value is Map<String, dynamic> &&
          (value['roots'] == null ||
              (value['roots'] is List &&
                  (value['roots'] as List).every(
                    (root) => root is String && p.isAbsolute(root),
                  ))) &&
          (value['path'] == null ||
              (value['path'] is String &&
                  p.isAbsolute(value['path'] as String)))) {
        return value;
      }
      throw const FormatException('Invalid receive folder');
    } on FileSystemException catch (error) {
      if (await file.exists()) rethrow;
      if (error.osError?.errorCode == 2 || error.osError?.errorCode == 3) {
        return {};
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> location() async {
    Map<String, dynamic> saved = {};
    try {
      saved = await _read();
      final custom = saved['path'] as String?;
      final directory = custom == null ? defaultDirectory : Directory(custom);
      if (custom == null) await directory.create(recursive: true);
      if (!await directory.exists()) {
        throw const FileSystemException('接收文件夹不可用，请重新选择');
      }
      return {
        'path': directory.path,
        'label': directory.path,
        'custom': custom != null,
        'kind': custom == null ? 'downloads' : 'folder',
        'available': true,
        'roots': {
          defaultDirectory.path,
          ..._roots(saved),
          directory.path,
        }.toList(),
      };
    } on Object {
      // A disconnected drive or damaged setting must never silently redirect a
      // file to a different folder. The user can choose again or reset explicitly.
      return {
        'path': saved['path'] ?? defaultDirectory.path,
        'label': '接收文件夹不可用',
        'roots': [
          defaultDirectory.path,
          ..._roots(saved),
          if (saved['path'] is String) saved['path'] as String,
        ],
        'available': false,
        'error': '接收文件夹不可用，请重新选择或恢复默认',
        'custom': true,
      };
    }
  }

  List<String> _roots(Map<String, dynamic> saved) =>
      (saved['roots'] as List? ?? [])
          .whereType<String>()
          .where(p.isAbsolute)
          .toList();

  Future<Map<String, dynamic>> choose(String path) async {
    if (!p.isAbsolute(path) || !await Directory(path).exists()) {
      throw const FileSystemException('请选择可用的文件夹');
    }
    await _save(path);
    return location();
  }

  Future<void> reset() async {
    await defaultDirectory.create(recursive: true);
    await _save(null);
  }

  Future<void> _save(String? path) async {
    Map<String, dynamic> old;
    try {
      old = await _read();
    } on Object {
      old = {};
    }
    final roots = <String>{
      ..._roots(old),
      if (old['path'] is String && p.isAbsolute(old['path'] as String))
        old['path'] as String,
      defaultDirectory.path,
    };
    if (path != null) {
      roots.remove(path);
      roots.add(path);
    }
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(
      jsonEncode({
        'version': 1,
        'path': path,
        'roots': roots.toList().reversed.take(100).toList().reversed.toList(),
      }),
      flush: true,
    );
    await temporary.rename(file.path);
  }
}
