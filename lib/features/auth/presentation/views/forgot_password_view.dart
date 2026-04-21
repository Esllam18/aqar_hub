import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/core/widgets/custom_snackbar.dart';
import 'package:aqar_hub/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aqar_hub/features/auth/presentation/views/reset_password_view.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/auth_header.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailCtrl = TextEditingController();
  String? _emailError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  void _send() {
    final email = _emailCtrl.text.trim();
    setState(() {
      _emailError = email.isEmpty
          ? 'val_email_required'
          : !email.contains('@')
          ? 'val_email_invalid'
          : null;
    });
    if (_emailError == null) {
      context.read<AuthCubit>().sendPasswordReset(email);
    }
  }

  // ── State Handler ─────────────────────────────────────────────────────────

  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthPasswordResetSent) {
      CustomSnackBar.show(
        context,
        message: 'auth_reset_sent'.tr(context),
        type: SnackBarType.success,
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        // ignore: use_build_context_synchronously
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<AuthCubit>(),
              child: const ResetPasswordView(),
            ),
          ),
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
                    titleKey: 'auth_forgot_title',
                    subtitleKey: 'auth_forgot_subtitle',
                  ),

                  SizedBox(height: context.r(40)),

                  CustomTextField(
                    controller: _emailCtrl,
                    labelKey: 'auth_email_label',
                    hintKey: 'auth_email_hint',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                  ),

                  SizedBox(height: context.r(32)),

                  LoadingButton(
                    isLoading: state is AuthLoading,
                    textKey: 'auth_btn_send_reset',
                    loadingTextKey: 'auth_loading',
                    icon: Icons.send,
                    onPressed: _send,
                  ),

                  SizedBox(height: context.r(16)),

                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'auth_back_to_login'.tr(context),
                      style: GoogleFonts.cairo(
                        color: AppColors.primary,
                        fontSize: context.sp(14),
                      ),
                    ),
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
