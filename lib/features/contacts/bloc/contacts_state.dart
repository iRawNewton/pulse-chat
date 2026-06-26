import 'package:flutter/foundation.dart';
import 'package:pulse_chat/features/contacts/data/contact_list_type.dart';
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
    required this.contactsTotal,
    required this.incomingTotal,
    required this.sentTotal,
    required this.contactsHasMore,
    required this.incomingHasMore,
    required this.sentHasMore,
    this.isLoadingMoreContacts = false,
    this.isLoadingMoreIncoming = false,
    this.isLoadingMoreSent = false,
    this.isRefreshing = false,
  });

  final List<ContactUser> contacts;
  final List<ContactUser> incoming;
  final List<ContactUser> sent;
  final int contactsTotal;
  final int incomingTotal;
  final int sentTotal;
  final bool contactsHasMore;
  final bool incomingHasMore;
  final bool sentHasMore;
  final bool isLoadingMoreContacts;
  final bool isLoadingMoreIncoming;
  final bool isLoadingMoreSent;
  final bool isRefreshing;

  ContactsLoaded copyWith({
    List<ContactUser>? contacts,
    List<ContactUser>? incoming,
    List<ContactUser>? sent,
    int? contactsTotal,
    int? incomingTotal,
    int? sentTotal,
    bool? contactsHasMore,
    bool? incomingHasMore,
    bool? sentHasMore,
    bool? isLoadingMoreContacts,
    bool? isLoadingMoreIncoming,
    bool? isLoadingMoreSent,
    bool? isRefreshing,
  }) {
    return ContactsLoaded(
      contacts: contacts ?? this.contacts,
      incoming: incoming ?? this.incoming,
      sent: sent ?? this.sent,
      contactsTotal: contactsTotal ?? this.contactsTotal,
      incomingTotal: incomingTotal ?? this.incomingTotal,
      sentTotal: sentTotal ?? this.sentTotal,
      contactsHasMore: contactsHasMore ?? this.contactsHasMore,
      incomingHasMore: incomingHasMore ?? this.incomingHasMore,
      sentHasMore: sentHasMore ?? this.sentHasMore,
      isLoadingMoreContacts: isLoadingMoreContacts ?? this.isLoadingMoreContacts,
      isLoadingMoreIncoming: isLoadingMoreIncoming ?? this.isLoadingMoreIncoming,
      isLoadingMoreSent: isLoadingMoreSent ?? this.isLoadingMoreSent,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  bool hasMoreFor(ContactListType type) {
    return switch (type) {
      ContactListType.contacts => contactsHasMore,
      ContactListType.incoming => incomingHasMore,
      ContactListType.sent => sentHasMore,
    };
  }

  bool isLoadingMoreFor(ContactListType type) {
    return switch (type) {
      ContactListType.contacts => isLoadingMoreContacts,
      ContactListType.incoming => isLoadingMoreIncoming,
      ContactListType.sent => isLoadingMoreSent,
    };
  }

  ContactsLoaded copyWithLoadingMore(ContactListType type, bool value) {
    return switch (type) {
      ContactListType.contacts => copyWith(isLoadingMoreContacts: value),
      ContactListType.incoming => copyWith(isLoadingMoreIncoming: value),
      ContactListType.sent => copyWith(isLoadingMoreSent: value),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactsLoaded &&
          runtimeType == other.runtimeType &&
          listEquals(contacts, other.contacts) &&
          listEquals(incoming, other.incoming) &&
          listEquals(sent, other.sent) &&
          contactsTotal == other.contactsTotal &&
          incomingTotal == other.incomingTotal &&
          sentTotal == other.sentTotal &&
          contactsHasMore == other.contactsHasMore &&
          incomingHasMore == other.incomingHasMore &&
          sentHasMore == other.sentHasMore &&
          isLoadingMoreContacts == other.isLoadingMoreContacts &&
          isLoadingMoreIncoming == other.isLoadingMoreIncoming &&
          isLoadingMoreSent == other.isLoadingMoreSent &&
          isRefreshing == other.isRefreshing;

  @override
  int get hashCode =>
      contacts.hashCode ^
      incoming.hashCode ^
      sent.hashCode ^
      contactsTotal.hashCode ^
      incomingTotal.hashCode ^
      sentTotal.hashCode ^
      contactsHasMore.hashCode ^
      incomingHasMore.hashCode ^
      sentHasMore.hashCode ^
      isLoadingMoreContacts.hashCode ^
      isLoadingMoreIncoming.hashCode ^
      isLoadingMoreSent.hashCode ^
      isRefreshing.hashCode;
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
