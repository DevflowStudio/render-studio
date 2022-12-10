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
    required List<int> bytes
  }) async {
    File file = await new File('$rootPath$path').create(recursive: true);
    var raf = file.openSync(mode: FileMode.write);
    raf.writeFromSync(bytes);
    await raf.close();
    return await file.writeAsBytes(bytes);
  }

  String generateRelativePath(String path) {
    return '$rootPath$path';
  }

}