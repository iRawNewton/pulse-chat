import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pulse_chat/features/contacts/data/contact_list_type.dart';
import 'package:pulse_chat/features/contacts/data/contact_status.dart';
import 'package:pulse_chat/features/contacts/data/contacts_repository.dart';
import 'package:pulse_chat/features/profile/bloc/profile_event.dart';
import 'package:pulse_chat/features/profile/bloc/profile_state.dart';
import 'package:pulse_chat/features/profile/data/profile_repository.dart';
import 'package:pulse_chat/features/profile/profile_models.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._profileRepository, this._contactsRepository) : super(const ProfileInitial()) {
    on<FetchProfileEvent>(_onFetchProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ToggleOnlineStatusEvent>(_onToggleOnlineStatus);
    on<SendContactRequestProfileEvent>(_onSendContactRequest);
    on<AcceptContactRequestProfileEvent>(_onAcceptContactRequest);
    on<BlockUserProfileEvent>(_onBlockUser);
    on<UnblockUserProfileEvent>(_onUnblockUser);
  }

  final ProfileRepository _profileRepository;
  final ContactsRepository _contactsRepository;
  static const int _relationshipPageSize = 100;

  Future<void> _onFetchProfile(
    FetchProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = await _profileRepository.getProfile(event.uid);
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      final isMe = user.id == currentUid;

      var connectionStatus = ConnectionStatus.none;

      if (!isMe) {
        final contactStatus = await _getContactStatus(user.id);

        switch (contactStatus) {
          case ContactStatus.friends:
            connectionStatus = ConnectionStatus.connected;
          case ContactStatus.pendingSent:
            connectionStatus = ConnectionStatus.requestSent;
          case ContactStatus.pendingReceived:
            connectionStatus = ConnectionStatus.requestReceived;
          case ContactStatus.blockedByMe:
          case ContactStatus.none:
            connectionStatus = ConnectionStatus.none;
        }
      }

      emit(ProfileLoaded(
        user: user,
        isMe: isMe,
        connectionStatus: connectionStatus,
      ));
    } on Exception catch (e) {
      emit(ProfileFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<ContactStatus> _getContactStatus(String uid) async {
    for (final type in ContactListType.values) {
      var offset = 0;
      while (true) {
        final page = await _contactsRepository.getContactsPage(
          type: type,
          limit: _relationshipPageSize,
          offset: offset,
        );

        for (final contact in page.items) {
          if (contact.uid == uid) return contact.status;
        }

        if (!page.hasMore || page.items.isEmpty) break;
        offset += page.items.length;
      }
    }

    return ContactStatus.none;
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    emit(const ProfileSaving());
    try {
      await _profileRepository.updateProfile(event.user);
      showToast('Profile updated successfully.');
      
      // Emit success state then trigger a reload
      emit(ProfileSaveSuccess(event.user));
      add(FetchProfileEvent(event.user.id));
    } on Exception catch (e) {
      showToast(e.toString().replaceAll('Exception: ', ''));
      if (currentState is ProfileLoaded) {
        emit(currentState);
      } else {
        emit(ProfileFailure(e.toString()));
      }
    }
  }

  Future<void> _onToggleOnlineStatus(
    ToggleOnlineStatusEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    try {
      final updatedUser = currentState.user.copyWith(onlineStatus: event.status);
      
      // Update locally first
      emit(ProfileLoaded(
        user: updatedUser,
        isMe: currentState.isMe,
        connectionStatus: currentState.connectionStatus,
      ));

      // Persist online presence in Firestore directly
      await _profileRepository.updateProfile(updatedUser);
      
      showToast('Status set to ${event.status.name}');
    } on Exception catch (e) {
      showToast(e.toString().replaceAll('Exception: ', ''));
      emit(currentState);
    }
  }

  Future<void> _onSendContactRequest(
    SendContactRequestProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    try {
      await _contactsRepository.sendContactRequest(currentState.user.id);
      showToast('Contact request sent');
      add(FetchProfileEvent(currentState.user.id));
    } on Exception catch (e) {
      showToast(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _onAcceptContactRequest(
    AcceptContactRequestProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    try {
      await _contactsRepository.acceptContactRequest(currentState.user.id);
      showToast('Accepted contact request');
      add(FetchProfileEvent(currentState.user.id));
    } on Exception catch (e) {
      showToast(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _onBlockUser(
    BlockUserProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    try {
      await _contactsRepository.blockUser(currentState.user.id);
      showToast('User blocked');
      add(FetchProfileEvent(currentState.user.id));
    } on Exception catch (e) {
      showToast(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _onUnblockUser(
    UnblockUserProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    try {
      await _contactsRepository.unblockUser(currentState.user.id);
      showToast('User unblocked');
      add(FetchProfileEvent(currentState.user.id));
    } on Exception catch (e) {
      showToast(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
