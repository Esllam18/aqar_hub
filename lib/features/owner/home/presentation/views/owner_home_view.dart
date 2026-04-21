// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/features/owner/home/data/datasources/owner_properties_remote_datasource.dart';
import 'package:aqar_hub/features/owner/home/data/models/owner_property_model.dart';
import 'package:aqar_hub/features/owner/home/data/repositories/owner_properties_repository_impl.dart';
import 'package:aqar_hub/features/owner/home/presentation/cubit/owner_home_cubit.dart';
import 'package:aqar_hub/features/owner/home/presentation/widgets/owner_home/dashboard/owner_activity_tip.dart';
import 'package:aqar_hub/features/owner/home/presentation/widgets/owner_home/dashboard/owner_alerts_section.dart';
import 'package:aqar_hub/features/owner/home/presentation/widgets/owner_home/dashboard/owner_kpi_row.dart';
import 'package:aqar_hub/features/owner/home/presentation/widgets/owner_home/dashboard/owner_quick_actions.dart';
import 'package:aqar_hub/features/owner/home/presentation/widgets/owner_home/dashboard/owner_revenue_banner.dart';
import 'package:aqar_hub/features/owner/home/presentation/widgets/owner_home/dashboard/owner_section_header.dart';
import 'package:aqar_hub/features/owner/home/presentation/widgets/owner_home/edit_property_view.dart';
import 'package:aqar_hub/features/owner/home/presentation/widgets/owner_home/owner_empty_state.dart';
import 'package:aqar_hub/features/owner/home/presentation/widgets/owner_home/owner_filters_bar.dart';
import 'package:aqar_hub/features/owner/home/presentation/widgets/owner_home/owner_property_card.dart';
import 'package:aqar_hub/features/owner/home/presentation/widgets/shared/owner_error_view.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/features/owner/add_property/presentation/view/add_property_view.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/features/owner/owner_sale/presentation/cubit/owner_home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OwnerHomeView extends StatelessWidget {
  const OwnerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OwnerHomeCubit(
        OwnerPropertiesRepositoryImpl(OwnerPropertiesRemoteDatasource()),
      )..load(),
      child: const _OwnerHomeContent(),
    );
  }
}

// ── Content ───────────────────────────────────────────────────────────────────

class _OwnerHomeContent extends StatefulWidget {
  const _OwnerHomeContent();

  @override
  State<_OwnerHomeContent> createState() => _OwnerHomeContentState();
}

class _OwnerHomeContentState extends State<_OwnerHomeContent> {
  OwnerHomeFilter _filter = OwnerHomeFilter.all;
  List<OwnerPropertyModel> _applyFilter(List<OwnerPropertyModel> list) {
    return switch (_filter) {
      OwnerHomeFilter.all => list.toList(),
      OwnerHomeFilter.rent =>
        list.where((e) => e.listingType == 'rent').toList(),
      OwnerHomeFilter.sale =>
        list.where((e) => e.listingType == 'sale').toList(),
      OwnerHomeFilter.attention =>
        list.where((e) => e.alerts.any((a) => a.code != 'available')).toList(),
    };
  }

