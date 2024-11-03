// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyDF0NIIxTY4afBIqMJorUPvE16NDPjEiko',
    appId: '1:736084769112:web:3d39a3413c5d211297cd2d',
    messagingSenderId: '736084769112',
    projectId: 'piclinica-a37ba',
    authDomain: 'piclinica-a37ba.firebaseapp.com',
    databaseURL: 'https://piclinica-a37ba-default-rtdb.firebaseio.com',
    storageBucket: 'piclinica-a37ba.appspot.com',
    measurementId: 'G-60Q0475VFT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBgr0WHIBCP2rOTyRjSlROCOFMsWa4COqY',
    appId: '1:736084769112:android:88bbed1fee00efe697cd2d',
    messagingSenderId: '736084769112',
    projectId: 'piclinica-a37ba',
    databaseURL: 'https://piclinica-a37ba-default-rtdb.firebaseio.com',
    storageBucket: 'piclinica-a37ba.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBpvZgCpnZpsbIeNQxvbYZMvKfKm2W4hQc',
    appId: '1:736084769112:ios:3d045275278b152d97cd2d',
    messagingSenderId: '736084769112',
    projectId: 'piclinica-a37ba',
    databaseURL: 'https://piclinica-a37ba-default-rtdb.firebaseio.com',
    storageBucket: 'piclinica-a37ba.appspot.com',
    iosBundleId: 'com.example.clinica',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBpvZgCpnZpsbIeNQxvbYZMvKfKm2W4hQc',
    appId: '1:736084769112:ios:3d045275278b152d97cd2d',
    messagingSenderId: '736084769112',
    projectId: 'piclinica-a37ba',
    databaseURL: 'https://piclinica-a37ba-default-rtdb.firebaseio.com',
    storageBucket: 'piclinica-a37ba.appspot.com',
    iosBundleId: 'com.example.clinica',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDF0NIIxTY4afBIqMJorUPvE16NDPjEiko',
    appId: '1:736084769112:web:3d39a3413c5d211297cd2d',
    messagingSenderId: '736084769112',
    projectId: 'piclinica-a37ba',
    authDomain: 'piclinica-a37ba.firebaseapp.com',
    databaseURL: 'https://piclinica-a37ba-default-rtdb.firebaseio.com',
    storageBucket: 'piclinica-a37ba.appspot.com',
    measurementId: 'G-60Q0475VFT',
  );

}