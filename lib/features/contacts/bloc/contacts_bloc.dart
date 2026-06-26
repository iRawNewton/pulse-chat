import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pulse_chat/features/contacts/bloc/contacts_event.dart';
import 'package:pulse_chat/features/contacts/bloc/contacts_state.dart';
import 'package:pulse_chat/features/contacts/data/contact_status.dart';
import 'package:pulse_chat/features/contacts/data/contacts_repository.dart';

@injectable
class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  ContactsBloc(this._contactsRepository) : super(const ContactsInitial()) {
    on<FetchContactsEvent>(_onFetchContacts);
    on<AcceptContactRequestEvent>(_onAcceptContactRequest);
    on<RejectContactRequestEvent>(_onRejectContactRequest);
    on<CancelContactRequestEvent>(_onCancelContactRequest);
    on<BlockUserEvent>(_onBlockUser);
    on<UnblockUserEvent>(_onUnblockUser);
  }

  final ContactsRepository _contactsRepository;

  Future<void> _onFetchContacts(
    FetchContactsEvent event,
    Emitter<ContactsState> emit,
  ) async {
    emit(const ContactsLoading());
    try {
      final allContacts = await _contactsRepository.getContacts();

      final contacts = allContacts
          .where((u) => u.status == ContactStatus.friends || u.status == ContactStatus.blockedByMe)
          .toList();
      final incoming = allContacts
          .where((u) => u.status == ContactStatus.pendingReceived)
          .toList();
      final sent = allContacts
          .where((u) => u.status == ContactStatus.pendingSent)
          .toList();

      emit(ContactsLoaded(
        contacts: contacts,
        incoming: incoming,
        sent: sent,
      ));
    } on Exception catch (e) {
      emit(ContactsFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAcceptContactRequest(
    AcceptContactRequestEvent event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      await _contactsRepository.acceptContactRequest(event.user.uid);
      showToast('Accepted contact request from ${event.user.displayName}');
      add(const FetchContactsEvent());
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
      add(const FetchContactsEvent());
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
      add(const FetchContactsEvent());
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
      add(const FetchContactsEvent());
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
      add(const FetchContactsEvent());
    } on Exception catch (e) {
      showToast(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
