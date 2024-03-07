import 'package:device_corner_radius/device_corner_radius.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

late DeviceInfo device;

class DeviceInfo {

  static Future<DeviceInfo> get instance async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    BorderRadius cornerRadius = await DeviceCornerRadius.getCornerRadius();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return DeviceInfo(
        brand: androidInfo.brand,
        model: androidInfo.model,
        version: androidInfo.version.release,
        device: androidInfo.device,
        isEmulator: !androidInfo.isPhysicalDevice,
        os: 'android',
        cornerRadius: cornerRadius
      );
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return DeviceInfo(
        model: iosInfo.model,
        isEmulator: !iosInfo.isPhysicalDevice,
        brand: 'Apple',
        device: iosInfo.name,
        version: iosInfo.systemVersion,
        os: 'ios',
        cornerRadius: cornerRadius
      );
    } else if (Platform.isMacOS) {
      return DeviceInfo(
        model: 'Mac',
        isEmulator: false,
        brand: 'Apple',
        device: 'Mac',
        version: 'Unknown macOS Version',
        os: 'macos',
        cornerRadius: cornerRadius
      );
    }
    throw Exception('You are using an unsupported platform to run this app');
  }

  final String model;
  final bool isEmulator;
  final String brand;
  final String device;
  final String version;
  final String os;
  final BorderRadius cornerRadius;

  const DeviceInfo({
    required this.model,
    required this.isEmulator,
    required this.brand,
    required this.device,
    required this.version,
    required this.os,
    required this.cornerRadius
  });

  Future<Map> get info async {
    DeviceInfo deviceInfo = await DeviceInfo.instance;
    return {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'brand': deviceInfo.brand,
      'model': deviceInfo.model,
      'version': deviceInfo.version,
      'device': deviceInfo.device,
      'emulator': deviceInfo.isEmulator,
      'os': deviceInfo.os,
    };
  }

}