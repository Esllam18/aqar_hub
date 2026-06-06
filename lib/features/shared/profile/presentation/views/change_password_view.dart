import 'package:aqar_hub/core/animations/app_animations.dart';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/core/widgets/custom_snackbar.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../cubit/profile_cubit.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String? _currentPassError;
  String? _newPassError;
  String? _confirmError;

  bool _isVerifying = false;

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _currentPassError = _currentPassCtrl.text.isEmpty
          ? 'val_password_required'
          : null;
      _newPassError = _newPassCtrl.text.isEmpty
          ? 'val_password_required'
          : _newPassCtrl.text.length < 8
          ? 'val_password_min_8'
          : null;
      _confirmError = _confirmCtrl.text != _newPassCtrl.text
          ? 'val_password_mismatch'
          : null;
    });
    return _currentPassError == null &&
        _newPassError == null &&
        _confirmError == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    setState(() => _isVerifying = true);

    // Re-authenticate with the current password before allowing the change
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final email = user?.email ?? '';

      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: _currentPassCtrl.text,
      );
    } on AuthException {
      setState(() {
        _isVerifying = false;
        _currentPassError = 'err_current_password_wrong';
      });
      return;
    } catch (_) {
      setState(() {
        _isVerifying = false;
        _currentPassError = 'err_current_password_wrong';
      });
      return;
    }

    setState(() => _isVerifying = false);

    if (!mounted) return;
    context.read<ProfileCubit>().changePassword(_newPassCtrl.text.trim());
  }

  void _handleState(BuildContext context, ProfileState state) {
    if (state is ProfilePasswordChanged) {
      CustomSnackBar.show(
        context,
        message: 'profile_password_changed_success'.tr(context),
        type: SnackBarType.success,
      );
      Future.delayed(const Duration(milliseconds: 800), Navigation.back);
    }
    if (state is ProfileError) {
      CustomSnackBar.show(
        context,
        message: state.messageKey.tr(context),
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Respect the app's current directionality instead of hardcoding RTL
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: Navigation.back,
        ),
        title: Text(
          'profile_menu_change_password'.tr(context),
          style: GoogleFonts.cairo(
            fontSize: context.sp(18),
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: _handleState,
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            final isLoading = state is ProfileChangingPassword || _isVerifying;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: context.rAll(24),
              child: AppAnimations.combined(
                type: CombineType.fadeSlide,
                duration: const Duration(milliseconds: 400),
                child: Column(
                  children: [
                    SizedBox(height: context.r(20)),
                    Container(
                      width: context.r(72),
                      height: context.r(72),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: context.r(18),
                            offset: Offset(0, context.r(6)),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.lock_reset_rounded,
                        color: Colors.white,
                        size: context.r(32),
                      ),
                    ),
                    SizedBox(height: context.r(16)),
                    Text(
                      'change_password_title'.tr(context),
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(20),
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: context.r(6)),
                    Text(
                      'change_password_subtitle'.tr(context),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: context.sp(13),
                        color: Colors.grey.shade500,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: context.r(36)),

                    // ── Current password (re-auth) ─────────────────────────
                    CustomTextField(
                      controller: _currentPassCtrl,
                      labelKey: 'change_password_current_label',
                      hintKey: 'hint_password',
                      icon: Icons.lock_person_outlined,
                      obscureText: _obscureCurrent,
                      errorText: _currentPassError?.tr(context),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrent
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.primary,
                          size: context.r(20),
                        ),
                        onPressed: () =>
                            setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                    ),

                    SizedBox(height: context.r(16)),

                    // ── New password ──────────────────────────────────────
                    CustomTextField(
                      controller: _newPassCtrl,
                      labelKey: 'change_password_new_label',
                      hintKey: 'hint_password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscureNew,
                      errorText: _newPassError?.tr(context),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.primary,
                          size: context.r(20),
                        ),
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),

                    SizedBox(height: context.r(16)),

                    // ── Confirm new password ──────────────────────────────
                    CustomTextField(
                      controller: _confirmCtrl,
                      labelKey: 'change_password_confirm_label',
                      hintKey: 'hint_password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscureConfirm,
                      errorText: _confirmError?.tr(context),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.primary,
                          size: context.r(20),
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),

                    SizedBox(height: context.r(36)),

                    LoadingButton(
                      isLoading: isLoading,
                      textKey: 'btn_change_password',
                      loadingTextKey: 'btn_saving',
                      icon: Icons.check_circle_outline,
                      onPressed: isLoading ? () {} : _submit,
                    ),

                    SizedBox(height: context.r(40)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
