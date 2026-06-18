// ─────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────

enum ChatType { individual, group }

class ChatItem {
  const ChatItem({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.type,
    this.avatarUrl,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isMuted = false,
    this.isOnline = false,
    this.members,
    this.senderName,
  });

  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final ChatType type;
  final String? avatarUrl;
  final int unreadCount;
  final bool isPinned;
  final bool isMuted;
  final bool isOnline;
  final List<String>? members;
  final String? senderName;
}
