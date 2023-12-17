import 'package:flutter/material.dart';

import '../../rehmat.dart';

class UniversalSizeTranslator {

  final Project project;

  UniversalSizeTranslator({required this.project});

  Size getUniversalSize({
    CreatorWidget? widget,
    Size? size,
    Size? localContainerSize,
    Size? universalSize
  }) {
    assert(widget != null || size != null, 'Either widget or localSize must be provided');

    size ??= widget!.size;
    localContainerSize ??= project.contentSize;
    universalSize ??= project.size.size;

    double scale = universalSize.width / localContainerSize.width;

    return Size(
      size.width * scale,
      size.height * scale
    );
  }

  Size getLocalSize({
    CreatorWidget? widget,
    Size? size,
    Size? localContainerSize,
    Size? universalSize
  }) {
    assert(widget != null || size != null, 'Either widget or localSize must be provided');

    size ??= widget!.size;
    localContainerSize ??= project.contentSize;
    universalSize ??= project.size.size;

    double scale = localContainerSize.width / universalSize.width;

    return Size(
      size.width * scale,
      size.height * scale
    );
  }

  Offset getUniversalPosition({
    CreatorWidget? widget,
    Offset? position,
    Size? localContainerSize,
    Size? universalSize
  }) {
    assert(widget != null || position != null, 'Either widget or localSize must be provided');

    position ??= widget!.position;

    localContainerSize ??= project.contentSize;
    universalSize ??= project.size.size;

    double scale = universalSize.width / localContainerSize.width;

    return Offset(
      position.dx * scale,
      position.dy * scale
    );
  }

  Offset getLocalPosition({
    CreatorWidget? widget,
    Offset? position,
    Size? localContainerSize,
    Size? universalSize
  }) {
    assert(widget != null || position != null, 'Either widget or localSize must be provided');

    position ??= widget!.position;

    localContainerSize ??= project.contentSize;
    universalSize ??= project.size.size;

    double scale = localContainerSize.width / universalSize.width;

    return Offset(
      position.dx * scale,
      position.dy * scale
    );
  }

  double getUniversalValue({
    required double value,
    Size? localContainerSize,
    Size? universalSize
  }) {
    localContainerSize ??= project.contentSize;
    universalSize ??= project.size.size;

    double scale = universalSize.width / localContainerSize.width;

    return value * scale;
  }

  double getLocalValue({
    required double value,
    Size? localContainerSize,
    Size? universalSize
  }) {
    localContainerSize ??= project.contentSize;
    universalSize ??= project.size.size;

    double scale = localContainerSize.width / universalSize.width;

    return value * scale;
  }

  EdgeInsets getUniversalPadding({
    required EdgeInsets padding,
    Size? localContainerSize,
    Size? universalSize
  }) {
    localContainerSize ??= project.contentSize;
    universalSize ??= project.size.size;

    double scale = universalSize.width / localContainerSize.width;

    return EdgeInsets.fromLTRB(
      padding.left * scale,
      padding.top * scale,
      padding.right * scale,
      padding.bottom * scale
    );
  }
  
  EdgeInsets getLocalPadding({
    required EdgeInsets padding,
    Size? localContainerSize,
    Size? universalSize
  }) {
    localContainerSize ??= project.contentSize;
    universalSize ??= project.size.size;

    double scale = localContainerSize.width / universalSize.width;

    return EdgeInsets.fromLTRB(
      padding.left * scale,
      padding.top * scale,
      padding.right * scale,
      padding.bottom * scale
    );
  }

}