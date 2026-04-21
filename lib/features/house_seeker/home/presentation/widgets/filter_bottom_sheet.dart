// import 'package:aqar_hub/core/constants/app_colors.dart';
// import 'package:aqar_hub/core/localization/app_localizations.dart';
// import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../data/models/property_filter_model.dart';
// import '../cubit/home_cubit.dart';

// class FilterBottomSheet extends StatefulWidget {
//   final PropertyFilterModel currentFilter;
//   const FilterBottomSheet({super.key, required this.currentFilter});

//   @override
//   State<FilterBottomSheet> createState() => _FilterBottomSheetState();
// }

// class _FilterBottomSheetState extends State<FilterBottomSheet> {
//   late PropertyFilterModel _filter;
//   final _cityCtrl = TextEditingController();
//   late RangeValues _priceRange;

//   static const double _maxPrice = 20000;

//   @override
//   void initState() {
//     super.initState();
//     _filter = widget.currentFilter;
//     _cityCtrl.text = _filter.city ?? '';
//     _priceRange = RangeValues(
//       _filter.minPrice ?? 0,
//       _filter.maxPrice ?? _maxPrice,
//     );
//   }

//   @override
//   void dispose() {
//     _cityCtrl.dispose();
//     super.dispose();
//   }

//   void _apply() {
//     final f = _filter.copyWith(
//       city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
//       minPrice: _priceRange.start > 0 ? _priceRange.start : null,
//       maxPrice: _priceRange.end < _maxPrice ? _priceRange.end : null,
//     );
//     context.read<HomeCubit>().applyFilter(f);
//     Navigator.of(context).pop();
//   }

//   void _reset() {
//     setState(() {
//       _filter = const PropertyFilterModel.empty();
//       _cityCtrl.clear();
//       _priceRange = const RangeValues(0, _maxPrice);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.background,
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(context.r(24)),
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // ── Handle ──────────────────────────────────────────────────────
//           SizedBox(height: context.r(12)),
//           Center(
//             child: Container(
//               width: context.r(40),
//               height: context.r(4),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(context.r(4)),
//               ),
//             ),
//           ),
//           SizedBox(height: context.r(16)),

//           // ── Header ──────────────────────────────────────────────────────
//           Padding(
//             padding: context.rSymmetric(horizontal: 20),
//             child: Row(
//               children: [
//                 Text(
//                   'filter_title'.tr(context),
//                   style: GoogleFonts.cairo(
//                     fontSize: context.sp(18),
//                     fontWeight: FontWeight.w800,
//                     color: const Color(0xFF1B4B8C),
//                   ),
//                 ),
//                 const Spacer(),
//                 TextButton(
//                   onPressed: _reset,
//                   child: Text(
//                     'filter_reset'.tr(context),
//                     style: GoogleFonts.tajawal(
//                       fontSize: context.sp(13),
//                       color: Colors.redAccent,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ── Scrollable body ──────────────────────────────────────────────
//           Flexible(
//             child: SingleChildScrollView(
//               padding: context.rSymmetric(horizontal: 20, vertical: 4),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ── Listing type ─────────────────────────────────────────
//                   _SectionTitle('filter_listing_type'.tr(context)),
//                   SizedBox(height: context.r(10)),
//                   _ToggleGroup(
//                     options: [
//                       _ToggleOption('filter_all'.tr(context), null),
//                       _ToggleOption('home_filter_rent'.tr(context), 'rent'),
//                       _ToggleOption('home_filter_sale'.tr(context), 'sale'),
//                     ],
//                     selected: _filter.listingType,
//                     onSelect: (v) => setState(
//                       () => _filter = v == null
//                           ? _filter.copyWith(clearListingType: true)
//                           : _filter.copyWith(listingType: v),
//                     ),
//                   ),
//                   SizedBox(height: context.r(20)),

