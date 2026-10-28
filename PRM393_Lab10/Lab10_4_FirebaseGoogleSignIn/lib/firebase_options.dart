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
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyPRM393Lab10WebClientAuthXYZ',
    appId: '1:9823471029:web:9f8a7b6c5d4e3f2a1b',
    messagingSenderId: '9823471029',
    projectId: 'prm393-lab10-firebase',
    authDomain: 'prm393-lab10-firebase.firebaseapp.com',
    storageBucket: 'prm393-lab10-firebase.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyPRM393Lab10AndroidClientXYZ',
    appId: '1:9823471029:android:9f8a7b6c5d4e3f2a1b',
    messagingSenderId: '9823471029',
    projectId: 'prm393-lab10-firebase',
    storageBucket: 'prm393-lab10-firebase.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyPRM393Lab10iOSClientXYZ',
    appId: '1:9823471029:ios:9f8a7b6c5d4e3f2a1b',
    messagingSenderId: '9823471029',
    projectId: 'prm393-lab10-firebase',
    storageBucket: 'prm393-lab10-firebase.appspot.com',
    iosBundleId: 'com.example.lab104Firebasegooglesignin',
  );
}
