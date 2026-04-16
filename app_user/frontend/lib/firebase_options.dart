import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB7d8mR41AEaMWpQ308YujKZD2HHWGy89o',
    appId: '1:1046904512204:android:0dd02256a156cff112ac69',
    messagingSenderId: '1046904512204',
    projectId: 'private-sambad',
    storageBucket: 'private-sambad.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDhZ_Pbzco7eF-mfTpeLusIpSveV8WUDPU',
    appId: '1:1046904512204:ios:4b1ca15147167a0312ac69',
    messagingSenderId: '1046904512204',
    projectId: 'private-sambad',
    storageBucket: 'private-sambad.firebasestorage.app',
    iosBundleId: 'com.shamrai.sambad',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB7d8mR41AEaMWpQ308YujKZD2HHWGy89o',
    appId: '1:1046904512204:android:646b302f9a7520f112ac69', // Temporary: using Android ID for testing
    messagingSenderId: '1046904512204',
    projectId: 'private-sambad',
    storageBucket: 'private-sambad.firebasestorage.app',
    authDomain: 'private-sambad.firebaseapp.com',
  );
}
