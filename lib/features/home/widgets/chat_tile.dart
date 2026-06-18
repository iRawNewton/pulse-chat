import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/home/data/chat_item_model.dart';

class ChatTile extends StatelessWidget {
  const ChatTile({
    required this.chat,
    required this.colors,
    this.onTap,
    super.key,
  });

  final ChatItem chat;
  final AppColors colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: () {},
      splashColor: colors.primaryMuted,
      highlightColor: colors.primaryMuted.withValues(alpha: 0.5),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Row(
          children: [
            _buildAvatar(),
            SizedBox(width: 12.w),
            Expanded(child: _buildContent()),
            SizedBox(width: 8.w),
            _buildTrailing(),
          ],
        ),
      ),
    );
  }

  // ── Avatar ────────────────────────────────────

  Widget _buildAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 52.w,
          height: 52.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _avatarColor(),
            border: Border.all(
              color: colors.border,
              width: 0.5,
            ),
          ),
          child: chat.avatarUrl != null
              ? ClipOval(
                  child: Image.network(
                    chat.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _avatarLetters(),
                  ),
                )
              : chat.type == ChatType.group
              ? _groupAvatarContent()
              : _avatarLetters(),
        ),
        if (chat.type == ChatType.individual && chat.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 13.w,
              height: 13.w,
              decoration: BoxDecoration(
                color: colors.success,
                shape: BoxShape.circle,
                border: Border.all(color: colors.background, width: 2),
              ),
            ),
          ),
        if (chat.isPinned)
          Positioned(
            left: -2,
            top: -2,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.push_pin_rounded, size: 8.sp, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _avatarLetters() {
    final initials = _getInitials(chat.name);
    return Center(
      child: Text(
        initials,
        style: AppTextStyles.w700.copyWith(
          fontSize: 18.sp,
          color: _avatarTextColor(),
        ),
      ),
    );
  }

  Widget _groupAvatarContent() {
    return Center(
      child: Icon(Icons.group_rounded, size: 24.sp, color: _avatarTextColor()),
    );
  }

  Color _avatarColor() {
    final colorSets = [
      [const Color(0xFFFFE8E0), const Color(0xFFFF6B4A)],
      [const Color(0xFFDFF5F1), const Color(0xFF0E8C7F)],
      [const Color(0xFFEFE6FE), const Color(0xFF8B5CF6)],
      [const Color(0xFFE6F6E7), const Color(0xFF4CAF50)],
      [const Color(0xFFFCF0DC), const Color(0xFFF2A93B)],
    ];
    final idx = chat.name.codeUnitAt(0) % colorSets.length;
    return colorSets[idx][0];
  }

  Color _avatarTextColor() {
    final colorSets = [
      [const Color(0xFFFFE8E0), const Color(0xFFFF6B4A)],
      [const Color(0xFFDFF5F1), const Color(0xFF0E8C7F)],
      [const Color(0xFFEFE6FE), const Color(0xFF8B5CF6)],
      [const Color(0xFFE6F6E7), const Color(0xFF4CAF50)],
      [const Color(0xFFFCF0DC), const Color(0xFFF2A93B)],
    ];
    final idx = chat.name.codeUnitAt(0) % colorSets.length;
    return colorSets[idx][1];
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // ── Content ──────────────────────────────────

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                chat.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.w600.copyWith(
                  fontSize: 15.sp,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
        Row(
          children: [
            if (chat.isMuted)
              Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: Icon(
                  Icons.volume_off_rounded,
                  size: 13.sp,
                  color: colors.textTertiary,
                ),
              ),
            Expanded(
              child: Text(
                chat.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.w400.copyWith(
                  fontSize: 13.sp,
                  color: chat.unreadCount > 0 ? colors.textSecondary : colors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Trailing ─────────────────────────────────

  Widget _buildTrailing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          chat.time,
          style: AppTextStyles.w500.copyWith(
            fontSize: 11.sp,
            color: chat.unreadCount > 0 ? colors.primary : colors.textTertiary,
          ),
        ),
        SizedBox(height: 6.h),
        if (chat.unreadCount > 0)
          Container(
            constraints: BoxConstraints(minWidth: 20.w),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: chat.isMuted ? colors.textTertiary : colors.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              chat.unreadCount > 99 ? '99+' : '${chat.unreadCount}',
              textAlign: TextAlign.center,
              style: AppTextStyles.w700.copyWith(
                fontSize: 11.sp,
                color: Colors.white,
              ),
            ),
          )
        else
          SizedBox(height: 20.h),
      ],
    );
  }
}
