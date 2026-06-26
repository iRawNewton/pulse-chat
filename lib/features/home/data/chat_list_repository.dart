import 'package:injectable/injectable.dart';
import 'package:pulse_chat/features/contacts/data/contact_list_type.dart';
import 'package:pulse_chat/features/contacts/data/contacts_repository.dart';
import 'package:pulse_chat/features/home/data/chat_item_model.dart';

@lazySingleton
class ChatListRepository {
  ChatListRepository(this._contactsRepository);

  final ContactsRepository _contactsRepository;
  static const int _pageSize = 100;

  Future<List<ChatItem>> getChats() async {
    final chats = <ChatItem>[];
    var offset = 0;

    while (true) {
      final page = await _contactsRepository.getContactsPage(
        type: ContactListType.contacts,
        limit: _pageSize,
        offset: offset,
      );

      chats.addAll(
        page.items.map(
          (contact) => ChatItem(
            id: contact.uid,
            name: contact.displayName,
            lastMessage: 'Tap to start chatting',
            time: '',
            type: ChatType.individual,
            avatarUrl: contact.avatarUrl,
            isOnline: contact.isOnline,
          ),
        ),
      );

      if (!page.hasMore || page.items.isEmpty) break;
      offset += page.items.length;
    }

    return chats;
  }
}
