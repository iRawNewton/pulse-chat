import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/features/chats/data/chat_message_model.dart';

class StatusIcon extends StatelessWidget {
  const StatusIcon({
    required this.status,
    required this.colors,
    super.key,
  });
  final MessageStatus status;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sending:
        return Icon(Icons.access_time_rounded, size: 12.sp, color: Colors.white.withValues(alpha: 0.7));
      case MessageStatus.sent:
        return Icon(Icons.check_rounded, size: 13.sp, color: Colors.white.withValues(alpha: 0.7));
      case MessageStatus.delivered:
        return Icon(Icons.done_all_rounded, size: 13.sp, color: Colors.white.withValues(alpha: 0.7));
      case MessageStatus.read:
        return Icon(Icons.done_all_rounded, size: 13.sp, color: Colors.white);
    }
  }
}
