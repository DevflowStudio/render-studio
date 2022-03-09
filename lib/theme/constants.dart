import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Constants {

  Constants(this.context);
  final BuildContext context;

  static BorderRadius get borderRadius => BorderRadius.circular(20);

  Size get gridSize {
    Size size = Size(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.width / 2);
    if ((MediaQuery.of(context).size.width / 2) > 300) {
      size = const Size(305, 305);
    }
    return size;
  }

  int get crossAxisCount {
    if ((MediaQuery.of(context).size.width / 2) > 300) {
      return 5;
    }
    return 2;
  }

  static Constants of(BuildContext context) => Constants(context);

  static double get horizontalPadding => 15;

  static double get cardHorizontalPadding => 11;

  static Duration get animationDuration => const Duration(milliseconds: 200);

  static String generateUID(int length) {
    String uid = '';
    for (int i = 0; i < length; i++) {
      int random = Random().nextInt(_randomList.length - 1);
      uid += _randomList[random];
    }
    return uid;
  }

  static double get snapSenstivity => 0.8;

  static double get nudgeSenstivity => 2;

  static double get appBarExpandedHeight => 170;

  static String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  static String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');
    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

}

final List<String> _randomList = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z',
  '0',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
];