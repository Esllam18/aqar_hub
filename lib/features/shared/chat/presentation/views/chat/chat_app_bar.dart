// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String otherUserName;
  final String? otherUserAvatar;
  final bool isOnline;
  final bool isTyping;
  final DateTime? lastSeenAt;
  final VoidCallback onTap;
  final VoidCallback onBack;

  const ChatAppBar({
    super.key,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.isOnline,
    required this.isTyping,
    this.lastSeenAt,
    required this.onTap,
    required this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final hasAvatar = (otherUserAvatar ?? '').isNotEmpty;
    return AppBar(
      backgroundColor: const Color(0xFF1B2D5E),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
        ),
        onPressed: onBack,
      ),
      titleSpacing: 0,
      actions: [
        GestureDetector(
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(
              Icons.chevron_right_rounded,
              color: Colors.white54,
              size: 22,
            ),
          ),
        ),
      ],
      title: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: context.r(18),
                  backgroundColor: AppColors.primary.withOpacity(0.3),
                  child: hasAvatar
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: otherUserAvatar!,
                            width: context.r(36),
                            height: context.r(36),
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                _Initial(name: otherUserName),
                          ),
                        )
                      : _Initial(name: otherUserName),
                ),
                if (isOnline)
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: context.r(10),
                      height: context.r(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1B2D5E),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: context.r(10)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherUserName,
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _Subtitle(
                    key: ValueKey(isTyping ? 'typing' : isOnline.toString()),
                    isTyping: isTyping,
                    isOnline: isOnline,
                    lastSeenAt: lastSeenAt,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  final String name;
  const _Initial({required this.name});
  @override
  Widget build(BuildContext context) => Text(
    name.isNotEmpty ? name[0].toUpperCase() : '?',
    style: TextStyle(
      color: Colors.white,
      fontSize: context.sp(14),
      fontWeight: FontWeight.w700,
    ),
  );
}

class _Subtitle extends StatelessWidget {
  final bool isTyping, isOnline;
  final DateTime? lastSeenAt;
  const _Subtitle({
    super.key,
    required this.isTyping,
    required this.isOnline,
    this.lastSeenAt,
  });

  String _lastSeen(BuildContext context, DateTime dt) {
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inMinutes < 2) return 'chat_last_seen_recently'.tr(context);
    if (diff.inHours < 24) {
      return '${'chat_last_seen'.tr(context)} ${DateFormat.jm().format(dt.toLocal())}';
    }
    if (diff.inDays == 1) {
      return '${'chat_last_seen'.tr(context)} ${'chat_yesterday'.tr(context)}';
    }
    return '${'chat_last_seen'.tr(context)} ${dt.toLocal().day}/${dt.toLocal().month}';
  }

  @override
  Widget build(BuildContext context) {
    if (isTyping) {
      return Text(
        'chat_typing'.tr(context),
        style: GoogleFonts.tajawal(
          fontSize: context.sp(11),
          color: Colors.white70,
        ),
      );
    }
    if (isOnline) {
      return Text(
        'chat_online'.tr(context),
        style: GoogleFonts.tajawal(
          fontSize: context.sp(11),
          color: const Color(0xFF4CAF50),
          fontWeight: FontWeight.w600,
        ),
      );
    }
    if (lastSeenAt != null) {
      return Text(
        _lastSeen(context, lastSeenAt!),
        style: GoogleFonts.tajawal(
          fontSize: context.sp(11),
          color: Colors.white54,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
