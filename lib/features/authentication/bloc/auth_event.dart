import 'package:flutter/foundation.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class SignInWithEmailRequested extends AuthEvent {
  const SignInWithEmailRequested({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;
}

class SignUpWithEmailRequested extends AuthEvent {
  const SignUpWithEmailRequested({
    required this.name,
    required this.email,
    required this.password,
  });
  final String name;
  final String email;
  final String password;
}

class SignInWithGoogleRequested extends AuthEvent {
  const SignInWithGoogleRequested();
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}
