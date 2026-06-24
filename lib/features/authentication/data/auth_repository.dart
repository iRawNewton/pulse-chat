import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Email Sign-up
  Future<UserCredential> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    await credential.user?.reload();
    final user = _auth.currentUser ?? credential.user;
    if (user != null) {
      await _saveUserToFirestore(
        user,
        fallbackName: name,
        authProvider: 'password',
      );
    }
    return credential;
  }

  /// Email Sign-in
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      final authProvider = GoogleAuthProvider();
      final credential = await _auth.signInWithPopup(authProvider);
      await _saveSignedInGoogleUser(credential);
      return credential;
    } else {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      await _saveSignedInGoogleUser(userCredential);
      return userCredential;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  Future<void> _saveSignedInGoogleUser(UserCredential credential) async {
    final user = credential.user;
    if (user == null) return;

    await _saveUserToFirestore(
      user,
      authProvider: 'google.com',
    );
  }

  Future<void> _saveUserToFirestore(
    User user, {
    required String authProvider,
    String? fallbackName,
  }) async {
    final providerIds = user.providerData
        .map((provider) => provider.providerId)
        .where((providerId) => providerId.isNotEmpty)
        .toSet()
        .toList();

    final providerProfiles = user.providerData.map((provider) {
      return <String, Object?>{
        'providerId': provider.providerId,
        'uid': provider.uid,
        'displayName': provider.displayName,
        'email': provider.email,
        'phoneNumber': provider.phoneNumber,
        'photoURL': provider.photoURL,
      };
    }).toList();

    final userDocument = _firestore.collection('users').doc(user.uid);
    final snapshot = await userDocument.get();
    final userData = <String, Object?>{
      'uid': user.uid,
      'name': user.displayName ?? fallbackName,
      'email': user.email,
      'phoneNumber': user.phoneNumber,
      'photoURL': user.photoURL,
      'isEmailVerified': user.emailVerified,
      'isAnonymous': user.isAnonymous,
      'authProvider': authProvider,
      'providerIds': providerIds,
      'providerProfiles': providerProfiles,
      'metadata': <String, Object?>{
        'creationTime': user.metadata.creationTime,
        'lastSignInTime': user.metadata.lastSignInTime,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!snapshot.exists) {
      userData['createdAt'] = FieldValue.serverTimestamp();
    }

    await userDocument.set(userData, SetOptions(merge: true));
  }
}
