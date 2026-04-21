// lib/.../add_property/step_media.dart — Step 6: Photos + Video

// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/owner/add_property/data/models/add_property_form_model.dart';
import 'add_property_shared.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class StepMedia extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final AddPropertyFormModel form;
  final ValueChanged<AddPropertyFormModel> onChanged;
  const StepMedia({
    super.key,
    required this.formKey,
    required this.form,
    required this.onChanged,
  });
  @override
  State<StepMedia> createState() => _State();
}

class _State extends State<StepMedia> {
  bool _pickingImg = false, _pickingVid = false;
  final _picker = ImagePicker();

  Future<void> _pickImages() async {
    if (_pickingImg) return;
    setState(() => _pickingImg = true);
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 85);
      if (picked.isNotEmpty && mounted) {
        widget.onChanged(
          widget.form.copyWith(
            localImages: [
              ...widget.form.localImages,
              ...picked.map((x) => File(x.path)),
            ],
          ),
        );
      }
    } catch (_) {
      if (mounted) _snack('addprop_picker_error'.tr(context));
    } finally {
      if (mounted) setState(() => _pickingImg = false);
    }
  }

  Future<void> _pickVideo() async {
    if (_pickingVid) return;
    setState(() => _pickingVid = true);
    try {
      final picked = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 3),
      );
      if (picked != null && mounted) {
        widget.onChanged(widget.form.copyWith(localVideo: File(picked.path)));
      }
    } catch (_) {
      if (mounted) _snack('addprop_picker_error'.tr(context));
    } finally {
      if (mounted) setState(() => _pickingVid = false);
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
  );

  @override
  Widget build(BuildContext context) {
    final images = widget.form.localImages;
    final video = widget.form.localVideo;
    return stepScroll(
      context,
      Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepAlertBanner(
              message: 'addprop_banner_media'.tr(context),
              type: AlertBannerType.tip,
              icon: Icons.photo_library_outlined,
            ),
            Row(
              children: [
                SectionTitle('addprop_photos'.tr(context)),
                SizedBox(width: context.r(6)),
                const RequiredBadge(),
              ],
            ),
            HintText('addprop_photos_hint'.tr(context)),
            GestureDetector(
              onTap: _pickingImg ? null : _pickImages,
              child: Container(
                width: double.infinity,
                padding: context.rSymmetric(vertical: 22),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(context.r(14)),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    _pickingImg
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(
                            Icons.add_photo_alternate_outlined,
                            size: context.r(28),
                            color: AppColors.primary,
                          ),
                    SizedBox(height: context.r(8)),
                    Text(
                      'addprop_add_photos'.tr(context),
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(13),
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (images.isNotEmpty) ...[
              SizedBox(height: context.r(14)),
              Text(
                'addprop_first_is_cover'.tr(context),
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(11),
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(height: context.r(8)),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: context.r(8),
                  mainAxisSpacing: context.r(8),
                ),
                itemCount: images.length,
                itemBuilder: (_, i) => ImageThumb(
                  file: images[i],
                  isCover: i == 0,
                  onRemove: () {
                    final u = [...images];
                    u.removeAt(i);
                    widget.onChanged(widget.form.copyWith(localImages: u));
                  },
                ),
              ),
            ],
            SizedBox(height: context.r(28)),
            Row(
              children: [
                SectionTitle('addprop_video'.tr(context)),
                SizedBox(width: context.r(6)),
                const OptionalBadge(),
              ],
            ),
            HintText('addprop_video_hint'.tr(context)),
            video == null
                ? GestureDetector(
                    onTap: _pickingVid ? null : _pickVideo,
                    child: Container(
                      width: double.infinity,
                      padding: context.rSymmetric(vertical: 22),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(context.r(14)),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.25),
                        ),
                      ),
                      child: Column(
                        children: [
                          _pickingVid
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.videocam_outlined,
                                  size: context.r(28),
                                  color: Colors.grey.shade500,
                                ),
                          SizedBox(height: context.r(8)),
                          Text(
                            'addprop_add_video'.tr(context),
                            style: GoogleFonts.cairo(
                              fontSize: context.sp(13),
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _VideoTile(
                    file: video,
                    onRemove: () => widget.onChanged(
                      widget.form.copyWith(clearLocalVideo: true),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;
  const _VideoTile({required this.file, required this.onRemove});
  @override
  Widget build(BuildContext context) => Container(
    padding: context.rAll(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(context.r(12)),
      border: Border.all(color: Colors.grey.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Container(
          width: context.r(44),
          height: context.r(44),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(context.r(10)),
          ),
          child: Icon(
            Icons.videocam_rounded,
            color: AppColors.primary,
            size: context.r(22),
          ),
        ),
        SizedBox(width: context.r(12)),
        Expanded(
          child: Text(
            file.path.split('/').last,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.tajawal(fontSize: context.sp(13)),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.delete_outline_rounded,
            color: Colors.redAccent,
            size: context.r(20),
          ),
          onPressed: onRemove,
        ),
      ],
    ),
  );
}
