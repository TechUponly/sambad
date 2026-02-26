import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not supported');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB7d8mR41AEaMWpQ308YujKZD2HHWGy89o',
    appId: '1:1046904512204:android:646b302f9a7520f112ac69',
    messagingSenderId: '1046904512204',
    projectId: 'private-sambad',
    storageBucket: 'private-sambad.firebasestorage.app',
  );
}
