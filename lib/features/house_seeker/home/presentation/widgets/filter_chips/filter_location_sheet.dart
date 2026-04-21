// filter_location_sheet.dart — Governorate → City cascaded location picker
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/location/data/egypt_locations.dart';
import 'package:aqar_hub/core/location/models/location_node.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/home/data/models/property_filter_model.dart';
import 'filter_sheet_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterLocationSheet extends StatefulWidget {
  final PropertyFilterModel initialFilter;
  final ValueChanged<PropertyFilterModel> onApply;
  const FilterLocationSheet({super.key, required this.initialFilter, required this.onApply});
  @override State<FilterLocationSheet> createState() => _State();
}

class _State extends State<FilterLocationSheet> {
  String? _gov, _city;

  @override void initState() { super.initState(); _gov = widget.initialFilter.governorateSlug; _city = widget.initialFilter.citySlug; }

  EgyptLocationNode? get _govNode => EgyptLocations.findGovernorate(_gov);
  List<EgyptLocationNode> get _cities => _govNode?.children ?? const [];
  bool get _hasCities => _cities.isNotEmpty;
  int get _step => (_gov == null || !_hasCities) ? 0 : 1;

  String _tr(String key, String fallback) { final v = key.tr(context); return v == key ? fallback : v; }

  void _onSelect(EgyptLocationNode item) {
    if (_step == 0) {
      setState(() { _gov = item.slug; _city = null; });
      if (!item.children.isNotEmpty) _apply();
    } else {
      setState(() => _city = item.slug);
      _apply();
    }
  }

  void _apply() {
    Navigator.of(context).pop();
    widget.onApply(widget.initialFilter.copyWith(
      governorateSlug: _gov, citySlug: _city,
      clearGovernorate: _gov == null, clearCity: _city == null, clearArea: true));
  }

  void _clear() => setState(() { _gov = null; _city = null; });

  @override
  Widget build(BuildContext context) {
    final items = _step == 0 ? EgyptLocations.governorates : _cities;
    final title = _step == 0 ? _tr('filtergovernorate', 'Governorate') : _tr('filtercity', 'City / Center');

    return FractionallySizedBox(heightFactor: 0.82,
      child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(context.r(24)))),
        child: Column(children: [
          SizedBox(height: context.r(12)),
          Container(width: context.r(40), height: context.r(4), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(context.r(4)))),
          SizedBox(height: context.r(14)),
          Padding(padding: context.rSymmetric(horizontal: 18),
            child: Text(title, style: GoogleFonts.cairo(fontSize: context.sp(17), fontWeight: FontWeight.w800, color: const Color(0xFF1B2D5E)))),
          SizedBox(height: context.r(10)),
          // Breadcrumb badges
          Padding(padding: context.rSymmetric(horizontal: 18),
            child: Wrap(spacing: context.r(8), runSpacing: context.r(8), children: [
              _Badge(label: _gov == null ? _tr('filtergovernorate', 'Governorate') : (_govNode?.label(context) ?? _tr('filtergovernorate', 'Governorate')),
                isActive: _step == 0, onTap: () => setState(() { _city = null; })),
              if (_gov != null && _hasCities)
                _Badge(label: _city == null ? _tr('filtercity', 'City') : (EgyptLocations.findCity(governorateSlug: _gov, citySlug: _city)?.label(context) ?? _tr('filtercity', 'City')),
                  isActive: _step == 1, onTap: () => setState(() => _city = null)),
            ])),
          SizedBox(height: context.r(14)),
          Expanded(child: ListView.separated(
            padding: context.rSymmetric(horizontal: 18), itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(height: context.r(8)),
            itemBuilder: (_, i) {
              final item = items[i];
              final sel = _step == 0 ? _gov == item.slug : _city == item.slug;
              return FilterSheetTile(label: item.label(context), isSelected: sel, onTap: () => _onSelect(item));
            })),
          Padding(padding: context.rOnly(left: 18, right: 18, top: 12, bottom: 18 + MediaQuery.paddingOf(context).bottom),
            child: Row(children: [
              Expanded(child: OutlinedButton(onPressed: _clear,
                style: OutlinedButton.styleFrom(padding: context.rSymmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(14)))),
                child: Text(_tr('filterreset', 'Reset'), style: GoogleFonts.cairo(fontSize: context.sp(13), fontWeight: FontWeight.w700)))),
              SizedBox(width: context.r(10)),
              Expanded(child: ElevatedButton(onPressed: _apply,
                style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: AppColors.primary, padding: context.rSymmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(14)))),
                child: Text(_tr('filterapply', 'Apply'), style: GoogleFonts.cairo(fontSize: context.sp(13), fontWeight: FontWeight.w700, color: Colors.white)))),
            ])),
        ])));
  }
}

class _Badge extends StatelessWidget {
  final String label; final bool isActive; final VoidCallback onTap;
  const _Badge({required this.label, required this.isActive, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(borderRadius: BorderRadius.circular(context.r(999)), onTap: onTap,
    child: Container(padding: context.rSymmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withValues(alpha: 0.10) : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(context.r(999)),
        border: Border.all(color: isActive ? AppColors.primary.withValues(alpha: 0.30) : Colors.grey.withValues(alpha: 0.18))),
      child: Text(label, style: GoogleFonts.tajawal(fontSize: context.sp(12), fontWeight: FontWeight.w600,
          color: isActive ? AppColors.primary : const Color(0xFF1B2D5E)))));
}
