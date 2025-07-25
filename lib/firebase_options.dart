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
    apiKey: 'AIzaSyDHKFtDRmPGviGf4FRVRlaRpgciRDl25PY',
    appId: '1:1091358463914:web:cef0ebadd2ef31ba933dd3',
    messagingSenderId: '1091358463914',
    projectId: 'sdg-app-f7edf',
    authDomain: 'sdg-app-f7edf.firebaseapp.com',
    storageBucket: 'sdg-app-f7edf.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAUpEmn3GfHcackMPImi4gYBbtkODUxUTY',
    appId: '1:1091358463914:android:f99e6d0f61220f5e933dd3',
    messagingSenderId: '1091358463914',
    projectId: 'sdg-app-f7edf',
    storageBucket: 'sdg-app-f7edf.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD8-QpcT0c49Po108fDX60EnNLpPkG4jWM',
    appId: '1:1091358463914:ios:53fe3a01ef1a6870933dd3',
    messagingSenderId: '1091358463914',
    projectId: 'sdg-app-f7edf',
    storageBucket: 'sdg-app-f7edf.appspot.com',
    iosBundleId: 'com.example.flutterSdg',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD8-QpcT0c49Po108fDX60EnNLpPkG4jWM',
    appId: '1:1091358463914:ios:0653465940528c3c933dd3',
    messagingSenderId: '1091358463914',
    projectId: 'sdg-app-f7edf',
    storageBucket: 'sdg-app-f7edf.appspot.com',
    iosBundleId: 'com.example.flutterSdg.RunnerTests',
  );
}
