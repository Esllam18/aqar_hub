// lib/.../chat/chat_input_bar.dart — Text input + attach + mic/send button
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool sending;
  final bool hasPropertyCard;
  final ValueChanged<String> onChanged;
  final VoidCallback onSendText;
  final VoidCallback onPickImage;
  final VoidCallback onPickVideo;
  final VoidCallback onShareCard;
  final VoidCallback onStartRecord;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.sending,
    required this.hasPropertyCard,
    required this.onChanged,
    required this.onSendText,
    required this.onPickImage,
    required this.onPickVideo,
    required this.onShareCard,
    required this.onStartRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: context.r(8),
        right: context.r(8),
        top: context.r(6),
        bottom: context.r(6) + MediaQuery.paddingOf(context).bottom,
      ),
      child: Row(
        children: [
          _AttachBtn(
            onPickImage: onPickImage,
            onPickVideo: onPickVideo,
            onShareCard: onShareCard,
            hasPropertyCard: hasPropertyCard,
          ),
          SizedBox(width: context.r(6)),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.r(24)),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                maxLines: 5,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                style: GoogleFonts.tajawal(fontSize: context.sp(14)),
                decoration: InputDecoration(
                  hintText: 'chat_input_hint'.tr(context),
                  hintStyle: GoogleFonts.tajawal(
                    fontSize: context.sp(14),
                    color: Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                  contentPadding: context.rSymmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: context.r(6)),
          AnimatedBuilder(
            animation: controller,
            builder: (_, __) {
              final hasText = controller.text.trim().isNotEmpty;
              if (!hasText && !sending) {
                return GestureDetector(
                  onTapDown: (_) => onStartRecord(),
                  child: const _CircleBtn(
                    color: AppColors.primary,
                    icon: Icons.mic_rounded,
                  ),
                );
              }
              return GestureDetector(
                onTap: (hasText && !sending) ? onSendText : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: context.r(44),
                  height: context.r(44),
                  decoration: BoxDecoration(
                    color: hasText ? AppColors.primary : Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: sending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: context.r(20),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _CircleBtn({required this.color, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    width: context.r(44),
    height: context.r(44),
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    child: Icon(icon, color: Colors.white, size: context.r(22)),
  );
}

class _AttachBtn extends StatelessWidget {
  final VoidCallback onPickImage, onPickVideo, onShareCard;
  final bool hasPropertyCard;
  const _AttachBtn({
    required this.onPickImage,
    required this.onPickVideo,
    required this.onShareCard,
    required this.hasPropertyCard,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.r(20)),
          ),
        ),
        builder: (_) => SafeArea(
          child: Padding(
            padding: context.rAll(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.image_rounded,
                    color: AppColors.primary,
                    size: context.r(26),
                  ),
                  title: Text(
                    'chat_attach_image'.tr(context),
                    style: GoogleFonts.cairo(fontSize: context.sp(14)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onPickImage();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.videocam_rounded,
                    color: AppColors.primary,
                    size: context.r(26),
                  ),
                  title: Text(
                    'chat_attach_video'.tr(context),
                    style: GoogleFonts.cairo(fontSize: context.sp(14)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onPickVideo();
                  },
                ),
                if (hasPropertyCard)
                  ListTile(
                    leading: Icon(
                      Icons.home_work_outlined,
                      color: AppColors.primary,
                      size: context.r(26),
                    ),
                    title: Text(
                      'chat_share_property'.tr(context),
                      style: GoogleFonts.cairo(fontSize: context.sp(14)),
                    ),
                    subtitle: Text(
                      'chat_share_property_hint'.tr(context),
                      style: GoogleFonts.tajawal(
                        fontSize: context.sp(11),
                        color: Colors.grey.shade500,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onShareCard();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      child: Container(
        width: context.r(40),
        height: context.r(40),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.attach_file_rounded,
          color: Colors.grey.shade600,
          size: context.r(20),
        ),
      ),
    );
  }
}
