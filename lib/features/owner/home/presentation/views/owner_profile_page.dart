// lib/features/owner/home/presentation/views/owner_profile_page.dart
//
// Orchestrator only — 1,212 lines → ~160 lines.
// All UI widgets are in owner_profile/ subfolder.

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/home/data/models/property_model.dart';
import 'package:aqar_hub/features/house_seeker/home/presentation/views/property_details_view.dart';
import 'package:aqar_hub/features/owner/home/presentation/views/owner_profile/owner_profile_header.dart';
import 'package:aqar_hub/features/owner/home/presentation/views/owner_profile/owner_profile_widgets.dart';
import 'package:aqar_hub/features/shared/chat/chat_navigator.dart';
import 'package:aqar_hub/features/shared/profile/data/models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class OwnerProfilePage extends StatefulWidget {
  final String ownerId;
  final String? ownerName;
  final String? ownerPhone;
  final String? ownerAvatar;

  const OwnerProfilePage({
    super.key,
    required this.ownerId,
    this.ownerName,
    this.ownerPhone,
    this.ownerAvatar,
  });

  @override
  State<OwnerProfilePage> createState() => _OwnerProfilePageState();
}

class _OwnerProfilePageState extends State<OwnerProfilePage> {
  final _supabase = Supabase.instance.client;
  final _scrollCtrl = ScrollController();

  ProfileModel? _profile;
  String? _oauthAvatar;
  List<PropertyModel> _properties = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;

  static const _pageSize = 10;
  bool get _isSelf => _supabase.auth.currentUser?.id == widget.ownerId;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      ProfileModel? profile;
      try {
        final data = await _supabase
            .from('profiles')
            .select()
            .eq('id', widget.ownerId)
            .maybeSingle();
        if (data != null) profile = ProfileModel.fromMap(data);
      } catch (_) {}

      String? oauthAvatar;
      if ((profile?.profileImageUrl ?? '').isEmpty) {
        final cur = _supabase.auth.currentUser;
        if (cur?.id == widget.ownerId) {
          final meta = cur?.userMetadata ?? {};
          oauthAvatar = (meta['avatar_url'] as String? ?? '').isNotEmpty
              ? meta['avatar_url'] as String
              : (meta['picture'] as String? ?? '').isNotEmpty
              ? meta['picture'] as String
              : null;
        }
      }

