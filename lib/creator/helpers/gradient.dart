import 'package:flutter/material.dart';

import '../../rehmat.dart';

class CreativeGradient {

  factory CreativeGradient.fromColors({
    required Color from,
    required Color to,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight
  }) {
    return CreativeGradient._(
      from: from,
      to: to,
      begin: begin,
      end: end
    );
  }

  factory CreativeGradient.fromPalette({
    required ColorPalette palette,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight
  }) {
    return CreativeGradient._(
      from: palette.primary,
      to: palette.secondary,
      begin: begin,
      end: end
    );
  }

  CreativeGradient._({required this.from, required this.to, required this.begin, required this.end});

  late Color from;
  late Color to;

  late Alignment begin;

  late Alignment end;

  Gradient get gradient => LinearGradient(
    colors: [
      from,
      to
    ],
    begin: begin,
    end: end,
  );

  EditorTab getEditor({
    required CreatorWidget widget,
    String name = 'Gradient',
    ColorPalette? palette,
    void Function(WidgetChange change)? onChange,
    bool allowOpacity = true,
  }) => EditorTab(
    name: name,
    type: EditorTabType.single,
    options: [
      Option.custom(
        widget: (context) => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  ColorSelector(
                    widget: widget,
                    size: Size.square(40),
                    onColorSelect: (color) {
                      from = color;
                      onChange?.call(WidgetChange.misc);
                    },
                    palette: palette,
                    color: from,
                    allowOpacity: allowOpacity,
                  ),
                  SizedBox(width: 6),
                  _getAlignmentEditorButton(
                    context,
                    current: begin,
                    toHide: end,
                    onSelected: (alignment) {
                      begin = alignment;
                      onChange?.call(WidgetChange.misc);
                    },
                  )
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  ColorSelector(
                    widget: widget,
                    size: Size.square(40),
                    onColorSelect: (color) {
                      to = color;
                      onChange?.call(WidgetChange.misc);
                    },
                    palette: palette,
                    color: to,
                    allowOpacity: allowOpacity,
                  ),
                  SizedBox(width: 6),
                  _getAlignmentEditorButton(
                    context,
                    current: end,
                    toHide: begin,
                    onSelected: (alignment) {
                      end = alignment;
                      onChange?.call(WidgetChange.misc);
                    },
                  )
                ],
              ),
            ],
          ),
        )
      )
    ]
  );

  Map<String, dynamic> toJSON() => {
    'colors': [
      from.toHex(),
      to.toHex(),
    ],
    'begin': _alignmentToString(begin),
    'end': _alignmentToString(end),
  };

  factory CreativeGradient.fromJSON(Map data) {
    List<Color> colors = [];
    for (String color in data['colors']) {
      colors.add(HexColor.fromHex(color));
    }
    return CreativeGradient._(
      from: colors[0],
      to: colors[1],
      begin: _stringToAlignment(data['begin']),
      end: _stringToAlignment(data['end']),
    );
  }

}

Widget _getAlignmentEditorButton(BuildContext context, {
  required Alignment current,
  required Alignment toHide,
  required void Function(Alignment alignment) onSelected,
}) {
  List<Alignment> alignments = [
    Alignment.topLeft,
    Alignment.topCenter,
    Alignment.topRight,
    Alignment.centerLeft,
    Alignment.center,
    Alignment.centerRight,
    Alignment.bottomLeft,
    Alignment.bottomCenter,
    Alignment.bottomRight,
  ];
  alignments.remove(toHide);
  return InkWellButton(
    onTap: () {
      Alerts.picker(
        context,
        initialIndex: alignments.indexOf(current),
        children: [
          for (Alignment alignment in alignments) Text(
            _alignmentToName(alignment),
          ),
        ],
        onSelectedItemChanged: (value) {
          onSelected(alignments[value]);
        },
      );
    },
    radius: BorderRadius.circular(6),
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 6
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _alignmentToName(current),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(width: 3),
          Icon(
            RenderIcons.arrow_down,
            size: Theme.of(context).textTheme.bodyMedium?.fontSize,
          )
        ],
      ),
    ),
  );
}

String _alignmentToString(Alignment alignment) {
  return '${alignment.x.toStringAsFixed(2)},${alignment.y.toStringAsFixed(2)}';
}

String _alignmentToName(Alignment alignment) {
  if (alignment == Alignment.topLeft) return 'Top Left';
  if (alignment == Alignment.topCenter) return 'Top Center';
  if (alignment == Alignment.topRight) return 'Top Right';
  if (alignment == Alignment.centerLeft) return 'Center Left';
  if (alignment == Alignment.center) return 'Center';
  if (alignment == Alignment.centerRight) return 'Center Right';
  if (alignment == Alignment.bottomLeft) return 'Bottom Left';
  if (alignment == Alignment.bottomCenter) return 'Bottom Center';
  if (alignment == Alignment.bottomRight) return 'Bottom Right';
  return 'Custom';
}

Alignment _stringToAlignment(String string) {
  List<String> parts = string.split(',');
  return Alignment(double.parse(parts[0]), double.parse(parts[1]));
}