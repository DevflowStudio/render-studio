import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';

import '../rehmat.dart';

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
        return FontAwesomeIcons.snapchatGhost;
      default:
        return Icons.error;
    }
  }

  PostSize toSize() {
    return PostSize(size, title, icon);
  }

}



class SelectSize extends StatefulWidget {

  const SelectSize({Key? key, required this.project}) : super(key: key);

  final Project project;

  @override
  _SelectSizeState createState() => _SelectSizeState();
}

class _SelectSizeState extends State<SelectSize> {

  late Project project;

  @override
  void initState() {
    project = widget.project;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            centerTitle: false,
            expandedHeight: Constants.appBarExpandedHeight,
            titleTextStyle: const TextStyle(
              fontSize: 14
            ),
            flexibleSpace: RenderFlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              centerTitle: false,
              title: Text(
                'Size',
                style: AppTheme.flexibleSpaceBarStyle
              ),
              titlePaddingTween: EdgeInsetsTween(
                begin: const EdgeInsets.only(
                  left: 16.0,
                  bottom: 16
                ),
                end: const EdgeInsets.symmetric(
                  horizontal: 55,
                  vertical: 15
                )
              ),
              stretchModes: const [
                StretchMode.fadeTitle,
              ],
            ),
            actions: [
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    child: Text('Custom Size'),
                    value: 'custom-size',
                  )
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'custom-size':
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Palette.of(context).surface,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Constants.borderRadius.bottomLeft)
                        ),
                        builder: (context) {
                          TextEditingController widthCtrl = TextEditingController(text: '1080');
                          TextEditingController heightCtrl = TextEditingController(text: '1080');
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Label(
                                  label: 'Custom Size'
                                ),
                                Container(height: 10,),
                                Row(
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: TextFormField(
                                        controller: widthCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'Width'
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    Container(width: 10,),
                                    Flexible(
                                      flex: 1,
                                      child: TextFormField(
                                        controller: heightCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'Height'
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(height: 10,),
                                Padding(
                                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                  child: SizedBox(
                                    width: double.maxFinite,
                                    child: Button(
                                      text: 'Select',
                                      background: App.getThemedObject(context, light: Colors.black, dark: Colors.grey[800]),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        project.size = PostSize.custom(width: double.tryParse(widthCtrl.text) ?? 1080, height: double.tryParse(heightCtrl.text) ?? 1080);
                                        AppRouter.replace(context, page: Create(project: project));
                                      },
                                    ),
                                  ),
                                )
                              ]
                            ),
                          );
                        },
                      );
                      break;
                    default:
                  }
                },
              )
            ]
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => SizedBox.fromSize(
                  size: Constants.of(context).gridSize,
                  child: InteractiveCard(
                    onTap: () {
                      project.size = PostSizePresets.values[index].toSize();
                      AppRouter.replace(context, page: Create(project: project));
                    },
                    child: Column(
                      children: [
                        const Spacer(),
                        Icon(PostSizePresets.values[index].icon),
                        const Spacer(),
                        Text(
                          PostSizePresets.values[index].title,
                          style: Theme.of(context).textTheme.caption,
                        ),
                        Container(height: 10,)
                      ],
                    ),
                  )
                ),
                childCount: PostSizePresets.values.length
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Constants.of(context).crossAxisCount,
              ),
            ),
          ),
        ],
      ),
    );
  }
}