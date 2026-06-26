import 'package:flutter/foundation.dart';

/// Relationship between the viewer and the profile owner.
/// Drives which CTA shows up on the visitor's side of the profile.
enum ConnectionStatus {
  none,
  requestSent,
  requestReceived, // they sent ME a request — show Accept/Decline
  connected,
}

/// Online presence. Kept separate from [ConnectionStatus] since it's
/// orthogonal — anyone can be online/offline regardless of connection state.
enum OnlineStatus { online, offline, away }

/// The fixed set of social platforms we render chips/icons for.
/// Order here = render order in the UI.
enum SocialPlatform { facebook, x, instagram, snapchat, linkedin }

@immutable
class SocialLink {
  const SocialLink({required this.platform, required this.url});
  final SocialPlatform platform;
  final String url;
}

@immutable
class ProfileUserEntity {
  const ProfileUserEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.photoUrl,
    this.bio,
    this.mobile,
    this.onlineStatus = OnlineStatus.offline,
    this.socialLinks = const [],
    this.customUrl,
  });

  final String id;
  final String name;
  final String username;
  final String email;
  final String? photoUrl;
  final String? bio;
  final String? mobile;
  final OnlineStatus onlineStatus;

  /// Only entries the user has actually filled in are present here —
  /// fixed platforms (facebook/x/instagram/snapchat/linkedin) that are
  /// empty just don't show up on the viewer's screen.
  final List<SocialLink> socialLinks;

  /// Exactly one custom link is allowed, enforced in the edit screen.
  final String? customUrl;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  ProfileUserEntity copyWith({
    String? name,
    String? username,
    String? email,
    String? photoUrl,
    String? bio,
    String? mobile,
    OnlineStatus? onlineStatus,
    List<SocialLink>? socialLinks,
    String? customUrl,
  }) {
    return ProfileUserEntity(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      mobile: mobile ?? this.mobile,
      onlineStatus: onlineStatus ?? this.onlineStatus,
      socialLinks: socialLinks ?? this.socialLinks,
      customUrl: customUrl ?? this.customUrl,
    );
  }
}