      final raw = await _supabase
          .from('properties')
          .select('*, rental_options(*)')
          .eq('owner_id', widget.ownerId)
          .order('created_at', ascending: false)
          .range(0, _pageSize - 1);
      final props = (raw as List)
          .map((e) => PropertyModel.fromMap(e as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _oauthAvatar = oauthAvatar;
        _properties = props;
        _hasMore = props.length >= _pageSize;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final raw = await _supabase
          .from('properties')
          .select('*, rental_options(*)')
          .eq('owner_id', widget.ownerId)
          .order('created_at', ascending: false)
          .range(_properties.length, _properties.length + _pageSize - 1);
      final more = (raw as List)
          .map((e) => PropertyModel.fromMap(e as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() {
        _properties.addAll(more);
        _hasMore = more.length >= _pageSize;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  // ── Display helpers ─────────────────────────────────────────────────────────

  String get _displayName {
    final n = _profile?.fullName.trim() ?? '';
    if (n.isNotEmpty) return n;
    final fb = (widget.ownerName ?? '').trim();
    return fb.isNotEmpty ? fb : 'profile_unknown_name'.tr(context);
  }

  String? get _displayPhone => (_profile?.phoneNumber?.isNotEmpty == true)
      ? _profile!.phoneNumber
      : widget.ownerPhone;

  String? get _displayAvatar {
    final p = _profile?.profileImageUrl ?? '';
    if (p.isNotEmpty) return p;
    if ((_oauthAvatar ?? '').isNotEmpty) return _oauthAvatar;
    return widget.ownerAvatar;
  }

  String? get _displayCity => _profile?.city?.trim();
  String? get _displayEmail => _profile?.email?.trim();
  String? get _displayAddress => _profile?.address?.trim();

  String get _memberSince {
    if (_properties.isEmpty) return '—';
    final oldest = _properties.reduce(
      (a, b) => a.createdAt.isBefore(b.createdAt) ? a : b,
    );
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[oldest.createdAt.month]} ${oldest.createdAt.year}';
  }

  // Reads the actual DB role — never hardcoded.
  String get _roleLabel {
    if (_profile == null) return '';
    final r = _profile!.role ?? 'owner';
    return r == 'seeker' ? 'role_seeker'.tr(context) : 'role_owner'.tr(context);
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _openWhatsApp() async {
    final phone = _displayPhone;
    if (phone == null || phone.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('owner_no_phone'.tr(context)),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final number = clean.startsWith('20') ? clean : '20$clean';
    final uri = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callPhone() async {
    final phone = _displayPhone;
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openChat() => ChatNavigator.openChat(
    context,
    otherUserId: widget.ownerId,
    otherUserName: _displayName,
    otherUserAvatar: _displayAvatar,
  );

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) return const OwnerProfileSkeleton();
    if (_error != null) {
      return OwnerProfileErrorBody(error: _error!, onRetry: _load);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            OwnerProfileSliverHeader(
              displayName: _displayName,
              displayPhone: _displayPhone,
              displayAvatar: _displayAvatar,
              displayCity: _displayCity,
              displayEmail: _displayEmail,
              displayAddress: _displayAddress,
              roleLabel: _roleLabel,
              isSelf: _isSelf,
              memberSince: _memberSince,
              propertiesCount: _properties.length,
              onWhatsApp: _openWhatsApp,
              onCall: _callPhone,
              onChat: _isSelf ? null : _openChat,
            ),

            SliverToBoxAdapter(
              child: OwnerProfileStatsRow(
                propertiesCount: _properties.length,
                memberSince: _memberSince,
                city: _displayCity,
              ),
            ),

            if ((_displayEmail ?? '').isNotEmpty ||
                (_displayAddress ?? '').isNotEmpty)
              SliverToBoxAdapter(
                child: OwnerProfileInfoCard(
                  email: _displayEmail,
                  address: _displayAddress,
                ),
              ),

            // Section title
            if (_properties.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: context.rOnly(
                    left: 20,
                    right: 20,
                    top: 24,
                    bottom: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: context.r(4),
                        height: context.r(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(context.r(4)),
                        ),
                      ),
                      SizedBox(width: context.r(10)),
                      Text(
                        'owner_profile_listings'.tr(context),
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(16),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1B2D5E),
                        ),
                      ),
                      SizedBox(width: context.r(8)),
                      Container(
                        padding: context.rSymmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(context.r(8)),
                        ),
                        child: Text(
                          '${_properties.length}',
                          style: GoogleFonts.cairo(
                            fontSize: context.sp(12),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Property list
            if (_properties.isNotEmpty)
              SliverPadding(
                padding: context.rOnly(left: 16, right: 16, bottom: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => OwnerProfilePropertyCard(
                      property: _properties[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PropertyDetailsView(property: _properties[i]),
                        ),
                      ),
                    ),
                    childCount: _properties.length,
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: context.rOnly(top: 60, bottom: 40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.apartment_outlined,
                        size: context.r(48),
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: context.r(12)),
                      Text(
                        'owner_no_listings'.tr(context),
                        style: GoogleFonts.tajawal(
                          fontSize: context.sp(14),
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_loadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: context.rAll(16),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: context.r(18),
                          height: context.r(18),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: context.r(10)),
                        Text(
                          'owner_profile_pagination_loading'.tr(context),
                          style: GoogleFonts.tajawal(
                            fontSize: context.sp(12),
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            SliverToBoxAdapter(child: SizedBox(height: context.r(40))),
          ],
        ),
      ),
    );
  }
}