//                   // ── Rental type (only when rent) ─────────────────────────
//                   if (_filter.listingType == 'rent' ||
//                       _filter.listingType == null) ...[
//                     _SectionTitle('filter_rental_type'.tr(context)),
//                     SizedBox(height: context.r(10)),
//                     _ToggleGroup(
//                       options: [
//                         _ToggleOption('filter_all'.tr(context), null),
//                         _ToggleOption('rental_bed'.tr(context), 'bed'),
//                         _ToggleOption('rental_room'.tr(context), 'room'),
//                         _ToggleOption(
//                           'rental_apartment'.tr(context),
//                           'apartment',
//                         ),
//                       ],
//                       selected: _filter.rentalType,
//                       onSelect: (v) => setState(
//                         () => _filter = v == null
//                             ? _filter.copyWith(clearRentalType: true)
//                             : _filter.copyWith(rentalType: v),
//                       ),
//                     ),
//                     SizedBox(height: context.r(20)),
//                   ],

//                   // ── City ─────────────────────────────────────────────────
//                   _SectionTitle('filter_city'.tr(context)),
//                   SizedBox(height: context.r(10)),
//                   TextField(
//                     controller: _cityCtrl,
//                     style: GoogleFonts.tajawal(fontSize: context.sp(13)),
//                     decoration: InputDecoration(
//                       hintText: 'filter_city_hint'.tr(context),
//                       hintStyle: GoogleFonts.tajawal(
//                         fontSize: context.sp(13),
//                         color: Colors.grey.shade400,
//                       ),
//                       prefixIcon: Icon(
//                         Icons.location_on_outlined,
//                         size: context.r(18),
//                         color: AppColors.primary,
//                       ),
//                       filled: true,
//                       fillColor: Colors.white,
//                       contentPadding: context.rSymmetric(
//                         horizontal: 14,
//                         vertical: 12,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(context.r(12)),
//                         borderSide: BorderSide(
//                           color: Colors.grey.withValues(alpha: 0.2),
//                         ),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(context.r(12)),
//                         borderSide: BorderSide(
//                           color: Colors.grey.withValues(alpha: 0.2),
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(context.r(12)),
//                         borderSide: const BorderSide(color: AppColors.primary),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: context.r(20)),

//                   // ── Price range ──────────────────────────────────────────
//                   _SectionTitle('filter_price'.tr(context)),
//                   SizedBox(height: context.r(4)),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         '${_priceRange.start.toInt()} ${'currency'.tr(context)}',
//                         style: GoogleFonts.cairo(
//                           fontSize: context.sp(12),
//                           color: AppColors.primary,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       Text(
//                         _priceRange.end >= _maxPrice
//                             ? 'filter_price_any'.tr(context)
//                             : '${_priceRange.end.toInt()} ${'currency'.tr(context)}',
//                         style: GoogleFonts.cairo(
//                           fontSize: context.sp(12),
//                           color: AppColors.primary,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SliderTheme(
//                     data: SliderThemeData(
//                       activeTrackColor: AppColors.primary,
//                       inactiveTrackColor: AppColors.primary.withValues(
//                         alpha: 0.15,
//                       ),
//                       thumbColor: AppColors.primary,
//                       overlayColor: AppColors.primary.withValues(alpha: 0.1),
//                       rangeThumbShape: const RoundRangeSliderThumbShape(
//                         enabledThumbRadius: 10,
//                       ),
//                     ),
//                     child: RangeSlider(
//                       values: _priceRange,
//                       min: 0,
//                       max: _maxPrice,
//                       divisions: 40,
//                       onChanged: (v) => setState(() => _priceRange = v),
//                     ),
//                   ),
//                   SizedBox(height: context.r(20)),

//                   // ── Furnished ────────────────────────────────────────────
//                   _SectionTitle('filter_furnished'.tr(context)),
//                   SizedBox(height: context.r(10)),
//                   _ToggleGroup(
//                     options: [
//                       _ToggleOption('filter_all'.tr(context), null),
//                       _ToggleOption('filter_furnished_yes'.tr(context), 'yes'),
//                       _ToggleOption('filter_furnished_no'.tr(context), 'no'),
//                     ],
//                     selected: _filter.isFurnished == null
//                         ? null
//                         : _filter.isFurnished!
//                         ? 'yes'
//                         : 'no',
//                     onSelect: (v) => setState(
//                       () => _filter = v == null
//                           ? _filter.copyWith(clearIsFurnished: true)
//                           : _filter.copyWith(isFurnished: v == 'yes'),
//                     ),
//                   ),
//                   SizedBox(height: context.r(20)),

