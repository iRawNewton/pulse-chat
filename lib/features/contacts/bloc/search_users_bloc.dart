import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pulse_chat/features/contacts/bloc/search_users_event.dart';
import 'package:pulse_chat/features/contacts/bloc/search_users_state.dart';
import 'package:pulse_chat/features/contacts/data/contact_status.dart';
import 'package:pulse_chat/features/contacts/data/contacts_repository.dart';

@injectable
class SearchUsersBloc extends Bloc<SearchUsersEvent, SearchUsersState> {
  SearchUsersBloc(this._contactsRepository) : super(const SearchIdle()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SendRequest>(_onSendRequest);
    on<CancelRequest>(_onCancelRequest);
    on<UnblockUserInSearch>(_onUnblockUser);
  }

  final ContactsRepository _contactsRepository;

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchUsersState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const SearchIdle());
      return;
    }

    emit(const SearchLoading());
    try {
      final results = await _contactsRepository.searchUsers(query);

      if (results.isEmpty) {
        emit(const SearchEmpty());
        return;
      }

      emit(SearchSuccess(results));
    } on Exception catch (e) {
      emit(SearchFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSendRequest(
    SendRequest event,
    Emitter<SearchUsersState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SearchSuccess) return;

    // Optimistic UI update
    final updatedResults = currentState.results.map((u) {
      return u.uid == event.user.uid ? u.copyWith(status: ContactStatus.pendingSent) : u;
    }).toList();
    emit(SearchSuccess(updatedResults));

    try {
      await _contactsRepository.sendContactRequest(event.user.uid);
      showToast('Contact request sent to ${event.user.displayName}');
    } on Exception catch (e) {
      showToast(e.toString().replaceAll('Exception: ', ''));
      // Revert back to original results on error
      emit(SearchSuccess(currentState.results));
    }
  }

  Future<void> _onCancelRequest(
    CancelRequest event,
    Emitter<SearchUsersState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SearchSuccess) return;

    // Optimistic UI update
    final updatedResults = currentState.results.map((u) {
      return u.uid == event.user.uid ? u.copyWith(status: ContactStatus.none) : u;
    }).toList();
    emit(SearchSuccess(updatedResults));

    try {
      await _contactsRepository.rejectContactRequest(event.user.uid);
      showToast('Cancelled contact request to ${event.user.displayName}');
    } on Exception catch (e) {
      showToast(e.toString().replaceAll('Exception: ', ''));
      // Revert back to original results on error
      emit(SearchSuccess(currentState.results));
    }
  }

  Future<void> _onUnblockUser(
    UnblockUserInSearch event,
    Emitter<SearchUsersState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SearchSuccess) return;

    // Optimistic UI update
    final updatedResults = currentState.results.map((u) {
      return u.uid == event.user.uid ? u.copyWith(status: ContactStatus.none) : u;
    }).toList();
    emit(SearchSuccess(updatedResults));

    try {
      await _contactsRepository.unblockUser(event.user.uid);
      showToast('Unblocked ${event.user.displayName}');
    } on Exception catch (e) {
      showToast(e.toString().replaceAll('Exception: ', ''));
      // Revert back to original results on error
      emit(SearchSuccess(currentState.results));
    }
  }
}
