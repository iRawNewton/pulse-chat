import 'package:flutter/foundation.dart';
import 'package:pulse_chat/features/contacts/data/contact_status.dart';

@immutable
abstract class ContactsState {
  const ContactsState();
}

class ContactsInitial extends ContactsState {
  const ContactsInitial();
}

class ContactsLoading extends ContactsState {
  const ContactsLoading();
}

class ContactsLoaded extends ContactsState {
  const ContactsLoaded({
    required this.contacts,
    required this.incoming,
    required this.sent,
  });

  final List<ContactUser> contacts;
  final List<ContactUser> incoming;
  final List<ContactUser> sent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactsLoaded &&
          runtimeType == other.runtimeType &&
          listEquals(contacts, other.contacts) &&
          listEquals(incoming, other.incoming) &&
          listEquals(sent, other.sent);

  @override
  int get hashCode => contacts.hashCode ^ incoming.hashCode ^ sent.hashCode;
}

class ContactsFailure extends ContactsState {
  const ContactsFailure(this.error);
  final String error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactsFailure &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;
}