  void _openEdit(OwnerPropertyModel p) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditPropertyView(property: p)),
    );
    if (mounted) context.read<OwnerHomeCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<OwnerHomeCubit, OwnerHomeState>(
        builder: (context, state) {
          final loaded = state is OwnerHomeLoaded ? state : null;
          final all = loaded?.properties ?? [];
          final List<OwnerPropertyModel> filtered = loaded == null
              ? []
              : _applyFilter(all);
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: context.read<OwnerHomeCubit>().refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // ── Gradient header ──────────────────────────────────────
                SliverToBoxAdapter(child: _DashboardTop(state: state)),

                // ── Dashboard body ───────────────────────────────────────
                if (loaded != null) ...[
                  SliverToBoxAdapter(
                    child: OwnerRevenueBanner(
                      totalRevenue: loaded.totalRevenue,
                      alertsCount: loaded.alertsCount,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: OwnerQuickActions(
                      onAlertsTap: () =>
                          setState(() => _filter = OwnerHomeFilter.attention),
                    ),
                  ),
                ],

                // ── Filter bar ───────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _FilterSection(
                    selected: _filter,
                    title: 'owner_my_properties'.tr(context),
                    onChanged: (v) => setState(() => _filter = v),
                  ),
                ),

                // ── Tip card (below filter, above alerts) ────────────────
                if (loaded != null)
                  SliverToBoxAdapter(
                    child: OwnerActivityTip(
                      total: loaded.totalCount,
                      alerts: loaded.alertsCount,
                      available: loaded.availableCount,
                    ),
                  ),

                // ── Standalone alerts section ─────────────────────────────
                if (loaded != null && loaded.alertsCount > 0)
                  SliverToBoxAdapter(
                    child: OwnerAlertsSection(
                      properties: loaded.properties,
                      onViewAll: () =>
                          setState(() => _filter = OwnerHomeFilter.attention),
                    ),
                  ),

                // ── Body states ──────────────────────────────────────────
                if (state is OwnerHomeLoading)
                  _LoadingSliver()
                else if (state is OwnerHomeError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: OwnerErrorView(
                      message: state.message,
                      onRetry: context.read<OwnerHomeCubit>().load,
                    ),
                  )
                else if (loaded != null && all.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: OwnerEmptyState(
                      onAddTap: () => Navigation.to(const AddPropertyView()),
                    ),
                  )
                else if (loaded != null && filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: OwnerEmptyState(
                      isFilterEmpty: true,
                      filterName: _filter,
                    ),
                  )
                else
                  _PropertyList(properties: filtered, onEdit: _openEdit),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Dashboard top (gradient background with KPIs) ─────────────────────────────

class _DashboardTop extends StatelessWidget {
  final OwnerHomeState state;
  const _DashboardTop({required this.state});

  @override
  Widget build(BuildContext context) {
    final loaded = state is OwnerHomeLoaded ? state as OwnerHomeLoaded : null;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF163F7A), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _OwnerAppBar(),
            OwnerKpiRow(
              total: loaded?.totalCount ?? 0,
              available: loaded?.availableCount ?? 0,
              rented: loaded?.rentedCount ?? 0,
              sale: loaded?.saleCount ?? 0,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _OwnerAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          const Icon(
            Icons.dashboard_customize_rounded,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'nav_dashboard'.tr(context),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 20,
            ),
            tooltip: 'Refresh',
            onPressed: () => context.read<OwnerHomeCubit>().refresh(),
          ),
        ],
      ),
    );
  }
}

// ── Filter section ────────────────────────────────────────────────────────────

class _FilterSection extends StatelessWidget {
  final OwnerHomeFilter selected;
  final String title;
  final ValueChanged<OwnerHomeFilter> onChanged;

  const _FilterSection({
    required this.selected,
    required this.title,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OwnerSectionHeader(title: title),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Material(
            color: Colors.white,
            elevation: 1,
            shadowColor: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: OwnerFiltersBar(selected: selected, onChanged: onChanged),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────

class _LoadingSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => Container(
            margin: const EdgeInsets.only(bottom: 14),
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          childCount: 4,
        ),
      ),
    );
  }
}

// ── Property list ─────────────────────────────────────────────────────────────

class _PropertyList extends StatelessWidget {
  final List<OwnerPropertyModel> properties;
  final void Function(OwnerPropertyModel) onEdit;

  const _PropertyList({required this.properties, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OwnerHomeCubit>();
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((ctx, i) {
          final p = properties[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: OwnerPropertyCard(
              property: p,
              index: i,
              onSaveDescription: (id, desc) =>
                  cubit.saveDescription(propertyId: id, description: desc),
              onToggleRented: (id, v) =>
                  cubit.toggleRented(propertyId: id, isRented: v),
              onUpdateAvailability: (opt, qty) =>
                  cubit.updateOptionAvailability(
                    option: opt,
                    availableQuantity: qty,
                  ),
              onDelete: (id) => cubit.deleteProperty(id),
              onEdit: onEdit,
            ),
          );
        }, childCount: properties.length),
      ),
    );
  }
}
