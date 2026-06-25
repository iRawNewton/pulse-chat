/// Mirrors the relationship state between the current user and another user,
/// derived from your backend's contact record (or its absence).
///
/// Suggested mapping once wired to the real API:
/// - No contact row found                         -> [none]
/// - Contact row exists, requester == me           -> [pendingSent]
/// - Contact row exists, requester == them         -> [pendingReceived]
/// - Contact row status == accepted                -> [friends]
/// - Contact row status == blocked, blocker == me  -> [blockedByMe]
enum ContactStatus {
  none,
  pendingSent,
  pendingReceived,
  friends,
  blockedByMe;

  bool get canSendRequest => this == ContactStatus.none;
  bool get isPending => this == pendingSent || this == pendingReceived;
}

/// UI-layer model for a single user, whether from search results or the
/// contacts list. Replace with your Freezed entity + json_serializable when
/// wiring this up to GET /users/search, /users/contacts, etc.
class ContactUser {
  const ContactUser({
    required this.uid,
    required this.username,
    required this.displayName,
    required this.status,
    this.avatarUrl,
    this.bio,
    this.isOnline = false,
    this.lastSeen,
    this.mutualContactsCount = 0,
  });

  final String uid;
  final String username;
  final String displayName;
  final ContactStatus status;
  final String? avatarUrl;
  final String? bio;
  final bool isOnline;
  final DateTime? lastSeen;
  final int mutualContactsCount;

  ContactUser copyWith({ContactStatus? status}) {
    return ContactUser(
      uid: uid,
      username: username,
      displayName: displayName,
      status: status ?? this.status,
      avatarUrl: avatarUrl,
      bio: bio,
      isOnline: isOnline,
      lastSeen: lastSeen,
      mutualContactsCount: mutualContactsCount,
    );
  }
}
