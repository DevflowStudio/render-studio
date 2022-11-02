import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';

class PostSize {

  PostSize(this.size, this.title, this.icon);

  final Size size;
  final String title;
  final IconData icon;

  CropAspectRatio get cropRatio {
    return CropAspectRatio(ratioY: 1 / size.width, ratioX: 1 / size.height);
  }

  static PostSize custom({
    required double width,
    required double height,
  }) {
    return PostSize(Size(width, height), 'Custom', FontAwesomeIcons.square);
  }

}

enum PostSizePresets {
  square,
  landscape,
  instagram,
  instagramStory,
  instagramPortrait,
  instagramLandscape,
  facebook,
  pinterest,
  youtubeThumbnail,
  linkedInPost,
  linkedInPostMobile,
  snapchatStory,
}

extension PostSizePresetsExtension on PostSizePresets {

  Size get size {
    switch (this) {
      case PostSizePresets.square:
        return const Size(1080, 1080);
      case PostSizePresets.landscape:
        return const Size(1080, 566);
      case PostSizePresets.instagram:
        return const Size(1080, 1080);
      case PostSizePresets.instagramStory:
        return const Size(1080, 1920);
      case PostSizePresets.instagramPortrait:
        return const Size(1080, 1350);
      case PostSizePresets.instagramLandscape:
        return const Size(1350, 1080);
      case PostSizePresets.facebook:
        return const Size(1200, 628);
      case PostSizePresets.pinterest:
        return const Size(1000, 1500);
      case PostSizePresets.youtubeThumbnail:
        return const Size(1280, 720);
      case PostSizePresets.linkedInPost:
        return const Size(1200, 1200);
      case PostSizePresets.linkedInPostMobile:
        return const Size(1200, 628);
      case PostSizePresets.snapchatStory:
        return const Size(1080, 1920);
      default:
        return const Size(1920, 1080);
    }
  }

  String get title {
    switch (this) {
      case PostSizePresets.square:
        return 'Square';
      case PostSizePresets.landscape:
        return 'Landscape';
      case PostSizePresets.instagram:
        return 'Instagram';
      case PostSizePresets.instagramStory:
        return 'Instagram Story';
      case PostSizePresets.instagramPortrait:
        return 'Instagram Portrait';
      case PostSizePresets.instagramLandscape:
        return 'Instagram Landscape';
      case PostSizePresets.facebook:
        return 'Facebook';
      case PostSizePresets.pinterest:
        return 'Pinterest';
      case PostSizePresets.youtubeThumbnail:
        return 'YouTube Thumbnail';
      case PostSizePresets.linkedInPost:
        return 'LinkedIn Project';
      case PostSizePresets.linkedInPostMobile:
        return 'LinkedIn Mobile Project';
      case PostSizePresets.snapchatStory:
        return 'Snapchat Story';
      default:
        return 'Rectangle';
    }
  }

  IconData get icon {
    switch (this) {
      case PostSizePresets.square:
        return FontAwesomeIcons.square;
      case PostSizePresets.landscape:
        return Icons.crop_16_9;
      case PostSizePresets.instagram:
        return FontAwesomeIcons.instagram;
      case PostSizePresets.instagramStory:
        return Icons.crop_portrait;
      case PostSizePresets.instagramPortrait:
        return Icons.crop_portrait_outlined;
      case PostSizePresets.instagramLandscape:
        return Icons.crop_16_9;
      case PostSizePresets.facebook:
        return FontAwesomeIcons.facebook;
      case PostSizePresets.pinterest:
        return FontAwesomeIcons.pinterest;
      case PostSizePresets.youtubeThumbnail:
        return FontAwesomeIcons.youtube;
      case PostSizePresets.linkedInPost:
        return FontAwesomeIcons.linkedin;
      case PostSizePresets.linkedInPostMobile:
        return FontAwesomeIcons.linkedinIn;
      case PostSizePresets.snapchatStory:
        return FontAwesomeIcons.snapchat;
      default:
        return Icons.error;
    }
  }

  PostSize toSize() {
    return PostSize(size, title, icon);
  }

}