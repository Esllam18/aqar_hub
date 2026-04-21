// lib/.../chat/chat_misc_widgets.dart — Typing indicator, date divider, skeleton, empty state, context strip, image preview sheet
// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:aqar_hub/features/shared/chat/data/models/chat_message_model.dart';

// ── Typing indicator ──────────────────────────────────────────────────────────

class TypingIndicator extends StatefulWidget {
  final String name;
  const TypingIndicator({super.key, required this.name});
  @override
  State<TypingIndicator> createState() => _TypingState();
}

class _TypingState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: context.rOnly(left: 12, bottom: 4),
      padding: context.rSymmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (i) => AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              final t = ((_ctrl.value - i * 0.15) % 1.0);
              final y = t < 0.5
                  ? -4.0 * (t / 0.5)
                  : -4.0 * (1.0 - (t - 0.5) / 0.5);
              return Transform.translate(
                offset: Offset(0, y),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: context.r(2)),
                  width: context.r(7),
                  height: context.r(7),
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}

// ── Date divider ──────────────────────────────────────────────────────────────

class DateDivider extends StatelessWidget {
  final DateTime date;
  const DateDivider({super.key, required this.date});
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: context.r(10)),
    child: Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade400, thickness: 0.4)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.r(10)),
          child: Container(
            padding: context.rSymmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(context.r(12)),
            ),
            child: Text(
              DateFormat('d MMM yyyy').format(date.toLocal()),
              style: GoogleFonts.tajawal(
                fontSize: context.sp(11),
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade400, thickness: 0.4)),
      ],
    ),
  );
}

// ── Messages skeleton ─────────────────────────────────────────────────────────

class MessagesSkeleton extends StatefulWidget {
  const MessagesSkeleton({super.key});
  @override
  State<MessagesSkeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<MessagesSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.4,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pattern = [true, false, true, true, false, true, false];
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => ListView.builder(
        padding: context.rAll(12),
        itemCount: pattern.length,
        itemBuilder: (_, i) => Align(
          alignment: pattern[i] ? Alignment.centerRight : Alignment.centerLeft,
          child: Opacity(
            opacity: _anim.value,
            child: Container(
              margin: context.rOnly(bottom: 8),
              width: context.r(pattern[i] ? 180 : 220),
              height: context.r(40),
              decoration: BoxDecoration(
                color: pattern[i] ? const Color(0xFFDCF8C6) : Colors.white,
                borderRadius: BorderRadius.circular(context.r(14)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty chat ────────────────────────────────────────────────────────────────

class EmptyChat extends StatelessWidget {
  final String name;
  final PropertyCardMeta? card;
  const EmptyChat({super.key, required this.name, this.card});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: context.rSymmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.r(72),
            height: context.r(72),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.waving_hand_rounded,
              size: context.r(34),
              color: AppColors.primary.withOpacity(0.6),
            ),
          ),
          SizedBox(height: context.r(16)),
          Text(
            name,
            style: GoogleFonts.cairo(
              fontSize: context.sp(16),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B2D5E),
            ),
          ),
          SizedBox(height: context.r(6)),
          Text(
            'chat_empty_hint'.tr(context),
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: context.sp(13),
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          if (card != null) ...[
            SizedBox(height: context.r(10)),
            Container(
              padding: context.rSymmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(context.r(10)),
              ),
              child: Text(
                'chat_property_context_hint'.tr(context),
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(12),
                  color: AppColors.primary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

// ── Property context strip ────────────────────────────────────────────────────

class PropertyContextStrip extends StatelessWidget {
  final PropertyCardMeta card;
  final bool expanded;
  final VoidCallback onToggle;
  const PropertyContextStrip({
    super.key,
    required this.card,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final hasImg = (card.imageUrl ?? '').isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: context.rSymmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(context.r(8)),
              child: hasImg
                  ? CachedNetworkImage(
                      imageUrl: card.imageUrl!,
                      width: context.r(40),
                      height: context.r(40),
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _ThumbPlaceholder(),
                    )
                  : _ThumbPlaceholder(),
            ),
            SizedBox(width: context.r(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.home_work_outlined,
                        size: context.r(11),
                        color: AppColors.primary,
                      ),
                      SizedBox(width: context.r(4)),
                      Text(
                        'chat_regarding_property'.tr(context),
                        style: GoogleFonts.tajawal(
                          fontSize: context.sp(10),
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.r(2)),
                  Text(
                    card.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(13),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B2D5E),
                    ),
                  ),
                  Text(
                    card.city,
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(11),
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (card.price != null)
                  Text(
                    '${card.price!.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')} ${'currency'.tr(context)}',
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                SizedBox(height: context.r(4)),
                GestureDetector(
                  onTap: onToggle,
                  child: Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade400,
                    size: context.r(20),
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

class _ThumbPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: context.r(40),
    height: context.r(40),
    color: AppColors.primary.withOpacity(0.08),
    child: Icon(
      Icons.apartment_rounded,
      color: AppColors.primary.withOpacity(0.4),
      size: context.r(20),
    ),
  );
}

// ── Image preview sheet ───────────────────────────────────────────────────────

class ImagePreviewSheet extends StatelessWidget {
  final List<File> images;
  final void Function(List<File>) onSend;
  final VoidCallback onCancel;
  final VoidCallback? onAddMore;
  const ImagePreviewSheet({
    super.key,
    required this.images,
    required this.onSend,
    required this.onCancel,
    this.onAddMore,
  });

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: 0.65,
    minChildSize: 0.4,
    maxChildSize: 0.92,
    builder: (_, sc) => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.r(24)),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: context.rOnly(top: 10, bottom: 6),
            width: context.r(40),
            height: context.r(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(context.r(4)),
            ),
          ),
          Padding(
            padding: context.rOnly(left: 20, right: 12, top: 8, bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'chat_image_preview_title'.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(16),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B2D5E),
                    ),
                  ),
                ),
                if (onAddMore != null)
                  TextButton.icon(
                    onPressed: onAddMore,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(
                      'chat_add_more'.tr(context),
                      style: GoogleFonts.cairo(fontSize: context.sp(13)),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              controller: sc,
              padding: context.rAll(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: context.r(6),
                mainAxisSpacing: context.r(6),
              ),
              itemCount: images.length,
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(context.r(10)),
                child: Image.file(images[i], fit: BoxFit.cover),
              ),
            ),
          ),
          Padding(
            padding: context.rOnly(
              left: 16,
              right: 16,
              bottom: 16 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: context.rSymmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.r(14)),
                      ),
                    ),
                    child: Text(
                      'chat_cancel'.tr(context),
                      style: GoogleFonts.cairo(fontSize: context.sp(14)),
                    ),
                  ),
                ),
                SizedBox(width: context.r(12)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onSend(images),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.primary,
                      padding: context.rSymmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.r(14)),
                      ),
                    ),
                    child: Text(
                      'chat_send'.tr(context),
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(14),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
