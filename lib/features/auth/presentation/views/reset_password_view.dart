import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/navigation/transition_type.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/core/widgets/custom_snackbar.dart';
import 'package:aqar_hub/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aqar_hub/features/auth/presentation/views/login_view.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/auth_header.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _passwordError;
  String? _confirmError;
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  void _submit() {
    setState(() {
      _passwordError = _passwordCtrl.text.length < 6
          ? 'val_password_short'
          : null;
      _confirmError = _passwordCtrl.text != _confirmCtrl.text
          ? 'val_passwords_mismatch'
          : null;
    });
    if (_passwordError == null && _confirmError == null) {
      context.read<AuthCubit>().updatePassword(_passwordCtrl.text.trim());
    }
  }

  // ── State Handler ─────────────────────────────────────────────────────────

  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthPasswordUpdated) {
      CustomSnackBar.show(
        context,
        message: 'auth_password_updated'.tr(context),
        type: SnackBarType.success,
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigation.offAll(
          BlocProvider.value(
            // ignore: use_build_context_synchronously
            value: context.read<AuthCubit>(),
            child: const LoginView(),
          ),
          transition: TransitionType.fade,
        );
      });
    } else if (state is AuthError) {
      CustomSnackBar.show(
        context,
        message: state.message.tr(context),
        type: SnackBarType.error,
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: _handleState,
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) => SafeArea(
            child: SingleChildScrollView(
              padding: context.rAll(24),
              child: Column(
                children: [
                  SizedBox(height: context.r(20)),

                  const AuthHeader(
                    titleKey: 'auth_reset_title',
                    subtitleKey: 'auth_reset_subtitle',
                  ),

                  SizedBox(height: context.r(40)),

                  // ── New Password ─────────────────────────────────────────
                  CustomTextField(
                    controller: _passwordCtrl,
                    labelKey: 'auth_password_label',
                    hintKey: 'auth_password_hint',
                    icon: Icons.lock_outline,
                    obscureText: _obscure1,
                    errorText: _passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure1 ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.primary,
                        size: context.r(20),
                      ),
                      onPressed: () => setState(() => _obscure1 = !_obscure1),
                    ),
                  ),

                  SizedBox(height: context.r(16)),

                  // ── Confirm Password ─────────────────────────────────────
                  CustomTextField(
                    controller: _confirmCtrl,
                    labelKey: 'auth_confirm_password_label',
                    hintKey: 'auth_password_hint',
                    icon: Icons.lock_outline,
                    obscureText: _obscure2,
                    errorText: _confirmError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure2 ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.primary,
                        size: context.r(20),
                      ),
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                    ),
                  ),

                  SizedBox(height: context.r(32)),

                  LoadingButton(
                    isLoading: state is AuthLoading,
                    textKey: 'auth_btn_save_password',
                    loadingTextKey: 'auth_loading',
                    icon: Icons.check_circle_outline,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
