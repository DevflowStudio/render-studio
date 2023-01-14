import 'package:universal_io/io.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../rehmat.dart';

class UnsplashAPI extends ChangeNotifier {

  static String get baseURL => 'https://api.unsplash.com';

  final PagingController<int, UnsplashPhoto> controller = PagingController(firstPageKey: 0);

  UnsplashAPI({
    String? query
  }) {
    this.searchTerm = query;
    controller.addPageRequestListener((pageKey) {
      get(pageKey);
    });
  }

  String? searchTerm;

  Future<void> get(int page) async {
    List<UnsplashPhoto>? photos = await query(page: page, searchTerm: searchTerm);
    if (photos == null) {
      controller.error = 'There seems to be an error.';
      return;
    }
    controller.error = null;
    if (photos.isEmpty || photos.length < 30) {
      controller.appendLastPage(photos);
    } else {
      controller.appendPage(photos, page + photos.length);
    }
  }

  static Future<List<UnsplashPhoto>?> query({String? searchTerm, int? page}) async {
    try {
      Response response = await Dio().get(
        searchTerm != null ? '$baseURL/search/photos' : '$baseURL/photos',
        options: Options(
          headers: {
            'Authorization': 'Client-ID ${environment.unsplashAccessKey}'
          }
        ),
        queryParameters: {
          'page': page != null ? ((page/30) + 1).toInt() : null,
          'query': searchTerm,
          'per_page': 30,
          'order_by': 'popular',
        }
      );
      if (response.statusCode != 200) {
        await analytics.logError('Status code ${response.statusCode} with message: ${response.statusMessage}', cause: 'Failed to fetch Unsplash photo');
      } else {
        try {
          List<UnsplashPhoto> _photos = [];
          for (Map photoData in (searchTerm != null ? response.data['results'] : response.data)) {
            UnsplashPhoto photo = UnsplashPhoto(photoData);
            _photos.add(photo);
          }
          return _photos;
        } catch (e, stacktrace) {
          analytics.logError(e, stacktrace: stacktrace, cause: 'Failed to parse Unsplash photos');
        }
      }
      return null;
    } catch (e, stacktrace) {
      await analytics.logError(e, stacktrace: stacktrace, cause: 'Failed to fetch Unsplash photos');
      return null;
    }
  }

  void search(String? searchTerm) {
    if (searchTerm != null && searchTerm.isNotEmpty) {
      analytics.logSearch(query: searchTerm, origin: 'unsplash_api');
      this.searchTerm = searchTerm;
    } else {
      this.searchTerm = null;
    }
    controller.refresh();
  }

}

class UnsplashPhoto extends ChangeNotifier {

  UnsplashPhoto(this.data);
  final Map data;

  String get id => data['id'];

  String get url => data['urls']['regular'];

  String get thumbnail => data['urls']['thumb'];

  UnsplashUser get user => UnsplashUser(data['user']);

  String get downloadURL => data['links']['download'];

  String get blurHash => data['blur_hash'];

  Color get color => HexColor.fromHex(data['color']);

  Size get size => Size(data['width'].toDouble(), data['height'].toDouble());

  double get ratio => size.width / size.height;

  bool isLoading = false;
  double? progress;

  void download(BuildContext context, {
    required Function(File? file) onDownloadComplete
  }) {
    isLoading = true;
    notifyListeners();
    Asset.downloadFile(
      context,
      url: data['urls']['full'],
      headers: {
        'Authorization': 'Client-ID ${environment.unsplashAccessKey}'
      },
      extension: 'jpg',
      onDownloadComplete: (asset) {
        isLoading = false;
        notifyListeners();
        onDownloadComplete(asset);
      }
    ).listen((event) {
      progress = event;
      notifyListeners();
    });
  }

  static Future<UnsplashPhoto?> get(String id) async {
    Response response = await Dio().get(
      '${UnsplashAPI.baseURL}/photos/$id',
      options: Options(
        headers: {
          'accept': 'application/json',
          'Authorization': 'Client-ID ${environment.unsplashAccessKey}'
        },
      ),
      queryParameters: {
        'client_id': environment.unsplashAccessKey
      }
    );
    if (response.statusCode != 200) {
      await analytics.logError('Status code ${response.statusCode} with message: ${response.statusMessage} when fetching Unsplash photo $id', cause: 'Failed to fetch Unsplash photo');
      return null;
    } else {
      return UnsplashPhoto(response.data);
    }
  }

}

class UnsplashUser {

  UnsplashUser(this.data);
  final Map data;

  String get id => data['id'];

  String get name => data['name'];

  String get username => data['username'];

  String get bio => data['bio'];

  String get profileImage => data['profile_image']['large'];

  String get portfolioURL => data['portfolio_url'];


}