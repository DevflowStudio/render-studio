import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../rehmat.dart';

class ColorTool extends StatefulWidget {

  ColorTool({
    Key? key,
    this.palette,
    this.selection,
    this.allowClear = false,
  }) : super(key: key);

  /// Provide a palette to allow few pre-defined colors to be selected.
  final ColorPalette? palette;
  /// If there is an already selected color, provide it here.
  final Color? selection;

  /// Set this to true to allow the user to remove selection.
  final bool allowClear;

  static Future<Color?> openTool(BuildContext context, {
    ColorPalette? palette,
    Color? selection
  }) => AppRouter.push(context, page: ColorTool(palette: palette, selection: selection,));

  @override
  State<ColorTool> createState() => _ColorToolState();
}

class _ColorToolState extends State<ColorTool> {

  late Color _color;

  TextEditingController textCtrl = TextEditingController();

  PaletteType paletteType = PaletteType.hueWheel;

  @override
  void initState() {
    super.initState();
    _color = Colors.white;
    if (widget.selection != null) {
      if (widget.selection!.computeLuminance() > 3) _color = widget.selection!;
    }
    textCtrl.text = _color.toHex().replaceFirst('#', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: NewBackButton(),
        title: Text('Color Tool'),
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: MediaQuery.of(context).platformBrightness
        ),
        actions: [
          PopupMenuButton<PaletteType>(
            // child: Text('Palette'),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Color Wheel'),
                value: PaletteType.hueWheel,
              ),
              PopupMenuItem(
                child: Text('HSL'),
                value: PaletteType.hsl,
              ),
              PopupMenuItem(
                child: Text('HSV'),
                value: PaletteType.hsv,
              ),
              PopupMenuItem(
                child: Text('HSV with Value'),
                value: PaletteType.hsvWithValue,
              ),
            ],
            onSelected: (value) => setState(() {
              paletteType = value;
            }),
          ),
          // IconButton(
          //   onPressed: () async {
          //     File? image = await FilePicker.pick(
          //       context: context,
          //       type: FileType.image,
          //       crop: false
          //     );
          //     print(image);
          //     if (image != null) AppRouter.replace(context, page: ImageColorPicker(image: image));
          //   },
          //   icon: Icon(RenderIcons.color_picker)
          // ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(_color),
            icon: Icon(RenderIcons.done)
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 12),
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: textCtrl,
                  decoration: InputDecoration(
                    prefixText: 'Hex #',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none
                    ),
                  ),
                  onChanged: (value) {
                    try {
                      changeColor(HexColor.fromHex(value), false);
                    } catch (e) { }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 60),
          wheel,
          slider,
          paletteColors,
        ],
      ),
    );
  }

  void changeColor(Color color, [bool updateText = true]) {
    if (updateText) textCtrl.text = color.toHex().replaceFirst('#', '');
    setState(() => _color = color);
  }

  Widget get wheel => Center(
    child: Container(
      // duration: Duration(milliseconds: 100),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: _color.withOpacity(Palette.isDark(context) ? 0.1 : 0.2),
            blurRadius: 200,
            spreadRadius: 150,
          ),
        ],
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 2/3)
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.width * 2/3,
        width: MediaQuery.of(context).size.width * 2/3,
        child: ColorPickerArea(
          HSVColor.fromColor(_color),
          (value) => changeColor(value.toColor()),
          paletteType
        ),
      ),
    ),
  );

  Widget get slider => SizedBox(
    height: 100,
    width: MediaQuery.of(context).size.width * 4/5,
    child: ColorPickerSlider(
      TrackType.lightness,
      HSVColor.fromColor(_color),
      (value) => changeColor(value.toColor()),
      displayThumbColor: true,
    ),
  );

  Widget get paletteColors => (widget.palette != null) ? Padding(
    padding: EdgeInsets.symmetric(vertical: 0),
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        ... List.generate(
          widget.palette!.colors.length,
          (index) => InkWell(
            onTap: () => changeColor(widget.palette!.colors[index]),
            borderRadius: BorderRadius.circular(50),
            child: AnimatedContainer(
              duration: Constants.animationDuration,
              height: 60,
              width: 60,
              padding: _color == widget.palette!.colors[index] ? EdgeInsets.all(2) : EdgeInsets.zero,
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.palette!.colors[index],
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: widget.palette!.colors[index].withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.palette!.colors[index],
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          )
        )
      ],
    ),
  ) : Container();

}

