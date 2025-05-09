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
    apiKey: 'AIzaSyD2w24jQ3m28dG1d89JqaogEqJgUXaaitc',
    appId: '1:629568376278:web:09f8f1ed54be74c3f46877',
    messagingSenderId: '629568376278',
    projectId: 'appfirmarpdf',
    authDomain: 'appfirmarpdf.firebaseapp.com',
    storageBucket: 'appfirmarpdf.firebasestorage.app',
    measurementId: 'G-6H7CEF6YQM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDBO3Tkktg6H3P_LsC0gIIiUSCnNsXjryU',
    appId: '1:629568376278:android:1dec51754568ba0ef46877',
    messagingSenderId: '629568376278',
    projectId: 'appfirmarpdf',
    storageBucket: 'appfirmarpdf.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDm6TncNYEXGP4ceGRODEVclWlXQLidrdU',
    appId: '1:629568376278:ios:fd5ae3976ef50a06f46877',
    messagingSenderId: '629568376278',
    projectId: 'appfirmarpdf',
    storageBucket: 'appfirmarpdf.firebasestorage.app',
    iosBundleId: 'com.example.appfima',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDm6TncNYEXGP4ceGRODEVclWlXQLidrdU',
    appId: '1:629568376278:ios:fd5ae3976ef50a06f46877',
    messagingSenderId: '629568376278',
    projectId: 'appfirmarpdf',
    storageBucket: 'appfirmarpdf.firebasestorage.app',
    iosBundleId: 'com.example.appfima',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD2w24jQ3m28dG1d89JqaogEqJgUXaaitc',
    appId: '1:629568376278:web:8d52dcba989e462af46877',
    messagingSenderId: '629568376278',
    projectId: 'appfirmarpdf',
    authDomain: 'appfirmarpdf.firebaseapp.com',
    storageBucket: 'appfirmarpdf.firebasestorage.app',
    measurementId: 'G-0DCKC7W3JC',
  );
}
