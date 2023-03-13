import 'package:flutter/material.dart';

import '../../rehmat.dart';

class WidgetActionButton extends StatefulWidget {

  const WidgetActionButton({
    super.key,
    required this.widget,
    this.backgroundColor,
    this.iconColor,
  });

  final CreatorWidget widget;

  final Color? backgroundColor;
  final Color? iconColor;

  @override
  State<WidgetActionButton> createState() => _WidgetActionButtonState();
}

class _WidgetActionButtonState extends State<WidgetActionButton> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.widget.size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.widget.size.width < (35 * 3)) DragHandler(
            onPositionUpdate: (details) {
              widget.widget.updatePosition(details);
            },
            onPositionUpdateEnd: (details) => widget.widget.onDragFinish(context),
          )
          else Container(
            height: 35,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? Palette.of(context).background,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: (widget.iconColor ?? Palette.of(context).onBackground).withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 1,
                )
              ]
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildIconButton(
                  icon: widget.widget.isLocked ? RenderIcons.lock : RenderIcons.unlock,
                  onTap: () {
                    if (widget.widget.isLocked) widget.widget.unlock();
                    else widget.widget.lock();
                    setState(() { });
                  },
                  tooltip: widget.widget.isLocked ? 'Unlock' : 'Lock',
                ),
                if (widget.widget.allowClipboard) ... [
                  SizedBox(width: 12),
                  buildIconButton(
                    icon: RenderIcons.duplicate,
                    tooltip: 'Duplicate',
                    onTap: () {
                      Spinner.fullscreen(
                        context,
                        task: () async {
                          CreatorWidget? duplicate = await widget.widget.duplicate();
                          if (duplicate != null) widget.widget.page.widgets.add(duplicate);
                        },
                      );
                    },
                  ),
                ],
                if (!widget.widget.isLocked) ... [
                  SizedBox(width: 12),
                  buildIconButton(
                    icon: RenderIcons.delete,
                    tooltip: 'Delete',
                    onTap: () {
                      widget.widget.delete();
                    },
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIconButton({
    required IconData icon,
    required String tooltip,
    Function()? onTap,
  }) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: () {
        TapFeedback.light();
        onTap?.call();
      },
      child: Center(
        child: Icon(
          icon,
          color: widget.iconColor ?? Palette.of(context).onBackground,
          size: 20,
        ),
      ),
    ),
  );

}