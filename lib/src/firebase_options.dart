import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC3sWejAB1_9uqbhTpWjaKcyHAW-U_8ei8',
    appId: '1:760672931872:web:e1dc64665662b900af2c45',
    messagingSenderId: '760672931872',
    projectId: 'duonow-cabda',
    authDomain: 'duonow-cabda.firebaseapp.com',
    storageBucket: 'duonow-cabda.firebasestorage.app',
    measurementId: 'G-S38ZESHY9K',
    databaseURL: 'https://duonow-cabda-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC3sWejAB1_9uqbhTpWjaKcyHAW-U_8ei8',
    appId: '1:760672931872:web:e1dc64665662b900af2c45',
    messagingSenderId: '760672931872',
    projectId: 'duonow-cabda',
    storageBucket: 'duonow-cabda.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC3sWejAB1_9uqbhTpWjaKcyHAW-U_8ei8',
    appId: '1:760672931872:web:e1dc64665662b900af2c45',
    messagingSenderId: '760672931872',
    projectId: 'duonow-cabda',
    storageBucket: 'duonow-cabda.firebasestorage.app',
    iosBundleId: 'com.example.duonow',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC3sWejAB1_9uqbhTpWjaKcyHAW-U_8ei8',
    appId: '1:760672931872:web:e1dc64665662b900af2c45',
    messagingSenderId: '760672931872',
    projectId: 'duonow-cabda',
    storageBucket: 'duonow-cabda.firebasestorage.app',
    iosBundleId: 'com.example.duonow',
  );

  static bool get isConfigured => true;

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
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return web;
    }
  }
}
