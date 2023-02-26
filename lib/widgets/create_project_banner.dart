import 'package:flutter/material.dart';

import '../rehmat.dart';

class CreateProjectBanner extends StatefulWidget {

  const CreateProjectBanner({super.key});

  @override
  State<CreateProjectBanner> createState() => CreateProjectBannerState();
}

class CreateProjectBannerState extends State<CreateProjectBanner> {

  final BlurredEdgesController blurredEdgesCtrl = BlurredEdgesController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: 9
          ),
          child: Text(
            app.remoteConfig.createProjectBannerTitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1,
              color: Palette.of(context).onSurfaceVariant
            )
          )
        ),
        Container(
          decoration: BoxDecoration(
            color: Palette.of(context).surfaceVariant,
            borderRadius: BorderRadius.circular(kBorderRadius)
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kBorderRadius),
            child: SizedBox(
              height: ((Theme.of(context).textTheme.labelMedium?.fontSize ?? 20) * 2 * 1.2) + 12 + 70 + 3 + 12,
              child: BlurredEdgesView(
                controller: blurredEdgesCtrl,
                child: ListView.separated(
                  controller: blurredEdgesCtrl.scrollCtrl,
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) => SizedBox(width: 3),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12
                  ),
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      TapFeedback.light();
                      Project.createNewProject(context, PostSizePresets.values[index].toSize());
                    },
                    child: SizedBox(
                      width: 70,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 70,
                            width: 70,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Palette.of(context).surface,
                                borderRadius: BorderRadius.circular(kBorderRadius - 8),
                                border: Border.all(
                                  color: Palette.of(context).outline,
                                  width: 1
                                )
                              ),
                              child: Center(child: Icon(PostSizePresets.values[index].icon)),
                            ),
                          ),
                          SizedBox(height: 3),
                          Flexible(
                            child: Text(
                              PostSizePresets.values[index].title.toTitleCase(),
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
                    ),
                  ),
                  itemCount: PostSizePresets.values.length,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

}