// lib/features/owner/home/presentation/views/add_property_view.dart
// 8-step guided wizard — each step lives in its own file under add_property/
// This file is the orchestrator only: navigation, progress bar, bottom bar.

// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/owner/add_property/data/datasources/add_property_remote_datasource.dart';
import 'package:aqar_hub/features/owner/add_property/data/models/add_property_form_model.dart';
import 'package:aqar_hub/features/owner/add_property/data/repositories/add_property_repository_impl.dart';
import 'package:aqar_hub/features/owner/add_property/presentation/cubit/add_property_cubit.dart';
import 'package:aqar_hub/features/owner/add_property/presentation/cubit/add_property_state.dart';
import 'package:aqar_hub/features/owner/add_property/presentation/widgets/add_property/step_amenities.dart';
import 'package:aqar_hub/features/owner/add_property/presentation/widgets/add_property/step_basic_info.dart';
import 'package:aqar_hub/features/owner/add_property/presentation/widgets/add_property/step_description.dart';
import 'package:aqar_hub/features/owner/add_property/presentation/widgets/add_property/step_listing_type.dart';
import 'package:aqar_hub/features/owner/add_property/presentation/widgets/add_property/step_media.dart';
import 'package:aqar_hub/features/owner/add_property/presentation/widgets/add_property/step_pricing.dart';
import 'package:aqar_hub/features/owner/add_property/presentation/widgets/add_property/step_property_type.dart';
import 'package:aqar_hub/features/owner/add_property/presentation/widgets/add_property/step_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AddPropertyView extends StatelessWidget {
  const AddPropertyView({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => AddPropertyCubit(
      AddPropertyRepositoryImpl(AddPropertyRemoteDatasource()),
    ),
    child: const _Content(),
  );
}

class _Content extends StatefulWidget {
  const _Content();
  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  final _pageCtrl = PageController();
  int _step = 0;
  static const _total = 8;
  AddPropertyFormModel _form = const AddPropertyFormModel();
  final _keys = List.generate(_total, (_) => GlobalKey<FormState>());

  static const _stepTitles = [
    'addprop_step_basic',
    'addprop_step_type',
    'addprop_step_specs',
    'addprop_step_amenities',
    'addprop_step_listing',
    'addprop_step_pricing',
    'addprop_step_media',
    'addprop_step_description',
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_keys[_step].currentState?.validate() == false) return;
    _keys[_step].currentState?.save();
    if (_step == 0 && !_form.hasLocation) {
      _err('addprop_location_required'.tr(context));
      return;
    }
    if (_step == 6 && _form.localImages.isEmpty) {
      _err('addprop_min_photo'.tr(context));
      return;
    }
    if (_step < _total - 1) {
      setState(() => _step++);
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submit() => context.read<AddPropertyCubit>().submit(_form);

  void _err(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.redAccent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.r(12)),
      ),
      content: Text(msg, style: GoogleFonts.cairo(color: Colors.white)),
    ),
  );

  void _update(AddPropertyFormModel f) => setState(() => _form = f);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddPropertyCubit, AddPropertyState>(
      listener: (ctx, s) {
        if (s is AddPropertySuccess) {
          Navigator.pop(ctx, true);
        } else if (s is AddPropertyError)
          _err(s.message);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: _appBar(context),
        body: PageView(
          controller: _pageCtrl,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            StepBasicInfo(formKey: _keys[0], form: _form, onChanged: _update),
            StepPropertyType(
              formKey: _keys[1],
              form: _form,
              onChanged: _update,
            ),
            StepSpecs(formKey: _keys[2], form: _form, onChanged: _update),
            StepAmenities(formKey: _keys[3], form: _form, onChanged: _update),
            StepListingType(formKey: _keys[4], form: _form, onChanged: _update),
            StepPricing(formKey: _keys[5], form: _form, onChanged: _update),
            StepMedia(formKey: _keys[6], form: _form, onChanged: _update),
            StepDescription(formKey: _keys[7], form: _form, onChanged: _update),
          ],
        ),
        bottomNavigationBar: _bottomBar(context),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) => AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        size: context.r(20),
        color: const Color(0xFF1B2D5E),
      ),
      onPressed: _back,
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'addprop_title'.tr(context),
          style: GoogleFonts.cairo(
            fontSize: context.sp(15),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1B2D5E),
          ),
        ),
        Text(
          _stepTitles[_step].tr(context),
          style: GoogleFonts.tajawal(
            fontSize: context.sp(11),
            color: Colors.grey.shade500,
          ),
        ),
      ],
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(4),
      child: _ProgressBar(current: _step + 1, total: _total),
    ),
  );

  Widget _bottomBar(BuildContext context) =>
      BlocBuilder<AddPropertyCubit, AddPropertyState>(
        builder: (ctx, s) {
          final loading = s is AddPropertyLoading;
          final isLast = _step == _total - 1;
          final aiPending = isLast && _form.aiPriceResult == null;
          return Container(
            padding: context.rOnly(
              left: 16,
              right: 16,
              top: 12,
              bottom: 12 + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: context.r(16),
                  offset: Offset(0, context.r(-4)),
                ),
              ],
            ),
            child: aiPending
                ? Row(
                    children: [
                      Icon(
                        Icons.lock_clock_outlined,
                        size: context.r(18),
                        color: Colors.orange.shade600,
                      ),
                      SizedBox(width: context.r(8)),
                      Expanded(
                        child: Text(
                          'addprop_ai_required'.tr(context),
                          style: GoogleFonts.cairo(
                            fontSize: context.sp(12),
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Text(
                        '${_step + 1} / $_total',
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(13),
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: context.r(12)),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: loading ? null : _next,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.primary,
                            padding: context.rSymmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                context.r(14),
                              ),
                            ),
                          ),
                          child: loading
                              ? SizedBox(
                                  width: context.r(20),
                                  height: context.r(20),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isLast
                                      ? 'addprop_publish'.tr(context)
                                      : 'addprop_next'.tr(context),
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
          );
        },
      );
}

class _ProgressBar extends StatelessWidget {
  final int current, total;
  const _ProgressBar({required this.current, required this.total});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (ctx, c) => Stack(
      children: [
        Container(height: 4, color: Colors.grey.shade100),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 4,
          width: c.maxWidth * (current / total),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    ),
  );
}
