import 'dart:io';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import '../../../data/models/profile_model.dart';
import '../profile_view/profile_avatar_widget.dart';

class EditProfileAvatarWidget extends StatelessWidget {
  final ProfileModel profile;
  final String? resolvedAvatarUrl; // ✅ custom URL or Google avatar fallback
  final File? pickedImage;
  final bool isUploading;
  final VoidCallback onTap;

  const EditProfileAvatarWidget({
    super.key,
    required this.profile,
    required this.resolvedAvatarUrl,
    required this.pickedImage,
    required this.isUploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: context.rSymmetric(vertical: 28),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (pickedImage != null)
              // ── Locally picked file preview ──────────────────────────
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: context.r(90),
                  height: context.r(90),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.7),
                      width: 2.5,
                    ),
                    image: DecorationImage(
                      image: FileImage(pickedImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: isUploading
                      ? Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.4),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : null,
                ),
              )
            else
              // ── Network image (custom or Google) or default icon ─────
              // ✅ resolvedAvatarUrl is passed in — already checked for
              //    profileImageUrl first, then userMetadata fallback
              ProfileAvatarWidget(
                imageUrl: resolvedAvatarUrl,
                size: context.r(90),
                onTap: onTap,
                showCameraBadge: true,
              ),
          ],
        ),
      ),
    );
  }
}
