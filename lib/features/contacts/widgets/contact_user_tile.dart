import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/contacts/data/contact_status.dart';
import 'package:pulse_chat/features/contacts/widgets/contact_action_button.dart';
import 'package:pulse_chat/features/contacts/widgets/pulse_avatar.dart';

/// A single user row: avatar, name/@username, a status-aware subtitle line,
/// and the morphing action button cluster. Used in search results, the
/// contacts list, and both request tabs — passing different [trailing]
/// builders and subtitle text keeps one row widget instead of four.
class ContactUserTile extends StatelessWidget {
  const ContactUserTile({
    super.key,
    required this.user,
    this.subtitleOverride,
    this.onTap,
    this.onSendRequest,
    this.onCancelRequest,
    this.onAccept,
    this.onReject,
    this.onMessage,
    this.onUnblock,
    this.onLongPress,
  });

  final ContactUser user;
  final String? subtitleOverride;
  final VoidCallback? onTap;
  final VoidCallback? onSendRequest;
  final VoidCallback? onCancelRequest;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onMessage;
  final VoidCallback? onUnblock;
  final VoidCallback? onLongPress;

  String _defaultSubtitle() {
    if (user.status == ContactStatus.pendingReceived) return 'Wants to connect with you';
    if (user.status == ContactStatus.pendingSent) return 'Request sent';
    if (user.isOnline) return 'Online';
    if (user.mutualContactsCount > 0) {
      return '${user.mutualContactsCount} mutual contact${user.mutualContactsCount == 1 ? '' : 's'}';
    }
    return '@${user.username}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final subtitle = subtitleOverride ?? _defaultSubtitle();
    final showOnlineDot = user.isOnline && user.status != ContactStatus.blockedByMe;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            children: [
              PulseAvatar(
                name: user.displayName,
                avatarUrl: user.avatarUrl,
                seed: user.uid,
                isOnline: showOnlineDot,
                size: 52,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.displayName,
                      style: AppTextStyles.w600.copyWith(fontSize: 15.sp, color: colors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.w400.copyWith(
                        fontSize: 12.5.sp,
                        color: user.status == ContactStatus.pendingReceived
                            ? colors.primary
                            : colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              ContactActionButton(
                status: user.status,
                onSendRequest: onSendRequest,
                onCancelRequest: onCancelRequest,
                onAccept: onAccept,
                onReject: onReject,
                onMessage: onMessage,
                onUnblock: onUnblock,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
