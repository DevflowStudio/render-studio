import 'package:universal_io/io.dart';

import 'package:path_provider/path_provider.dart';

late PathProvider pathProvider;

class PathProvider {

  final String rootPath;
  PathProvider._(this.rootPath);

  static Future<PathProvider> get instance async {
    final rootPath = await getApplicationDocumentsDirectory();
    return PathProvider._(rootPath.path);
  }

  String get path => rootPath;

  /// Create a new file in applications document directory + [path]
  /// 
  /// **Important: include a leading slash in [path]**
  Future<File> saveToDocumentsDirectory(String path, {
    List<int>? bytes,
    String? text
  }) async {
    assert(bytes != null || text != null);
    File file = await new File('$rootPath$path');
    bool exists = await file.exists();
    if (!exists) await file.create(recursive: true);
    // var raf = file.openSync(mode: FileMode.write);
    // raf.writeFromSync(bytes);
    // await raf.close();
    if (text != null) return await file.writeAsString(text);
    else return await file.writeAsBytes(bytes!);
  }

  String generateRelativePath(String path) {
    return '$rootPath$path';
  }

}