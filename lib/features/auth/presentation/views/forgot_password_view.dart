// lib/features/auth/presentation/views/forgot_password_view.dart
//
// FIX: The previous implementation pushed ResetPasswordView immediately after
// sending the email. This is wrong — updateUser() requires an active
// password-reset session that only exists AFTER the user taps the email link.
//
// Correct flow:
//   1. User enters email → Supabase sends reset email.
//   2. User taps link in email → deep link opens the app.
//   3. App detects the deep-link session → navigates to ResetPasswordView.
//
// This screen now shows a clear "check your email" state after sending,
// with a "Resend" option and correct instructions for the user.

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/core/widgets/custom_snackbar.dart';
import 'package:aqar_hub/features/auth/presentation/cubit/auth_cubit.dart';
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
  bool _emailSent = false;
  String _sentToEmail = '';

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

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

  void _resend() {
    setState(() => _emailSent = false);
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthPasswordResetSent) {
      setState(() {
        _emailSent = true;
        _sentToEmail = _emailCtrl.text.trim();
      });
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _emailSent
                    ? _SentState(
                        key: const ValueKey('sent'),
                        sentToEmail: _sentToEmail,
                        onResend: _resend,
                        onBackToLogin: () => Navigator.of(context).pop(),
                      )
                    : _EnterEmailState(
                        key: const ValueKey('input'),
                        emailCtrl: _emailCtrl,
                        emailError: _emailError,
                        isLoading: state is AuthLoading,
                        onSend: _send,
                        onBack: () => Navigator.of(context).pop(),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Enter email state ─────────────────────────────────────────────────────────

class _EnterEmailState extends StatelessWidget {
  final TextEditingController emailCtrl;
  final String? emailError;
  final bool isLoading;
  final VoidCallback onSend;
  final VoidCallback onBack;

  const _EnterEmailState({
    super.key,
    required this.emailCtrl,
    required this.emailError,
    required this.isLoading,
    required this.onSend,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: context.r(20)),
        const AuthHeader(
          titleKey: 'auth_forgot_title',
          subtitleKey: 'auth_forgot_subtitle',
        ),
        SizedBox(height: context.r(40)),
        CustomTextField(
          controller: emailCtrl,
          labelKey: 'auth_email_label',
          hintKey: 'auth_email_hint',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          errorText: emailError,
        ),
        SizedBox(height: context.r(32)),
        LoadingButton(
          isLoading: isLoading,
          textKey: 'auth_btn_send_reset',
          loadingTextKey: 'auth_loading',
          icon: Icons.send,
          onPressed: onSend,
        ),
        SizedBox(height: context.r(16)),
        TextButton(
          onPressed: onBack,
          child: Text(
            'auth_back_to_login'.tr(context),
            style: GoogleFonts.cairo(
              color: AppColors.primary,
              fontSize: context.sp(14),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Email sent confirmation state ─────────────────────────────────────────────

class _SentState extends StatelessWidget {
  final String sentToEmail;
  final VoidCallback onResend;
  final VoidCallback onBackToLogin;

  const _SentState({
    super.key,
    required this.sentToEmail,
    required this.onResend,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: context.r(40)),

        // Icon
        Container(
          width: context.r(80),
          height: context.r(80),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read_outlined,
            size: context.r(36),
            color: AppColors.primary,
          ),
        ),

        SizedBox(height: context.r(24)),

        Text(
          'auth_reset_sent_title'.tr(context),
          style: GoogleFonts.cairo(
            fontSize: context.sp(22),
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: context.r(12)),

        Text(
          'auth_reset_sent_body'.tr(context).replaceAll('{email}', sentToEmail),
          style: GoogleFonts.tajawal(
            fontSize: context.sp(14),
            color: Colors.grey.shade600,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: context.r(16)),

        // Instructions box
        Container(
          width: double.infinity,
          padding: context.rAll(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(context.r(14)),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Step(number: '1', textKey: 'auth_reset_step1', context: context),
              SizedBox(height: context.r(8)),
              _Step(number: '2', textKey: 'auth_reset_step2', context: context),
              SizedBox(height: context.r(8)),
              _Step(number: '3', textKey: 'auth_reset_step3', context: context),
            ],
          ),
        ),

        SizedBox(height: context.r(32)),

        // Back to login (primary action)
        SizedBox(
          width: double.infinity,
          height: context.r(52),
          child: ElevatedButton(
            onPressed: onBackToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.r(14)),
              ),
              elevation: 0,
            ),
            child: Text(
              'auth_back_to_login'.tr(context),
              style: GoogleFonts.cairo(
                fontSize: context.sp(15),
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),

        SizedBox(height: context.r(12)),

        // Resend
        TextButton(
          onPressed: onResend,
          child: Text(
            'auth_reset_resend'.tr(context),
            style: GoogleFonts.cairo(
              color: Colors.grey.shade500,
              fontSize: context.sp(13),
            ),
          ),
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String textKey;
  final BuildContext context;

  const _Step({
    required this.number,
    required this.textKey,
    required this.context,
  });

  @override
  Widget build(BuildContext outerCtx) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: context.r(22),
          height: context.r(22),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.cairo(
                fontSize: context.sp(11),
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: context.r(10)),
        Expanded(
          child: Text(
            textKey.tr(context),
            style: GoogleFonts.tajawal(
              fontSize: context.sp(13),
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
