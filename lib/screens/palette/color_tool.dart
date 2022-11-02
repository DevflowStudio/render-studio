import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../rehmat.dart';

class ColorTool extends StatefulWidget {

  ColorTool({
    Key? key,
    this.palette,
    this.selection,
  }) : super(key: key);

  /// Provide a palette to allow few pre-defined colors to be selected.
  final ColorPalette? palette;
  /// If there is an already selected color, provide it here.
  final Color? selection;

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
    _color = widget.selection ?? Colors.blue;
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
          IconButton(
            onPressed: () => Navigator.of(context).pop(_color),
            icon: Icon(Icons.check_circle)
          )
        ],
      ),
      body: Column(
        children: [
          Spacer(),
          Center(
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
          ),
          SizedBox(
            height: 100,
            width: MediaQuery.of(context).size.width * 4/5,
            child: ColorPickerSlider(
              TrackType.lightness,
              HSVColor.fromColor(_color),
              (value) => changeColor(value.toColor()),
              displayThumbColor: true,
            ),
          ),
          if (widget.palette != null) Padding(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 4/5,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: textCtrl,
                      decoration: InputDecoration(
                        prefixText: 'Color Hex: #',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      onChanged: (value) {
                        try {
                          changeColor(HexColor.fromHex(value), false);
                        } catch (e) {
                          changeColor(Colors.white, false);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Spacer(),
          // Padding(
          //   padding: EdgeInsets.only(
          //     bottom: MediaQuery.of(context).padding.bottom,
          //     left: 12,
          //     right: 12,
          //   ),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         flex: 3,
          //         child: PrimaryButton(
          //           onPressed: () {},
          //           child: Text('Select'),
          //         ),
          //       ),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  void changeColor(Color color, [bool updateText = true]) {
    if (updateText) textCtrl.text = color.toHex().replaceFirst('#', '');
    setState(() => _color = color);
  }

}