class ColorEditorTab extends StatefulWidget {

  ColorEditorTab({
    Key? key,
    this.color,
    required this.onChange,
    this.palette
  }) : super(key: key);

  final ColorPalette? palette;

  final void Function(Color color) onChange;

  final Color? color;

  @override
  State<ColorEditorTab> createState() => _ColorEditorTabState();
}

class _ColorEditorTabState extends State<ColorEditorTab> {

  ColorPalette? palette;

  late Color color;

  late List<Color> colors;

  @override
  void initState() {
    palette = widget.palette;
    color = widget.color ?? Colors.white;
    colors = [];
    if (palette != null) colors.addAll(palette!.colors);
    colors.addAll([
      Colors.black,
      Colors.white,
      Colors.grey.shade200,
      Colors.grey.shade300,
      Colors.grey.shade400,
      Colors.grey.shade600,
      Colors.grey.shade800,
      Colors.grey.shade900,
      Colors.brown,
      Colors.red,
      Colors.redAccent,
      Colors.blue,
      Colors.blueAccent,
      Colors.blueGrey,
      Colors.lightBlue,
      Colors.lightBlueAccent,
      Colors.green,
      Colors.greenAccent,
      Colors.lightGreen,
      Colors.lightGreenAccent,
      Colors.yellow,
      Colors.yellowAccent,
      Colors.orange,
      Colors.orangeAccent,
      Colors.pink,
      Colors.pinkAccent,
      Colors.purple,
      Colors.purpleAccent,
      Colors.indigo,
      Colors.indigoAccent,
      Colors.teal,
      Colors.tealAccent,
      Colors.cyan,
      Colors.cyanAccent,
      Colors.lime,
      Colors.limeAccent,
      Colors.amber,
      Colors.amberAccent,
      Colors.deepOrange,
      Colors.deepOrangeAccent,
      Colors.deepPurple,
      Colors.deepPurpleAccent,
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: 12,
            left: 12,
            right: 12,
            top: 12
          ),
          child: Center(
            child: SizedBox(
              height: 100,
              width: MediaQuery.of(context).size.width,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ColorPickerArea(
                  HSVColor.fromColor(color),
                  (value) => onChange(value.toColor()),
                  PaletteType.hsv
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            children: [
              SizedBox(width: 12,),
              SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: OutlinedIconButtons(
                    onPressed: () async {
                      Color? _color = await ColorTool.openTool(
                        context,
                        palette: palette,
                        selection: color
                      );
                      if (_color != null) onChange(_color);
                    },
                    icon: Icon(RenderIcons.add),
                    tooltip: 'Open Advanced Color Tool',
                  ),
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: colors.length,
                    separatorBuilder: (context, index) {
                      if (palette != null && index == palette!.colors.length - 1) return SizedBox(
                        height: 40,
                        child: VerticalDivider(
                          width: 24,
                          endIndent: 3,
                          indent: 3,
                        )
                      );
                      else return SizedBox(width: 6,);
                    },
                    itemBuilder: (context, index) => SizedBox(
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors[index],
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                            width: 0
                          )
                        ),
                        child: InkWell(
                          onTap: () {
                            onChange(colors[index]);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).padding.bottom,
        )
      ],
    );
  }

  void onChange(Color color) {
    widget.onChange(color);
    setState(() {
      this.color = color;
    });
  }

}