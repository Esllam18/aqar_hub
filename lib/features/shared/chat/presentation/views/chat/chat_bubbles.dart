// lib/features/shared/chat/presentation/views/chat/chat_bubbles.dart
//
// Message bubble dispatcher + Text, PropertyCard, Image bubbles.
// Video → chat_video_bubble.dart  |  Voice → chat_voice_bubble.dart
// 980 lines → ~250 lines.

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/home/data/models/property_model.dart';
import 'package:aqar_hub/features/house_seeker/home/presentation/views/property_details_view.dart';
import 'package:aqar_hub/features/shared/chat/data/models/chat_message_model.dart';
import 'package:aqar_hub/features/shared/chat/presentation/views/chat/chat_video_bubble.dart';
import 'package:aqar_hub/features/shared/chat/presentation/views/chat/chat_voice_bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

export 'chat_video_bubble.dart';
export 'chat_voice_bubble.dart';

// ── Dispatcher ────────────────────────────────────────────────────────────────

class MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMine;
  const MessageBubble({super.key, required this.message, required this.isMine});

  String _time(DateTime dt, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat.jm(locale).format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final isText =
        !message.isPropertyCard &&
        !message.isImage &&
        !message.isVideo &&
        !message.isVoice;

    Widget bubble;
    if (message.isPropertyCard) {
      bubble = PropertyCardBubble(meta: message.propertyCard!, isMine: isMine);
    } else if (message.isImage) {
      bubble = ImageBubble(url: message.mediaUrl ?? '', isMine: isMine);
    } else if (message.isVideo) {
      bubble = VideoBubble(
        url: message.mediaUrl,
        isMine: isMine,
        isPending: message.mediaUrl == null,
      );
    } else if (message.isVoice) {
      bubble = VoiceBubble(
        durationSecs: message.durationSecs ?? 0,
        isMine: isMine,
        mediaUrl: message.mediaUrl,
      );
    } else {
      bubble = TextBubble(
        text: message.content ?? '',
        isMine: isMine,
        time: _time(message.createdAt, context),
        isRead: message.isRead,
      );
    }

    Widget child = bubble;
    if (!isText) {
      child = Column(
        crossAxisAlignment: isMine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          bubble,
          Padding(
            padding: context.rOnly(top: 3, left: 4, right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _time(message.createdAt, context),
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(10),
                    color: Colors.grey.shade500,
                  ),
                ),
                if (isMine) ...[
                  SizedBox(width: context.r(4)),
                  Icon(
                    message.id.startsWith('pending_')
                        ? Icons.access_time_rounded
                        : Icons.done_all_rounded,
                    size: context.r(13),
                    color: message.id.startsWith('pending_')
                        ? Colors.grey.shade500
                        : message.isRead
                        ? const Color(0xFF34B7F1)
                        : Colors.grey.shade400,
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: context.rOnly(
          bottom: 4,
          left: isMine ? context.r(60) : 0,
          right: isMine ? 0 : context.r(60),
        ),
        child: child,
      ),
    );
  }
}

// ── Text bubble ───────────────────────────────────────────────────────────────

class TextBubble extends StatelessWidget {
  final String text;
  final bool isMine;
  final String time;
  final bool isRead;
  const TextBubble({
    super.key,
    required this.text,
    required this.isMine,
    required this.time,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: context.rOnly(bottom: 2),
      padding: context.rOnly(left: 12, right: 12, top: 8, bottom: 6),
      decoration: BoxDecoration(
        color: isMine ? const Color(0xFFDCF8C6) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.r(18)),
          topRight: Radius.circular(context.r(18)),
          bottomLeft: Radius.circular(isMine ? context.r(18) : context.r(4)),
          bottomRight: Radius.circular(isMine ? context.r(4) : context.r(18)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: GoogleFonts.tajawal(
              fontSize: context.sp(14),
              color: isMine ? const Color(0xFF1A3C2E) : const Color(0xFF1B2D5E),
              height: 1.4,
            ),
          ),
          SizedBox(height: context.r(2)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(10),
                  color: isMine
                      ? Colors.green.shade800.withValues(alpha: 0.65)
                      : Colors.grey.shade400,
                ),
              ),
              if (isMine) ...[
                SizedBox(width: context.r(3)),
                Icon(
                  Icons.done_all_rounded,
                  size: context.r(14),
                  color: isRead
                      ? const Color(0xFF34B7F1)
                      : Colors.grey.shade400,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Property card bubble ──────────────────────────────────────────────────────

class PropertyCardBubble extends StatelessWidget {
  final PropertyCardMeta meta;
  final bool isMine;
  const PropertyCardBubble({
    super.key,
    required this.meta,
    required this.isMine,
  });

  Future<void> _open(BuildContext context) async {
    // Show loading indicator while fetching full property data
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final data = await Supabase.instance.client
          .from('properties')
          .select(
            '*, rental_options(*), profiles!properties_owner_id_fkey(id,first_name,last_name,profile_image_url,phone_number)',
          )
          .eq('id', meta.propertyId)
          .maybeSingle();

      if (!context.mounted) return;
      Navigator.of(context).pop(); // close loading dialog

      if (data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم العثور على العقار'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final property = _buildPropertyModel(data);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PropertyDetailsView(property: property, fromChat: true),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل العقار: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  PropertyModel _buildPropertyModel(Map<String, dynamic> m) {
    final imageUrls = <String>[];
    final rawUrls = m['image_urls'];
    if (rawUrls is List) {
      imageUrls.addAll(rawUrls.map((e) => e.toString()));
    }
    return PropertyModel(
      id: m['id']?.toString() ?? meta.propertyId,
      ownerId: m['owner_id']?.toString() ?? '',
      title: m['title']?.toString() ?? meta.title,
      description: m['description']?.toString() ?? '',
      city: m['city']?.toString() ?? meta.city,
      address: m['address']?.toString() ?? '',
      latitude: (m['latitude'] as num?)?.toDouble(),
      longitude: (m['longitude'] as num?)?.toDouble(),
      totalRooms: m['total_rooms'] as int?,
      totalBeds: m['total_beds'] as int?,
      bathrooms: m['bathrooms'] as int?,
      areaM2: (m['area_m2'] as num?)?.toDouble(),
      isFurnished: m['is_furnished'] as bool? ?? false,
      listingType:
          m['listing_type']?.toString() ?? (meta.isForSale ? 'sale' : 'rent'),
      targetAudience: m['target_audience']?.toString() ?? 'all',
      propertyType: m['property_type']?.toString() ?? 'apartment',
      isRented: m['is_rented'] as bool? ?? false,
      basePrice: (m['base_price'] as num?)?.toDouble() ?? meta.price,
      imageUrls: imageUrls.isNotEmpty
          ? imageUrls
          : (meta.imageUrl != null ? [meta.imageUrl!] : []),
      videoUrl: m['video_url']?.toString(),
      governorateSlug: m['governorate_slug']?.toString(),
      citySlug: m['city_slug']?.toString(),
      locationPath: m['location_path']?.toString(),
      createdAt: m['created_at'] != null
          ? DateTime.parse(m['created_at'].toString())
          : DateTime.now(),
      amenities:
          (m['amenities'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImg = (meta.imageUrl ?? '').isNotEmpty;
    final price = meta.price;
    final priceStr = price != null
        ? '${price.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')} ${'currency'.tr(context)}'
        : null;

    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        width: context.r(240),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isMine ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(context.r(16)),
            topRight: Radius.circular(context.r(16)),
            bottomLeft: Radius.circular(isMine ? context.r(16) : context.r(4)),
            bottomRight: Radius.circular(isMine ? context.r(4) : context.r(16)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasImg)
              SizedBox(
                height: context.r(120),
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: meta.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: Colors.grey.shade200),
                  errorWidget: (_, __, ___) => const _CardPlaceholder(),
                ),
              )
            else
              _CardPlaceholder(height: context.r(70)),
            Container(
              width: double.infinity,
              color: AppColors.primary.withValues(alpha: 0.08),
              padding: context.rSymmetric(horizontal: 10, vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.home_work_outlined,
                    size: context.r(12),
                    color: AppColors.primary,
                  ),
                  SizedBox(width: context.r(4)),
                  Expanded(
                    child: Text(
                      isMine
                          ? 'chat_property_card_sent'.tr(context)
                          : 'chat_property_card_received'.tr(context),
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(10),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: context.rAll(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    meta.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(13),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B2D5E),
                    ),
                  ),
                  SizedBox(height: context.r(3)),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: context.r(11),
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(width: context.r(3)),
                      Expanded(
                        child: Text(
                          meta.city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(
                            fontSize: context.sp(11),
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (priceStr != null) ...[
                    SizedBox(height: context.r(4)),
                    Row(
                      children: [
                        Container(
                          padding: context.rSymmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (meta.isForSale
                                        ? const Color(0xFF1B2D5E)
                                        : const Color(0xFF25A244))
                                    .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(context.r(6)),
                          ),
                          child: Text(
                            meta.isForSale
                                ? 'listing_type_sale'.tr(context)
                                : 'listing_type_rent'.tr(context),
                            style: GoogleFonts.cairo(
                              fontSize: context.sp(9),
                              fontWeight: FontWeight.w700,
                              color: meta.isForSale
                                  ? const Color(0xFF1B2D5E)
                                  : const Color(0xFF25A244),
                            ),
                          ),
                        ),
                        SizedBox(width: context.r(6)),
                        Text(
                          priceStr,
                          style: GoogleFonts.cairo(
                            fontSize: context.sp(13),
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: context.r(8)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: context.r(7)),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(context.r(8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.open_in_new_rounded,
                          size: context.r(12),
                          color: AppColors.primary,
                        ),
                        SizedBox(width: context.r(4)),
                        Text(
                          'chat_view_property'.tr(context),
                          style: GoogleFonts.cairo(
                            fontSize: context.sp(11),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
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

class _CardPlaceholder extends StatelessWidget {
  final double? height;
  const _CardPlaceholder({this.height});

  @override
  Widget build(BuildContext context) => Container(
    height: height ?? context.r(70),
    width: double.infinity,
    color: AppColors.primary.withValues(alpha: 0.06),
    child: Icon(
      Icons.apartment_rounded,
      color: AppColors.primary.withValues(alpha: 0.4),
      size: context.r(36),
    ),
  );
}

// ── Image bubble ──────────────────────────────────────────────────────────────

class ImageBubble extends StatelessWidget {
  final String url;
  final bool isMine;
  const ImageBubble({super.key, required this.url, required this.isMine});

  void _open(BuildContext ctx) => Navigator.push(
    ctx,
    MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: InteractiveViewer(
            child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => _open(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.r(14)),
        child: CachedNetworkImage(
          imageUrl: url,
          width: context.r(200),
          height: context.r(160),
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            width: context.r(200),
            height: context.r(160),
            color: Colors.grey.shade300,
          ),
          errorWidget: (_, __, ___) => Container(
            width: context.r(200),
            height: context.r(160),
            color: Colors.grey.shade300,
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.grey.shade500,
              size: context.r(40),
            ),
          ),
        ),
      ),
    );
  }
}
