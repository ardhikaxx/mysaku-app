// File generated for MySAKU
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyAs0SEH7T_Im2BUVpVxH_qbXhmLsbAFazM',
    appId: '1:1033802383199:web:mysaku_web',
    messagingSenderId: '1033802383199',
    projectId: 'mysaku-a652f',
    authDomain: 'mysaku-a652f.firebaseapp.com',
    databaseURL: 'https://mysaku-a652f-default-rtdb.firebaseio.com',
    storageBucket: 'mysaku-a652f.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAs0SEH7T_Im2BUVpVxH_qbXhmLsbAFazM',
    appId: '1:1033802383199:android:5a55e8c0a6b3a56f4fc0ea',
    messagingSenderId: '1033802383199',
    projectId: 'mysaku-a652f',
    databaseURL: 'https://mysaku-a652f-default-rtdb.firebaseio.com',
    storageBucket: 'mysaku-a652f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAs0SEH7T_Im2BUVpVxH_qbXhmLsbAFazM',
    appId: '1:1033802383199:ios:mysaku_ios',
    messagingSenderId: '1033802383199',
    projectId: 'mysaku-a652f',
    databaseURL: 'https://mysaku-a652f-default-rtdb.firebaseio.com',
    storageBucket: 'mysaku-a652f.firebasestorage.app',
    iosBundleId: 'com.example.mysakuApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAs0SEH7T_Im2BUVpVxH_qbXhmLsbAFazM',
    appId: '1:1033802383199:ios:mysaku_ios',
    messagingSenderId: '1033802383199',
    projectId: 'mysaku-a652f',
    databaseURL: 'https://mysaku-a652f-default-rtdb.firebaseio.com',
    storageBucket: 'mysaku-a652f.firebasestorage.app',
    iosBundleId: 'com.example.mysakuApp',
  );
}
