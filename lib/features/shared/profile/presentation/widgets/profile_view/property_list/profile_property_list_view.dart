// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/home/data/models/property_model.dart';
import 'package:aqar_hub/features/house_seeker/home/presentation/views/property_details_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ProfilePropertyListType { favorites, owned }

class ProfilePropertyListView extends StatefulWidget {
  final String title;
  final String uid;
  final ProfilePropertyListType listType;

  const ProfilePropertyListView({
    super.key,
    required this.title,
    required this.uid,
    required this.listType,
  });

  @override
  State<ProfilePropertyListView> createState() => _State();
}

class _State extends State<ProfilePropertyListView> {
  final _supabase = Supabase.instance.client;
  final _scrollCtrl = ScrollController();
  List<PropertyModel> _items = [];
  bool _loading = true, _loadingMore = false, _hasMore = true;
  String? _error;
  static const _pageSize = 12;

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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _fetchPage(0);
      if (!mounted) return;
      setState(() {
        _items = items;
        _hasMore = items.length >= _pageSize;
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
      final more = await _fetchPage(_items.length);
      if (!mounted) return;
      setState(() {
        _items.addAll(more);
        _hasMore = more.length >= _pageSize;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<List<PropertyModel>> _fetchPage(int offset) async {
    if (widget.listType == ProfilePropertyListType.owned) {
      final raw = await _supabase
          .from('properties')
          .select('*, rental_options(*)')
          .eq('owner_id', widget.uid)
          .order('created_at', ascending: false)
          .range(offset, offset + _pageSize - 1);
      return (raw as List)
          .map((e) => PropertyModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } else {
      final raw = await _supabase
          .from('favorites')
          .select('properties(*, rental_options(*))')
          .eq('user_id', widget.uid)
          .order('created_at', ascending: false)
          .range(offset, offset + _pageSize - 1);
      return (raw as List)
          .map((e) {
            final prop = e['properties'] as Map<String, dynamic>?;
            return prop != null ? PropertyModel.fromMap(prop) : null;
          })
          .whereType<PropertyModel>()
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.cairo(
            fontSize: context.sp(17),
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
          ? _ErrorState(onRetry: _load)
          : _items.isEmpty
          ? _EmptyState(listType: widget.listType)
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _load,
              child: ListView.builder(
                controller: _scrollCtrl,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: context.rAll(16),
                itemCount: _items.length + (_loadingMore ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _items.length) {
                    return Padding(
                      padding: context.rAll(16),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }
                  return _PropertyCard(
                    property: _items[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PropertyDetailsView(property: _items[i]),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onTap;
  const _PropertyCard({required this.property, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final hasImg = property.firstImage != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: context.rOnly(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: context.r(10),
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(context.r(14)),
              ),
              child: SizedBox(
                width: context.r(96),
                height: context.r(96),
                child: hasImg
                    ? CachedNetworkImage(
                        imageUrl: property.firstImage!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _thumb(context),
                      )
                    : _thumb(context),
              ),
            ),
            SizedBox(width: context.r(12)),
            Expanded(
              child: Padding(
                padding: context.rOnly(right: 14, top: 12, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(13),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B2D5E),
                      ),
                    ),
                    SizedBox(height: context.r(4)),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: context.r(11),
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(width: context.r(3)),
                        Expanded(
                          child: Text(
                            property.city,
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
                    SizedBox(height: context.r(8)),
                    Text(
                      '${property.basePrice?.toStringAsFixed(0) ?? '—'} ${'currency'.tr(context)}',
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(13),
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumb(BuildContext context) => Container(
    color: AppColors.primary.withOpacity(0.07),
    child: Center(
      child: Icon(
        Icons.apartment_rounded,
        color: AppColors.primary.withOpacity(0.3),
        size: context.r(28),
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final ProfilePropertyListType listType;
  const _EmptyState({required this.listType});
  @override
  Widget build(BuildContext context) {
    final isFav = listType == ProfilePropertyListType.favorites;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFav ? Icons.favorite_border_rounded : Icons.apartment_outlined,
            size: context.r(60),
            color: Colors.grey.shade300,
          ),
          SizedBox(height: context.r(16)),
          Text(
            isFav
                ? 'profile_no_favorites'.tr(context)
                : 'profile_no_properties'.tr(context),
            style: GoogleFonts.tajawal(
              fontSize: context.sp(15),
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: context.r(48),
          color: Colors.redAccent,
        ),
        SizedBox(height: context.r(12)),
        Text(
          'err_unknown'.tr(context),
          style: GoogleFonts.tajawal(color: Colors.grey.shade500),
        ),
        SizedBox(height: context.r(16)),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 0,
          ),
          child: Text(
            'btnretry'.tr(context),
            style: GoogleFonts.cairo(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
