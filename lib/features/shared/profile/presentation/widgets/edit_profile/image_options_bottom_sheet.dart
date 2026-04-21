// ── Image options bottom sheet ────────────────────────────────────────────────

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/edit_profile/sheet_options.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImageOptionsSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback? onRemove;

  const ImageOptionsSheet({
    super.key,
    required this.onCamera,
    required this.onGallery,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: context.rSymmetric(horizontal: 12, vertical: 8),
      padding: context.rAll(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.r(40),
            height: context.r(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: context.r(16)),
          Text(
            'edit_pick_image_title'.tr(context),
            style: GoogleFonts.cairo(
              fontSize: context.sp(16),
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: context.r(20)),
          SheetOption(
            icon: Icons.camera_alt_rounded,
            iconColor: AppColors.primary,
            labelKey: 'edit_pick_camera',
            onTap: onCamera,
          ),
          SheetOption(
            icon: Icons.photo_library_rounded,
            iconColor: const Color(0xFF039BE5),
            labelKey: 'edit_pick_gallery',
            onTap: onGallery,
          ),
          if (onRemove != null)
            SheetOption(
              icon: Icons.delete_outline_rounded,
              iconColor: const Color(0xFFE53935),
              labelKey: 'edit_pick_remove',
              onTap: onRemove!,
              isDestructive: true,
            ),
          SizedBox(height: context.r(8)),
        ],
      ),
    );
  }
}
