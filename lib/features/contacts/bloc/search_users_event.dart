import 'package:flutter/foundation.dart';
import 'package:pulse_chat/features/contacts/data/contact_status.dart';

@immutable
abstract class SearchUsersEvent {
  const SearchUsersEvent();
}

class SearchQueryChanged extends SearchUsersEvent {
  const SearchQueryChanged(this.query);

  final String query;
}

class SendRequest extends SearchUsersEvent {
  const SendRequest(this.user);

  final ContactUser user;
}

class CancelRequest extends SearchUsersEvent {
  const CancelRequest(this.user);

  final ContactUser user;
}

class UnblockUserInSearch extends SearchUsersEvent {
  const UnblockUserInSearch(this.user);

  final ContactUser user;
}
