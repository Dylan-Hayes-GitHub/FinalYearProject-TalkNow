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
    apiKey: 'AIzaSyDvxT0_iJLXUwgKdVuWlCNsHfmj25GZOT8',
    appId: '1:237865862267:web:37c6dd8abd80e83fd70ede',
    messagingSenderId: '237865862267',
    projectId: 'talknow-47812',
    authDomain: 'talknow-47812.firebaseapp.com',
    databaseURL: 'https://talknow-47812-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'talknow-47812.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCNDqqa9X-22PR2b1_-0DtXIBXPTrHCMDs',
    appId: '1:237865862267:android:d5d2ecbc394a228ed70ede',
    messagingSenderId: '237865862267',
    projectId: 'talknow-47812',
    databaseURL: 'https://talknow-47812-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'talknow-47812.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAxyK1tHoVsCXJ-2qyiE6BXm9bzKfUYJ-A',
    appId: '1:237865862267:ios:9bbba4891fcc247ed70ede',
    messagingSenderId: '237865862267',
    projectId: 'talknow-47812',
    databaseURL: 'https://talknow-47812-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'talknow-47812.appspot.com',
    iosClientId: '237865862267-nq407masqkdmnh7b0cdkqh8sn62g16vi.apps.googleusercontent.com',
    iosBundleId: 'com.example.talkNowApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAxyK1tHoVsCXJ-2qyiE6BXm9bzKfUYJ-A',
    appId: '1:237865862267:ios:9bbba4891fcc247ed70ede',
    messagingSenderId: '237865862267',
    projectId: 'talknow-47812',
    databaseURL: 'https://talknow-47812-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'talknow-47812.appspot.com',
    iosClientId: '237865862267-nq407masqkdmnh7b0cdkqh8sn62g16vi.apps.googleusercontent.com',
    iosBundleId: 'com.example.talkNowApp',
  );
}
