import 'package:render_studio/models/cloud.dart';
import 'package:universal_io/io.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../rehmat.dart';

class UnsplashSearchAPI extends ChangeNotifier {

  final PagingController<int, UnsplashPhoto> controller = PagingController(firstPageKey: 0);

  UnsplashSearchAPI({
    String? query,
    UnsplashTopic? topic
  }) {
    this.searchTerm = query;
    this.topic = topic;
    controller.addPageRequestListener((pageKey) {
      get(pageKey);
    });
  }

  String? searchTerm;

  UnsplashTopic? topic;

  Future<void> get(int page) async {
    List<UnsplashPhoto>? photos = await query(page: page, searchTerm: searchTerm, topic: topic);
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

  static Future<List<UnsplashPhoto>?> query({String? searchTerm, int? page, UnsplashTopic? topic}) async {
    assert(searchTerm != null || topic != null);
    String path;
    if (searchTerm != null) {
      path = 'photos/search';
    } else {
      path = 'photos/topics/${topic!.slug}/photos';
    }
    print(path);
    try {
      Response response = await Cloud.get(
        path,
        queryParameters: {
          'page': page != null ? ((page/30) + 1).toInt() : null,
          if (searchTerm != null) 'query': searchTerm,
          'per_page': 30,
          'order_by': searchTerm != null ? 'relevant' : 'latest',
        }
      );
      if (response.statusCode != 200) {
        await analytics.logError('Status code ${response.statusCode} with message: ${response.statusMessage}', cause: 'Failed to fetch Unsplash photo e1');
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
      await analytics.logError(e, stacktrace: stacktrace, cause: 'Failed to fetch Unsplash photos e2');
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

class UnsplashTopicAPI extends ChangeNotifier {

  final PagingController<int, UnsplashTopic> controller = PagingController(firstPageKey: 0);

  UnsplashTopicAPI() {
    get(0);
    controller.addPageRequestListener((pageKey) {
      get(pageKey);
    });
  }

  Future<void> get(int page) async {
    print('Fetching topics ... ');
    List<UnsplashTopic>? topics = await getTopics(page: page);
    if (topics == null) {
      controller.error = 'There seems to be an error.';
      return;
    }
    controller.error = null;
    if (topics.isEmpty || topics.length < 30) {
      controller.appendLastPage(topics);
    } else {
      controller.appendPage(topics, page + topics.length);
    }
  }

  static Future<List<UnsplashTopic>?> getTopics({int? page}) async {
    print('Fetching topics');
    try {
      Response response = await Cloud.get(
        'photos/topics',
        queryParameters: {
          'page': page != null ? ((page/30) + 1).toInt() : null,
          'per_page': 30,
        }
      );
      if (response.statusCode != 200) {
        await analytics.logError('Status code ${response.statusCode} with message: ${response.statusMessage}', cause: 'Failed to fetch Unsplash photo e1');
      } else {
        try {
          List<UnsplashTopic> _topics = [];
          for (Map topicData in response.data) {
            UnsplashTopic topic = UnsplashTopic(topicData);
            _topics.add(topic);
          }
          return _topics;
        } catch (e, stacktrace) {
          analytics.logError(e, stacktrace: stacktrace, cause: 'Failed to parse Unsplash photos');
        }
      }
      return null;
    } catch (e, stacktrace) {
      await analytics.logError(e, stacktrace: stacktrace, cause: 'Failed to fetch Unsplash photos e2');
      return null;
    }
  }

}

class UnsplashPhoto {

  UnsplashPhoto(this.data);
  final Map data;

  String get id => data['id'];

  String get url => data['urls']['regular'];

  String get thumbnail => data['urls']['thumb'];

  UnsplashUser get user => UnsplashUser(data['user']);

  String get downloadURL => data['links']['download'];

  String? get blurHash => data['blur_hash'];

  Color get color => HexColor.fromHex(data['color']);

  Size get size => Size(data['width'].toDouble(), data['height'].toDouble());

  double get ratio => size.width / size.height;

  double? progress;

  Future<File> download(BuildContext context) async {
    File file = await FilePicker.downloadFile(
      data['urls']['full'],
      precache: true,
      context: context,
      type: FileType.image
    );
    print('Downloaded file: ${file.path}');
    return file;
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

class UnsplashTopic {

  UnsplashTopic(this.data);
  final Map data;

  String get id => data['id'];

  String get slug => data['slug'];

  String get title => data['title'];

  String get description => data['description'];

  String get coverPhotoURL => data['cover_photo']['urls']['regular'];

  String? get blurHash => data['cover_photo']['blur_hash'];

  Size get size => Size(data['cover_photo']['width'].toDouble(), data['cover_photo']['height'].toDouble());

}