// lib/features/house_seeker/home/presentation/views/property_details_view.dart
//
// Orchestrator only — all UI sections are in property_details/ subfolder.
// 1,362 lines → ~130 lines.

import 'package:aqar_hub/core/animations/app_animations.dart';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/home/data/models/property_model.dart';
import 'package:aqar_hub/features/house_seeker/home/presentation/views/property_details/details_description_location.dart';
import 'package:aqar_hub/features/house_seeker/home/presentation/views/property_details/details_gallery.dart';
import 'package:aqar_hub/features/house_seeker/home/presentation/views/property_details/details_header_section.dart';
import 'package:aqar_hub/features/house_seeker/home/presentation/views/property_details/details_stats_amenities.dart';
import 'package:aqar_hub/features/house_seeker/home/presentation/views/property_details/details_video_player.dart';
import 'package:aqar_hub/features/owner/home/presentation/widgets/owner_home/details_owner_card.dart';
import 'package:aqar_hub/features/shared/chat/chat_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/property_details/details_action_buttons.dart';
import '../widgets/property_details/details_info_row.dart';
import '../widgets/property_details/details_rental_options.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';

class PropertyDetailsView extends StatefulWidget {
  final PropertyModel property;

  /// True when navigating here from chat — hides owner card + contact buttons.
  final bool fromChat;

  const PropertyDetailsView({
    super.key,
    required this.property,
    this.fromChat = false,
  });

  @override
  State<PropertyDetailsView> createState() => _PropertyDetailsViewState();
}

class _PropertyDetailsViewState extends State<PropertyDetailsView> {
  bool _descExpanded = false;

  bool get _isOwner =>
      widget.fromChat ||
      widget.property.ownerId.isEmpty ||
      Supabase.instance.client.auth.currentUser?.id == widget.property.ownerId;

  Future<void> _openWhatsApp(String? phone) async {
    if (phone == null || phone.trim().isEmpty) return;
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final number = clean.startsWith('0')
        ? '2$clean'
        : clean.startsWith('20')
        ? clean
        : '20$clean';
    final appUri = Uri.parse('whatsapp://send?phone=$number');
    final webUri = Uri.parse('https://wa.me/$number');
    if (!await launchUrl(appUri, mode: LaunchMode.externalApplication)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openMap(double? lat, double? lng, String title) async {
    if (lat == null || lng == null) return;
    final geoUri = Uri.parse(
      'geo:$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(title)})',
    );
    final webUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    try {
      await launchUrl(geoUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  void _openChat(BuildContext ctx) => ChatNavigator.openChat(
    ctx,
    otherUserId: widget.property.ownerId,
    otherUserName: widget.property.ownerName ?? '',
    otherUserAvatar: widget.property.ownerAvatar,
    property: widget.property,
  );

  @override
  Widget build(BuildContext context) {
    final p = widget.property;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            DetailsGallerySliver(
              imageUrls: p.imageUrls,
              onBack: Navigation.back,
            ),
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: Offset(0, -context.r(14)),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(context.r(28)),
                    ),
                  ),
                  child: Padding(
                    padding: context.rOnly(
                      left: 20,
                      right: 20,
                      top: 10,
                      bottom: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: context.r(20)),
                        AppAnimations.combined(
                          type: CombineType.fadeSlide,
                          duration: const Duration(milliseconds: 350),
                          child: DetailsHeaderSection(property: p),
                        ),
                        SizedBox(height: context.r(14)),
                        AppAnimations.fade(
                          duration: const Duration(milliseconds: 350),
                          delay: const Duration(milliseconds: 50),
                          child: DetailsInfoRow(property: p),
                        ),
                        SizedBox(height: context.r(16)),
                        AppAnimations.fade(
                          duration: const Duration(milliseconds: 350),
                          delay: const Duration(milliseconds: 90),
                          child: DetailsQuickStats(property: p),
                        ),
                        if ((p.amenities).isNotEmpty) ...[
                          SizedBox(height: context.r(18)),
                          AppAnimations.fade(
                            duration: const Duration(milliseconds: 350),
                            delay: const Duration(milliseconds: 110),
                            child: DetailsAmenitiesSection(
                              amenities: p.amenities,
                            ),
                          ),
                        ],
                        if ((p.videoUrl ?? '').trim().isNotEmpty) ...[
                          SizedBox(height: context.r(18)),
                          AppAnimations.fade(
                            duration: const Duration(milliseconds: 350),
                            delay: const Duration(milliseconds: 120),
                            child: DetailsVideoPlayer(url: p.videoUrl!),
                          ),
                        ],
                        if (p.latitude != null && p.longitude != null) ...[
                          SizedBox(height: context.r(18)),
                          AppAnimations.fade(
                            duration: const Duration(milliseconds: 350),
                            delay: const Duration(milliseconds: 130),
                            child: DetailsLocationCard(
                              address: p.address.isNotEmpty ? p.address : null,
                              city: p.city.isNotEmpty ? p.city : null,
                              onOpen: () =>
                                  _openMap(p.latitude, p.longitude, p.title),
                            ),
                          ),
                        ],
                        SizedBox(height: context.r(18)),
                        AppAnimations.fade(
                          duration: const Duration(milliseconds: 350),
                          delay: const Duration(milliseconds: 140),
                          child: DetailsDescriptionSection(
                            description: p.description,
                            expanded: _descExpanded,
                            onToggle: () =>
                                setState(() => _descExpanded = !_descExpanded),
                          ),
                        ),
                        if (p.rentalOptions.isNotEmpty) ...[
                          SizedBox(height: context.r(18)),
                          AppAnimations.fade(
                            duration: const Duration(milliseconds: 350),
                            delay: const Duration(milliseconds: 170),
                            child: DetailsRentalOptions(
                              options: p.rentalOptions,
                            ),
                          ),
                        ],
                        if (!_isOwner) ...[
                          SizedBox(height: context.r(18)),
                          AppAnimations.fade(
                            duration: const Duration(milliseconds: 350),
                            delay: const Duration(milliseconds: 200),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'details_owner'.tr(context),
                                  style: GoogleFonts.cairo(
                                    fontSize: context.sp(15),
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1B2D5E),
                                  ),
                                ),
                                SizedBox(height: context.r(10)),
                                DetailsOwnerCard(property: p),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: context.r(100)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _isOwner
            ? DetailsLocationOnlyBar(
                onLocation: () => _openMap(p.latitude, p.longitude, p.title),
              )
            : DetailsActionButtons(
                onWhatsApp: () => _openWhatsApp(p.ownerPhone),
                onLocation: () => _openMap(p.latitude, p.longitude, p.title),
                onChat: () => _openChat(context),
              ),
      ),
    );
  }
}
