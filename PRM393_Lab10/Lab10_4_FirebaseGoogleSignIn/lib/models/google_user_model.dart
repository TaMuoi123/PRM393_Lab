import 'package:firebase_auth/firebase_auth.dart';

class GoogleUserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String providerId;

  GoogleUserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.providerId = 'google.com',
  });

  factory GoogleUserModel.fromFirebaseUser(User user) {
    return GoogleUserModel(
      uid: user.uid,
      displayName: user.displayName ?? 'Google User',
      email: user.email ?? 'No email provided',
      photoUrl: user.photoURL,
      providerId: user.providerData.isNotEmpty
          ? user.providerData.first.providerId
          : 'google.com',
    );
  }

  factory GoogleUserModel.demoAccount() {
    return GoogleUserModel(
      uid: 'firebase-uid-google-98234710',
      displayName: 'Nguyen Van A (Google User)',
      email: 'anguyen.prm393@gmail.com',
      photoUrl: 'https://lh3.googleusercontent.com/a/default-user=s128',
      providerId: 'google.com',
    );
  }
}
