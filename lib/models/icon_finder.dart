import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';
import '../rehmat.dart';

class IconFinder extends ChangeNotifier {

  IconFinder({
    String? query
  }) {
    search(query ?? [
      'Tech',
      'Social',
      'Weather',
      'Food',
      'Travel',
      'Art',
    ].getRandom());
    notifyListeners();
  }

  bool isLoading = true;

  String? error;

  List<IconFinderIcon> icons = [];

  Future<void> search(String searchTerm) async {
    isLoading = true;
    notifyListeners();
    analytics.logSearch(query: searchTerm, origin: 'icon_finder_api');
    List<IconFinderIcon>? _icons = await query(searchTerm);
    if (_icons == null) {
      error = 'There seems to be an error.';
    } else {
      icons = _icons;
    }
    isLoading = false;
    notifyListeners();
  }

  static Future<List<IconFinderIcon>?> query(String query, {
    int limit = 150
  }) async {
    analytics.logSearch(query: query, origin: 'icon_finder_api');
    Response response = await Dio().get(
      'https://api.iconfinder.com/v4/icons/search',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer ${environment.iconFinderToken}'
        }
      ),
      queryParameters: {
        'query': query,
        'count': limit,
        'premium': false,
        'vector': true
      }
    );
    if (response.statusCode != 200) return null;
    List<IconFinderIcon> icons = [];
    for (var icon in response.data['icons']) {
      IconFinderIcon iconFinderIcon = IconFinderIcon(Map.from(icon));
      icons.add(iconFinderIcon);
    }
    return icons;
  }

}

class IconFinderIcon extends ChangeNotifier {

  final Map data;

  IconFinderIcon(this.data);

  int get id => data['icon_id'];

  List<String> get previewURLs {
    List rasterSizes = data['raster_sizes'];
    List<String> result = [];
    for (var map in rasterSizes) {
      result.add(map['formats'].last['preview_url']);
    }
    return result;
  }

  String get downloadURL => data['vector_sizes'][0]['formats'][0]['download_url'];

  String? get category {
    try {
      return data['categories'][0]['name'];
    } catch (e) {
      return null;
    }
  }

  List<String> get tags {
    List<String> result = [];
    for (var tag in data['tags']) {
      result.add(tag);
    }
    return result;
  }

  bool isLoading = false;

  void toFile(BuildContext context, {
    required Function(File? file) onDownloadComplete
  }) {
    isLoading = true;
    notifyListeners();
    Asset.downloadFile(
      context,
      url: downloadURL,
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer ${environment.iconFinderToken}'
      },
      extension: 'svg',
      onDownloadComplete: (file) {
        isLoading = false;
        notifyListeners();
        onDownloadComplete(file);
      }
    ).listen((event) {
      progress = event;
      notifyListeners();
    });
  }

  double? progress;

}