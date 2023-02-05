// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC4gCgngXlkC1woDvGB8AQtHIpx-LfyM1A',
    appId: '1:583685461758:web:4f5e05283f8d07f08337af',
    messagingSenderId: '583685461758',
    projectId: 'app-render-studio',
    authDomain: 'app-render-studio.firebaseapp.com',
    storageBucket: 'app-render-studio.appspot.com',
    measurementId: 'G-ZBJGMWYR1R',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAJZasYgglDkkXpJ7ejHGuG1iOA3v5gapc',
    appId: '1:583685461758:android:c9f49a6ca9dad2f68337af',
    messagingSenderId: '583685461758',
    projectId: 'app-render-studio',
    storageBucket: 'app-render-studio.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAwp_JgWBBmHK2SW31Y31uHEukqAH6OYVc',
    appId: '1:583685461758:ios:5b633e401991a3528337af',
    messagingSenderId: '583685461758',
    projectId: 'app-render-studio',
    storageBucket: 'app-render-studio.appspot.com',
    iosClientId: '583685461758-30nvkndne7gfatnr4p3opr91251bs3ll.apps.googleusercontent.com',
    iosBundleId: 'app.studio.render',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAwp_JgWBBmHK2SW31Y31uHEukqAH6OYVc',
    appId: '1:583685461758:ios:5b633e401991a3528337af',
    messagingSenderId: '583685461758',
    projectId: 'app-render-studio',
    storageBucket: 'app-render-studio.appspot.com',
    iosClientId: '583685461758-30nvkndne7gfatnr4p3opr91251bs3ll.apps.googleusercontent.com',
    iosBundleId: 'app.studio.render',
  );
}
