// lib/core/map/map_picker_screen.dart
//
// A fully self-contained in-app map picker.
// Uses flutter_map (OpenStreetMap tiles — no API key required) + Nominatim
// search + geolocator for GPS.
//
// Returns MapPickerResult via Navigator.pop when the user confirms.
// Can also be used as a read-only viewer (isReadOnly = true) for the details
// screen.

// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:ui' as ui;
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Result model returned to callers ─────────────────────────────────────────

class MapPickerResult {
  final double latitude;
  final double longitude;
  final String address;
  final String googleMapsUrl;

  const MapPickerResult({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.googleMapsUrl,
  });
}

// ── Screen ────────────────────────────────────────────────────────────────────

class MapPickerScreen extends StatefulWidget {
  /// Pre-selected coordinates (e.g. when editing an existing property).
  final double? initialLat;
  final double? initialLng;

  /// When true: no marker dragging, no search, no confirm button.
  /// Only the full-screen viewer + Open in Maps button are shown.
  final bool isReadOnly;

  /// Title shown in the app bar.
  final String? title;

  const MapPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
    this.isReadOnly = false,
    this.title,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  // ── Default: centre of Egypt ─────────────────────────────────────────────
  static const _defaultCenter = LatLng(26.82, 30.80);
  static const _defaultZoom = 6.0;
  static const _pickedZoom = 15.0;

  late final MapController _mapCtrl;
  LatLng? _picked;
  String _address = '';
  bool _loadingGps = false;
  bool _loadingAddress = false;

  // Search
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  List<_NominatimResult> _suggestions = [];
  bool _loadingSearch = false;

  @override
  void initState() {
    super.initState();
    _mapCtrl = MapController();
    if (widget.initialLat != null && widget.initialLng != null) {
      _picked = LatLng(widget.initialLat!, widget.initialLng!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_picked != null) {
        _mapCtrl.move(_picked!, _pickedZoom);
        if (!widget.isReadOnly) _reverseGeocode(_picked!);
      } else if (!widget.isReadOnly) {
        // Auto-jump to GPS when opening with no pre-selected location
        _useCurrentLocation();
      }
    });
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ── Google Maps link helper ───────────────────────────────────────────────

  String _googleMapsUrl(LatLng ll) =>
      'https://www.google.com/maps/search/?api=1'
      '&query=${ll.latitude},${ll.longitude}';

  // ── GPS ───────────────────────────────────────────────────────────────────

  Future<void> _useCurrentLocation() async {
    if (_loadingGps) return;
    setState(() => _loadingGps = true);
    try {
      // Check / request permission
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) _showError('map_perm_denied'.tr(context));
        return;
      }

