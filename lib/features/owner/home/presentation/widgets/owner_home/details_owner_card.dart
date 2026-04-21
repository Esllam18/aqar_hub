// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/home/data/models/property_model.dart';
import 'package:aqar_hub/features/owner/owner_profile/presentation/view/owner_profile_page.dart';
import 'package:aqar_hub/features/shared/chat/chat_navigator.dart';
import 'package:aqar_hub/features/shared/profile/data/datasources/profile_datasource_impl.dart';
import 'package:aqar_hub/features/shared/profile/data/models/profile_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

/// Redesigned owner info card for PropertyDetailsView.
/// Fetches the real owner profile from `profiles` table using ProfileDatasourceImpl.
/// Falls back to PropertyModel fields while loading or on error.
class DetailsOwnerCard extends StatefulWidget {
  final PropertyModel property;

  const DetailsOwnerCard({super.key, required this.property});

  @override
  State<DetailsOwnerCard> createState() => _DetailsOwnerCardState();
}

class _DetailsOwnerCardState extends State<DetailsOwnerCard> {
  final _datasource = ProfileDatasourceImpl();

  ProfileModel? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final ownerId = widget.property.ownerId;
    if (ownerId.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final profile = await _datasource.getProfile(ownerId);
      if (mounted) {
        setState(() {
          _profile = profile;
          _loading = false;
        });
      }
    } catch (_) {
      // Silently fall back to PropertyModel fields
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Resolved helpers ───────────────────────────────────────────────────────

  String _resolvedName(BuildContext context) {
    if (_profile != null) {
      final name = _profile!.fullName;
      if (name.isNotEmpty) return name;
    }
    final fb = (widget.property.ownerName ?? '').trim();
    if (fb.isNotEmpty) return fb;
    return 'profile_unknown_name'.tr(context);
  }

  String? get _resolvedPhone {
    if (_profile?.phoneNumber?.isNotEmpty == true) {
      return _profile!.phoneNumber;
    }
    return widget.property.ownerPhone;
  }

  String? get _resolvedAvatar {
    if (_profile?.profileImageUrl?.isNotEmpty == true) {
      return _profile!.profileImageUrl;
    }
    return widget.property.ownerAvatar;
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerProfilePage(
          ownerId: widget.property.ownerId,
          ownerName: _resolvedName(context),
          ownerPhone: _resolvedPhone,
          ownerAvatar: _resolvedAvatar,
        ),
      ),
    );
  }

  // ── WhatsApp ───────────────────────────────────────────────────────────────

  Future<void> _openWhatsApp(BuildContext context) async {
    final phone = _resolvedPhone;
    if (phone == null || phone.trim().isEmpty) {
      _showSnack(
        context,
        message: 'owner_no_phone'.tr(context),
        color: AppColors.warning,
      );
      return;
    }
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final number = clean.startsWith('20') ? clean : '20$clean';
    final appUri = Uri.parse('whatsapp://send?phone=$number');
    final webUri = Uri.parse('https://wa.me/$number');
    try {
      final opened = await launchUrl(
        appUri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  void _openChat(BuildContext context) {
    if (widget.property.ownerId.isEmpty) return;
    ChatNavigator.openChat(
      context,
      otherUserId: widget.property.ownerId,
      otherUserName: _resolvedName(context),
      otherUserAvatar: _resolvedAvatar,
      property: widget.property,
    );
  }

  void _showSnack(
    BuildContext context, {
    required String message,
    required Color color,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(
          message,
          style: GoogleFonts.tajawal(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhone = (_resolvedPhone ?? '').trim().isNotEmpty;
    final avatar = _resolvedAvatar ?? '';
    final hasAvatar = avatar.isNotEmpty;

    return GestureDetector(
      onTap: () => _navigateToProfile(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: context.r(18),
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Owner info row ─────────────────────────────────────────────
            Padding(
              padding: context.rOnly(left: 16, right: 12, top: 14, bottom: 14),
              child: Row(
                children: [
                  // Avatar with gradient ring
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: context.r(24),
                      backgroundColor: AppColors.primary.withOpacity(0.08),
                      backgroundImage: hasAvatar
                          ? CachedNetworkImageProvider(avatar)
                          : null,
                      child: _loading
                          ? SizedBox(
                              width: context.r(16),
                              height: context.r(16),
                              child: const CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: AppColors.primary,
                              ),
                            )
                          : !hasAvatar
                          ? Icon(
                              Icons.person_rounded,
                              size: context.r(22),
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(width: context.r(12)),

                  // Name + phone + role
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _resolvedName(context),
                          style: GoogleFonts.cairo(
                            fontSize: context.sp(14.5),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1B2D5E),
                          ),
                        ),
                        SizedBox(height: context.r(2)),
                        Row(
                          children: [
                            Container(
                              padding: context.rSymmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(
                                  context.r(6),
                                ),
                              ),
                              child: Text(
                                'role_owner'.tr(context),
                                style: GoogleFonts.tajawal(
                                  fontSize: context.sp(10),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            if (hasPhone) ...[
                              SizedBox(width: context.r(6)),
                              Icon(
                                Icons.phone_outlined,
                                size: context.r(11),
                                color: Colors.grey.shade500,
                              ),
                              SizedBox(width: context.r(3)),
                              Flexible(
                                child: Text(
                                  _resolvedPhone!,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.tajawal(
                                    fontSize: context.sp(10.5),
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Chevron
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade300,
                    size: context.r(22),
                  ),
                ],
              ),
            ),

            // ── Divider ────────────────────────────────────────────────────
            Divider(height: 1, thickness: 0.5, color: Colors.grey.shade100),

            // ── Action buttons ─────────────────────────────────────────────
            Padding(
              padding: context.rOnly(left: 10, right: 10, top: 12, bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.phone_in_talk_rounded,
                      label: 'WhatsApp',
                      solidColor: const Color(0xFF25D366),
                      enabled: hasPhone,
                      onTap: () => _openWhatsApp(context),
                    ),
                  ),
                  SizedBox(width: context.r(8)),
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.forum_outlined,
                      label: 'details_btn_chat'.tr(context),
                      solidColor: AppColors.primary,
                      outlined: true,
                      onTap: () => _openChat(context),
                    ),
                  ),
                  SizedBox(width: context.r(8)),
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.person_outline_rounded,
                      label: 'owner_profile_title'.tr(context),
                      solidColor: const Color(0xFF7C3AED),
                      outlined: true,
                      onTap: () => _navigateToProfile(context),
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
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color solidColor;
  final VoidCallback onTap;
  final bool outlined;
  final bool enabled;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.solidColor,
    required this.onTap,
    this.outlined = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effective = enabled ? solidColor : Colors.grey.shade400;

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Material(
        color: outlined ? effective.withOpacity(0.07) : effective,
        borderRadius: BorderRadius.circular(context.r(14)),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(context.r(14)),
          child: Padding(
            padding: context.rSymmetric(horizontal: 8, vertical: 11),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: outlined ? effective : Colors.white,
                  size: context.r(20),
                ),
                SizedBox(height: context.r(4)),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(9.5),
                    fontWeight: FontWeight.w700,
                    color: outlined ? effective : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
