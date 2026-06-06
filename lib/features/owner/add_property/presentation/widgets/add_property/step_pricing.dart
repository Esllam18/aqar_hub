// lib/.../add_property/step_pricing.dart — Step 5: Base price + rental options

// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/owner/add_property/data/models/add_property_form_model.dart';
import 'add_property_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class StepPricing extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final AddPropertyFormModel form;
  final ValueChanged<AddPropertyFormModel> onChanged;
  const StepPricing({
    super.key,
    required this.formKey,
    required this.form,
    required this.onChanged,
  });
  @override
  State<StepPricing> createState() => _StepPricingState();
}

class _StepPricingState extends State<StepPricing> {
  late final TextEditingController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.form.basePrice?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _addOption() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => RentalOptionSheet(
      suggestedBeds: widget.form.totalBeds,
      suggestedRooms: widget.form.totalRooms,
      onSave: (opt) {
        final u = [...widget.form.rentalOptions, opt];
        widget.onChanged(widget.form.copyWith(rentalOptions: u));
      },
    ),
  );

  void _editOption(int i, RentalOptionDraft opt) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => RentalOptionSheet(
      initial: opt,
      suggestedBeds: widget.form.totalBeds,
      suggestedRooms: widget.form.totalRooms,
      onSave: (o) {
        final u = [...widget.form.rentalOptions];
        u[i] = o;
        widget.onChanged(widget.form.copyWith(rentalOptions: u));
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isRent = widget.form.listingType == 'rent';
    final opts = widget.form.rentalOptions;
    return stepScroll(
      context,
      Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepAlertBanner(
              message: isRent
                  ? 'addprop_banner_pricing_rent'.tr(context)
                  : 'addprop_banner_pricing_sale'.tr(context),
              type: AlertBannerType.warning,
              icon: Icons.payments_outlined,
            ),
            SectionTitle('addprop_base_price'.tr(context)),
            HintText(
              isRent
                  ? 'addprop_base_price_rent_hint'.tr(context)
                  : 'addprop_base_price_sale_hint'.tr(context),
            ),
            inputField(
              context: context,
              hint: 'addprop_price'.tr(context),
              controller: _ctrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              prefix: Icon(
                Icons.payments_outlined,
                size: context.r(18),
                color: AppColors.primary,
              ),
              suffix: Padding(
                padding: context.rOnly(right: 12),
                child: Text(
                  'currency'.tr(context),
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(12),
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              onChanged: (v) {
                final p = double.tryParse(v);
                widget.onChanged(
                  widget.form.copyWith(basePrice: p, clearBasePrice: p == null),
                );
              },
            ),
            if ((widget.form.basePrice ?? 0) > 0)
              _HighPriceWarning(price: widget.form.basePrice!, isRent: isRent),
            if (isRent) ...[
              SizedBox(height: context.r(24)),
              Row(
                children: [
                  Expanded(
                    child: SectionTitle('addprop_rental_options'.tr(context)),
                  ),
                  TextButton.icon(
                    onPressed: _addOption,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(
                      'addprop_add_option'.tr(context),
                      style: GoogleFonts.cairo(fontSize: context.sp(13)),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              HintText('addprop_rental_options_hint'.tr(context)),
              if (opts.isEmpty)
                Center(
                  child: Padding(
                    padding: context.rSymmetric(vertical: 12),
                    child: Text(
                      'addprop_no_options_yet'.tr(context),
                      style: GoogleFonts.tajawal(
                        fontSize: context.sp(13),
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                )
              else
                ...opts.asMap().entries.map(
                  (e) => _OptionCard(
                    option: e.value,
                    onEdit: () => _editOption(e.key, e.value),
                    onDelete: () {
                      final u = [...opts];
                      u.removeAt(e.key);
                      widget.onChanged(widget.form.copyWith(rentalOptions: u));
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final RentalOptionDraft option;
  final VoidCallback onEdit, onDelete;
  const _OptionCard({
    required this.option,
    required this.onEdit,
    required this.onDelete,
  });
  @override
  Widget build(BuildContext context) {
    const icons = {'bed': '🛏️', 'room': '🚪', 'apartment': '🏠'};
    return Container(
      margin: context.rOnly(bottom: 10),
      padding: context.rAll(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: Colors.grey.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Text(
            icons[option.type] ?? '🏠',
            style: TextStyle(fontSize: context.sp(22)),
          ),
          SizedBox(width: context.r(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'rental${option.type}'.tr(context),
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B2D5E),
                  ),
                ),
                Text(
                  '${option.price.toStringAsFixed(0)} ${'currency'.tr(context)} / ${'addprop_per_${option.type}'.tr(context)}',
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(12),
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              size: context.r(18),
              color: AppColors.primary,
            ),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              size: context.r(18),
              color: Colors.redAccent,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _HighPriceWarning extends StatelessWidget {
  final double price;
  final bool isRent;
  const _HighPriceWarning({required this.price, required this.isRent});
  bool get _high => isRent ? price > 50000 : price > 20000000;
  @override
  Widget build(BuildContext context) {
    if (!_high) return const SizedBox.shrink();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: context.rOnly(top: 8, bottom: 4),
      padding: context.rAll(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: const Color(0xFFFF8F00),
            size: context.r(18),
          ),
          SizedBox(width: context.r(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'addprop_price_warning_title'.tr(context),
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(13),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE65100),
                  ),
                ),
                SizedBox(height: context.r(3)),
                Text(
                  'addprop_price_warning_body'.tr(context),
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(12),
                    color: Colors.brown.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rental option bottom sheet ────────────────────────────────────────────────
class RentalOptionSheet extends StatefulWidget {
  final RentalOptionDraft? initial;
  final ValueChanged<RentalOptionDraft> onSave;
  // Auto-fill hints derived from step_specs (totalBeds / totalRooms)
  final int? suggestedBeds;
  final int? suggestedRooms;

  const RentalOptionSheet({
    super.key,
    this.initial,
    required this.onSave,
    this.suggestedBeds,
    this.suggestedRooms,
  });

  @override
  State<RentalOptionSheet> createState() => _SheetState();
}

class _SheetState extends State<RentalOptionSheet> {
  late String _type;
  late final TextEditingController _price, _total, _avail;
  final _key = GlobalKey<FormState>();

  /// Returns the suggested total quantity for the given type, as a string.
  String _suggestedQty(String type) {
    if (type == 'bed' && widget.suggestedBeds != null) {
      return '${widget.suggestedBeds}';
    }
    if (type == 'room' && widget.suggestedRooms != null) {
      return '${widget.suggestedRooms}';
    }
    return '';
  }

  /// Called when the user switches type — updates qty fields with auto-fill.
  void _onTypeChanged(String newType) {
    setState(() => _type = newType);
    // Only auto-fill if the user has NOT already typed a custom value
    final isNew = widget.initial == null;
    if (isNew) {
      final suggested = _suggestedQty(newType);
      if (suggested.isNotEmpty) {
        _total.text = suggested;
        _avail.text = suggested;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _type = widget.initial?.type ?? 'bed';
    _price = TextEditingController(
      text: widget.initial?.price.toStringAsFixed(0) ?? '',
    );
    // Pre-fill total/available from specs when creating a brand-new option
    final isNew = widget.initial == null;
    final autoQty = isNew ? _suggestedQty(_type) : '';
    _total = TextEditingController(
      text: isNew ? autoQty : '${widget.initial!.totalQuantity}',
    );
    _avail = TextEditingController(
      text: isNew ? autoQty : '${widget.initial!.availableQuantity}',
    );
  }

  @override
  void dispose() {
    _price.dispose();
    _total.dispose();
    _avail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const types = ['bed', 'room', 'apartment'];
    const icons = {'bed': '🛏️', 'room': '🚪', 'apartment': '🏠'};
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.r(24)),
          ),
        ),
        padding: context.rAll(20),
        child: Form(
          key: _key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: context.r(40),
                  height: context.r(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(context.r(4)),
                  ),
                ),
              ),
              SizedBox(height: context.r(16)),
              Text(
                widget.initial == null
                    ? 'addprop_add_option'.tr(context)
                    : 'addprop_edit_option'.tr(context),
                style: GoogleFonts.cairo(
                  fontSize: context.sp(17),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B2D5E),
                ),
              ),
              SizedBox(height: context.r(16)),
              Row(
                children: types.map((t) {
                  final active = _type == t;
                  return Expanded(
                    child: Padding(
                      padding: context.rOnly(right: t != 'apartment' ? 8 : 0),
                      child: GestureDetector(
                        onTap: () => _onTypeChanged(t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: context.rSymmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: active ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(context.r(10)),
                            border: Border.all(
                              color: active
                                  ? AppColors.primary
                                  : Colors.grey.withOpacity(0.25),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                icons[t] ?? '',
                                style: TextStyle(fontSize: context.sp(18)),
                              ),
                              SizedBox(height: context.r(2)),
                              Text(
                                'rental$t'.tr(context),
                                style: GoogleFonts.cairo(
                                  fontSize: context.sp(11),
                                  fontWeight: FontWeight.w700,
                                  color: active
                                      ? Colors.white
                                      : const Color(0xFF1B2D5E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: context.r(16)),
              _QtyRow(
                priceCtrl: _price,
                totalCtrl: _total,
                availCtrl: _avail,
                type: _type,
              ),
              SizedBox(height: context.r(20)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_key.currentState?.validate() != true) return;
                    final price = double.tryParse(_price.text.trim()) ?? 0;
                    if (price <= 0) {
                      return; // double-guard, validator already catches this
                    }
                    Navigator.pop(context);
                    // Apartment is always 1 unit — quantity fields are hidden
                    final qty = _type == 'apartment'
                        ? 1
                        : (int.tryParse(_total.text.trim()) ?? 1).clamp(
                            1,
                            9999,
                          );
                    final avail = _type == 'apartment'
                        ? 1
                        : (int.tryParse(_avail.text.trim()) ?? 1).clamp(0, qty);
                    widget.onSave(
                      RentalOptionDraft(
                        type: _type,
                        price: price,
                        totalQuantity: qty,
                        availableQuantity: avail,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    padding: context.rSymmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.r(14)),
                    ),
                  ),
                  child: Text(
                    'addprop_save_option'.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyRow extends StatelessWidget {
  final TextEditingController priceCtrl, totalCtrl, availCtrl;
  final String type;
  const _QtyRow({
    required this.priceCtrl,
    required this.totalCtrl,
    required this.availCtrl,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isApartment = type == 'apartment';

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.r(10)),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.r(10)),
      borderSide: const BorderSide(color: AppColors.primary),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.r(10)),
      borderSide: const BorderSide(color: Colors.redAccent),
    );

    InputDecoration deco(String hint, {String? suffix, Widget? prefix}) =>
        InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF8F9FB),
          contentPadding: context.rSymmetric(horizontal: 14, vertical: 12),
          border: border,
          enabledBorder: border,
          focusedBorder: focusedBorder,
          errorBorder: errorBorder,
          focusedErrorBorder: errorBorder,
          suffixText: suffix,
          prefixIcon: prefix,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Price field ──────────────────────────────────────────────────
        Text(
          '${'addprop_price_per'.tr(context)} '
          '${'addprop_per_$type'.tr(context)}',
          style: GoogleFonts.tajawal(
            fontSize: context.sp(12),
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: context.r(6)),
        TextFormField(
          controller: priceCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: deco(
            'addprop_price_hint'.tr(context),
            suffix: 'currency'.tr(context),
            prefix: Icon(
              Icons.payments_outlined,
              size: context.r(16),
              color: AppColors.primary,
            ),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'addprop_price_required'.tr(context);
            }
            final parsed = double.tryParse(v.trim());
            if (parsed == null) return 'addprop_price_invalid'.tr(context);
            if (parsed <= 0) return 'addprop_price_positive'.tr(context);
            return null;
          },
        ),

        // ── Quantity fields (hidden for apartment) ───────────────────────
        if (!isApartment) ...[
          SizedBox(height: context.r(12)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total quantity
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'addprop_total_qty'.tr(context),
                      style: GoogleFonts.tajawal(
                        fontSize: context.sp(12),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: context.r(6)),
                    TextFormField(
                      controller: totalCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: deco('1'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'addprop_required'.tr(context);
                        }
                        final n = int.tryParse(v.trim());
                        if (n == null || n < 1) {
                          return 'addprop_qty_min_1'.tr(context);
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.r(12)),
              // Available quantity
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'addprop_available_qty'.tr(context),
                      style: GoogleFonts.tajawal(
                        fontSize: context.sp(12),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: context.r(6)),
                    TextFormField(
                      controller: availCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: deco('1'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'addprop_required'.tr(context);
                        }
                        final avail = int.tryParse(v.trim());
                        final total = int.tryParse(totalCtrl.text.trim()) ?? 0;
                        if (avail == null || avail < 0) {
                          return 'addprop_qty_non_neg'.tr(context);
                        }
                        if (avail > total && total > 0) {
                          return 'addprop_avail_exceeds_total'.tr(context);
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
