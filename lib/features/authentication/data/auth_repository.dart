import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  Future<User?> getInitialUser() async {
    final user = _auth.currentUser;
    if (user != null) return user;

    return _auth.authStateChanges().first.timeout(
      const Duration(seconds: 5),
      onTimeout: () => _auth.currentUser,
    );
  }

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
      await _saveUserToFirestore(user, fallbackName: name);
      await _saveFCMToken(user.uid); // ← Added
    }
    return credential;
  }

  /// Email Sign-in
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user != null) {
      await _saveUserToFirestore(credential.user!);
      await _saveFCMToken(credential.user!.uid); // ← Added
    }
    return credential;
  }

  /// Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    UserCredential? userCredential;

    if (kIsWeb) {
      final authProvider = GoogleAuthProvider();
      userCredential = await _auth.signInWithPopup(authProvider);
    } else {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      userCredential = await _auth.signInWithCredential(credential);
    }

    if (userCredential.user != null) {
      await _saveSignedInGoogleUser(userCredential);
      await _saveFCMToken(userCredential.user!.uid);
    }

    return userCredential;
  }

  /// Sign out
  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
    // Optional: Clear token on logout
    await _messaging.deleteToken();
  }

  // ─────────────────────────────────────────────
  // Private Helpers
  // ─────────────────────────────────────────────

  Future<void> _saveSignedInGoogleUser(UserCredential credential) async {
    final user = credential.user;
    if (user == null) return;
    await _saveUserToFirestore(user);
  }

  Future<void> _saveUserToFirestore(
    User user, {
    String? fallbackName,
  }) async {
    final userDocument = _firestore.collection('users').doc(user.uid);

    final profile = user.providerData.isNotEmpty ? user.providerData.first : null;

    final userData = <String, dynamic>{
      'uid': user.uid,
      'email': user.email ?? profile?.email,
      'name': _firstNonEmpty([user.displayName, fallbackName, profile?.displayName]),
      'photoURL': user.photoURL ?? profile?.photoURL,
      'isEmailVerified': user.emailVerified,
      'phoneNumber': user.phoneNumber,
      'lastLoginAt': FieldValue.serverTimestamp(),
    }..removeWhere((key, value) => value == null);

    try {
      await userDocument.set(userData, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await user.getIdToken(true);
        await userDocument.set(userData, SetOptions(merge: true));
      } else {
        rethrow;
      }
    }
  }

  /// Save / Update FCM Token
  Future<void> _saveFCMToken(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      await _firestore.collection('users').doc(userId).set({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Optional: Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': newToken,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on Exception catch (e) {
      debugPrint('Failed to save FCM token: $e');
    }
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }
}
