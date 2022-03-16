import 'dart:io' show Platform, Directory, File;
import 'package:path/path.dart' as path;

class _CacheDir {
  String name;
  _CacheDir(this.name);

  String get() {
    if (Platform.isWindows) {
      return path.join(
        Platform.environment['USERPROFILE']!,
        'AppData',
        'Roaming',
        name,
      );
    } else if (Platform.isMacOS || Platform.isLinux) {
      return path.join(Platform.environment['HOME']!, '.$name');
    } else {
      throw Exception('Not compatible with Flutter.');
    }
  }
}

class FileCache {
  Directory cacheDir;
  File cachePath;

  FileCache(String dirname, String filename)
      : cacheDir = Directory(_CacheDir(dirname).get()),
        cachePath = File(path.join(_CacheDir(dirname).get(), filename));

  Future<String?> get() async {
    if (await cacheDir.exists() && await cachePath.exists()) {
      return await cachePath.readAsString();
    } else {
      return null;
    }
  }

  Future<void> put(String data) async {
    if (!await cacheDir.exists()) {
      await cacheDir.create();
    }
    await cachePath.writeAsString(data);
  }

  Future<void> delete() async {
    if (await cachePath.exists()) {
      await cachePath.delete();
    }
  }
}
