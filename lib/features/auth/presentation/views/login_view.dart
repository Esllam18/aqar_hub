import 'package:aqar_hub/core/constants/app_assets.dart';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/enums/app_role.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/navigation/transition_type.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/core/widgets/custom_snackbar.dart';
import 'package:aqar_hub/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aqar_hub/features/auth/presentation/views/complete_profile_view.dart';
import 'package:aqar_hub/features/auth/presentation/views/forgot_password_view.dart';
import 'package:aqar_hub/features/auth/presentation/views/role_selection_view.dart';
import 'package:aqar_hub/features/auth/presentation/views/sign_up_view.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/auth_header.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/loading_button.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/or_divider_widget.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/social_button.dart';
import 'package:aqar_hub/layout/views/main_layout_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _emailError = _emailCtrl.text.trim().isEmpty
          ? 'val_email_required'
          : !_emailCtrl.text.contains('@')
          ? 'val_email_invalid'
          : null;
      _passwordError = _passwordCtrl.text.isEmpty
          ? 'val_password_required'
          : _passwordCtrl.text.length <
                6 // ← remove the quotes
          ? 'val_password_short'
          : null;
    });
    return _emailError == null && _passwordError == null;
  }

  void _login() {
    if (!_validate()) return;
    context.read<AuthCubit>().signInWithEmail(
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
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
                    titleKey: 'auth_login_title',
                    subtitleKey: 'auth_login_subtitle',
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
                  SizedBox(height: context.r(16)),
                  CustomTextField(
                    controller: _passwordCtrl,
                    labelKey: 'auth_password_label',
                    hintKey: 'auth_password_hint',
                    icon: Icons.lock_outline,
                    obscureText: _obscure,
                    errorText: _passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.primary,
                        size: context.r(20),
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  SizedBox(height: context.r(8)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => _push(const ForgotPasswordView()),
                      child: Text(
                        'auth_forgot_password'.tr(context),
                        style: GoogleFonts.cairo(
                          color: AppColors.primary,
                          fontSize: context.sp(14),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.r(24)),
                  LoadingButton(
                    isLoading: state is AuthLoading,
                    textKey: 'auth_btn_login',
                    loadingTextKey: 'auth_loading',
                    icon: Icons.login,
                    onPressed: _login,
                  ),
                  SizedBox(height: context.r(24)),
                  OrDividerWidget(text: 'auth_or_continue'.tr(context)),
                  SizedBox(height: context.r(16)),
                  SocialButton(
                    textKey: 'auth_btn_google',
                    imagePath: AppIcons.google,
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
                        'auth_no_account'.tr(context),
                        style: GoogleFonts.cairo(
                          color: AppColors.primary.withValues(alpha: 0.7),
                          fontSize: context.sp(14),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _push(
                          BlocProvider.value(
                            value: context.read<AuthCubit>(),
                            child: const SignUpView(),
                          ),
                        ),
                        child: Text(
                          'auth_btn_signup'.tr(context),
                          style: GoogleFonts.cairo(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: context.sp(14),
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
