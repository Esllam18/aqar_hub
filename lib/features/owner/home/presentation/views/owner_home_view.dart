// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/features/owner/home/data/datasources/owner_properties_remote_datasource.dart';
import 'package:aqar_hub/features/owner/home/data/models/owner_property_model.dart';
import 'package:aqar_hub/features/owner/home/data/repositories/owner_properties_repository_impl.dart';
import 'package:aqar_hub/features/owner/home/presentation/cubit/owner_home_cubit.dart';
import 'package:aqar_hub/features/owner/home/presentation/widgets/owner_home/dashboard/owner_activity_tip.dart';
import 'package:aqar_hub/features/owner/home/presentation/widgets/owner_home/dashboard/owner_alerts_section.dart';
import 'package:aqar_hub/features/owner/home/presentation/widgets/owner_home/dashboard/owner_comments_section.dart';
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
import 'package:aqar_hub/features/shared/notifications/notification_center/notification_center_cubit.dart';
import 'package:aqar_hub/features/shared/notifications/notification_center/notification_center_view.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class _OwnerHomeContent extends StatefulWidget {
  const _OwnerHomeContent();

  @override
  State<_OwnerHomeContent> createState() => _OwnerHomeContentState();
}

class _OwnerHomeContentState extends State<_OwnerHomeContent> {
  OwnerHomeFilter _filter = OwnerHomeFilter.all;

