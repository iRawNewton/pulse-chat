import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pulse_chat/config/routes/app_routes.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/home/data/chat_item_model.dart';
import 'package:pulse_chat/features/profile/bloc/profile_bloc.dart';
import 'package:pulse_chat/features/profile/bloc/profile_event.dart';
import 'package:pulse_chat/features/profile/bloc/profile_state.dart';
import 'package:pulse_chat/features/profile/edit_profile_screen.dart';
import 'package:pulse_chat/features/profile/profile_models.dart';
import 'package:pulse_chat/features/profile/profile_screen.dart';

class ProfileScreenWrapper extends StatelessWidget {
  const ProfileScreenWrapper({required this.uid, super.key});
  final String uid;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSaveSuccess) {
          showToast('Profile saved successfully.');
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial || state is ProfileSaving) {
          return Scaffold(
            backgroundColor: colors.background,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
            ),
          );
        }

        if (state is ProfileFailure) {
          return Scaffold(
            backgroundColor: colors.background,
            appBar: AppBar(
              backgroundColor: colors.background,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp, color: colors.textPrimary),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, color: colors.error, size: 48.sp),
                    SizedBox(height: 16.h),
                    Text(
                      state.error,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.w500.copyWith(fontSize: 14.sp, color: colors.textPrimary),
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton(
                      onPressed: () => context.read<ProfileBloc>().add(FetchProfileEvent(uid)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      ),
                      child: Text(
                        'Retry',
                        style: AppTextStyles.w600.copyWith(fontSize: 14.sp, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is ProfileLoaded) {
          return ProfileScreen(
            user: state.user,
            isMe: state.isMe,
            connectionStatus: state.connectionStatus,
            onEditProfile: () {
              unawaited(
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider.value(
                      value: context.read<ProfileBloc>(),
                      child: EditProfileScreen(
                        user: state.user,
                        onSave: (updated) {
                          context.read<ProfileBloc>().add(UpdateProfileEvent(updated));
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
            onToggleOnlineStatus: (status) {
              context.read<ProfileBloc>().add(ToggleOnlineStatusEvent(status));
            },
            onSendRequest: () {
              if (state.connectionStatus == ConnectionStatus.requestReceived) {
                context.read<ProfileBloc>().add(const AcceptContactRequestProfileEvent());
              } else {
                context.read<ProfileBloc>().add(const SendContactRequestProfileEvent());
              }
            },
            onMessage: () {
              final chatItem = ChatItem(
                id: state.user.id,
                name: state.user.name,
                lastMessage: '',
                time: '',
                type: ChatType.individual,
                avatarUrl: state.user.photoUrl,
                isOnline: state.user.onlineStatus == OnlineStatus.online,
              );
              unawaited(context.push(AppRoutes.chatScreen, extra: chatItem));
            },
            onBlock: () {
              context.read<ProfileBloc>().add(const BlockUserProfileEvent());
            },
            onReport: () {
              showToast('Report submitted for ${state.user.name}');
            },
            onOpenLink: (url) {
              showToast('Link: $url');
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
