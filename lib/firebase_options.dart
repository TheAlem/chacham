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
    apiKey: 'AIzaSyDanb-BFhXLwqLSRUhCy72uT45XlkQgjQY',
    appId: '1:25615348978:web:8c15b5b0ce0ce19213cc6b',
    messagingSenderId: '25615348978',
    projectId: 'shazam-78aef',
    authDomain: 'shazam-78aef.firebaseapp.com',
    storageBucket: 'shazam-78aef.appspot.com',
    measurementId: 'G-KPYJZDKXLF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD7KCDmHziFFEcDdX-U53gOzBtIdvOWyIY',
    appId: '1:25615348978:android:f16af6c0dbc8d28713cc6b',
    messagingSenderId: '25615348978',
    projectId: 'shazam-78aef',
    storageBucket: 'shazam-78aef.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBKgVOQtXguJOQ9bjXadyDmgvalfI5sDDM',
    appId: '1:25615348978:ios:38b8b9943f1efa6b13cc6b',
    messagingSenderId: '25615348978',
    projectId: 'shazam-78aef',
    storageBucket: 'shazam-78aef.appspot.com',
    androidClientId: '25615348978-iuc48hi2n2plrbt8d48amcdvvklatopl.apps.googleusercontent.com',
    iosClientId: '25615348978-poa3hdo3a95dd64nuds6tumsllkvilap.apps.googleusercontent.com',
    iosBundleId: 'com.example.chacham',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBKgVOQtXguJOQ9bjXadyDmgvalfI5sDDM',
    appId: '1:25615348978:ios:079aaa2d0518dc7213cc6b',
    messagingSenderId: '25615348978',
    projectId: 'shazam-78aef',
    storageBucket: 'shazam-78aef.appspot.com',
    androidClientId: '25615348978-iuc48hi2n2plrbt8d48amcdvvklatopl.apps.googleusercontent.com',
    iosClientId: '25615348978-imuk6e6uhb886fp3hkhtpao8b3hkdlv9.apps.googleusercontent.com',
    iosBundleId: 'com.example.chacham.RunnerTests',
  );
}
