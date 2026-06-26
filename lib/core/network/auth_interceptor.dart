import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        final token = await user.getIdToken();
        options.headers['Authorization'] = 'Bearer $token';
        for (var i = 0; i < token!.length; i += 500) {
          final end = (i + 500 < token.length) ? i + 500 : token.length;
          debugPrint('Firebase Token: ${token.substring(i, end)}');
        }
        log('Firebase Token: $token');
      } on Exception catch (_) {
        // Log or handle token retrieval error
        // We still proceed with the request, which might fail on the backend
        // with a 401 if the token is missing/invalid.
      }
    }
    return super.onRequest(options, handler);
  }
}

/*
eyJhbGciOiJSUzI1NiIsImtpZCI6IjJmMjk1MGEyNGFlYWRkMjYzYzIxM2I2MDNhZjMxNWEzMjdiNmM3MjAiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiR2F1cmFiIFJveSIsInBpY3R1cmUiOiJodHRwczovL2xoMy5nb29nbGV1c2VyY29udGVudC5jb20vYS9BQ2c4b2NKUFpoS2hldndOc3Izc0x0djh4dFZyZ2JkM0JZcjl1a0ZRTHhCUFlBR21DbUc3emtvPXM5Ni1jIiwiaXNzIjoiaHR0cHM6Ly9zZWN1cmV0b2tlbi5nb29nbGUuY29tL3B1bHNlLWNoYXQtNzk5ZDkiLCJhdWQiOiJwdWxzZS1jaGF0LTc5OWQ5IiwiYXV0aF90aW1lIjoxNzgyNDU2MjcwLCJ1c2VyX2lkIjoiM1dGcm8yVFdhVFRxcmZZWjJGN1U4MHh4bmJsMSIsInN1YiI6IjNXRnJvMlRXYVRUcXJmWVoyRjdVODB4eG5ibDEiLCJpYXQiOjE3ODI0NjA4MTMsImV4cCI6MTc4MjQ2NDQxMywiZW1haWwiOiJob3N0aW5nLnJhd25ld3RvbkBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJnb29nbGUuY29tIjpbIjExNDk4NTQ0MjQzNTkyMDc0MzMwNyJdLCJlbWFpbCI6WyJob3N0aW5nLnJhd25ld3RvbkBnbWFpbC5jb20iXX0sInNpZ25faW5fcHJvdmlkZXIiOiJnb29nbGUuY29tIn19.jWlcjIdQM8FUrC1KewZ2mEF-YPgCMvvLct-OKG8Z0hoFNBjkbYstCDa6FGp4abQ_Z598pQY-fcn2XkvOx-YoM-467t1DmNJw66iFX8o0u5LxzmE5IKoFw89ehF1ZItezZdrwbIiDMSYsHHMvnb6aoY17BUr90zxfGh_CGlqdH-tdCzb

eyJhbGciOiJSUzI1NiIsImtpZCI6IjJmMjk1MGEyNGFlYWRkMjYzYzIxM2I2MDNhZjMxNWEzMjdiNmM3MjAiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiR2F1cmFiIFJveSIsInBpY3R1cmUiOiJodHRwczovL2xoMy5nb29nbGV1c2VyY29udGVudC5jb20vYS9BQ2c4b2NKUFpoS2hldndOc3Izc0x0djh4dFZyZ2JkM0JZcjl1a0ZRTHhCUFlBR21DbUc3emtvPXM5Ni1jIiwiaXNzIjoiaHR0cHM6Ly9zZWN1cmV0b2tlbi5nb29nbGUuY29tL3B1bHNlLWNoYXQtNzk5ZDkiLCJhdWQiOiJwdWxzZS1jaGF0LTc5OWQ5IiwiYXV0aF90aW1lIjoxNzgyNDU2MjcwLCJ1c2VyX2lkIjoiM1dGcm8yVFdhVFRxcmZZWjJGN1U4MHh4bmJsMSIsInN1YiI6IjNXRnJvMlRXYVRUcXJmWVoyRjdVODB4eG5ibDEiLCJpYXQiOjE3ODI0NjA4MTMsImV4cCI6MTc4MjQ2NDQxMywiZW1haWwiOiJob3N0aW5nLnJhd25ld3RvbkBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJnb29nbGUuY29tIjpbIjExNDk4NTQ0MjQzNTkyMDc0MzMwNyJdLCJlbWFpbCI6WyJob3N0aW5nLnJhd25ld3RvbkBnbWFpbC5jb20iXX0sInNpZ25faW5fcHJvdmlkZXIiOiJnb29nbGUuY29tIn19.jWlcjIdQM8FUrC1KewZ2mEF-YPgCMvvLct-OKG8Z0hoFNBjkbYstCDa6FGp4abQ_Z598pQY-fcn2XkvOx-YoM-467t1DmNJw66iFX8o0u5LxzmE5IKoFw89ehF1ZItezZdrwbIiDMSYsHHMvnb6aoY17BUr90zxfGh_CGlqdH-tdCzbr8uJNX27vUfYo1F6kUm4CHgorNx_WqZnObNuGRt6ireSTxyf0O_xcMeux90zHT6DArzg8kr1PUCYnaolWQyXv5WgEypou6xOYwlKWZwnq4ChilKRqPw89LpLZq6VqjT4tcQtilQ_Pk5eCiBm8R7YFCKmTuAGf4VO-1vF46g

*/
