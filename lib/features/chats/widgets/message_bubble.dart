import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pulse_chat/core/theme/app_colors.dart';
import 'package:pulse_chat/core/theme/app_text_style.dart';
import 'package:pulse_chat/features/chats/data/chat_message_model.dart';
import 'package:pulse_chat/features/chats/widgets/reaction_row.dart';
import 'package:pulse_chat/features/chats/widgets/reply_quote.dart';
import 'package:pulse_chat/features/chats/widgets/status_icon.dart';
import 'package:pulse_chat/features/chats/widgets/url_preview_card.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message,
    required this.colors,
    required this.contactName,
    required this.onReact,
    super.key,
    this.onReplyTap,
  });

  final ChatMessage message;
  final AppColors colors;
  final String contactName;
  final VoidCallback? onReplyTap;
  final ValueChanged<String> onReact;

  static const double _kBubbleMaxWidth = 0.75;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    final screenW = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(
        top: 2.h,
        bottom: message.reactions.isNotEmpty ? 20.h : 4.h,
      ),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: screenW * _kBubbleMaxWidth),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Bubble
                  Container(
                    decoration: BoxDecoration(
                      color: isMine ? colors.primary : colors.card,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18.r),
                        topRight: Radius.circular(18.r),
                        bottomLeft: Radius.circular(isMine ? 18.r : 4.r),
                        bottomRight: Radius.circular(isMine ? 4.r : 18.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Reply quote
                        if (message.replyTo != null)
                          ReplyQuote(
                            original: message.replyTo!,
                            isMine: isMine,
                            colors: colors,
                            contactName: contactName,
                            onTap: onReplyTap,
                          ),
                        // URL preview
                        if (message.urlPreview != null)
                          UrlPreviewCard(
                            data: message.urlPreview!,
                            isMine: isMine,
                            colors: colors,
                          ),
                        // Text
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            12.w,
                            message.replyTo == null && message.urlPreview == null ? 10.h : 6.h,
                            12.w,
                            6.h,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  message.text,
                                  style: AppTextStyles.w400.copyWith(
                                    fontSize: 15.sp,
                                    color: isMine ? Colors.white : colors.textPrimary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    message.time,
                                    style: AppTextStyles.w400.copyWith(
                                      fontSize: 10.sp,
                                      color: isMine ? Colors.white.withValues(alpha: 0.7) : colors.textTertiary,
                                    ),
                                  ),
                                  if (isMine) ...[
                                    SizedBox(width: 3.w),
                                    StatusIcon(status: message.status, colors: colors),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Reactions
              if (message.reactions.isNotEmpty)
                Positioned(
                  bottom: -14.h,
                  right: isMine ? 4.w : null,
                  left: isMine ? null : 4.w,
                  child: ReactionsRow(
                    reactions: message.reactions,
                    isMine: isMine,
                    colors: colors,
                    onTap: onReact,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
