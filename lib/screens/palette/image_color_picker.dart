import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_pixels/image_pixels.dart';
import 'package:octo_image/octo_image.dart';
import 'package:universal_io/io.dart';

import '../../rehmat.dart';

class ImageColorPicker extends StatefulWidget {

  ImageColorPicker({
    Key? key,
    required this.image,
  }) : super(key: key);

  final File image;

  @override
  State<ImageColorPicker> createState() => _ImageColorPickerState();
}

class _ImageColorPickerState extends State<ImageColorPicker> {

  late File image;
  late ImageProvider provider;

  Color? color;

  Offset localPosition = Offset.zero;

  @override
  void initState() {
    image = widget.image;
    provider = FileImage(image);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: NewBackButton(),
        title: Text('Color Picker'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Spacer(),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
                maxWidth: MediaQuery.of(context).size.width * 0.95,
              ),
              child: Listener(
                onPointerMove: (PointerMoveEvent details) {
                  setState(() {
                    localPosition = details.localPosition;
                  });
                },
                onPointerDown: (PointerDownEvent details) {
                  setState(() {
                    localPosition = details.localPosition;
                  });
                },
                child: ImagePixels(
                  imageProvider: provider,
                  builder: (context, img) {
                    color = img.pixelColorAt!(
                      localPosition.dx.toInt(),
                      localPosition.dy.toInt(),
                    );
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: OctoImage(
                            image: provider,
                            fit: BoxFit.contain,
                          ),
                        ),
                        if (localPosition.dy < img.height!/2) Positioned(
                          left: localPosition.dx - 25,
                          top: localPosition.dy - 25,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 10,
                                sigmaY: 10,
                              ),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Palette.blurBackground(context)
                                ),
                                child: Center(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

}