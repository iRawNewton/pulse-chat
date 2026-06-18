// ─────────────────────────────────────────────
// Sample Data
// ─────────────────────────────────────────────

import 'package:pulse_chat/features/home/data/chat_item_model.dart';

class ChatData {
  final List<ChatItem> sampleChats = [
    const ChatItem(
      id: '1',
      name: 'Aanya Sharma',
      lastMessage: 'Sure, see you at 7 then! 😊',
      time: '9:41 AM',
      type: ChatType.individual,
      unreadCount: 2,
      isPinned: true,
      isOnline: true,
    ),
    const ChatItem(
      id: '2',
      name: 'Dev Squad 🚀',
      lastMessage: 'Rohan: pushed the fix, CI is green now',
      time: '9:15 AM',
      type: ChatType.group,
      unreadCount: 14,
      isPinned: true,
      members: ['Rohan', 'Priya', 'You', '+4'],
      senderName: 'Rohan',
    ),
    const ChatItem(
      id: '3',
      name: 'Kabir Mehta',
      lastMessage: "Can you review my PR when you're free?",
      time: 'Yesterday',
      type: ChatType.individual,
      isMuted: true,
    ),
    const ChatItem(
      id: '4',
      name: 'Family 🏠',
      lastMessage: 'Mom: Did you eat dinner?',
      time: 'Yesterday',
      type: ChatType.group,
      unreadCount: 5,
      members: ['Mom', 'Dad', 'Sister'],
      senderName: 'Mom',
    ),
    const ChatItem(
      id: '5',
      name: 'Priya Nair',
      lastMessage: 'The design looks amazing! 🎨',
      time: 'Mon',
      type: ChatType.individual,
      isOnline: true,
    ),
    const ChatItem(
      id: '6',
      name: 'Product Team',
      lastMessage: 'Sneha: Sprint planning at 2pm',
      time: 'Mon',
      type: ChatType.group,
      unreadCount: 3,
      isMuted: true,
      members: ['Sneha', 'Vikram', 'You', '+6'],
      senderName: 'Sneha',
    ),
    const ChatItem(
      id: '7',
      name: 'Riya Desai',
      lastMessage: 'Haha yes exactly what I was thinking 😂',
      time: 'Sun',
      type: ChatType.individual,
    ),
    const ChatItem(
      id: '8',
      name: 'College Gang 🎓',
      lastMessage: 'Arjun: Reunion this weekend?',
      time: 'Sun',
      type: ChatType.group,
      unreadCount: 28,
      members: ['Arjun', 'Meera', 'Dev', '+8'],
      senderName: 'Arjun',
    ),
    const ChatItem(
      id: '9',
      name: 'Vikram Rao',
      lastMessage: "Let's catch up soon!",
      time: 'Sat',
      type: ChatType.individual,
      isMuted: true,
    ),
    const ChatItem(
      id: '10',
      name: 'Neha Kulkarni',
      lastMessage: 'Thanks for the help 🙏',
      time: 'Fri',
      type: ChatType.individual,
      isOnline: true,
    ),
  ];
}
