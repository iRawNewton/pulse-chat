import 'package:flutter/foundation.dart';
import 'package:pulse_chat/features/contacts/data/contact_status.dart';

@immutable
abstract class ContactsEvent {
  const ContactsEvent();
}

class FetchContactsEvent extends ContactsEvent {
  const FetchContactsEvent();
}

class AcceptContactRequestEvent extends ContactsEvent {
  const AcceptContactRequestEvent(this.user);

  final ContactUser user;
}

class RejectContactRequestEvent extends ContactsEvent {
  const RejectContactRequestEvent(this.user);

  final ContactUser user;
}

class CancelContactRequestEvent extends ContactsEvent {
  const CancelContactRequestEvent(this.user);

  final ContactUser user;
}

class BlockUserEvent extends ContactsEvent {
  const BlockUserEvent(this.user);

  final ContactUser user;
}

class UnblockUserEvent extends ContactsEvent {
  const UnblockUserEvent(this.user);

  final ContactUser user;
}
