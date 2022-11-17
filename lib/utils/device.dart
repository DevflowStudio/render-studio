import 'package:device_info_plus/device_info_plus.dart';
import 'package:universal_io/io.dart';

late DeviceInfo device;

class DeviceInfo {

  static Future<DeviceInfo> get instance async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return DeviceInfo(
        brand: androidInfo.brand,
        model: androidInfo.model,
        version: androidInfo.version.release,
        device: androidInfo.device,
        isEmulator: !androidInfo.isPhysicalDevice,
        os: 'android'
      );
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return DeviceInfo(
        model: iosInfo.model ?? iosInfo.localizedModel ?? 'Unknown iPhone',
        isEmulator: !iosInfo.isPhysicalDevice,
        brand: 'Apple',
        device: iosInfo.name ?? 'Unknown iPhone',
        version: iosInfo.systemVersion ?? 'Unknown iOS Version',
        os: 'ios'
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

  const DeviceInfo({
    required this.model,
    required this.isEmulator,
    required this.brand,
    required this.device,
    required this.version,
    required this.os
  });

}