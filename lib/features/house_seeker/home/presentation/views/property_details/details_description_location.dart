// ignore_for_file: deprecated_member_use

import 'dart:ui' as ui;
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/map/map_picker_screen.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Description ───────────────────────────────────────────────────────────────

class DetailsDescriptionSection extends StatelessWidget {
  final String description;
  final bool expanded;
  final VoidCallback onToggle;
  const DetailsDescriptionSection({
    super.key,
    required this.description,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (description.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      padding: context.rAll(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: context.r(14),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'details_description'.tr(context),
            style: GoogleFonts.cairo(
              fontSize: context.sp(15),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B2D5E),
            ),
          ),
          SizedBox(height: context.r(8)),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            child: Text(
              description,
              maxLines: expanded ? null : 4,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(13),
                color: Colors.grey.shade700,
                height: 1.7,
              ),
            ),
          ),
          if (description.trim().length > 140)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: onToggle,
                child: Text(
                  expanded
                      ? 'btn_show_less'.tr(context)
                      : 'btn_show_more'.tr(context),
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(12),
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Location card router ──────────────────────────────────────────────────────

class DetailsLocationCard extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final String? locationLink;

  const DetailsLocationCard({
    super.key,
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.locationLink,
  });

  bool get _hasCoords => latitude != null && longitude != null;

  String get _label =>
      [address, city].where((s) => s != null && s.isNotEmpty).join(', ');

  Future<void> _openExternal() async {
    Uri? uri;
    if (_hasCoords) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1'
        '&query=$latitude,$longitude',
      );
    } else if (locationLink != null && locationLink!.isNotEmpty) {
      uri = Uri.tryParse(locationLink!.trim());
    }
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openFullscreen(BuildContext ctx) {
    if (!_hasCoords) return;
    Navigator.push(
      ctx,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, a, __) => FadeTransition(
          opacity: a,
          child: MapPickerScreen(
            initialLat: latitude,
            initialLng: longitude,
            isReadOnly: true,
            title: _label.isNotEmpty ? _label : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasCoords) {
      return _PremiumMapCard(
        latitude: latitude!,
        longitude: longitude!,
        addressLabel: _label,
        onFullscreen: () => _openFullscreen(context),
        onExternal: _openExternal,
      );
    }
    return _LinkFallbackCard(address: _label, onOpen: _openExternal);
  }
}

// ── Premium map card ──────────────────────────────────────────────────────────

class _PremiumMapCard extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String addressLabel;
  final VoidCallback onFullscreen;
  final VoidCallback onExternal;

  const _PremiumMapCard({
    required this.latitude,
    required this.longitude,
    required this.addressLabel,
    required this.onFullscreen,
    required this.onExternal,
  });

  @override
  State<_PremiumMapCard> createState() => _PremiumMapCardState();
}

class _PremiumMapCardState extends State<_PremiumMapCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(widget.latitude, widget.longitude);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(20)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4B8C).withValues(alpha: 0.10),
            blurRadius: context.r(20),
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _CardHeader(
            addressLabel: widget.addressLabel,
            onExternal: widget.onExternal,
          ),

          // Map
          GestureDetector(
            onTap: widget.onFullscreen,
            child: SizedBox(
              height: context.r(210),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 15.5,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.aqarhub.app',
                        maxNativeZoom: 19,
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: center,
                            width: context.r(56),
                            height: context.r(72),
                            alignment: Alignment.topCenter,
                            child: _AnimatedPin(
                              pulse: _pulse,
                              size: context.r(56),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Top fade scrim
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: context.r(28),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.55),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Expand hint
                  Positioned(
                    bottom: context.r(12),
                    left: 0,
                    right: 0,
                    child: Center(child: _ExpandHint()),
                  ),
                ],
              ),
            ),
          ),

          // Footer
          _CardFooter(
            latitude: widget.latitude,
            longitude: widget.longitude,
            onFullscreen: widget.onFullscreen,
            onExternal: widget.onExternal,
          ),
        ],
      ),
    );
  }
}

