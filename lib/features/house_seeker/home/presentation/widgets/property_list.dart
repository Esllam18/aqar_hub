import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/navigation/transition_type.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/property_model.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../views/property_details_view.dart';
import 'property_card.dart';

class PropertyList extends StatelessWidget {
  const PropertyList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const _LoadingSliver();
        }

        if (state is HomeError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _ErrorView(
              messageKey: state.messageKey,
              onRetry: () => context.read<HomeCubit>().refresh(),
            ),
          );
        }

        if (state is HomeLoaded) {
          if (state.properties.isEmpty) {
            return const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyView(),
            );
          }

          return BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, favState) {
              final extra =
                  (state is HomeLoadingMore ? 1 : 0) +
                  (!state.hasMore && state.properties.isNotEmpty ? 1 : 0);

              return SliverPadding(
                padding: context.rOnly(
                  left: 16,
                  right: 16,
                  top: 4,
                  bottom: 110,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (state is HomeLoadingMore &&
                        index == state.properties.length) {
                      return Padding(
                        padding: context.rSymmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: context.r(2.5),
                          ),
                        ),
                      );
                    }

                    if (!state.hasMore && index == state.properties.length) {
                      return Padding(
                        padding: context.rSymmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'homeendoflist'.tr(context),
                            style: GoogleFonts.tajawal(
                              fontSize: context.sp(12),
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      );
                    }

                    final property = state.properties[index];
                    final isFavorite = context
                        .read<FavoritesCubit>()
                        .isFavorite(property.id);

                    return PropertyCard(
                      property: property,
                      index: index,
                      isFavorite: isFavorite,
                      onFavoriteTap: () =>
                          context.read<FavoritesCubit>().toggle(property.id),
                      onTap: () => _openDetails(context, property),
                    );
                  }, childCount: state.properties.length + extra),
                ),
              );
            },
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  void _openDetails(BuildContext context, PropertyModel property) {
    Navigation.to(
      PropertyDetailsView(property: property),
      transition: TransitionType.slide,
    );
  }
}

class _LoadingSliver extends StatelessWidget {
  const _LoadingSliver();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: context.rAll(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => _ShimmerCard(),
          childCount: 4,
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final color = Color.lerp(
          Colors.grey.shade200,
          Colors.grey.shade100,
          _anim.value,
        )!;
        return Container(
          margin: context.rOnly(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.r(18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: context.r(190),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(context.r(18)),
                  ),
                ),
              ),
              Padding(
                padding: context.rAll(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bar(color, context.r(160), context.r(16)),
                    SizedBox(height: context.r(8)),
                    _Bar(color, context.r(100), context.r(12)),
                    SizedBox(height: context.r(12)),
                    Row(
                      children: [
                        _Bar(color, context.r(50), context.r(12)),
                        SizedBox(width: context.r(8)),
                        _Bar(color, context.r(50), context.r(12)),
                        SizedBox(width: context.r(8)),
                        _Bar(color, context.r(50), context.r(12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ignore: non_constant_identifier_names
  Widget _Bar(Color color, double width, double height) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(context.r(6)),
    ),
  );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off_rounded,
          size: context.r(60),
          color: Colors.grey.shade300,
        ),
        SizedBox(height: context.r(12)),
        Text(
          'homenoresults'.tr(context),
          style: GoogleFonts.cairo(
            fontSize: context.sp(15),
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    ),
  );
}

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
            'btnretry'.tr(context),
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
