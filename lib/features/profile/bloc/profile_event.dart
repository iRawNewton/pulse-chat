import 'package:flutter/foundation.dart';
import 'package:pulse_chat/features/profile/profile_models.dart';

@immutable
abstract class ProfileEvent {
  const ProfileEvent();
}

class FetchProfileEvent extends ProfileEvent {
  const FetchProfileEvent(this.uid);
  final String uid;
}

class UpdateProfileEvent extends ProfileEvent {
  const UpdateProfileEvent(this.user);
  final ProfileUserEntity user;
}

class ToggleOnlineStatusEvent extends ProfileEvent {
  const ToggleOnlineStatusEvent(this.status);
  final OnlineStatus status;
}

class SendContactRequestProfileEvent extends ProfileEvent {
  const SendContactRequestProfileEvent();
}

class AcceptContactRequestProfileEvent extends ProfileEvent {
  const AcceptContactRequestProfileEvent();
}

class BlockUserProfileEvent extends ProfileEvent {
  const BlockUserProfileEvent();
}

class UnblockUserProfileEvent extends ProfileEvent {
  const UnblockUserProfileEvent();
}
