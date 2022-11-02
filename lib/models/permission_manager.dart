// import 'package:app_settings/app_settings.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// 
// import '../rehmat.dart';
// 
// class PermissionManager {
// 
//   static List<Permission> permissions = [
//     // Permission.accessMediaLocation,
//     // Permission.microphone,
//     // Permission.mediaLibrary,
//     // Permission.photos,
//     // Permission.photosAddOnly,
//     Permission.storage,
//   ];
// 
//   static Future<void> request(BuildContext context, Widget child) async {
//     Map<Permission, PermissionStatus> statuses = await permissions.request();
//     if (statuses.values.where((element) => !element.isGranted).isNotEmpty) {
//       Alerts.snackbar(
//         context,
//         text: 'Some of the permissions were not granted',
//         action: SnackBarAction(
//           label: 'Open Settings',
//           onPressed: () => AppSettings.openAppSettings()
//         )
//       );
//     }
//     AppRouter.removeAllAndPush(context, page: child);
//   }
// 
//   static Future<bool> get runtime async {
//     List<PermissionStatus> statuses = [];
//     for (Permission permission in permissions) {
//       statuses.add(await permission.status);
//     }
//     if (statuses.where((element) => !element.isGranted).isNotEmpty) return false;
//     return true;
//   }
// 
// }