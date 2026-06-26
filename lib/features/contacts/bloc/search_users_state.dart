import 'package:flutter/foundation.dart';
import 'package:pulse_chat/features/contacts/data/contact_status.dart';

@immutable
abstract class SearchUsersState {
  const SearchUsersState();
}

class SearchIdle extends SearchUsersState {
  const SearchIdle();
}

class SearchLoading extends SearchUsersState {
  const SearchLoading();
}

class SearchSuccess extends SearchUsersState {
  const SearchSuccess(this.results);

  final List<ContactUser> results;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchSuccess &&
          runtimeType == other.runtimeType &&
          listEquals(results, other.results);

  @override
  int get hashCode => results.hashCode;
}

class SearchEmpty extends SearchUsersState {
  const SearchEmpty();
}

class SearchFailure extends SearchUsersState {
  const SearchFailure(this.error);

  final String error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchFailure &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;
}
