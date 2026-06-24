enum MessageStatus { sending, sent, delivered, read }

class UrlPreviewData {
  const UrlPreviewData({
    required this.url,
    required this.title,
    required this.description,
    required this.siteName,
    this.imageUrl,
  });
  final String url;
  final String title;
  final String description;
  final String? imageUrl;
  final String siteName;
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.text,
    required this.isMine,
    required this.time,
    this.status = MessageStatus.read,
    this.replyTo,
    this.reactions = const {},
    this.urlPreview,
    this.isDeleted = false,
  });

  final String id;
  final String text;
  final bool isMine;
  final String time;
  final MessageStatus status;
  final ChatMessage? replyTo;
  Map<String, List<String>> reactions; // emoji -> [userIds]
  final UrlPreviewData? urlPreview;
  final bool isDeleted;
}
