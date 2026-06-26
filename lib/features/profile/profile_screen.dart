import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/profile/connection_action_button.dart';
import 'package:pulse_chat/features/profile/profile_avatar.dart';
import 'package:pulse_chat/features/profile/profile_info_tile.dart';
import 'package:pulse_chat/features/profile/profile_models.dart';
import 'package:pulse_chat/features/profile/social_links_row.dart';

/// Unified profile screen for both "my profile" and "visitor viewing
/// someone else" — controlled entirely by [isMe].
///
/// ---- BLoC INTEGRATION NOTES ----
/// This widget is intentionally presentation-only. Wire it up by:
///   1. Wrapping the call site in a BlocProvider<ProfileCubit> (or
///      BlocBuilder) that emits a ProfileState{ user, connectionStatus,
///      isLoading } and pass `user`/`connectionStatus` down as params.
///   2. Replacing the callbacks below (onEditProfile, onSendRequest,
///      onMessage, onBlock, onReport, onToggleOnlineStatus, onOpenLink)
///      with calls into the cubit, e.g.
///        onSendRequest: () => context.read<ProfileCubit>().sendRequest(user.id)
///   3. onOpenLink should go through url_launcher in the integration
///      layer — left out here to keep this package-free.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.user,
    required this.isMe,
    this.connectionStatus = ConnectionStatus.none,
    this.onEditProfile,
    this.onSendRequest,
    this.onMessage,
    this.onBlock,
    this.onReport,
    this.onToggleOnlineStatus,
    this.onOpenLink,
    super.key,
  });

  /// The profile being displayed (could be "my" user or a visited user).
  final ProfileUserEntity user;

  /// True when the signed-in user is viewing their own profile.
  /// Flips the app bar actions, bottom CTA, and online-status control.
  final bool isMe;

  /// Only relevant when [isMe] is false — drives the bottom CTA.
  final ConnectionStatus connectionStatus;

  final VoidCallback? onEditProfile;
  final VoidCallback? onSendRequest;
  final VoidCallback? onMessage;
  final VoidCallback? onBlock;
  final VoidCallback? onReport;

  /// Called when the owner taps their own online-status dot to change it.
  final ValueChanged<OnlineStatus>? onToggleOnlineStatus;

  final ValueChanged<String>? onOpenLink;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: colors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            expandedHeight: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp, color: colors.textPrimary),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: Text(
              isMe ? 'My Profile' : user.name,
              style: AppTextStyles.w600.copyWith(fontSize: 17.sp, color: colors.textPrimary),
            ),
            actions: [
              if (isMe)
                IconButton(
                  icon: Icon(Icons.edit_rounded, size: 21.sp, color: colors.primary),
                  onPressed: onEditProfile,
                )
              else
                _VisitorMenuButton(onBlock: onBlock, onReport: onReport),
              SizedBox(width: 4.w),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
              child: Column(
                children: [
                  _HeaderSection(
                    user: user,
                    isMe: isMe,
                    onToggleOnlineStatus: onToggleOnlineStatus,
                  ),
                  SizedBox(height: 28.h),
                  if (user.bio != null && user.bio!.trim().isNotEmpty) ...[
                    _BioCard(bio: user.bio!),
                    SizedBox(height: 20.h),
                  ],
                  _DetailsCard(user: user),
                  if (user.socialLinks.isNotEmpty || user.customUrl != null) ...[
                    SizedBox(height: 20.h),
                    _SocialCard(user: user, onOpenLink: onOpenLink ?? (_) {}),
                  ],
                  SizedBox(height: 28.h),
                  if (!isMe)
                    ConnectionActionButton(
                      status: connectionStatus,
                      onPrimaryTap: () {
                        switch (connectionStatus) {
                          case ConnectionStatus.none:
                            onSendRequest?.call();
                          case ConnectionStatus.connected:
                            onMessage?.call();
                          case ConnectionStatus.requestReceived:
                            onSendRequest?.call(); // treat as "accept" entrypoint
                          case ConnectionStatus.requestSent:
                            break; // disabled state, nothing to do
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.user, required this.isMe, this.onToggleOnlineStatus});
  final ProfileUserEntity user;
  final bool isMe;
  final ValueChanged<OnlineStatus>? onToggleOnlineStatus;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Column(
      children: [
        GestureDetector(
          onTap: isMe ? () => _showStatusPicker(context, colors) : null,
          child: ProfileAvatar(
            name: user.name,
            initials: user.initials,
            photoUrl: user.photoUrl,
            size: 108,
            showOnlineDot: true,
            onlineStatus: user.onlineStatus,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          user.name,
          style: AppTextStyles.w700.copyWith(fontSize: 22.sp, color: colors.textPrimary, letterSpacing: -0.3),
        ),
        SizedBox(height: 4.h),
        Text(
          '@${user.username}',
          style: AppTextStyles.w500.copyWith(fontSize: 14.sp, color: colors.textSecondary),
        ),
        SizedBox(height: 10.h),
        _StatusPill(status: user.onlineStatus, isMe: isMe, onTap: isMe ? () => _showStatusPicker(context, colors) : null),
      ],
    );
  }

  Future<void> _showStatusPicker(BuildContext context, AppColors colors) async {
    if (!isMe || onToggleOnlineStatus == null) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _OnlineStatusSheet(
        current: user.onlineStatus,
        onSelect: (status) {
          Navigator.of(sheetContext).pop();
          onToggleOnlineStatus?.call(status);
        },
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.isMe, this.onTap});
  final OnlineStatus status;
  final bool isMe;
  final VoidCallback? onTap;

  String get _label {
    switch (status) {
      case OnlineStatus.online:
        return 'Online';
      case OnlineStatus.away:
        return 'Away';
      case OnlineStatus.offline:
        return 'Offline';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final dotColor = status == OnlineStatus.online
        ? colors.success
        : status == OnlineStatus.away
        ? colors.warning
        : colors.textTertiary;

    final pill = Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.w,
            height: 7.w,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
          SizedBox(width: 6.w),
          Text(
            _label,
            style: AppTextStyles.w500.copyWith(fontSize: 12.sp, color: colors.textSecondary),
          ),
          if (isMe) ...[
            SizedBox(width: 4.w),
            Icon(Icons.keyboard_arrow_down_rounded, size: 14.sp, color: colors.textTertiary),
          ],
        ],
      ),
    );

    if (!isMe || onTap == null) return pill;
    return InkWell(borderRadius: BorderRadius.circular(20.r), onTap: onTap, child: pill);
  }
}

class _OnlineStatusSheet extends StatelessWidget {
  const _OnlineStatusSheet({required this.current, required this.onSelect});
  final OnlineStatus current;
  final ValueChanged<OnlineStatus> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 18.h),
              decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(4.r)),
            ),
          ),
          Text(
            'Set your status',
            style: AppTextStyles.w700.copyWith(fontSize: 17.sp, color: colors.textPrimary),
          ),
          SizedBox(height: 16.h),
          for (final status in OnlineStatus.values) _statusOption(context, colors, status),
        ],
      ),
    );
  }

  Widget _statusOption(BuildContext context, AppColors colors, OnlineStatus status) {
    final selected = status == current;
    final label = switch (status) {
      OnlineStatus.online => 'Online',
      OnlineStatus.away => 'Away',
      OnlineStatus.offline => 'Offline',
    };
    final dotColor = switch (status) {
      OnlineStatus.online => colors.success,
      OnlineStatus.away => colors.warning,
      OnlineStatus.offline => colors.textTertiary,
    };

    return InkWell(
      onTap: () => onSelect(status),
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: selected ? colors.primaryMuted : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: AppTextStyles.w500.copyWith(fontSize: 15.sp, color: colors.textPrimary),
            ),
            const Spacer(),
            if (selected) Icon(Icons.check_rounded, size: 18.sp, color: colors.primary),
          ],
        ),
      ),
    );
  }
}

