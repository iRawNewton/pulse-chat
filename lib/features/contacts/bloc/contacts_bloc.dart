import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pulse_chat/features/contacts/bloc/contacts_event.dart';
import 'package:pulse_chat/features/contacts/bloc/contacts_state.dart';
import 'package:pulse_chat/features/contacts/data/contact_list_type.dart';
import 'package:pulse_chat/features/contacts/data/contact_status.dart';
import 'package:pulse_chat/features/contacts/data/contacts_repository.dart';

@lazySingleton
class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  ContactsBloc(this._contactsRepository) : super(const ContactsInitial()) {
    on<FetchContactsEvent>(_onFetchContacts);
    on<LoadMoreContactsEvent>(_onLoadMoreContacts);
    on<AcceptContactRequestEvent>(_onAcceptContactRequest);
    on<RejectContactRequestEvent>(_onRejectContactRequest);
    on<CancelContactRequestEvent>(_onCancelContactRequest);
    on<BlockUserEvent>(_onBlockUser);
    on<UnblockUserEvent>(_onUnblockUser);
  }

  final ContactsRepository _contactsRepository;
  static const int _pageSize = 20;

  Future<void> _onFetchContacts(
    FetchContactsEvent event,
    Emitter<ContactsState> emit,
  ) async {
    final previousState = state;
    if (previousState is ContactsLoaded && !event.forceRefresh) {
      return;
    }

    if (previousState is ContactsLoaded) {
      emit(previousState.copyWith(
        isRefreshing: true,
        isLoadingMoreContacts: false,
        isLoadingMoreIncoming: false,
        isLoadingMoreSent: false,
      ));
    } else {
      emit(const ContactsLoading());
    }

    try {
      final pages = await Future.wait([
        _contactsRepository.getContactsPage(
          type: ContactListType.contacts,
          limit: _pageSize,
          offset: 0,
        ),
        _contactsRepository.getContactsPage(
          type: ContactListType.incoming,
          limit: _pageSize,
          offset: 0,
        ),
        _contactsRepository.getContactsPage(
          type: ContactListType.sent,
          limit: _pageSize,
          offset: 0,
        ),
      ]);

      emit(ContactsLoaded(
        contacts: pages[0].items,
        incoming: pages[1].items,
        sent: pages[2].items,
        contactsTotal: pages[0].total,
        incomingTotal: pages[1].total,
        sentTotal: pages[2].total,
        contactsHasMore: pages[0].hasMore,
        incomingHasMore: pages[1].hasMore,
        sentHasMore: pages[2].hasMore,
      ));
    } on Exception catch (e) {
      final error = e.toString().replaceAll('Exception: ', '');
      if (previousState is ContactsLoaded) {
        showToast(error);
        emit(previousState.copyWith(
          isRefreshing: false,
          isLoadingMoreContacts: false,
          isLoadingMoreIncoming: false,
          isLoadingMoreSent: false,
        ));
      } else {
        emit(ContactsFailure(error));
      }
    }
  }

  Future<void> _onLoadMoreContacts(
    LoadMoreContactsEvent event,
    Emitter<ContactsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ContactsLoaded ||
        !currentState.hasMoreFor(event.type) ||
        currentState.isLoadingMoreFor(event.type)) {
      return;
    }

    emit(currentState.copyWithLoadingMore(event.type, true));

    try {
      final page = await _contactsRepository.getContactsPage(
        type: event.type,
        limit: _pageSize,
        offset: _itemsFor(currentState, event.type).length,
      );

      final latestState = state;
      if (latestState is! ContactsLoaded) return;

      emit(_appendPage(latestState, event.type, page));
    } on Exception catch (e) {
      showToast(e.toString().replaceAll('Exception: ', ''));
      final latestState = state;
      if (latestState is ContactsLoaded) {
        emit(latestState.copyWithLoadingMore(event.type, false));
      }
    }
  }

  List<ContactUser> _itemsFor(ContactsLoaded state, ContactListType type) {
    return switch (type) {
      ContactListType.contacts => state.contacts,
      ContactListType.incoming => state.incoming,
      ContactListType.sent => state.sent,
    };
  }

  ContactsLoaded _appendPage(
    ContactsLoaded state,
    ContactListType type,
    ContactsPage page,
  ) {
    return switch (type) {
      ContactListType.contacts => state.copyWith(
          contacts: [...state.contacts, ...page.items],
          contactsTotal: page.total,
          contactsHasMore: page.hasMore,
          isLoadingMoreContacts: false,
        ),
      ContactListType.incoming => state.copyWith(
          incoming: [...state.incoming, ...page.items],
          incomingTotal: page.total,
          incomingHasMore: page.hasMore,
          isLoadingMoreIncoming: false,
        ),
      ContactListType.sent => state.copyWith(
          sent: [...state.sent, ...page.items],
          sentTotal: page.total,
          sentHasMore: page.hasMore,
          isLoadingMoreSent: false,
        ),
    };
  }

  Future<void> _onAcceptContactRequest(
    AcceptContactRequestEvent event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      await _contactsRepository.acceptContactRequest(event.user.uid);
      showToast('Accepted contact request from ${event.user.displayName}');
      add(const FetchContactsEvent(forceRefresh: true));
    } on Exception catch (e) {
      showToast(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _onRejectContactRequest(
    RejectContactRequestEvent event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      await _contactsRepository.rejectContactRequest(event.user.uid);
      showToast('Rejected contact request from ${event.user.displayName}');
      add(const FetchContactsEvent(forceRefresh: true));
    } on Exception catch (e) {
      showToast(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _onCancelContactRequest(
    CancelContactRequestEvent event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      await _contactsRepository.rejectContactRequest(event.user.uid);
      showToast('Cancelled contact request to ${event.user.displayName}');
      add(const FetchContactsEvent(forceRefresh: true));
    } on Exception catch (e) {
      showToast(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _onBlockUser(
    BlockUserEvent event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      await _contactsRepository.blockUser(event.user.uid);
      showToast('${event.user.displayName} blocked');
      add(const FetchContactsEvent(forceRefresh: true));
    } on Exception catch (e) {
      showToast(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _onUnblockUser(
    UnblockUserEvent event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      await _contactsRepository.unblockUser(event.user.uid);
      showToast('${event.user.displayName} unblocked');
      add(const FetchContactsEvent(forceRefresh: true));
    } on Exception catch (e) {
      showToast(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
