import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pulse_chat/features/contacts/data/contact_status.dart';

@lazySingleton
class ContactsRepository {
  ContactsRepository(this._dio);

  final Dio _dio;

  /// Fetches all contact relationships for the authenticated user
  Future<List<ContactUser>> getContacts() async {
    try {
      final response = await _dio.get<List<dynamic>>('/api/v1/users/contacts');
      if (response.data == null) return [];
      return response.data!.map((item) => _mapToContactUser(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Searches users by name or email
  Future<List<ContactUser>> searchUsers(String query) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/api/v1/users/search',
        queryParameters: {'q': query},
      );
      if (response.data == null) return [];
      return response.data!.map((item) => _mapToContactUser(item as Map<String, dynamic>, forceStatus: ContactStatus.none)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Sends a contact request to the target user
  Future<void> sendContactRequest(String receiverUid) async {
    try {
      await _dio.post<dynamic>(
        '/api/v1/contacts/request',
        data: {'receiver_uid': receiverUid},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Accepts an incoming contact request
  Future<void> acceptContactRequest(String requesterUid) async {
    try {
      await _dio.post<dynamic>(
        '/api/v1/contacts/accept',
        data: {'requester_uid': requesterUid},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Rejects (or cancels) a contact request
  Future<void> rejectContactRequest(String requesterUid) async {
    try {
      await _dio.post<dynamic>(
        '/api/v1/contacts/reject',
        data: {'requester_uid': requesterUid},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Blocks a user
  Future<void> blockUser(String targetUid) async {
    try {
      await _dio.post<dynamic>(
        '/api/v1/contacts/block',
        data: {'target_uid': targetUid},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Unblocks a user
  Future<void> unblockUser(String targetUid) async {
    try {
      await _dio.post<dynamic>(
        '/api/v1/contacts/unblock',
        data: {'target_uid': targetUid},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─────────────────────────────────────────────
  // Private Helper Methods
  // ─────────────────────────────────────────────

  /// Maps backend JSON response into a ContactUser entity
  ContactUser _mapToContactUser(Map<String, dynamic> json, {ContactStatus? forceStatus}) {
    final statusStr = json['status'] as String?;
    var status = forceStatus ?? ContactStatus.none;

    if (forceStatus == null && statusStr != null) {
      switch (statusStr) {
        case 'pending_sent':
          status = ContactStatus.pendingSent;
        case 'pending_received':
          status = ContactStatus.pendingReceived;
        case 'accepted':
          status = ContactStatus.friends;
        case 'blocked':
          status = ContactStatus.blockedByMe;
        default:
          status = ContactStatus.none;
      }
    }

    final email = json['email'] as String? ?? '';
    final username = email.split('@').first;

    return ContactUser(
      uid: json['uid'] as String? ?? '',
      username: username,
      displayName: json['name'] as String? ?? json['displayName'] as String? ?? email,
      status: status,
      avatarUrl: json['photoURL'] as String? ?? json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeenAt'] != null
          ? DateTime.tryParse(json['lastSeenAt'] as String)
          : (json['lastSeen'] != null ? DateTime.tryParse(json['lastSeen'] as String) : null),
      mutualContactsCount: json['mutualContactsCount'] as int? ?? 0,
    );
  }

  /// Helper to extract server/network error messages
  Exception _handleDioError(DioException error) {
    var message = 'An unexpected network error occurred.';

    if (error.response != null) {
      final responseData = error.response!.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey('detail')) {
        message = responseData['detail'].toString();
      } else if (responseData is String && responseData.isNotEmpty) {
        message = responseData;
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
