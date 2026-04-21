import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/datasources/favorites_datasource.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../cubit/favorites_cubit.dart';
import '../widgets/favorites_empty_view.dart';
import '../widgets/favorites_header.dart';
import '../widgets/favorites_property_card.dart';
import '../widgets/favorites_sort_bar.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          FavoritesCubit(FavoritesRepositoryImpl(FavoritesDatasourceImpl()))
            ..loadFavoriteProperties(),
      child: const _FavoritesContent(),
    );
  }
}

class _FavoritesContent extends StatefulWidget {
  const _FavoritesContent();

  @override
  State<_FavoritesContent> createState() => _FavoritesContentState();
}

class _FavoritesContentState extends State<_FavoritesContent> {
  FavoritesSortOption _sort = FavoritesSortOption.newest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          return Column(
            children: [
              // ── Header ─────────────────────────────────────────────────
              FavoritesHeader(
                count: state is FavoritesLoaded ? state.properties.length : 0,
              ),

              // ── Body ───────────────────────────────────────────────────
              Expanded(
                child: switch (state) {
                  FavoritesLoading() => const _LoadingView(),
                  FavoritesError(:final messageKey) => _ErrorView(
                    messageKey: messageKey,
                    onRetry: () =>
                        context.read<FavoritesCubit>().loadFavoriteProperties(),
                  ),
                  FavoritesLoaded(:final properties) when properties.isEmpty =>
                    const FavoritesEmptyView(),
                  FavoritesLoaded(:final properties) => Column(
                    children: [
                      // Sort bar
                      FavoritesSortBar(
                        count: properties.length,
                        selected: _sort,
                        onChanged: (s) => setState(() => _sort = s),
                      ),

                      // List
                      Expanded(
                        child: RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () => context
                              .read<FavoritesCubit>()
                              .loadFavoriteProperties(),
                          child: ListView.builder(
                            padding: context.rOnly(
                              left: 16,
                              right: 16,
                              top: 4,
                              bottom: 100,
                            ),
                            itemCount: FavoritesSorter.sort(
                              properties,
                              _sort,
                            ).length,
                            itemBuilder: (context, index) {
                              final sorted = FavoritesSorter.sort(
                                properties,
                                _sort,
                              );
                              return FavoritesPropertyCard(
                                property: sorted[index],
                                index: index,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  _ => const FavoritesEmptyView(),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Loading shimmer ───────────────────────────────────────────────────────────

class _LoadingView extends StatefulWidget {
  const _LoadingView();

  @override
  State<_LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<_LoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: context.rAll(16),
      itemCount: 5,
      itemBuilder: (_, __) => AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final c = Color.lerp(
            Colors.grey.shade200,
            Colors.grey.shade100,
            _anim.value,
          )!;
          return Container(
            margin: context.rOnly(bottom: 14),
            height: context.r(130),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.r(18)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(context.r(18)),
                  ),
                  child: Container(width: context.r(110), color: c),
                ),
                Expanded(
                  child: Padding(
                    padding: context.rAll(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Bar(c, double.infinity, context.r(14)),
                        SizedBox(height: context.r(8)),
                        _Bar(c, context.r(100), context.r(12)),
                        SizedBox(height: context.r(12)),
                        _Bar(c, context.r(80), context.r(16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _Bar(Color c, double w, double h) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: c,
      borderRadius: BorderRadius.circular(context.r(6)),
    ),
  );
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String messageKey;
  final VoidCallback onRetry;
  const _ErrorView({required this.messageKey, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.wifi_off_rounded,
          size: context.r(52),
          color: Colors.grey.shade300,
        ),
        SizedBox(height: context.r(12)),
        Text(
          messageKey.tr(context),
          style: GoogleFonts.tajawal(color: Colors.grey.shade500),
        ),
        SizedBox(height: context.r(16)),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: Icon(Icons.refresh_rounded, size: context.r(18)),
          label: Text(
            'btn_retry'.tr(context),
            style: GoogleFonts.tajawal(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.r(12)),
            ),
          ),
        ),
      ],
    ),
  );
}
