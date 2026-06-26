import 'package:flutter/foundation.dart';
import 'package:pulse_chat/features/profile/profile_models.dart';

@immutable
abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.user,
    required this.isMe,
    this.connectionStatus = ConnectionStatus.none,
  });

  final ProfileUserEntity user;
  final bool isMe;
  final ConnectionStatus connectionStatus;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileLoaded &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          isMe == other.isMe &&
          connectionStatus == other.connectionStatus;

  @override
  int get hashCode => user.hashCode ^ isMe.hashCode ^ connectionStatus.hashCode;
}

class ProfileFailure extends ProfileState {
  const ProfileFailure(this.error);
  final String error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileFailure &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;
}

class ProfileSaving extends ProfileState {
  const ProfileSaving();
}

class ProfileSaveSuccess extends ProfileState {
  const ProfileSaveSuccess(this.user);
  final ProfileUserEntity user;
}
