import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/enums/app_role.dart';
import 'package:aqar_hub/core/helpers/app_prefs.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/navigation/transition_type.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/core/widgets/custom_snackbar.dart';
import 'package:aqar_hub/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/auth_header.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/loading_button.dart';
import 'package:aqar_hub/layout/views/main_layout_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CompleteProfileView extends StatefulWidget {
  final String? initialUid;
  final String? initialRole;

  const CompleteProfileView({super.key, this.initialUid, this.initialRole});

  @override
  State<CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String? _uid;
  String _role = 'seeker';

  String? _firstNameError;
  String? _lastNameError;
  String? _phoneError;
  String? _cityError;

  @override
  void initState() {
    super.initState();
    _resolveUidAndRole();
  }

  Future<void> _resolveUidAndRole() async {
    final cubitState = context.read<AuthCubit>().state;

    if (cubitState is AuthNeedsProfileCompletion) {
      setState(() {
        _uid = cubitState.user.uid;
        _role = cubitState.user.role ?? 'seeker';
      });
      return;
    }

    final uid = widget.initialUid ?? await AppPrefs.getUserId();
    final role = widget.initialRole ?? await AppPrefs.getUserRole();

    if (mounted) {
      setState(() {
        _uid = uid;
        _role = role ?? 'seeker';
      });
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _nationalIdCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _firstNameError = _firstNameCtrl.text.trim().isEmpty
          ? 'val_first_name_required'
          : null;
      _lastNameError = _lastNameCtrl.text.trim().isEmpty
          ? 'val_last_name_required'
          : null;
      _phoneError = _validatePhone(_phoneCtrl.text.trim());
      _cityError = _cityCtrl.text.trim().isEmpty ? 'val_city_required' : null;
    });

    return _firstNameError == null &&
        _lastNameError == null &&
        _phoneError == null &&
        _cityError == null;
  }

  String? _validatePhone(String phone) {
    if (phone.isEmpty) return 'val_phone_required';
    if (!RegExp(r'^01[0125]\d{8}$').hasMatch(phone)) {
      return 'val_phone_invalid';
    }
    return null;
  }

  void _finish() {
    if (!_validate()) return;
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      CustomSnackBar.show(
        context,
        message: 'err_unknown'.tr(context),
        type: SnackBarType.error,
      );
      return;
    }
    context.read<AuthCubit>().completeProfile(
      uid: uid,
      role: _role,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      nationalId: _nationalIdCtrl.text.trim().isEmpty
          ? null
          : _nationalIdCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty
          ? null
          : _addressCtrl.text.trim(),
    );
  }

  void _skip() {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return;
    context.read<AuthCubit>().skipProfile(uid, _role);
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthSuccess) {
      final appRole = state.user.role == 'owner'
          ? AppRole.owner
          : AppRole.seeker;
      Navigation.offAll(
        MainLayoutView(role: appRole),
        transition: TransitionType.fade,
      );
    } else if (state is AuthError) {
      CustomSnackBar.show(
        context,
        message: state.message.tr(context),
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: .3,
        actions: [
          TextButton(
            onPressed: _skip,
            child: Text(
              'auth_btn_skip'.tr(context),
              style: GoogleFonts.cairo(
                color: AppColors.primary,
                fontSize: context.sp(14),
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: _handleState,
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) => SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: context.rAll(24),
              child: Column(
                children: [
                  SizedBox(height: context.r(16)),
                  const AuthHeader(
                    titleKey: 'auth_complete_profile_title',
                    subtitleKey: 'auth_complete_profile_subtitle',
                  ),
                  SizedBox(height: context.r(32)),
                  CustomTextField(
                    controller: _firstNameCtrl,
                    labelKey: 'auth_first_name_label',
                    hintKey: 'auth_first_name_hint',
                    icon: Icons.person_outline,
                    errorText: _firstNameError,
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: context.r(16)),
                  CustomTextField(
                    controller: _lastNameCtrl,
                    labelKey: 'auth_last_name_label',
                    hintKey: 'auth_last_name_hint',
                    icon: Icons.person_outline,
                    errorText: _lastNameError,
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: context.r(16)),
                  CustomTextField(
                    controller: _phoneCtrl,
                    labelKey: 'auth_phone_label',
                    hintKey: 'auth_phone_hint',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    errorText: _phoneError,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                  ),
                  SizedBox(height: context.r(16)),
                  CustomTextField(
                    controller: _cityCtrl,
                    labelKey: 'auth_city_label',
                    hintKey: 'auth_city_hint',
                    icon: Icons.location_city_outlined,
                    errorText: _cityError,
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: context.r(24)),
                  _sectionLabel(context, 'val_optional'),
                  SizedBox(height: context.r(16)),
                  CustomTextField(
                    controller: _nationalIdCtrl,
                    labelKey: 'auth_national_id_label',
                    hintKey: 'auth_national_id_hint',
                    icon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(14),
                    ],
                  ),
                  SizedBox(height: context.r(16)),
                  CustomTextField(
                    controller: _addressCtrl,
                    labelKey: 'auth_address_label',
                    hintKey: 'auth_address_hint',
                    icon: Icons.home_outlined,
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: context.r(40)),
                  LoadingButton(
                    isLoading: state is AuthLoading,
                    textKey: 'auth_btn_finish',
                    loadingTextKey: 'auth_loading',
                    icon: Icons.check_circle_outline,
                    onPressed: _finish,
                  ),
                  SizedBox(height: context.r(24)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String key) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.r(12)),
          child: Text(
            key.tr(context),
            style: TextStyle(color: Colors.grey, fontSize: context.sp(12)),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
      ],
    );
  }
}
