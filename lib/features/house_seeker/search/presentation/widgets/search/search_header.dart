// search_header.dart — AppBar + text input + quick chips for the AI search screen
// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode focus;
  final bool hasText;
  final VoidCallback onSubmit, onClear, onBack;

  const SearchHeader({
    super.key,
    required this.ctrl,
    required this.focus,
    required this.hasText,
    required this.onSubmit,
    required this.onClear,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: context.rOnly(left: 8, right: 16, top: 10, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: context.r(20),
                  color: const Color(0xFF1B2D5E),
                ),
                onPressed: onBack,
              ),
              Expanded(
                child: Text(
                  'search_title'.tr(context),
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(19),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1B2D5E),
                  ),
                ),
              ),
              Container(
                padding: context.rSymmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B2D5E), Color(0xFF2A3F7E)],
                  ),
                  borderRadius: BorderRadius.circular(context.r(20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: context.r(12),
                    ),
                    SizedBox(width: context.r(4)),
                    Text(
                      'AI',
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(10),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.r(4)),
          Padding(
            padding: context.rOnly(right: 8, bottom: 10),
            child: Text(
              'search_label'.tr(context),
              style: GoogleFonts.tajawal(
                fontSize: context.sp(13),
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FA),
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: AppColors.primary.withOpacity(0.14)),
            ),
            child: Row(
              children: [
                SizedBox(width: context.r(14)),
                Container(
                  padding: context.rAll(7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B2D5E), Color(0xFF2A5298)],
                    ),
                    borderRadius: BorderRadius.circular(context.r(10)),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: context.r(15),
                  ),
                ),
                SizedBox(width: context.r(10)),
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    focusNode: focus,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(14),
                      color: const Color(0xFF1B2D5E),
                    ),
                    decoration: InputDecoration(
                      hintText: 'search_input_placeholder'.tr(context),
                      hintStyle: GoogleFonts.tajawal(
                        fontSize: context.sp(12),
                        color: Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                      contentPadding: context.rSymmetric(vertical: 14),
                    ),
                    onSubmitted: (_) => onSubmit(),
                    textInputAction: TextInputAction.search,
                    maxLines: 1,
                  ),
                ),
                if (hasText)
                  GestureDetector(
                    onTap: onClear,
                    child: Padding(
                      padding: context.rAll(10),
                      child: Icon(
                        Icons.close_rounded,
                        size: context.r(17),
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: onSubmit,
                  child: Container(
                    margin: context.rAll(6),
                    padding: context.rAll(11),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(context.r(12)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.30),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                      size: context.r(18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SearchChipBar extends StatelessWidget {
  final List<String> chips;
  final void Function(String) onChipTap;
  const SearchChipBar({
    super.key,
    required this.chips,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: context.rOnly(bottom: 12),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: context.rSymmetric(horizontal: 16),
      child: Row(
        children: chips
            .map(
              (key) => GestureDetector(
                onTap: () => onChipTap(key),
                child: Container(
                  margin: context.rOnly(left: 8),
                  padding: context.rSymmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(context.r(20)),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.18),
                    ),
                  ),
                  child: Text(
                    key.tr(context),
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(12),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    ),
  );
}
