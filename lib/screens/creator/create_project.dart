import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import '../../rehmat.dart';

class CreateProject extends StatefulWidget {
  const CreateProject({super.key});

  @override
  State<CreateProject> createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> {

  TextEditingController titleCtrl = TextEditingController();
  TextEditingController descriptionCtrl = TextEditingController();

  final BlurredEdgesController blurredEdgesCtrl = BlurredEdgesController();

  bool titleError = false;
  bool hasTitleChanged = false;

  bool isTemplate = false;

  int page = 0;

  PostSizePresets sizePreset = PostSizePresets.square;

  @override
  void initState() {
    setTitle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          RenderAppBar(
            title: Text(
              'New Project'
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(pageContents)
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            fillOverscroll: false,
            child: Column(
              children: [
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 12,
                    bottom: Constants.of(context).bottomPadding
                  ),
                  child: PrimaryButton(
                    child: Text('Next')
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void setTitle() {
    if (hasTitleChanged) return;
    if (manager.projects.isEmpty) {
      if (isTemplate) {
        titleCtrl.text = 'My First Template';
      } else {
        titleCtrl.text = 'My First Project';
      }
    }
    else {
      String prefix = isTemplate ? 'Template' : 'Project';
      int n = manager.projects.length + 1;
      titleCtrl.text = '$prefix ($n)';
      while (manager.projects.where((glance) => glance.title == titleCtrl.text).isNotEmpty) {
        n++;
        titleCtrl.text = '$prefix ($n)';
      }
    }
  }

  List<Widget> get pageContents {
    print(sizePreset.size);
    Size deviceSize = MediaQuery.of(context).size;
    Size contentSize = Size.zero;
    double ratio = sizePreset.size.width / sizePreset.size.height;
    double maxHeight = deviceSize.height * 0.4;
    double maxWidth = deviceSize.width;
    if (sizePreset.size.height > maxHeight) {
      contentSize = Size(maxHeight * ratio, maxHeight);
    } else if (sizePreset.size.width > maxWidth) {
      contentSize = Size(maxWidth, maxWidth / ratio);
    } else {
      contentSize = sizePreset.size;
    }
    switch (page) {
      case 0:
        return [
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 12,
            ),
            child: Label(
              label: 'Choose Project Size'
            ),
          ),
          Center(
            child: SizedBox.fromSize(
              size: contentSize,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      sizePreset.icon,
                      size: 40,
                      color: Colors.black,
                    ),
                    SizedBox(height: 3),
                    Text(
                      sizePreset.title.toTitleCase(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      "${sizePreset.size.width.toInt()} x ${sizePreset.size.height.toInt()}",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 94,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12
              ),
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 70,
                  width: 70,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Palette.of(context).surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        PostSizePresets.values[index].icon,
                        size: 30,
                        color: Palette.of(context).onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => SizedBox(width: 6),
              itemCount: PostSizePresets.values.length,
            ),
          )
        ];
      case 1:
        return [
          TextFormField(
            controller: titleCtrl,
            decoration: InputDecoration(
              labelText: 'Title',
              errorText: titleError ? 'Please add a title' : null
            ),
            maxLength: 80,
            onChanged: (value) {
              hasTitleChanged = true;
            },
          ),
          TextFormField(
            controller: descriptionCtrl,
            decoration: const InputDecoration(
              labelText: 'Description',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              helperText: '(optional)'
            ),
            maxLines: 7,
            minLines: 4,
            maxLength: 2000,
          ),
          // ListView.separated(
          //   controller: blurredEdgesCtrl.scrollCtrl,
          //   scrollDirection: Axis.horizontal,
          //   separatorBuilder: (context, index) => SizedBox(width: 6),
          //   padding: EdgeInsets.symmetric(
          //     horizontal: 12,
          //     vertical: 12
          //   ),
          //   itemBuilder: (context, index) {
          //     return _CreateButton(
          //       onTap: () {
          //         TapFeedback.light();
          //       },
          //       icon: PostSizePresets.values[index].icon,
          //       title: PostSizePresets.values[index].title.toTitleCase(),
          //     );
          //   },
          //   itemCount: PostSizePresets.values.length,
          // ),
        ];
      default:
        return [];
    }
  }

}

class _CreateButton extends StatelessWidget {

  const _CreateButton({
    this.onTap,
    required this.icon,
    required this.title,
  });

  final void Function()? onTap;
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.of(context).surfaceVariant,
        borderRadius: SmoothBorderRadius(
          cornerRadius: kBorderRadius - 8,
          cornerSmoothing: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, 1),
            blurRadius: 2
          )
        ]
      ),
      child: Column(
        children: [
          Spacer(),
          Material(
            color: Colors.transparent,
            child: Ink(
              child: InkWell(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: kBorderRadius - 8,
                  cornerSmoothing: 0.5,
                ),
                onTap: onTap,
                child: Center(child: Icon(icon)),
              ),
            ),
          ),
          Spacer(),
          Flexible(
            child: Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                height: 1.2,
                color: Palette.of(context).onSurfaceVariant,
              ),
            ),
          )
        ],
      ),
    );
  }
}