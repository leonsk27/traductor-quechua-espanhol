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
    apiKey: 'AIzaSyDfAZuXjWjtAQCORyAOE540zz61waLY3Hw',
    appId: '1:463333547610:web:74669fe845d34dd1fb8263',
    messagingSenderId: '463333547610',
    projectId: 'app-translate-quechua-v1',
    authDomain: 'app-translate-quechua-v1.firebaseapp.com',
    storageBucket: 'app-translate-quechua-v1.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDQBYjTWXgYs2zHPBgjx5mr-TmE6wTUrPw',
    appId: '1:463333547610:android:f7f3c7cf9adcb0edfb8263',
    messagingSenderId: '463333547610',
    projectId: 'app-translate-quechua-v1',
    storageBucket: 'app-translate-quechua-v1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBW3VUb9_taA4F_2-Nf7yoTTP3npECq6Oo',
    appId: '1:463333547610:ios:5415847fa83b56f5fb8263',
    messagingSenderId: '463333547610',
    projectId: 'app-translate-quechua-v1',
    storageBucket: 'app-translate-quechua-v1.firebasestorage.app',
    iosClientId: '463333547610-np736aecschm5v3opp3pb34orn843u6r.apps.googleusercontent.com',
    iosBundleId: 'com.example.transQuechua',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBW3VUb9_taA4F_2-Nf7yoTTP3npECq6Oo',
    appId: '1:463333547610:ios:5415847fa83b56f5fb8263',
    messagingSenderId: '463333547610',
    projectId: 'app-translate-quechua-v1',
    storageBucket: 'app-translate-quechua-v1.firebasestorage.app',
    iosClientId: '463333547610-np736aecschm5v3opp3pb34orn843u6r.apps.googleusercontent.com',
    iosBundleId: 'com.example.transQuechua',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDfAZuXjWjtAQCORyAOE540zz61waLY3Hw',
    appId: '1:463333547610:web:b46c392b3ce8c925fb8263',
    messagingSenderId: '463333547610',
    projectId: 'app-translate-quechua-v1',
    authDomain: 'app-translate-quechua-v1.firebaseapp.com',
    storageBucket: 'app-translate-quechua-v1.firebasestorage.app',
  );

}