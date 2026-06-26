import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:pulse_chat/features/profile/profile_models.dart';

@lazySingleton
class ProfileRepository {
  ProfileRepository(this._dio);

  final Dio _dio;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches a user profile by UID from both the REST API and Firestore
  Future<ProfileUserEntity> getProfile(String uid) async {
    try {
      // 1. Call REST API
      final response = await _dio.get<Map<String, dynamic>>('/api/v1/users/profile/$uid');
      final apiData = response.data;
      if (apiData == null) {
        throw Exception('User profile not found.');
      }

      // 2. Fetch Firestore document for additional fields
      DocumentSnapshot<Map<String, dynamic>>? docSnap;
      try {
        docSnap = await _firestore.collection('users').doc(uid).get();
      } on FirebaseException catch (_) {
        // Fallback or ignore firestore-specific read errors to keep the flow resilient
      }
      final firestoreData = docSnap?.data();

      // 3. Merge sources into unified ProfileUserEntity
      return _mapToProfileUserEntity(apiData, firestoreData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Updates a user profile directly to Firestore
  Future<void> updateProfile(ProfileUserEntity user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.id);
      final data = <String, dynamic>{
        'name': user.name,
        'username': user.username,
        'photoURL': user.photoUrl,
        'photoUrl': user.photoUrl,
        'phoneNumber': user.mobile,
        'mobile': user.mobile,
        'bio': user.bio,
        'customUrl': user.customUrl,
        'socialLinks': user.socialLinks.map((link) => {
          'platform': link.platform.name,
          'url': link.url,
        }).toList(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      }..removeWhere((key, value) => value == null);

      await userDoc.set(data, SetOptions(merge: true));

      // Synchronize with Firebase Auth if it is the current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.uid == user.id) {
        await currentUser.updateDisplayName(user.name);
        if (user.photoUrl != null) {
          await currentUser.updatePhotoURL(user.photoUrl);
        }
        await currentUser.reload();
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  ProfileUserEntity _mapToProfileUserEntity(Map<String, dynamic> apiData, Map<String, dynamic>? firestoreData) {
    final uid = apiData['uid'] as String? ?? apiData['id'] as String? ?? '';
    final email = apiData['email'] as String? ?? firestoreData?['email'] as String? ?? '';
    final name = apiData['name'] as String? ?? firestoreData?['name'] as String? ?? '';
    
    // Check photoURL from both sources
    final photoUrl = apiData['photoURL'] as String? ?? 
                     firestoreData?['photoURL'] as String? ?? 
                     firestoreData?['photoUrl'] as String?;
                     
    final mobile = apiData['phoneNumber'] as String? ?? 
                   firestoreData?['phoneNumber'] as String? ?? 
                   firestoreData?['mobile'] as String?;

    final bio = firestoreData?['bio'] as String?;
    final customUrl = firestoreData?['customUrl'] as String?;

    var socialLinks = <SocialLink>[];
    if (firestoreData?['socialLinks'] != null) {
      final list = firestoreData!['socialLinks'] as List<dynamic>;
      socialLinks = list.map((item) {
        final map = item as Map<String, dynamic>;
        final platformStr = map['platform'] as String;
        final url = map['url'] as String;
        final platform = SocialPlatform.values.firstWhere(
          (p) => p.name == platformStr,
          orElse: () => SocialPlatform.instagram,
        );
        return SocialLink(platform: platform, url: url);
      }).toList();
    }

    final username = firestoreData?['username'] as String? ?? email.split('@').first;

    // Presence fields
    final isOnline = firestoreData?['isOnline'] as bool? ?? false;
    final onlineStatus = isOnline ? OnlineStatus.online : OnlineStatus.offline;

    return ProfileUserEntity(
      id: uid,
      name: name,
      username: username,
      email: email,
      photoUrl: photoUrl,
      bio: bio,
      mobile: mobile,
      onlineStatus: onlineStatus,
      socialLinks: socialLinks,
      customUrl: customUrl,
    );
  }

  Exception _handleDioError(DioException error) {
    var message = 'An unexpected network error occurred.';
    if (error.response != null) {
      final responseData = error.response!.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey('detail')) {
        message = responseData['detail'].toString();
      } else {
        message = 'Server returned HTTP ${error.response!.statusCode}';
      }
    } else {
      final type = error.type;
      if (type == DioExceptionType.connectionTimeout || type == DioExceptionType.sendTimeout || type == DioExceptionType.receiveTimeout) {
        message = 'Connection timed out. Please check your internet.';
      } else if (type == DioExceptionType.connectionError) {
        message = 'Cannot connect to the server. Please verify the backend is running.';
      } else {
        message = error.message ?? message;
      }
    }
    return Exception(message);
  }
}
