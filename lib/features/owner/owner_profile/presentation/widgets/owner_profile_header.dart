import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerProfileSliverHeader extends StatelessWidget {
  final String displayName;
  final String? displayPhone;
  final String? displayAvatar;
  final String? displayCity;
  final String? displayEmail;
  final String? displayAddress;
  final String roleLabel;
  final bool isSelf;
  final String memberSince;
  final int propertiesCount;
  final VoidCallback onWhatsApp;
  final VoidCallback onCall;
  final VoidCallback? onChat;

  const OwnerProfileSliverHeader({
    super.key,
    required this.displayName,
    required this.displayPhone,
    required this.displayAvatar,
    required this.displayCity,
    required this.displayEmail,
    required this.displayAddress,
    required this.roleLabel,
    required this.isSelf,
    required this.memberSince,
    required this.propertiesCount,
    required this.onWhatsApp,
    required this.onCall,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = (displayAvatar ?? '').isNotEmpty;
    final hasPhone = (displayPhone ?? '').isNotEmpty;

    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A2656), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: context.r(180),
                  height: context.r(180),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: -20,
                child: Container(
                  width: context.r(100),
                  height: context.r(100),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),

              Column(
                children: [
                  // Back button
                  Padding(
                    padding: context.rOnly(left: 4, right: 16, top: 4),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  // Avatar
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: context.r(48),
                      backgroundColor: Colors.white24,
                      backgroundImage: hasAvatar
                          ? CachedNetworkImageProvider(displayAvatar!)
                          : null,
                      child: !hasAvatar
                          ? Icon(
                              Icons.person_rounded,
                              size: context.r(44),
                              color: Colors.white70,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: context.r(14)),

                  // Name
                  Padding(
                    padding: context.rSymmetric(horizontal: 24),
                    child: Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(20),
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: context.r(6)),

                  // // Role badge — reads from DB, never hardcoded
                  // if (roleLabel.isNotEmpty)
                  //   Container(
                  //     padding:
                  //         context.rSymmetric(horizontal: 14, vertical: 4),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white.withValues(alpha: 0.15),
                  //       borderRadius:
                  //           BorderRadius.circular(context.r(20)),
                  //       border: Border.all(
                  //         color: Colors.white.withValues(alpha: 0.25),
                  //       ),
                  //     ),
                  //     child: Text(
                  //       isSelf
                  //           ? 'owner_profile_is_self'.tr(context)
                  //           : roleLabel,
                  //       style: GoogleFonts.tajawal(
                  //         fontSize: context.sp(12),
                  //         color: Colors.white,
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //     ),
                  //   ),

                  // City
                  if ((displayCity ?? '').isNotEmpty) ...[
                    SizedBox(height: context.r(8)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: context.r(13),
                          color: Colors.white54,
                        ),
                        SizedBox(width: context.r(4)),
                        Text(
                          displayCity!,
                          style: GoogleFonts.tajawal(
                            fontSize: context.sp(12),
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],

                  SizedBox(height: context.r(20)),

                  // CTA buttons
                  if (!isSelf)
                    Padding(
                      padding: context.rSymmetric(horizontal: 24),
                      child: Row(
                        children: [
                          if (hasPhone) ...[
                            Expanded(
                              child: _ActionBtn(
                                icon: Icons.chat_rounded,
                                label: 'WhatsApp',
                                bg: const Color(0xFF25D366),
                                onTap: onWhatsApp,
                              ),
                            ),
                            SizedBox(width: context.r(10)),
                            Expanded(
                              child: _ActionBtn(
                                icon: Icons.phone_rounded,
                                label: 'details_btn_call'.tr(context),
                                bg: Colors.white.withValues(alpha: 0.18),
                                onTap: onCall,
                              ),
                            ),
                            if (onChat != null) ...[
                              SizedBox(width: context.r(10)),
                              Expanded(
                                child: _ActionBtn(
                                  icon: Icons.forum_outlined,
                                  label: 'owner_profile_chat'.tr(context),
                                  bg: AppColors.secondary.withValues(
                                    alpha: 0.8,
                                  ),
                                  onTap: onChat!,
                                ),
                              ),
                            ],
                          ] else if (onChat != null)
                            Expanded(
                              child: _ActionBtn(
                                icon: Icons.forum_outlined,
                                label: 'owner_profile_chat'.tr(context),
                                bg: AppColors.secondary.withValues(alpha: 0.8),
                                onTap: onChat!,
                              ),
                            ),
                        ],
                      ),
                    ),

                  SizedBox(height: context.r(28)),

                  // Wave bottom
                  Container(
                    height: context.r(28),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: context.rSymmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(context.r(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: context.r(15), color: Colors.white),
          SizedBox(width: context.r(6)),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: context.sp(12),
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
