// lib/features/owner/home/presentation/views/owner_sale_properties_view.dart
//
// Orchestrator only — 814 lines → ~130 lines.
// Card extracted to owner_sale/sale_property_card.dart.

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/home/data/datasources/property_datasource_impl.dart';
import 'package:aqar_hub/features/house_seeker/home/data/models/property_filter_model.dart';
import 'package:aqar_hub/features/house_seeker/home/data/models/property_model.dart';
import 'package:aqar_hub/features/house_seeker/home/data/repositories/property_repository_impl.dart';
import 'package:aqar_hub/features/house_seeker/home/presentation/cubit/home_cubit.dart';
import 'package:aqar_hub/features/house_seeker/home/presentation/cubit/home_state.dart';
import 'package:aqar_hub/features/house_seeker/home/presentation/views/property_details_view.dart';
import 'package:aqar_hub/features/owner/owner_sale/presentation/widgets/owner_sale/sale_property_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerSalePropertiesView extends StatelessWidget {
  const OwnerSalePropertiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(PropertyRepositoryImpl(PropertyDatasourceImpl()))
        ..loadProperties(
          filter: const PropertyFilterModel.empty().copyWith(
            listingType: 'sale',
          ),
        ),
      child: const _SaleContent(),
    );
  }
}

// ── Content shell ─────────────────────────────────────────────────────────────

class _SaleContent extends StatelessWidget {
  const _SaleContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => switch (state) {
          HomeLoading() => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          HomeError(:final messageKey) => _ErrorView(messageKey: messageKey),
          HomeLoaded(:final properties) when properties.isEmpty =>
            const _EmptyView(),
          HomeLoadingMore(:final properties, :final hasMore) => _SaleList(
            properties: properties,
            hasMore: hasMore,
            loadingMore: true,
          ),
          HomeLoaded(:final properties, :final hasMore) => _SaleList(
            properties: properties,
            hasMore: hasMore,
            loadingMore: false,
          ),
          _ => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        },
      ),
    );
  }
}

// ── Scrollable list ───────────────────────────────────────────────────────────

class _SaleList extends StatefulWidget {
  final List<PropertyModel> properties;
  final bool hasMore;
  final bool loadingMore;
  const _SaleList({
    required this.properties,
    required this.hasMore,
    required this.loadingMore,
  });

  @override
  State<_SaleList> createState() => _SaleListState();
}

class _SaleListState extends State<_SaleList> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || widget.loadingMore) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      context.read<HomeCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<HomeCubit>().loadProperties(
        filter: const PropertyFilterModel.empty().copyWith(listingType: 'sale'),
      ),
      child: CustomScrollView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: _SaleHeader(count: widget.properties.length),
          ),
          SliverPadding(
            padding: context.rOnly(left: 16, right: 16, top: 8, bottom: 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: context.rOnly(bottom: 14),
                  child: SalePropertyCard(
                    property: widget.properties[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PropertyDetailsView(property: widget.properties[i]),
                      ),
                    ),
                  ),
                ),
                childCount: widget.properties.length,
              ),
            ),
          ),
          if (widget.loadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else if (!widget.hasMore && widget.properties.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'no_more_results'.tr(context),
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

// ── Gradient header ───────────────────────────────────────────────────────────

class _SaleHeader extends StatelessWidget {
  final int count;
  const _SaleHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF163F7A), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: context.r(160),
                height: context.r(160),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Padding(
              padding: context.rOnly(left: 20, right: 20, top: 16, bottom: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: context.r(44),
                                  height: context.r(44),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(
                                      context.r(14),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.sell_rounded,
                                    color: Colors.white,
                                    size: context.r(24),
                                  ),
                                ),
                                SizedBox(width: context.r(12)),
                                Text(
                                  'homefiltersale'.tr(context),
                                  style: GoogleFonts.cairo(
                                    fontSize: context.sp(22),
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.r(10)),
                            Text(
                              'sale_properties_hint'.tr(context),
                              style: GoogleFonts.tajawal(
                                fontSize: context.sp(12.5),
                                height: 1.5,
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: context.r(12)),
                      Container(
                        padding: context.rSymmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(context.r(16)),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$count',
                              style: GoogleFonts.cairo(
                                fontSize: context.sp(20),
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'listing_count_label'.tr(context),
                              style: GoogleFonts.tajawal(
                                fontSize: context.sp(10),
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.r(18)),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.verified_rounded,
                        label: 'sale_chip_verified'.tr(context),
                      ),
                      SizedBox(width: context.r(8)),
                      _InfoChip(
                        icon: Icons.handshake_rounded,
                        label: 'sale_chip_negotiable'.tr(context),
                      ),
                    ],
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rSymmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.r(20)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.r(13), color: Colors.white),
          SizedBox(width: context.r(5)),
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: context.sp(11),
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error / Empty ─────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String messageKey;
  const _ErrorView({required this.messageKey});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: context.r(52),
            color: Colors.grey.shade300,
          ),
          SizedBox(height: context.r(16)),
          Text(
            messageKey.tr(context),
            style: GoogleFonts.tajawal(
              color: Colors.grey.shade500,
              fontSize: context.sp(14),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.r(20)),
          ElevatedButton.icon(
            onPressed: () => context.read<HomeCubit>().loadProperties(
              filter: const PropertyFilterModel.empty().copyWith(
                listingType: 'sale',
              ),
            ),
            icon: Icon(Icons.refresh_rounded, size: context.r(18)),
            label: Text(
              'btn_retry'.tr(context),
              style: GoogleFonts.tajawal(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.r(80),
            height: context.r(80),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sell_outlined,
              size: context.r(38),
              color: const Color(0xFF7C3AED),
            ),
          ),
          SizedBox(height: context.r(20)),
          Text(
            'sale_empty_title'.tr(context),
            style: GoogleFonts.cairo(
              fontSize: context.sp(17),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B2D5E),
            ),
          ),
          SizedBox(height: context.r(8)),
          Text(
            'sale_empty_subtitle'.tr(context),
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: context.sp(13),
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