//                   // ── Target audience ──────────────────────────────────────
//                   _SectionTitle('filter_audience'.tr(context)),
//                   SizedBox(height: context.r(10)),
//                   _ToggleGroup(
//                     options: [
//                       _ToggleOption('filter_all'.tr(context), null),
//                       _ToggleOption('audience_male'.tr(context), 'male'),
//                       _ToggleOption('audience_female'.tr(context), 'female'),
//                       _ToggleOption('audience_family'.tr(context), 'family'),
//                     ],
//                     selected: _filter.targetAudience,
//                     onSelect: (v) => setState(
//                       () => _filter = v == null
//                           ? _filter.copyWith(clearTargetAudience: true)
//                           : _filter.copyWith(targetAudience: v),
//                     ),
//                   ),
//                   SizedBox(height: context.r(20)),

//                   // ── Rooms ────────────────────────────────────────────────
//                   _SectionTitle('filter_rooms'.tr(context)),
//                   SizedBox(height: context.r(10)),
//                   _ToggleGroup(
//                     options: [
//                       _ToggleOption('filter_all'.tr(context), null),
//                       const _ToggleOption('1+', '1'),
//                       const _ToggleOption('2+', '2'),
//                       const _ToggleOption('3+', '3'),
//                       const _ToggleOption('4+', '4'),
//                     ],
//                     selected: _filter.minRooms?.toString(),
//                     onSelect: (v) => setState(
//                       () => _filter = v == null
//                           ? _filter.copyWith(clearMinRooms: true)
//                           : _filter.copyWith(minRooms: int.parse(v)),
//                     ),
//                   ),
//                   SizedBox(height: context.r(32)),
//                 ],
//               ),
//             ),
//           ),

//           // ── Apply button ─────────────────────────────────────────────────
//           Padding(
//             padding: context.rOnly(
//               left: 20,
//               right: 20,
//               bottom: 24 + MediaQuery.paddingOf(context).bottom,
//               top: 8,
//             ),
//             child: SizedBox(
//               width: double.infinity,
//               height: context.r(52),
//               child: ElevatedButton(
//                 onPressed: _apply,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(context.r(16)),
//                   ),
//                 ),
//                 child: Text(
//                   'filter_apply'.tr(context),
//                   style: GoogleFonts.cairo(
//                     fontSize: context.sp(15),
//                     fontWeight: FontWeight.w700,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Section title ─────────────────────────────────────────────────────────────

// class _SectionTitle extends StatelessWidget {
//   final String text;
//   const _SectionTitle(this.text);

//   @override
//   Widget build(BuildContext context) => Text(
//     text,
//     style: GoogleFonts.cairo(
//       fontSize: context.sp(14),
//       fontWeight: FontWeight.w700,
//       color: const Color(0xFF1B4B8C),
//     ),
//   );
// }

// // ── Toggle option data ────────────────────────────────────────────────────────

// class _ToggleOption {
//   final String label;
//   final String? value;
//   const _ToggleOption(this.label, this.value);
// }

// // ── Toggle group ──────────────────────────────────────────────────────────────

// class _ToggleGroup extends StatelessWidget {
//   final List<_ToggleOption> options;
//   final String? selected;
//   final ValueChanged<String?> onSelect;

//   const _ToggleGroup({
//     required this.options,
//     required this.selected,
//     required this.onSelect,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       spacing: context.r(8),
//       runSpacing: context.r(8),
//       children: options.map((o) {
//         final isActive = selected == o.value;
//         return GestureDetector(
//           onTap: () => onSelect(isActive ? null : o.value),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             padding: context.rSymmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               color: isActive ? AppColors.primary : Colors.white,
//               borderRadius: BorderRadius.circular(context.r(10)),
//               border: Border.all(
//                 color: isActive
//                     ? AppColors.primary
//                     : Colors.grey.withValues(alpha: 0.25),
//               ),
//             ),
//             child: Text(
//               o.label,
//               style: GoogleFonts.tajawal(
//                 fontSize: context.sp(12),
//                 fontWeight: FontWeight.w600,
//                 color: isActive ? Colors.white : Colors.grey.shade600,
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
