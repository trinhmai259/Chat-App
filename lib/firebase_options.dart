// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
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
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBBw_PAwJN9-aiF_lHVgUT14ags0hncMRo',
    appId: '1:143630103525:web:4cd52d714d4830f41cf50c',
    messagingSenderId: '143630103525',
    projectId: 'achat-d2901',
    authDomain: 'achat-d2901.firebaseapp.com',
    storageBucket: 'achat-d2901.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCSdtZm7ajb25Apxm6INcWTi2MUGD8xqNE',
    appId: '1:143630103525:android:d1a8bd1554dd98bc1cf50c',
    messagingSenderId: '143630103525',
    projectId: 'achat-d2901',
    storageBucket: 'achat-d2901.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAnNgQNZjTq54sN-KF-v94UUch8eKuNSw0',
    appId: '1:143630103525:ios:9427e892db2ab9141cf50c',
    messagingSenderId: '143630103525',
    projectId: 'achat-d2901',
    storageBucket: 'achat-d2901.appspot.com',
    androidClientId: '143630103525-73ehb0nujk49lfoptbbi9kc4pi97naka.apps.googleusercontent.com',
    iosClientId: '143630103525-ol94gh42qrma7r57fgu8ck3m2e53r0jq.apps.googleusercontent.com',
    iosBundleId: 'com.lumi.achat',
  );
}
