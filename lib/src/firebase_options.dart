import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static const String apiKey = String.fromEnvironment('FIREBASE_API_KEY', defaultValue: '');
  static const String appId = String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '');
  static const String messagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '');
  static const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'duonow-cabda');
  static const String authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN', defaultValue: '');
  static const String storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: '');
  static const String measurementId = String.fromEnvironment('FIREBASE_MEASUREMENT_ID', defaultValue: '');
  static const String iosBundleId = String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID', defaultValue: '');

  static bool get isConfigured => apiKey.isNotEmpty && appId.isNotEmpty && messagingSenderId.isNotEmpty && projectId.isNotEmpty;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    authDomain: authDomain,
    storageBucket: storageBucket,
    measurementId: measurementId,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
    iosBundleId: iosBundleId,
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
    iosBundleId: iosBundleId,
  );

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
