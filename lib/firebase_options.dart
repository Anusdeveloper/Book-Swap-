import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyBJhSS17cgcfGrleaPib0qv_MpJsVxYMDs',
        appId: '1:841923752053:ios:your-ios-app-id',  // Replace with your actual iOS app ID
        messagingSenderId: '841923752053',
        projectId: 'book-swap-app-f02a1',
        authDomain: 'book-swap-app-f02a1.firebaseapp.com',
        iosBundleId: 'com.yourcompany.bookswap',  // Replace with your actual iOS bundle ID
        storageBucket: 'book-swap-app-f02a1.appspot.com',
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyBJhSS17cgcfGrleaPib0qv_MpJsVxYMDs',
        appId: '1:841923752053:android:your-android-app-id',  // Replace with your actual Android app ID
        messagingSenderId: '841923752053',
        projectId: 'book-swap-app-f02a1',
        authDomain: 'book-swap-app-f02a1.firebaseapp.com',
        storageBucket: 'book-swap-app-f02a1.appspot.com',
        androidClientId: 'your-android-client-id',  // Replace with your actual Android client ID
        iosBundleId: 'com.yourcompany.bookswap',  // Replace with your actual iOS bundle ID
      );
    } else if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyBJhSS17cgcfGrleaPib0qv_MpJsVxYMDs',
        authDomain: 'book-swap-app-f02a1.firebaseapp.com',
        projectId: 'book-swap-app-f02a1',
        storageBucket: 'book-swap-app-f02a1.appspot.com',
        messagingSenderId: '841923752053',
        appId: '1:841923752053:web:your-web-app-id',  // Replace with your actual Web app ID
        measurementId: 'your-measurement-id',  // Replace with your actual measurement ID (if you have one)
      );
    }
    throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
  }
}