class _BioCard extends StatelessWidget {
  const _BioCard({required this.bio});
  final String bio;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        bio,
        style: AppTextStyles.w400.copyWith(fontSize: 14.sp, color: colors.textPrimary, height: 1.5),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.user});
  final ProfileUserEntity user;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    final tiles = <Widget>[
      ProfileInfoTile(icon: Icons.email_rounded, label: 'EMAIL', value: user.email),
      if (user.mobile != null && user.mobile!.isNotEmpty) ProfileInfoTile(icon: Icons.phone_rounded, label: 'MOBILE', value: user.mobile!),
      ProfileInfoTile(icon: Icons.alternate_email_rounded, label: 'USERNAME', value: user.username, isLast: true),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: tiles),
    );
  }
}

class _SocialCard extends StatelessWidget {
  const _SocialCard({required this.user, required this.onOpenLink});
  final ProfileUserEntity user;
  final ValueChanged<String> onOpenLink;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LINKS',
            style: AppTextStyles.w500.copyWith(fontSize: 11.sp, color: colors.textTertiary, letterSpacing: 0.3),
          ),
          SizedBox(height: 12.h),
          SocialLinksRow(links: user.socialLinks, customUrl: user.customUrl, onTap: onOpenLink),
        ],
      ),
    );
  }
}

class _VisitorMenuButton extends StatelessWidget {
  const _VisitorMenuButton({this.onBlock, this.onReport});
  final VoidCallback? onBlock;
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: colors.textPrimary, size: 22.sp),
      color: colors.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 6,
      onSelected: (value) {
        if (value == 'block') onBlock?.call();
        if (value == 'report') onReport?.call();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'block',
          child: Row(
            children: [
              Icon(Icons.block_rounded, size: 18.sp, color: colors.textPrimary),
              SizedBox(width: 10.w),
              Text(
                'Block User',
                style: AppTextStyles.w500.copyWith(fontSize: 14.sp, color: colors.textPrimary),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              Icon(Icons.flag_rounded, size: 18.sp, color: colors.error),
              SizedBox(width: 10.w),
              Text(
                'Report User',
                style: AppTextStyles.w500.copyWith(fontSize: 14.sp, color: colors.error),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