  List<OwnerPropertyModel> _applyFilter(List<OwnerPropertyModel> list) {
    return switch (_filter) {
      // Properties-only tabs — pure filtering, NO alerts/comments mixed in
      OwnerHomeFilter.all => list.toList(),
      OwnerHomeFilter.rent =>
        list.where((e) => e.listingType == 'rent').toList(),
      OwnerHomeFilter.sale =>
        list.where((e) => e.listingType == 'sale').toList(),
      // Notifications tab — properties list is intentionally NOT shown here
      OwnerHomeFilter.notificationsAndComments => [],
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

          // Is the current tab the notification+comments tab?
          final isNotifTab =
              _filter == OwnerHomeFilter.notificationsAndComments;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: context.read<OwnerHomeCubit>().refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // ── Premium hero header ────────────────────────────────
                SliverToBoxAdapter(child: _OwnerHeroHeader(state: state)),

                // ── Revenue banner + quick actions (always visible) ────
                if (loaded != null) ...[
                  SliverToBoxAdapter(
                    child: OwnerRevenueBanner(
                      totalRevenue: loaded.totalRevenue,
                      alertsCount: loaded.alertsCount,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: OwnerQuickActions(
                      onAlertsTap: () => setState(
                        () =>
                            _filter = OwnerHomeFilter.notificationsAndComments,
                      ),
                    ),
                  ),
                ],

                // ── Section header + filter bar ────────────────────────
                SliverToBoxAdapter(
                  child: _FilterSection(
                    selected: _filter,
                    title: 'owner_my_properties'.tr(context),
                    onChanged: (v) => setState(() => _filter = v),
                  ),
                ),

                // ════════════════════════════════════════════════════════
                // NOTIFICATIONS & COMMENTS TAB — dedicated content only
                // ════════════════════════════════════════════════════════
                if (isNotifTab) ...[
                  if (loaded != null) ...[
                    // Alerts section
                    if (loaded.alertsCount > 0)
                      SliverToBoxAdapter(
                        child: OwnerAlertsSection(
                          properties: loaded.properties,
                          onViewAll: () {},
                        ),
                      ),
                    // Comments section
                    const SliverToBoxAdapter(child: OwnerCommentsSection()),
                    // Empty message if nothing to show
                    if (loaded.alertsCount == 0)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _NotifTabEmptyState(),
                      ),
                  ] else if (state is OwnerHomeLoading)
                    _LoadingSliver()
                  else if (state is OwnerHomeError)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: OwnerErrorView(
                        message: state.message,
                        onRetry: context.read<OwnerHomeCubit>().load,
                      ),
                    ),

                  SliverToBoxAdapter(child: SizedBox(height: context.r(150))),
                ]
                // ════════════════════════════════════════════════════════
                // PROPERTIES TABS — only property cards, no notifications
                // ════════════════════════════════════════════════════════
                else ...[
                  // Activity tip (only on all/rent/sale tabs)
                  if (loaded != null)
                    SliverToBoxAdapter(
                      child: OwnerActivityTip(
                        total: loaded.totalCount,
                        alerts: loaded.alertsCount,
                        available: loaded.availableCount,
                      ),
                    ),

                  // States
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
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Premium hero header ───────────────────────────────────────────────────────

class _OwnerHeroHeader extends StatelessWidget {
  final OwnerHomeState state;
  const _OwnerHeroHeader({required this.state});

  String _greeting(BuildContext context) {
    final h = DateTime.now().hour;
    if (h < 12) return 'greeting_morning'.tr(context);
    if (h < 17) return 'greeting_afternoon'.tr(context);
    return 'greeting_evening'.tr(context);
  }

  String _ownerFirstName() {
    final meta = Supabase.instance.client.auth.currentUser?.userMetadata ?? {};
    final first = (meta['first_name'] as String? ?? '').trim();
    return first.isNotEmpty ? first : '';
  }

  String _todayLabel() {
    final now = DateTime.now();
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
    return '${now.day} ${months[now.month]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final loaded = state is OwnerHomeLoaded ? state as OwnerHomeLoaded : null;
    final name = _ownerFirstName();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF102848), Color(0xFF1E5FAD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar: greeting + bell ────────────────────────────────
            Padding(
              padding: context.rOnly(left: 20, right: 16, top: 16, bottom: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting line
                        Row(
                          children: [
                            _greetingIcon(context),
                            SizedBox(width: context.r(8)),
                            Expanded(
                              child: Text(
                                name.isNotEmpty
                                    ? '${_greeting(context)}، $name'
                                    : _greeting(context),
                                style: GoogleFonts.cairo(
                                  fontSize: context.sp(17),
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.r(4)),
                        // Subtitle
                        Text(
                          'owner_hero_subtitle'.tr(context),
                          style: GoogleFonts.tajawal(
                            fontSize: context.sp(12),
                            color: Colors.white.withOpacity(0.78),
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: context.r(6)),
                        // Date chip
                        Container(
                          padding: context.rSymmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(context.r(20)),
                          ),
                          child: Text(
                            _todayLabel(),
                            style: GoogleFonts.tajawal(
                              fontSize: context.sp(10.5),
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: context.r(12)),
                  // Notification bell
                  _NotificationBell(),
                ],
              ),
            ),

            SizedBox(height: context.r(20)),

            // ── KPI cards ───────────────────────────────────────────────
            OwnerKpiRow(
              total: loaded?.totalCount ?? 0,
              available: loaded?.availableCount ?? 0,
              rented: loaded?.rentedCount ?? 0,
              sale: loaded?.saleCount ?? 0,
            ),

            SizedBox(height: context.r(20)),
          ],
        ),
      ),
    );
  }

  Widget _greetingIcon(BuildContext context) {
    final h = DateTime.now().hour;
    final icon = h < 12
        ? Icons.wb_sunny_rounded
        : h < 17
        ? Icons.wb_cloudy_rounded
        : Icons.nightlight_round;
    final color = h < 12
        ? const Color(0xFFFFD54F)
        : h < 17
        ? const Color(0xFF90CAF9)
        : const Color(0xFFB39DDB);

    return Container(
      width: context.r(32),
      height: context.r(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(context.r(9)),
      ),
      child: Icon(icon, size: context.r(18), color: color),
    );
  }
}

// ── Notification bell with badge ──────────────────────────────────────────────

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCenterCubit, NotificationCenterState>(
      builder: (ctx, notifState) {
        final unread = notifState is NotificationCenterLoaded
            ? notifState.unreadCount
            : 0;
        return GestureDetector(
          onTap: () =>
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: ctx.read<NotificationCenterCubit>(),
                    child: NotificationCenterView(onSwitchTab: (_) {}),
                  ),
                ),
              ).then((_) {
                // ignore: use_build_context_synchronously
                ctx.read<NotificationCenterCubit>().load();
              }),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: context.r(44),
                height: context.r(44),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(context.r(13)),
                  border: Border.all(color: Colors.white.withOpacity(0.22)),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: context.r(22),
                ),
              ),
              if (unread > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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
          padding: context.rSymmetric(horizontal: 16, vertical: 4),
          child: Material(
            color: Colors.white,
            elevation: 1,
            shadowColor: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(context.r(18)),
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

// ── Notification tab empty state ──────────────────────────────────────────────

class _NotifTabEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.rOnly(left: 16, right: 16, top: 4, bottom: 120),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: context.r(76),
                height: context.r(76),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  size: context.r(36),
                  color: AppColors.success,
                ),
              ),
              SizedBox(height: context.r(18)),
              Text(
                'owner_notif_tab_empty_title'.tr(context),
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B2D5E),
                ),
              ),
              SizedBox(height: context.r(8)),
              Text(
                'owner_notif_tab_empty_subtitle'.tr(context),
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(13),
                  color: Colors.grey.shade500,
                  height: 1.55,
                ),
              ),
              SizedBox(height: context.r(24)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────

class _LoadingSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: context.rOnly(left: 16, right: 16, top: 4, bottom: 120),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => Container(
            margin: context.rOnly(bottom: 14),
            height: context.r(200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.r(18)),
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
      padding: context.rOnly(left: 16, right: 16, top: 4, bottom: 120),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((ctx, i) {
          final p = properties[i];
          return Padding(
            padding: context.rOnly(bottom: 15),
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
