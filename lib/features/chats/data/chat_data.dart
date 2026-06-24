import 'package:pulse_chat/features/chats/data/chat_message_model.dart';

class ChatMessageData {
  List<ChatMessage> buildSampleMessages() {
    final m = <ChatMessage>[];

    final m1 = ChatMessage(
      id: '1',
      text: 'Hey! Did you check out the Flutter 3.x release notes?',
      isMine: false,
      time: '9:01 AM',
    );
    m.add(m1);

    final m2 = ChatMessage(
      id: '2',
      text: 'Yeah! The performance improvements are insane 🔥',
      isMine: true,
      time: '9:02 AM',
      reactions: {
        '🔥': ['me', 'them'],
        '👍': ['them'],
      },
    );
    m.add(m2);

    final m3 = ChatMessage(
      id: '3',
      text: 'Check this out — https://flutter.dev/multi-platform',
      isMine: false,
      time: '9:04 AM',
      urlPreview: _urlPreview,
    );
    m.add(m3);

    final m4 = ChatMessage(
      id: '4',
      text: 'This is exactly what I needed for the project!',
      isMine: true,
      time: '9:05 AM',
      replyTo: m3,
    );
    m.add(m4);

    final m5 = ChatMessage(
      id: '5',
      text: 'Are you planning to migrate the existing codebase?',
      isMine: false,
      time: '9:06 AM',
    );
    m.add(m5);

    final m6 = ChatMessage(
      id: '6',
      text: 'Yep, starting with the home screen first. Should be smooth.',
      isMine: true,
      time: '9:08 AM',
      replyTo: m5,
      reactions: {
        '❤️': ['them'],
      },
    );
    m.add(m6);

    final m7 = ChatMessage(
      id: '7',
      text: 'Let me know if you need help with the state management setup',
      isMine: false,
      time: '9:10 AM',
    );
    m.add(m7);

    final m8 = ChatMessage(
      id: '8',
      text: 'For sure! I was thinking of going with Riverpod this time',
      isMine: true,
      time: '9:12 AM',
      status: MessageStatus.delivered,
    );
    m.add(m8);

    final m9 = ChatMessage(
      id: '9',
      text: 'Great choice 👌 Riverpod 2.0 is much cleaner than Provider',
      isMine: false,
      time: '9:13 AM',
      reactions: {
        '👌': ['me'],
      },
    );
    m.add(m9);

    final m10 = ChatMessage(
      id: '10',
      text: 'Agreed. The ref.watch pattern makes rebuilds so predictable 😍',
      isMine: true,
      time: '9:15 AM',
      status: MessageStatus.sent,
    );
    m.add(m10);

    return m;
  }
}

const _urlPreview = UrlPreviewData(
  url: 'https://flutter.dev/multi-platform',
  title: 'Flutter – Build apps for any screen',
  description:
      'Flutter transforms the app development process. Build, test, and deploy beautiful mobile, web, desktop, and embedded apps from a single codebase.',
  siteName: 'flutter.dev',
);
