import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/home/data/models/property_filter_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'filter_chips/filter_helpers.dart';
import 'filter_chips/filter_sheet_widgets.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class HomeFilterChips extends StatelessWidget {
  const HomeFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final f = state is HomeLoaded
            ? state.filter
            : const PropertyFilterModel.empty();
        final chips = <Widget>[
          if (f.hasAnyFilter)
            FilterChipButton(
              label:
                  '${FilterHelpers.tr(context, 'filterreset', 'Reset')} (${f.activeCount})',
              icon: Icons.restart_alt_rounded,
              isActive: true,
              onTap: () => FilterHelpers.apply(
                context,
                const PropertyFilterModel.empty(),
              ),
            ),

          FilterChipButton(
            label: FilterHelpers.listingLabel(context, f),
            icon: Icons.sell_outlined,
            isActive: f.listingType != null,
            onTap: () => FilterHelpers.showListingType(context, f),
          ),

          if (f.listingType == 'rent')
            FilterChipButton(
              label: FilterHelpers.rentalLabel(context, f),
              icon: Icons.meeting_room_outlined,
              isActive: f.rentalType != null,
              onTap: () => FilterHelpers.showRentalType(context, f),
            ),

          FilterChipButton(
            label: FilterHelpers.locationLabel(context, f),
            icon: Icons.location_on_outlined,
            isActive: FilterHelpers.hasLocation(f),
            onTap: () => FilterHelpers.showLocation(context, f),
          ),

          FilterChipButton(
            label: FilterHelpers.priceLabel(context, f),
            icon: Icons.payments_outlined,
            isActive: f.minPrice != null || f.maxPrice != null,
            onTap: () => FilterHelpers.showPrice(context, f),
          ),

          FilterChipButton(
            label: FilterHelpers.propTypeLabel(context, f),
            icon: Icons.apartment_outlined,
            isActive: f.propertyType != null,
            onTap: () => FilterHelpers.showPropertyType(context, f),
          ),

          FilterChipButton(
            label: FilterHelpers.furnishedLabel(context, f),
            icon: Icons.chair_outlined,
            isActive: f.isFurnished != null,
            onTap: () => FilterHelpers.showFurnished(context, f),
          ),

          FilterChipButton(
            label: FilterHelpers.roomsLabel(context, f),
            icon: Icons.bed_outlined,
            isActive: f.minRooms != null,
            onTap: () => FilterHelpers.showRooms(context, f),
          ),

          if (f.listingType == 'rent')
            FilterChipButton(
              label: FilterHelpers.bedsLabel(context, f),
              icon: Icons.single_bed_outlined,
              isActive: f.minBeds != null,
              onTap: () => FilterHelpers.showBeds(context, f),
            ),

          if (f.listingType == 'rent')
            FilterChipButton(
              label: FilterHelpers.audienceLabel(context, f),
              icon: Icons.groups_2_outlined,
              isActive: f.targetAudience != null,
              onTap: () => FilterHelpers.showAudience(context, f),
            ),
        ];

        return SizedBox(
          height: context.r(46),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: context.rSymmetric(horizontal: 16),
            itemBuilder: (_, i) => chips[i],
            separatorBuilder: (_, __) => SizedBox(width: context.r(8)),
            itemCount: chips.length,
          ),
        );
      },
    );
  }
}
