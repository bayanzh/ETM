// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDSTTPvj6IqD3NU4_sadv-yLQ-lCuZaV_4',
    appId: '1:916499297682:web:48f8b0e5b0d2665be8fd4b',
    messagingSenderId: '916499297682',
    projectId: 'e-trainig-mate',
    authDomain: 'e-trainig-mate.firebaseapp.com',
    storageBucket: 'e-trainig-mate.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB6lbZ6O7Zi_zc2i9WJu4AQNWngF6TRNVE',
    appId: '1:916499297682:android:b9866a56e98027b8e8fd4b',
    messagingSenderId: '916499297682',
    projectId: 'e-trainig-mate',
    storageBucket: 'e-trainig-mate.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB0IvxVXRXgkvE87VfOp5VKKrS2Gy8m5kQ',
    appId: '1:916499297682:ios:988ddf99bd4b56dde8fd4b',
    messagingSenderId: '916499297682',
    projectId: 'e-trainig-mate',
    storageBucket: 'e-trainig-mate.appspot.com',
    iosBundleId: 'com.example.eTrainingMate',
  );
}