// ── Card header ───────────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  final String addressLabel;
  final VoidCallback onExternal;
  const _CardHeader({required this.addressLabel, required this.onExternal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rOnly(left: 16, right: 14, top: 14, bottom: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            width: context.r(38),
            height: context.r(38),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A8A3C), Color(0xFF34A853)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(context.r(11)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF34A853).withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: Colors.white,
              size: context.r(18),
            ),
          ),
          SizedBox(width: context.r(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'details_location'.tr(context),
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B2D5E),
                    height: 1.2,
                  ),
                ),
                if (addressLabel.isNotEmpty) ...[
                  SizedBox(height: context.r(2)),
                  Text(
                    addressLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(11.5),
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onExternal,
            child: Container(
              padding: context.rSymmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF34A853).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(context.r(20)),
                border: Border.all(
                  color: const Color(0xFF34A853).withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.open_in_new_rounded,
                    size: context.r(11),
                    color: const Color(0xFF1A8A3C),
                  ),
                  SizedBox(width: context.r(4)),
                  Text(
                    'details_open_maps'.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A8A3C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated pulsing pin ──────────────────────────────────────────────────────

class _AnimatedPin extends StatelessWidget {
  final Animation<double> pulse;
  final double size;
  const _AnimatedPin({required this.pulse, required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        AnimatedBuilder(
          animation: pulse,
          builder: (_, __) => Opacity(
            opacity: (1 - pulse.value) * 0.30,
            child: Container(
              width: size * (1 + pulse.value * 0.55),
              height: size * (1 + pulse.value * 0.55),
              decoration: const BoxDecoration(
                color: Color(0xFF34A853),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size * 0.64,
              height: size * 0.64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A8A3C), Color(0xFF34A853)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF34A853).withValues(alpha: 0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: size * 0.30,
              ),
            ),
            CustomPaint(
              size: Size(size * 0.25, size * 0.18),
              painter: _PinTailPainter(),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Expand hint ───────────────────────────────────────────────────────────────

class _ExpandHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.r(20)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: context.rSymmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(context.r(20)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.open_in_full_rounded,
                color: Colors.white,
                size: context.r(12),
              ),
              SizedBox(width: context.r(5)),
              Text(
                'map_tap_to_expand'.tr(context),
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(11),
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Card footer ───────────────────────────────────────────────────────────────

class _CardFooter extends StatelessWidget {
  final double latitude;
  final double longitude;
  final VoidCallback onFullscreen;
  final VoidCallback onExternal;

  const _CardFooter({
    required this.latitude,
    required this.longitude,
    required this.onFullscreen,
    required this.onExternal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rSymmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF8),
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          // Coordinates micro-chip
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.my_location_rounded,
                  size: context.r(12),
                  color: Colors.grey.shade400,
                ),
                SizedBox(width: context.r(5)),
                Flexible(
                  child: Text(
                    '${latitude.toStringAsFixed(5)}, '
                    '${longitude.toStringAsFixed(5)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(10),
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.r(8)),
          _FooterBtn(
            icon: Icons.map_rounded,
            labelKey: 'map_view_title',
            color: AppColors.primary,
            onTap: onFullscreen,
          ),
          SizedBox(width: context.r(8)),
          _FooterBtn(
            icon: Icons.directions_rounded,
            labelKey: 'details_btn_location',
            color: const Color(0xFF34A853),
            onTap: onExternal,
          ),
        ],
      ),
    );
  }
}

class _FooterBtn extends StatefulWidget {
  final IconData icon;
  final String labelKey;
  final Color color;
  final VoidCallback onTap;
  const _FooterBtn({
    required this.icon,
    required this.labelKey,
    required this.color,
    required this.onTap,
  });

  @override
  State<_FooterBtn> createState() => _FooterBtnState();
}

class _FooterBtnState extends State<_FooterBtn> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: context.rSymmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _down ? 0.16 : 0.09),
            borderRadius: BorderRadius.circular(context.r(10)),
            border: Border.all(color: widget.color.withValues(alpha: 0.20)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: context.r(13), color: widget.color),
              SizedBox(width: context.r(5)),
              Text(
                widget.labelKey.tr(context),
                style: GoogleFonts.cairo(
                  fontSize: context.sp(11),
                  fontWeight: FontWeight.w700,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pin tail painter ──────────────────────────────────────────────────────────

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      ui.Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(size.width, 0)
        ..close(),
      Paint()..color = const Color(0xFF34A853),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Link-only fallback card ───────────────────────────────────────────────────

class _LinkFallbackCard extends StatefulWidget {
  final String address;
  final VoidCallback onOpen;
  const _LinkFallbackCard({required this.address, required this.onOpen});

  @override
  State<_LinkFallbackCard> createState() => _LinkFallbackCardState();
}

class _LinkFallbackCardState extends State<_LinkFallbackCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onOpen();
      },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: context.rAll(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.r(20)),
            border: Border.all(
              color: const Color(0xFF34A853).withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF34A853).withValues(alpha: 0.08),
                blurRadius: context.r(16),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: context.r(50),
                height: context.r(50),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A8A3C), Color(0xFF34A853)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(context.r(14)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF34A853).withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: context.r(24),
                ),
              ),
              SizedBox(width: context.r(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'details_location'.tr(context),
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(14),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B2D5E),
                      ),
                    ),
                    if (widget.address.isNotEmpty) ...[
                      SizedBox(height: context.r(3)),
                      Text(
                        widget.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(
                          fontSize: context.sp(12),
                          color: Colors.grey.shade500,
                          height: 1.4,
                        ),
                      ),
                    ],
                    SizedBox(height: context.r(6)),
                    Row(
                      children: [
                        Icon(
                          Icons.open_in_new_rounded,
                          size: context.r(11),
                          color: const Color(0xFF1A8A3C),
                        ),
                        SizedBox(width: context.r(4)),
                        Text(
                          'details_open_maps'.tr(context),
                          style: GoogleFonts.cairo(
                            fontSize: context.sp(11),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A8A3C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: context.r(32),
                height: context.r(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF34A853).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons.arrow_forward_ios_rounded,
                  size: context.r(13),
                  color: const Color(0xFF34A853),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Owner-only bottom bar ─────────────────────────────────────────────────────

class DetailsLocationOnlyBar extends StatefulWidget {
  final VoidCallback onLocation;
  const DetailsLocationOnlyBar({super.key, required this.onLocation});

  @override
  State<DetailsLocationOnlyBar> createState() => _DetailsLocationOnlyBarState();
}

class _DetailsLocationOnlyBarState extends State<DetailsLocationOnlyBar> {
  bool _loading = false;

  Future<void> _handle() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      widget.onLocation();
      await Future.delayed(const Duration(milliseconds: 600));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rOnly(
        left: 16,
        right: 16,
        top: 14,
        bottom: 14 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.r(24)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: context.r(18),
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: context.r(52),
        child: ElevatedButton.icon(
          onPressed: _loading ? null : _handle,
          icon: _loading
              ? SizedBox(
                  width: context.r(18),
                  height: context.r(18),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : Icon(Icons.directions_rounded, size: context.r(20)),
          label: Text(
            'details_btn_location'.tr(context),
            style: GoogleFonts.cairo(
              fontSize: context.sp(14),
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _loading
                ? const Color(0xFF1A8A3C).withValues(alpha: 0.65)
                : const Color(0xFF1A8A3C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.r(16)),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
