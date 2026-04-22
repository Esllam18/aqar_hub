import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/enums/app_role.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/navigation/transition_type.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/core/widgets/custom_snackbar.dart';
import 'package:aqar_hub/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aqar_hub/features/auth/presentation/views/complete_profile_view.dart';
import 'package:aqar_hub/features/auth/presentation/views/role_selection_view.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/auth_header.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/loading_button.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/or_divider_widget.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/social_button.dart';
import 'package:aqar_hub/layout/views/main_layout_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirmPassword = _confirmPasswordCtrl.text;

    setState(() {
      _emailError = email.isEmpty
          ? 'val_email_required'
          : !email.contains('@')
          ? 'val_email_invalid'
          : null;
      _passwordError = password.isEmpty
          ? 'val_password_required'
          : password.length < 8
          ? 'val_password_min_8'
          : null;
      _confirmPasswordError = confirmPassword.isEmpty
          ? 'val_password_required'
          : confirmPassword != password
          ? 'val_passwords_mismatch'
          : null;
    });

    return _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  void _signUp() {
    if (!_validate()) return;
    context.read<AuthCubit>().signUpWithEmail(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthNeedsRoleSelection) {
      _push(
        BlocProvider.value(
          value: context.read<AuthCubit>(),
          child: const RoleSelectionView(),
        ),
      );
    } else if (state is AuthNeedsProfileCompletion) {
      _push(
        BlocProvider.value(
          value: context.read<AuthCubit>(),
          child: const CompleteProfileView(),
        ),
      );
    } else if (state is AuthSuccess) {
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

  void _push(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

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
                  SizedBox(height: context.r(16)),
                  const AuthHeader(
                    titleKey: 'auth_signup_title',
                    subtitleKey: 'auth_signup_subtitle',
                  ),
                  SizedBox(height: context.r(32)),
                  CustomTextField(
                    controller: _emailCtrl,
                    labelKey: 'auth_email_label',
                    hintKey: 'auth_email_hint',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                  ),
                  SizedBox(height: context.r(16)),
                  CustomTextField(
                    controller: _passwordCtrl,
                    labelKey: 'auth_password_label',
                    hintKey: 'auth_password_hint',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    errorText: _passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.primary,
                        size: context.r(20),
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  SizedBox(height: context.r(16)),
                  CustomTextField(
                    controller: _confirmPasswordCtrl,
                    labelKey: 'auth_confirm_password_label',
                    hintKey: 'auth_password_hint',
                    icon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    errorText: _confirmPasswordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.primary,
                        size: context.r(20),
                      ),
                      onPressed: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                  SizedBox(height: context.r(32)),
                  LoadingButton(
                    isLoading: state is AuthLoading,
                    textKey: 'auth_btn_signup',
                    loadingTextKey: 'auth_loading',
                    icon: Icons.person_add_outlined,
                    onPressed: _signUp,
                  ),
                  SizedBox(height: context.r(24)),
                  OrDividerWidget(text: 'auth_or_continue'.tr(context)),
                  SizedBox(height: context.r(16)),
                  SocialButton(
                    textKey: 'auth_btn_google',
                    imagePath: 'assets/icons/googleIcon.png',
                    backgroundColor: Colors.white,
                    textColor: AppColors.primary,
                    onPressed: () =>
                        context.read<AuthCubit>().signInWithGoogle(),
                  ),
                  SizedBox(height: context.r(24)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'auth_have_account'.tr(context),
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(14),
                          color: AppColors.primary.withValues(alpha: 0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'auth_btn_login'.tr(context),
                          style: GoogleFonts.cairo(
                            fontSize: context.sp(14),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.r(8)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
