import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../rehmat.dart';

class UnsplashAPI extends ChangeNotifier {

  static String get baseURL => 'https://api.unsplash.com';

  final PagingController<int, UnsplashPhoto> controller = PagingController(firstPageKey: 0);

  UnsplashAPI() {
    controller.addPageRequestListener((pageKey) {
      get(pageKey);
    });
  }

  String? query;

  Future<void> get(int page) async {
    try {
      Response response = await Dio().get(
        query != null ? '$baseURL/search/photos' : '$baseURL/photos',
        options: Options(
          headers: {
            'Authorization': 'Client-ID ${environment.unsplashAccessKey}'
          }
        ),
        queryParameters: {
          'page': ((page/30) + 1).toInt(),
          'query': query,
          'per_page': 30,
          'order_by': 'popular',
        }
      );
      if (response.statusCode != 200) {
        await analytics.logError('Status code ${response.statusCode} with message: ${response.statusMessage}', cause: 'Failed to fetch Unsplash photo');
        controller.error = 'There seems to be an error.';
        return;
      } else {
        try {
          controller.error = null;
          List<UnsplashPhoto> _photos = [];
          for (Map photoData in (query != null ? response.data['results'] : response.data)) {
            UnsplashPhoto photo = UnsplashPhoto(photoData);
            _photos.add(photo);
          }
          if (_photos.isEmpty || _photos.length < 30) {
            controller.appendLastPage(_photos);
          } else {
            controller.appendPage(_photos, page + _photos.length);
          }
        } catch (e, stacktrace) {
          controller.error = 'There seems to be an error.';
          analytics.logError(e, stacktrace: stacktrace, cause: 'Failed to parse Unsplash photos');
        }
      }
    } catch (e, stacktrace) {
      await analytics.logError(e, stacktrace: stacktrace, cause: 'Failed to fetch Unsplash photos');
      controller.error = 'There seems to be an error.';
    }
  }

  void search(String? query) {
    if (query != null && query.isNotEmpty) {
      analytics.logSearch(query: query, origin: 'unsplash_api');
      this.query = query;
    } else {
      this.query = null;
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