      // Check GPS service
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) _showError('map_gps_disabled'.tr(context));
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      final ll = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() => _picked = ll);
      _mapCtrl.move(ll, _pickedZoom);
      await _reverseGeocode(ll);
    } catch (e) {
      if (mounted) _showError('map_gps_error'.tr(context));
    } finally {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  // ── Nominatim search ──────────────────────────────────────────────────────

  Future<void> _search(String query) async {
    if (query.trim().length < 2) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() => _loadingSearch = true);
    try {
      // Bias toward Egypt, request structured address data, increase limit
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeQueryComponent(query)}'
        '&format=json'
        '&limit=8'
        '&addressdetails=1'
        '&countrycodes=eg' // Egypt first
        '&accept-language=ar,en',
      );
      final res = await http
          .get(
            uri,
            headers: {'User-Agent': 'AqarHub/1.0 (contact@aqarhub.app)'},
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200 && mounted) {
        final raw = jsonDecode(res.body) as List;
        // If Egypt-specific search returns no results, retry globally
        if (raw.isEmpty) {
          _searchGlobal(query);
          return;
        }
        setState(() {
          _suggestions = List<Map<String, dynamic>>.from(
            raw,
          ).map<_NominatimResult>(_NominatimResult.fromJson).toList();
        });
      }
    } catch (_) {
      // Silently ignore — user can still tap the map
    } finally {
      if (mounted) setState(() => _loadingSearch = false);
    }
  }

  /// Fallback global search when Egypt-only returns nothing.
  Future<void> _searchGlobal(String query) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeQueryComponent(query)}'
        '&format=json'
        '&limit=6'
        '&addressdetails=1'
        '&accept-language=ar,en',
      );
      final res = await http
          .get(
            uri,
            headers: {'User-Agent': 'AqarHub/1.0 (contact@aqarhub.app)'},
          )
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200 && mounted) {
        final raw = jsonDecode(res.body) as List;
        setState(() {
          _suggestions = List<Map<String, dynamic>>.from(
            raw,
          ).map<_NominatimResult>(_NominatimResult.fromJson).toList();
        });
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingSearch = false);
    }
  }

  void _selectSuggestion(_NominatimResult r) {
    _searchFocus.unfocus();
    _searchCtrl.text = r.shortName;
    setState(() {
      _suggestions = [];
      _picked = r.latLng;
      _address = r.shortName;
    });
    _mapCtrl.move(r.latLng, _pickedZoom);
  }

  // ── Reverse geocoding ─────────────────────────────────────────────────────

  Future<void> _reverseGeocode(LatLng ll) async {
    setState(() => _loadingAddress = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${ll.latitude}&lon=${ll.longitude}'
        '&format=json&accept-language=ar,en',
      );
      final res = await http
          .get(
            uri,
            headers: {'User-Agent': 'AqarHub/1.0 (contact@aqarhub.app)'},
          )
          .timeout(const Duration(seconds: 6));
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() {
          _address = (data['display_name'] as String?) ?? '';
        });
      }
    } catch (_) {
      // Silently ignore — address is optional
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  // ── Open in external maps ─────────────────────────────────────────────────

  Future<void> _openExternal(LatLng ll) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${ll.latitude},${ll.longitude}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ── Confirm ───────────────────────────────────────────────────────────────

  void _confirm() {
    if (_picked == null) return;
    Navigator.pop(
      context,
      MapPickerResult(
        latitude: _picked!.latitude,
        longitude: _picked!.longitude,
        address: _address,
        googleMapsUrl: _googleMapsUrl(_picked!),
      ),
    );
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg, style: GoogleFonts.tajawal(color: Colors.white)),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final title =
        widget.title ??
        (widget.isReadOnly
            ? 'map_view_title'.tr(context)
            : 'map_picker_title'.tr(context));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Map ────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: _picked ?? _defaultCenter,
              initialZoom: _picked != null ? _pickedZoom : _defaultZoom,
              onTap: widget.isReadOnly
                  ? null
                  : (_, ll) {
                      setState(() {
                        _picked = ll;
                        _suggestions = [];
                        _searchFocus.unfocus();
                      });
                      _reverseGeocode(ll);
                    },
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.aqarhub.app',
                maxNativeZoom: 19,
              ),
              if (_picked != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _picked!,
                      width: context.r(50),
                      height: context.r(60),
                      alignment: Alignment.topCenter,
                      child: _MapMarker(isReadOnly: widget.isReadOnly),
                    ),
                  ],
                ),
            ],
          ),

          // ── Top bar ────────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: context.rAll(12),
                child: Column(
                  children: [
                    // Title + back
                    Row(
                      children: [
                        _CircleMapBtn(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        SizedBox(width: context.r(10)),
                        Expanded(
                          child: Container(
                            padding: context.rSymmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                context.r(14),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              title,
                              style: GoogleFonts.cairo(
                                fontSize: context.sp(15),
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1B2D5E),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Search field (picker only)
                    if (!widget.isReadOnly) ...[
                      SizedBox(height: context.r(10)),
                      _SearchField(
                        controller: _searchCtrl,
                        focusNode: _searchFocus,
                        isLoading: _loadingSearch,
                        onChanged: _search,
                        onClear: () {
                          _searchCtrl.clear();
                          setState(() => _suggestions = []);
                        },
                      ),

                      // Search suggestions
                      if (_suggestions.isNotEmpty)
                        Container(
                          margin: context.rOnly(top: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(context.r(14)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          constraints: BoxConstraints(
                            maxHeight: context.r(220),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: context.rSymmetric(vertical: 6),
                            itemCount: _suggestions.length,
                            separatorBuilder: (_, __) =>
                                Divider(height: 1, color: Colors.grey.shade100),
                            itemBuilder: (_, i) {
                              final s = _suggestions[i];
                              return ListTile(
                                dense: true,
                                leading: Icon(
                                  Icons.place_rounded,
                                  size: context.r(18),
                                  color: AppColors.primary,
                                ),
                                title: Text(
                                  s.shortName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cairo(
                                    fontSize: context.sp(12.5),
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1B2D5E),
                                  ),
                                ),
                                subtitle: s.displayName != s.shortName
                                    ? Text(
                                        s.displayName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.tajawal(
                                          fontSize: context.sp(10.5),
                                          color: Colors.grey.shade500,
                                        ),
                                      )
                                    : null,
                                onTap: () => _selectSuggestion(s),
                              );
                            },
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── Right-side FABs ────────────────────────────────────────────
          Positioned(
            right: context.r(14),
            bottom: widget.isReadOnly ? context.r(90) : context.r(160),
            child: Column(
              children: [
                // Open in Google Maps (read-only mode)
                if (widget.isReadOnly && _picked != null)
                  _MapFab(
                    icon: Icons.open_in_new_rounded,
                    tooltip: 'map_open_external'.tr(context),
                    onTap: () => _openExternal(_picked!),
                    color: const Color(0xFF34A853),
                  ),
                if (!widget.isReadOnly) ...[
                  // GPS button
                  _MapFab(
                    icon: _loadingGps ? null : Icons.my_location_rounded,
                    tooltip: 'map_use_location'.tr(context),
                    isLoading: _loadingGps,
                    onTap: _useCurrentLocation,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: context.r(10)),
                ],
                // Zoom in
                _MapFab(
                  icon: Icons.add_rounded,
                  tooltip: '',
                  onTap: () {
                    final z = _mapCtrl.camera.zoom;
                    _mapCtrl.move(_mapCtrl.camera.center, z + 1);
                  },
                ),
                SizedBox(height: context.r(6)),
                // Zoom out
                _MapFab(
                  icon: Icons.remove_rounded,
                  tooltip: '',
                  onTap: () {
                    final z = _mapCtrl.camera.zoom;
                    _mapCtrl.move(_mapCtrl.camera.center, z - 1);
                  },
                ),
              ],
            ),
          ),

          // ── Bottom panel ───────────────────────────────────────────────
          if (!widget.isReadOnly)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _PickerBottomPanel(
                picked: _picked,
                address: _address,
                isLoadingAddress: _loadingAddress,
                onConfirm: _confirm,
              ),
            ),

          // Read-only address chip at bottom
          if (widget.isReadOnly && _address.isNotEmpty)
            Positioned(
              bottom: context.r(20) + MediaQuery.paddingOf(context).bottom,
              left: context.r(16),
              right: context.r(16),
              child: Container(
                padding: context.rAll(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(context.r(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: const Color(0xFF34A853),
                      size: context.r(20),
                    ),
                    SizedBox(width: context.r(10)),
                    Expanded(
                      child: Text(
                        _address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(
                          fontSize: context.sp(12),
                          color: const Color(0xFF1B2D5E),
                        ),
                      ),
                    ),
                    if (_picked != null)
                      GestureDetector(
                        onTap: () => _openExternal(_picked!),
                        child: Container(
                          padding: context.rSymmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF34A853).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(context.r(8)),
                          ),
                          child: Text(
                            'details_open_maps'.tr(context),
                            style: GoogleFonts.cairo(
                              fontSize: context.sp(11),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF34A853),
                            ),
                          ),
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

// ── Animated pin marker ───────────────────────────────────────────────────────

class _MapMarker extends StatelessWidget {
  final bool isReadOnly;
  const _MapMarker({required this.isReadOnly});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: context.r(36),
          height: context.r(36),
          decoration: BoxDecoration(
            color: isReadOnly ? const Color(0xFF34A853) : AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color:
                    (isReadOnly ? const Color(0xFF34A853) : AppColors.primary)
                        .withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.location_on_rounded,
            color: Colors.white,
            size: context.r(18),
          ),
        ),
        // Pointer triangle
        ClipPath(
          clipper: _TriangleClipper(),
          child: Container(
            width: context.r(14),
            height: context.r(9),
            color: isReadOnly ? const Color(0xFF34A853) : AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _TriangleClipper extends CustomClipper<ui.Path> {
  @override
  ui.Path getClip(Size size) => ui.Path()
    ..moveTo(0, 0)
    ..lineTo(size.width / 2, size.height)
    ..lineTo(size.width, 0)
    ..close();

  @override
  bool shouldReclip(_) => false;
}

// ── Search field ──────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: GoogleFonts.tajawal(
          fontSize: context.sp(13),
          color: const Color(0xFF1B2D5E),
        ),
        decoration: InputDecoration(
          hintText: 'map_search_hint'.tr(context),
          hintStyle: GoogleFonts.tajawal(
            fontSize: context.sp(13),
            color: Colors.grey.shade400,
          ),
          prefixIcon: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: context.r(20),
                ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: context.r(18),
                    color: Colors.grey.shade400,
                  ),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: context.rSymmetric(horizontal: 4, vertical: 14),
        ),
      ),
    );
  }
}

// ── Circular map button ───────────────────────────────────────────────────────

class _CircleMapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleMapBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.r(44),
        height: context.r(44),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: context.r(20), color: const Color(0xFF1B2D5E)),
      ),
    );
  }
}

// ── FAB button ────────────────────────────────────────────────────────────────

class _MapFab extends StatelessWidget {
  final IconData? icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isLoading;
  final Color color;

  const _MapFab({
    this.icon,
    required this.tooltip,
    required this.onTap,
    this.isLoading = false,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          width: context.r(44),
          height: context.r(44),
          decoration: BoxDecoration(
            color: color == Colors.white ? Colors.white : color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: isLoading
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color == Colors.white
                        ? AppColors.primary
                        : Colors.white,
                  ),
                )
              : Icon(
                  icon,
                  size: context.r(20),
                  color: color == Colors.white
                      ? const Color(0xFF1B2D5E)
                      : Colors.white,
                ),
        ),
      ),
    );
  }
}

// ── Bottom panel shown in picker mode ─────────────────────────────────────────

class _PickerBottomPanel extends StatelessWidget {
  final LatLng? picked;
  final String address;
  final bool isLoadingAddress;
  final VoidCallback onConfirm;

  const _PickerBottomPanel({
    required this.picked,
    required this.address,
    required this.isLoadingAddress,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rOnly(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.r(24)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: context.r(40),
              height: context.r(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(context.r(4)),
              ),
            ),
          ),
          SizedBox(height: context.r(14)),

          if (picked == null) ...[
            Row(
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  color: Colors.grey.shade400,
                  size: context.r(20),
                ),
                SizedBox(width: context.r(10)),
                Text(
                  'map_tap_to_pin'.tr(context),
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(13),
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: const Color(0xFF34A853),
                  size: context.r(20),
                ),
                SizedBox(width: context.r(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'map_selected_location'.tr(context),
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(11),
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: context.r(2)),
                      if (isLoadingAddress)
                        Row(
                          children: [
                            SizedBox(
                              width: context.r(14),
                              height: context.r(14),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: context.r(8)),
                            Text(
                              'map_loading_address'.tr(context),
                              style: GoogleFonts.tajawal(
                                fontSize: context.sp(12),
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          address.isNotEmpty
                              ? address
                              : '${picked!.latitude.toStringAsFixed(5)}, '
                                    '${picked!.longitude.toStringAsFixed(5)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(
                            fontSize: context.sp(13),
                            color: const Color(0xFF1B2D5E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: context.r(14)),
            SizedBox(
              width: double.infinity,
              height: context.r(52),
              child: ElevatedButton.icon(
                onPressed: onConfirm,
                icon: Icon(Icons.check_circle_rounded, size: context.r(20)),
                label: Text(
                  'map_confirm_location'.tr(context),
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.r(16)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Nominatim search result model ─────────────────────────────────────────────

class _NominatimResult {
  final String displayName;
  final String shortName;
  final LatLng latLng;

  const _NominatimResult({
    required this.displayName,
    required this.shortName,
    required this.latLng,
  });

  factory _NominatimResult.fromJson(Map<String, dynamic> m) {
    final full = m['display_name'] as String? ?? '';
    // Build a concise label from structured address fields when available
    final addr = m['address'] as Map<String, dynamic>? ?? {};
    final parts = <String>[];
    for (final key in [
      'road',
      'suburb',
      'neighbourhood',
      'quarter',
      'city',
      'town',
      'village',
      'county',
      'state',
    ]) {
      final v = addr[key] as String?;
      if (v != null && v.isNotEmpty && !parts.contains(v)) parts.add(v);
      if (parts.length >= 3) break;
    }
    final short = parts.isNotEmpty
        ? parts.join('، ')
        : full.split(',').take(2).join(',').trim();

    return _NominatimResult(
      displayName: full,
      shortName: short.isNotEmpty ? short : full,
      latLng: LatLng(
        double.tryParse(m['lat']?.toString() ?? '0') ?? 0,
        double.tryParse(m['lon']?.toString() ?? '0') ?? 0,
      ),
    );
  }
}
