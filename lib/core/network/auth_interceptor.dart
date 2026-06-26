import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthInterceptor extends Interceptor {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Force refresh if the token is close to expiry or expired
        final token = await user.getIdToken(true);
        options.headers['Authorization'] = 'Bearer $token';
      } on Exception catch (_) {
        // Log or handle token retrieval error
        // We still proceed with the request, which might fail on the backend
        // with a 401 if the token is missing/invalid.
      }
    }
    return super.onRequest(options, handler);
  }
}
