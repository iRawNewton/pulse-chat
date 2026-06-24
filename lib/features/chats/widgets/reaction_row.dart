import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';

class ReactionsRow extends StatelessWidget {
  const ReactionsRow({
    required this.reactions,
    required this.isMine,
    required this.colors,
    required this.onTap,
    super.key,
  });

  final Map<String, List<String>> reactions;
  final bool isMine;
  final AppColors colors;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: reactions.entries.map((e) {
        final iReacted = e.value.contains('me');
        return GestureDetector(
          onTap: () => onTap(e.key),
          child: Container(
            margin: EdgeInsets.only(right: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: iReacted ? colors.primaryMuted : colors.card,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: iReacted ? colors.primary : colors.border,
                width: iReacted ? 1.5 : 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.key, style: TextStyle(fontSize: 13.sp)),
                if (e.value.length > 1) ...[
                  SizedBox(width: 3.w),
                  Text(
                    '${e.value.length}',
                    style: AppTextStyles.w600.copyWith(
                      fontSize: 11.sp,
                      color: iReacted ? colors.primary : colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
