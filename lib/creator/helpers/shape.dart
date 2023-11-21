import 'package:flutter/material.dart';
import 'dart:math';

class CreativeShape extends CustomPainter {

  final Color color;
  final ShapeShadow? shadow;
  final String name;

  CreativeShape({
    required this.name,
    required this.color,
    this.shadow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    RenderShapeAbstract shape = RenderShapeAbstract.fromName(
      name,
      size: size,
      canvas: canvas,
      paint: Paint() .. color = color,
      shadow: shadow,
    );

    shape.draw();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  factory CreativeShape.fromJSON(Map<String, dynamic> json) => CreativeShape(
    color: Color(json['color']),
    shadow: json['shadow'] != null ? ShapeShadow.fromJSON(json['shadow']) : null,
    name: json['shape'],
  );

}

class ShapeShadow {

  final Color color;
  final double elevation;

  ShapeShadow({
    required this.color,
    required this.elevation,
  });

  factory ShapeShadow.fromJSON(Map<String, dynamic> data) => ShapeShadow(
    color: Color(data['color']),
    elevation: data['elevation'],
  );

  Map<String, dynamic> toJSON() {
    return {
      'color': color.value,
      'elevation': elevation,
    };
  }
}

abstract class RenderShapeAbstract {

  final bool keepAspectRatio = false;
  final bool rotate = false;

  final Canvas canvas;
  final Size size;
  final ShapeShadow? shadow;
  final Paint paint;
  
  final String name = 'shape';

  double get radius {
    if (size.width > size.height) {
      return size.height / 2;
    }
    else return size.width / 2;
  }

  RenderShapeAbstract({
    required this.canvas,
    required this.size,
    this.shadow,
    required this.paint
  });

  Path get path {
    Path path = Path();
    return path;
  }

  void draw() {
    if (rotate) {
      canvas.save();
      canvas.translate(size.width/2, size.height/2);
      canvas.rotate(0);
    }
    drawShadow();
    canvas.drawPath(path, paint);
    if (rotate) {
      canvas.restore();
    }
  }

  void drawShadow() {
    if (shadow != null) canvas.drawShadow(path, shadow!.color, shadow!.elevation, false);
  }
  
  static List<String> get names => [
    'circle',
    'heart',
    'triangle',
    'trapezium',
    'parallelogram',
    'wave1',
    'wave2',
    'wave3',
    'wave4',
    'wave5',
    'wave6',
    'wave7',
    'star',
    'star2',
    'star3',
    'star4',
    'diamond',
    'pentagon',
    'hexagon',
    'octagon',
    'decagon',
    'dodecagon',
    'spiky-circle',
    'spiky-circle2',
    'spiky-circle3',
    'message-box',
    'headless-arrow',
    'tag',
    'anti-tag',
    'headtailless-arrow',
    'bookmark'
  ];

  static RenderShapeAbstract fromName(String name, {
    required Canvas canvas,
    required Size size,
    ShapeShadow? shadow,
    required Paint paint
  }) {
    switch (name) {
      case 'circle':
        return ShapeCircle(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'triangle':
        return ShapeTriangle(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'trapezium':
        return ShapeTrapezium(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'parallelogram':
        return ShapeParallelogram(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'wave1':
        return ShapeWave1(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'wave2':
        return ShapeWave2(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'wave3':
        return ShapeWave3(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'wave4':
        return ShapeWave4(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'wave5':
        return ShapeWave5(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'wave6':
        return ShapeWave6(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'wave7':
        return ShapeWave7(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'diamond':
        return ShapeDiamond(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'heart':
        return ShapeHeart(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'star':
        return ShapeStar(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'star2':
        return ShapeStar2(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'star3':
        return ShapeStar3(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'star4':
        return ShapeStar4(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'pentagon':
        return ShapePentagon(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'hexagon':
        return ShapeHexagon(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'octagon':
        return ShapeOctagon(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'decagon':
        return ShapeDecagon(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'dodecagon':
        return ShapeDodecagon(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'spiky-circle':
        return SpikyCircle(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'spiky-circle2':
        return SpikyCircle2(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'spiky-circle3':
        return SpikyCircle3(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'message-box':
        return ShapeMessageBox(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'headless-arrow':
        return HeadlessArrowShape(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'tag':
        return TagShape(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'anti-tag':
        return AntiTagShape(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'headtailless-arrow':
        return HeadtaillessArrowShape(canvas: canvas, size: size, shadow: shadow, paint: paint);
      case 'bookmark':
        return BookmarkShape(canvas: canvas, size: size, shadow: shadow, paint: paint);
      default:
        return ShapeCircle(canvas: canvas, size: size, shadow: shadow, paint: paint);
    }
  }

}

class ShapeWave1 extends RenderShapeAbstract {

  ShapeWave1({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'wave1';

  @override
  Path get path {
    Path path = Path();
    path.lineTo(0, size.height * 0.11);
    path.cubicTo(0, size.height * 0.11, size.width * 0.04, size.height * 0.09, size.width * 0.04, size.height * 0.09);
    path.cubicTo(size.width * 0.08, size.height * 0.07, size.width * 0.17, size.height * 0.04, size.width / 4, size.height * 0.09);
    path.cubicTo(size.width / 3, size.height * 0.14, size.width * 0.42, size.height * 0.28, size.width / 2, size.height * 0.41);
    path.cubicTo(size.width * 0.58, size.height * 0.53, size.width * 0.67, size.height * 0.64, size.width * 0.75, size.height * 0.62);
    path.cubicTo(size.width * 0.83, size.height * 0.6, size.width * 0.92, size.height * 0.46, size.width * 0.96, size.height * 0.39);
    path.cubicTo(size.width * 0.96, size.height * 0.39, size.width, size.height * 0.32, size.width, size.height * 0.32);
    path.cubicTo(size.width, size.height * 0.32, size.width, size.height * 1, size.width, size.height * 1);
    path.cubicTo(size.width, size.height * 1, size.width * 0.96, size.height * 1, size.width * 0.96, size.height * 1);
    path.cubicTo(size.width * 0.92, size.height * 1, size.width * 0.83, size.height * 1, size.width * 0.75, size.height * 1);
    path.cubicTo(size.width * 0.67, size.height * 1, size.width * 0.58, size.height * 1, size.width / 2, size.height * 1);
    path.cubicTo(size.width * 0.42, size.height * 1, size.width / 3, size.height * 1, size.width / 4, size.height * 1);
    path.cubicTo(size.width * 0.17, size.height * 1, size.width * 0.08, size.height * 1, size.width * 0.04, size.height * 1);
    path.cubicTo(size.width * 0.04, size.height * 1, 0, size.height * 1, 0, size.height * 1);
    path.cubicTo(0, size.height * 1, 0, size.height * 0.11, 0, size.height * 0.11);
    return path;
  }

}

class ShapeWave2 extends RenderShapeAbstract {

  ShapeWave2({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'wave2';

  @override
  Path get path {
    Path path = Path();
    path.lineTo(0, size.height * 0.61);
    path.cubicTo(0, size.height * 0.61, size.width * 0.04, size.height * 0.61, size.width * 0.04, size.height * 0.61);
    path.cubicTo(size.width * 0.08, size.height * 0.61, size.width * 0.17, size.height * 0.61, size.width / 4, size.height * 0.51);
    path.cubicTo(size.width / 3, size.height * 0.41, size.width * 0.42, size.height / 5, size.width / 2, size.height * 0.22);
    path.cubicTo(size.width * 0.58, size.height * 0.24, size.width * 0.67, size.height * 0.49, size.width * 0.75, size.height * 0.57);
    path.cubicTo(size.width * 0.83, size.height * 0.65, size.width * 0.92, size.height * 0.57, size.width * 0.96, size.height * 0.53);
    path.cubicTo(size.width * 0.96, size.height * 0.53, size.width, size.height * 0.49, size.width, size.height * 0.49);
    path.cubicTo(size.width, size.height * 0.49, size.width, size.height * 1, size.width, size.height * 1);
    path.cubicTo(size.width, size.height * 1, size.width * 0.96, size.height * 1, size.width * 0.96, size.height * 1);
    path.cubicTo(size.width * 0.92, size.height * 1, size.width * 0.83, size.height * 1, size.width * 0.75, size.height * 1);
    path.cubicTo(size.width * 0.67, size.height * 1, size.width * 0.58, size.height * 1, size.width / 2, size.height * 1);
    path.cubicTo(size.width * 0.42, size.height * 1, size.width / 3, size.height * 1, size.width / 4, size.height * 1);
    path.cubicTo(size.width * 0.17, size.height * 1, size.width * 0.08, size.height * 1, size.width * 0.04, size.height * 1);
    path.cubicTo(size.width * 0.04, size.height * 1, 0, size.height * 1, 0, size.height * 1);
    path.cubicTo(0, size.height * 1, 0, size.height * 0.61, 0, size.height * 0.61);
    return path;
  }

}

class ShapeWave3 extends RenderShapeAbstract {

  ShapeWave3({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'wave3';

  @override
  Path get path {
    Path path = Path();
    path.lineTo(0, size.height * 0.11);
    path.cubicTo(0, size.height * 0.11, size.width * 0.04, size.height * 0.24, size.width * 0.04, size.height * 0.24);
    path.cubicTo(size.width * 0.08, size.height * 0.37, size.width * 0.17, size.height * 0.63, size.width / 4, size.height * 0.78);
    path.cubicTo(size.width / 3, size.height * 0.93, size.width * 0.42, size.height * 0.96, size.width / 2, size.height * 0.91);
    path.cubicTo(size.width * 0.58, size.height * 0.85, size.width * 0.67, size.height * 0.7, size.width * 0.75, size.height * 0.61);
    path.cubicTo(size.width * 0.83, size.height * 0.52, size.width * 0.92, size.height * 0.48, size.width * 0.96, size.height * 0.46);
    path.cubicTo(size.width * 0.96, size.height * 0.46, size.width, size.height * 0.44, size.width, size.height * 0.44);
    path.cubicTo(size.width, size.height * 0.44, size.width, size.height * 1, size.width, size.height * 1);
    path.cubicTo(size.width, size.height * 1, size.width * 0.96, size.height * 1, size.width * 0.96, size.height * 1);
    path.cubicTo(size.width * 0.92, size.height * 1, size.width * 0.83, size.height * 1, size.width * 0.75, size.height * 1);
    path.cubicTo(size.width * 0.67, size.height * 1, size.width * 0.58, size.height * 1, size.width / 2, size.height * 1);
    path.cubicTo(size.width * 0.42, size.height * 1, size.width / 3, size.height * 1, size.width / 4, size.height * 1);
    path.cubicTo(size.width * 0.17, size.height * 1, size.width * 0.08, size.height * 1, size.width * 0.04, size.height * 1);
    path.cubicTo(size.width * 0.04, size.height * 1, 0, size.height * 1, 0, size.height * 1);
    path.cubicTo(0, size.height * 1, 0, size.height * 0.11, 0, size.height * 0.11);
    return path;
  }

}

class ShapeWave4 extends RenderShapeAbstract {

  ShapeWave4({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'wave4';

  @override
  Path get path {
    Path path = Path();
    path.moveTo(0,size.height*0.8000000);
    path.lineTo(size.width*0.04166667,size.height*0.7334375);
    path.cubicTo(size.width*0.08333333,size.height*0.6656250,size.width*0.1666667,size.height*0.5343750,size.width*0.2500000,size.height*0.5500000);
    path.cubicTo(size.width*0.3333333,size.height*0.5656250,size.width*0.4166667,size.height*0.7343750,size.width*0.5000000,size.height*0.7165625);
    path.cubicTo(size.width*0.5833333,size.height*0.7000000,size.width*0.6666667,size.height*0.5000000,size.width*0.7500000,size.height*0.4334375);
    path.cubicTo(size.width*0.8333333,size.height*0.3656250,size.width*0.9166667,size.height*0.4343750,size.width*0.9583333,size.height*0.4665625);
    path.lineTo(size.width,size.height*0.5000000);
    path.lineTo(size.width,size.height);
    path.lineTo(size.width*0.9583333,size.height);
    path.cubicTo(size.width*0.9166667,size.height,size.width*0.8333333,size.height,size.width*0.7500000,size.height);
    path.cubicTo(size.width*0.6666667,size.height,size.width*0.5833333,size.height,size.width*0.5000000,size.height);
    path.cubicTo(size.width*0.4166667,size.height,size.width*0.3333333,size.height,size.width*0.2500000,size.height);
    path.cubicTo(size.width*0.1666667,size.height,size.width*0.08333333,size.height,size.width*0.04166667,size.height);
    path.lineTo(0,size.height);
    path.close();
    return path;
  }

}

class ShapeWave5 extends RenderShapeAbstract {

  ShapeWave5({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'wave5';

  @override
  Path get path {
    Path path = Path();
    path.lineTo(0, size.height / 2);
    path.cubicTo(0, size.height / 2, size.width * 0.04, size.height * 0.42, size.width * 0.04, size.height * 0.42);
    path.cubicTo(size.width * 0.08, size.height / 3, size.width * 0.17, size.height * 0.17, size.width / 4, size.height * 0.29);
    path.cubicTo(size.width / 3, size.height * 0.42, size.width * 0.42, size.height * 0.83, size.width / 2, size.height * 0.9);
    path.cubicTo(size.width * 0.58, size.height * 1, size.width * 0.67, size.height * 0.9, size.width * 0.75, size.height * 0.79);
    path.cubicTo(size.width * 0.83, size.height * 0.67, size.width * 0.92, size.height * 0.58, size.width * 0.96, size.height * 0.54);
    path.cubicTo(size.width * 0.96, size.height * 0.54, size.width, size.height / 2, size.width, size.height / 2);
    path.cubicTo(size.width, size.height / 2, size.width, size.height * 1, size.width, size.height * 1);
    path.cubicTo(size.width, size.height * 1, size.width * 0.96, size.height * 1, size.width * 0.96, size.height * 1);
    path.cubicTo(size.width * 0.92, size.height * 1, size.width * 0.83, size.height * 1, size.width * 0.75, size.height * 1);
    path.cubicTo(size.width * 0.67, size.height * 1, size.width * 0.58, size.height * 1, size.width / 2, size.height * 1);
    path.cubicTo(size.width * 0.42, size.height * 1, size.width / 3, size.height * 1, size.width / 4, size.height * 1);
    path.cubicTo(size.width * 0.17, size.height * 1, size.width * 0.08, size.height * 1, size.width * 0.04, size.height * 1);
    path.cubicTo(size.width * 0.04, size.height * 1, 0, size.height * 1, 0, size.height * 1);
    path.cubicTo(0, size.height * 1, 0, size.height / 2, 0, size.height / 2);
    return path;
  }

}

class ShapeWave6 extends RenderShapeAbstract {

  ShapeWave6({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'wave6';

  @override
  Path get path {
    Path path = Path();
    path.lineTo(0, size.height * 0.75);
    path.cubicTo(0, size.height * 0.75, size.width * 0.04, size.height * 0.8, size.width * 0.04, size.height * 0.8);
    path.cubicTo(size.width * 0.08, size.height * 0.84, size.width * 0.17, size.height * 0.92, size.width / 4, size.height * 0.94);
    path.cubicTo(size.width / 3, size.height * 0.96, size.width * 0.42, size.height * 0.92, size.width / 2, size.height * 0.78);
    path.cubicTo(size.width * 0.58, size.height * 0.63, size.width * 0.67, size.height * 0.38, size.width * 0.75, size.height * 0.29);
    path.cubicTo(size.width * 0.83, size.height / 5, size.width * 0.92, size.height * 0.29, size.width * 0.96, size.height * 0.34);
    path.cubicTo(size.width * 0.96, size.height * 0.34, size.width, size.height * 0.38, size.width, size.height * 0.38);
    path.cubicTo(size.width, size.height * 0.38, size.width, size.height * 1, size.width, size.height * 1);
    path.cubicTo(size.width, size.height * 1, size.width * 0.96, size.height * 1, size.width * 0.96, size.height * 1);
    path.cubicTo(size.width * 0.92, size.height * 1, size.width * 0.83, size.height * 1, size.width * 0.75, size.height * 1);
    path.cubicTo(size.width * 0.67, size.height * 1, size.width * 0.58, size.height * 1, size.width / 2, size.height * 1);
    path.cubicTo(size.width * 0.42, size.height * 1, size.width / 3, size.height * 1, size.width / 4, size.height * 1);
    path.cubicTo(size.width * 0.17, size.height * 1, size.width * 0.08, size.height * 1, size.width * 0.04, size.height * 1);
    path.cubicTo(size.width * 0.04, size.height * 1, 0, size.height * 1, 0, size.height * 1);
    path.cubicTo(0, size.height * 1, 0, size.height * 0.75, 0, size.height * 0.75);
    return path;
  }

}

class ShapeWave7 extends RenderShapeAbstract {

  ShapeWave7({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'wave7';

  @override
  Path get path {
    Path path = Path();
    path.lineTo(0, size.height * 0.55);
    path.cubicTo(0, size.height * 0.55, size.width * 0.04, size.height * 0.64, size.width * 0.04, size.height * 0.64);
    path.cubicTo(size.width * 0.08, size.height * 0.73, size.width * 0.17, size.height * 0.92, size.width / 4, size.height * 0.85);
    path.cubicTo(size.width / 3, size.height * 0.78, size.width * 0.42, size.height * 0.46, size.width / 2, size.height * 0.39);
    path.cubicTo(size.width * 0.58, size.height * 0.32, size.width * 0.67, size.height / 2, size.width * 0.75, size.height * 0.66);
    path.cubicTo(size.width * 0.83, size.height * 0.83, size.width * 0.92, size.height * 0.96, size.width * 0.96, size.height * 1);
    path.cubicTo(size.width * 0.96, size.height * 1, size.width, size.height * 1, size.width, size.height * 1);
    path.cubicTo(size.width, size.height * 1, size.width, size.height * 1, size.width, size.height * 1);
    path.cubicTo(size.width, size.height * 1, size.width * 0.96, size.height * 1, size.width * 0.96, size.height * 1);
    path.cubicTo(size.width * 0.92, size.height * 1, size.width * 0.83, size.height * 1, size.width * 0.75, size.height * 1);
    path.cubicTo(size.width * 0.67, size.height * 1, size.width * 0.58, size.height * 1, size.width / 2, size.height * 1);
    path.cubicTo(size.width * 0.42, size.height * 1, size.width / 3, size.height * 1, size.width / 4, size.height * 1);
    path.cubicTo(size.width * 0.17, size.height * 1, size.width * 0.08, size.height * 1, size.width * 0.04, size.height * 1);
    path.cubicTo(size.width * 0.04, size.height * 1, 0, size.height * 1, 0, size.height * 1);
    path.cubicTo(0, size.height * 1, 0, size.height * 0.55, 0, size.height * 0.55);
    return path;
  }

}

class ShapeTrapezium extends RenderShapeAbstract {

  ShapeTrapezium({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'trapezium';

  @override
  Path get path {
    final path = Path();

    path.moveTo(size.width/6, 0);
    path.lineTo(size.width - size.width/6, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

}

class ShapeParallelogram extends RenderShapeAbstract {

  ShapeParallelogram({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'trapezium';

  @override
  Path get path {
    final path = Path();
    final width = size.width;
    final height = size.height;
    final topWidth = width * 1;
    final bottomWidth = width * 0.75;

    path.moveTo(width * 0.25, 0);
    path.lineTo(topWidth, 0);
    path.lineTo(bottomWidth, height);
    path.lineTo(0, height);
    path.close();
    return path;
  }

}

class ShapeStar extends RenderShapeAbstract {

  ShapeStar({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'star';

  final bool rotate = true;

  @override
  Path get path {
    return _starBuilder(num: 10, radius: radius, initialAngle: 18);
  }

}

class ShapeStar2 extends RenderShapeAbstract {

  ShapeStar2({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'star2';

  final bool rotate = true;

  @override
  Path get path {
    return _starBuilder(num: 12, radius: radius, initialAngle: 0);
  }

}

class ShapeStar3 extends RenderShapeAbstract {

  ShapeStar3({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'star3';

  final bool rotate = true;

  @override
  Path get path {
    return _starBuilder(num: 14, radius: radius, initialAngle: 0);
  }

}

class ShapeStar4 extends RenderShapeAbstract {

  ShapeStar4({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'star4';

  final bool rotate = true;

  @override
  Path get path {
    return _starBuilder(num: 16, radius: radius, initialAngle: 0);
  }

}

class ShapeTriangle extends RenderShapeAbstract {

  ShapeTriangle({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'triangle';

  final bool rotate = true;

  @override
  Path get path {
    Path path = Path();
    path.moveTo(-size.width/2, size.height/2);
    path.lineTo(0, -size.height/2);
    path.lineTo(size.width/2, size.height/2);
    path.close();

    return path;
  }

}

class ShapeDiamond extends RenderShapeAbstract {

  ShapeDiamond({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'diamond';

  final bool rotate = true;
  final bool lockAspectRatio = true;

  @override
  Path get path => _polygonBuilder(num: 4, radius: radius, initialAngle: 0);

}

class ShapePentagon extends RenderShapeAbstract {

  ShapePentagon({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'pentagon';

  final bool rotate = true;
  final bool lockAspectRatio = true;

  @override
  Path get path => _polygonBuilder(num: 5, radius: radius, initialAngle: -18);

}

class ShapeHexagon extends RenderShapeAbstract {

  ShapeHexagon({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'hexagon';

  final bool rotate = true;
  final bool lockAspectRatio = true;

  @override
  Path get path => _polygonBuilder(num: 6, radius: radius, initialAngle: 0);

}

class ShapeOctagon extends RenderShapeAbstract {

  ShapeOctagon({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'octagon';

  final bool rotate = true;
  final bool lockAspectRatio = true;

  @override
  Path get path => _polygonBuilder(num: 8, radius: radius, initialAngle: 0);

}

class ShapeDecagon extends RenderShapeAbstract {

  ShapeDecagon({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'decagon';

  final bool rotate = true;
  final bool lockAspectRatio = true;

  @override
  Path get path => _polygonBuilder(num: 10, radius: radius, initialAngle: 0);

}

class ShapeDodecagon extends RenderShapeAbstract {

  ShapeDodecagon({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'dodecagon';

  final bool rotate = true;
  final bool lockAspectRatio = true;

  @override
  Path get path => _polygonBuilder(num: 12, radius: radius, initialAngle: 0);

}

class ShapeHeart extends RenderShapeAbstract {

  ShapeHeart({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'heart';

  final bool rotate = true;
  final bool lockAspectRatio = true;

  @override
  Path get path {
    final Path path = Path();
    path.moveTo(0, radius);
    path.cubicTo(-radius * 2, -radius * 0.5, -radius * 0.5, -radius * 1.5, 0,-radius * 0.5);
    path.cubicTo(radius * 0.5, -radius * 1.5, radius * 2, -radius * 0.5, 0, radius);
    return path;
  }

}

class ShapeCircle extends RenderShapeAbstract {

  ShapeCircle({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'circle';

  final bool rotate = true;
  final bool lockAspectRatio = true;

  @override
  Path get path {
    canvas.drawCircle(Offset.zero, radius, paint);
    return Path();
  }

}

class SpikyCircle extends RenderShapeAbstract {

  SpikyCircle({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'spiky-circle';

  final bool rotate = true;

  @override
  Path get path {
    return _spikyCircle(num: 30, radius: radius, initialAngle: 18);
  }

}

class SpikyCircle2 extends RenderShapeAbstract {

  SpikyCircle2({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'spiky-circle2';

  final bool rotate = true;

  @override
  Path get path {
    return _spikyCircle(num: 40, radius: radius, initialAngle: 18);
  }

}

class SpikyCircle3 extends RenderShapeAbstract {

  SpikyCircle3({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'spiky-circle3';

  final bool rotate = true;

  @override
  Path get path {
    return _spikyCircle(num: 50, radius: radius, initialAngle: 18);
  }

}

class ShapeMessageBox extends RenderShapeAbstract {

  ShapeMessageBox({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'message-box';

  @override
  Path get path {
    Path path = Path();
    canvas.drawRRect(
      RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(size.width/5)),
      paint
    );
    // draw a path with a triangle at bottom left corner
    path.moveTo(size.width/4, size.height);
    path.lineTo(size.width/4, size.height + size.height/5);
    path.lineTo(size.width/4 + size.width/5, size.height);
    path.close();
    return path;
  }

}

class HeadlessArrowShape extends RenderShapeAbstract {

  HeadlessArrowShape({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'headless-arrow';

  @override
  Path get path {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width - size.width/6, 0);
    path.lineTo(size.width, size.height/2);
    path.lineTo(size.width - size.width/6, size.height);
    path.lineTo(0, size.height);
    path.lineTo(size.width/6, size.height/2);
    path.close();
    return path;
  }

}

class HeadtaillessArrowShape extends RenderShapeAbstract {

  HeadtaillessArrowShape({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'headtailless-arrow';

  @override
  Path get path {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width - size.width/6, 0);
    path.lineTo(size.width, size.height/2);
    path.lineTo(size.width - size.width/6, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

}

class TagShape extends RenderShapeAbstract {

  TagShape({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'tag';

  @override
  Path get path {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width - size.width/6, size.height/2);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(size.width/6, size.height/2);
    path.close();
    return path;
  }

}

class AntiTagShape extends RenderShapeAbstract {

  AntiTagShape({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'anti-tag';

  @override
  Path get path {
    Path path = Path();
    path.moveTo(size.width/6, 0);
    path.lineTo(size.width - size.width/6, 0);
    path.lineTo(size.width, size.height/2);
    path.lineTo(size.width - size.width/6, size.height);
    path.lineTo(size.width/6, size.height);
    path.lineTo(0, size.height/2);
    path.close();
    return path;
  }

}

class BookmarkShape extends RenderShapeAbstract {

  BookmarkShape({required super.canvas, required super.size, super.shadow, required super.paint});

  final String name = 'bookmark';

  @override
  Path get path {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width/2, size.height - size.height/6);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

}

Path _starBuilder({
  required int num,
  required double radius,
  required double initialAngle,
}) {
  final Path path = Path();
  for (int i = 0; i < num; i++) {
    final double radian = _radians(initialAngle + 360 / num * i.toDouble());
    final double x = radius * (i.isEven ? 0.5 : 1) * cos(radian);
    final double y = radius * (i.isEven ? 0.5 : 1) * sin(radian);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  path.close();
  return path;
}

Path _spikyCircle({
  required int num,
  required double radius,
  required double initialAngle,
}) {
  final Path path = Path();
  for (int i = 0; i < num; i++) {
    final double radian = _radians(initialAngle + 360 / num * i.toDouble());
    final double x = radius * (i.isEven ? 0.9 : 1) * cos(radian);
    final double y = radius * (i.isEven ? 0.9 : 1) * sin(radian);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  path.close();
  return path;
}

Path _polygonBuilder({
  required int num,
  required double radius,
  required double initialAngle,
}) {
  final Path path = Path();
  for (int i = 0; i < num; i++) {
    final double radian = _radians(initialAngle + 360 / num * i.toDouble());
    final double x = radius * cos(radian);
    final double y = radius * sin(radian);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  path.close();
  return path;
}

double _radians(double degree) {
  return degree * pi / 180;
}