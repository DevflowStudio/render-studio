import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:universal_io/io.dart';
import '../../../rehmat.dart';

class TemplateGlance extends StatelessWidget {

  const TemplateGlance({
    Key? key,
    this.glance,
    this.onTap,
    this.isSelected = false
  }) : super(key: key);

  final ProjectGlance? glance;
  final void Function()? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.width / 3;
    double width = height * (glance?.size.size.aspectRatio ?? 1);
    return SizedBox(
      height: height,
      width: width,
      child: InkWell(
        onTap: () async {
          TapFeedback.light();
          if (onTap != null) onTap!();
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: kAnimationDuration,
          decoration: BoxDecoration(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 20
            ),
            border: Border.all(
              color: Palette.of(context).onBackground.withOpacity(isSelected ? 1 : 0),
              width: 2
            )
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: SmoothClipRRect(
              smoothness: 0.6,
              borderRadius: BorderRadius.circular(15),
              child: glance != null ? OctoImage(
                image: FileImage(File(glance!.thumbnail ?? '')),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Material(
                  color: Palette.of(context).surfaceVariant,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20
                    ),
                    child: Center(
                      child: const Icon(RenderIcons.warning),
                    ),
                  ),
                ),
                placeholderBuilder: (context) => LayoutBuilder(
                  builder: (context, constraints) {
                    Size parentSize = constraints.biggest;
                    return SizedBox(
                      width: parentSize.width,
                      height: parentSize.width / glance!.size.size.aspectRatio,
                      child: Center(
                      ),
                    );
                  }
                )
              ) : Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(
                        RenderIcons.add,
                        color: Palette.of(context).onSurfaceVariant,
                        size: Theme.of(context).textTheme.titleMedium?.fontSize,
                      )
                    ),
                    Text(
                      'Blank',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Palette.of(context).onBackground
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyTemplateGlance extends StatelessWidget {

  const EmptyTemplateGlance({
    Key? key,
    this.onTap,
    this.isSelected = false
  }) : super(key: key);

  final void Function()? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.width / 3,
      width: MediaQuery.of(context).size.width / 3,
      child: InkWell(
        onTap: () async {
          TapFeedback.light();
          if (onTap != null) onTap!();
        },
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                Size parentSize = constraints.biggest;
                return SmoothContainer(
                  color: Palette.of(context).surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    width: parentSize.width,
                    height: parentSize.width,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Icon(
                              RenderIcons.add,
                              color: Palette.of(context).onSurfaceVariant,
                              size: Theme.of(context).textTheme.titleMedium?.fontSize,
                            )
                          ),
                          Text(
                            'Blank',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Palette.of(context).onBackground
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }
            ),
            Positioned(
              right: 5,
              top: 5,
              child: Visibility(
                visible: isSelected,
                child: Container(
                  decoration: BoxDecoration(
                    color: Palette.of(context).onSurfaceVariant,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  padding: EdgeInsets.all(5),
                  child: Icon(
                    RenderIcons.done,
                    color: Palette.of(context).surfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}