// lib/features/auth/presentation/views/role_selection_view.dart

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/core/widgets/custom_snackbar.dart';
import 'package:aqar_hub/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aqar_hub/features/auth/presentation/views/complete_profile_view.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/loading_button.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/role_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleSelectionView extends StatefulWidget {
  const RoleSelectionView({super.key});

  @override
  State<RoleSelectionView> createState() => _RoleSelectionViewState();
}

class _RoleSelectionViewState extends State<RoleSelectionView> {
  String _selectedRole = 'user';
  String? _uid;

  @override
  void initState() {
    super.initState();
    _extractFromState();
  }

  void _extractFromState() {
    final s = context.read<AuthCubit>().state;

    if (s is AuthNeedsRoleSelection) {
      _uid = s.user.uid;
      _selectedRole = (s.user.role?.isNotEmpty == true) ? s.user.role! : 'user';
    } else if (s is AuthNeedsProfileCompletion) {
      _uid = s.user.uid;
      _selectedRole = (s.user.role?.isNotEmpty == true) ? s.user.role! : 'user';
    }
  }

  // ── Continue ──────────────────────────────────────────────────────────────

  void _continue() {
    final uid = _uid;

    if (uid == null || uid.isEmpty) {
      CustomSnackBar.show(
        context,
        message: 'err_unknown'.tr(context),
        type: SnackBarType.error,
      );
      return;
    }

    context.read<AuthCubit>().updateRole(uid, _selectedRole);
  }

  // ── State Handler ─────────────────────────────────────────────────────────

  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthNeedsProfileCompletion) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<AuthCubit>(),
            child: const CompleteProfileView(),
          ),
        ),
      );
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
      body: BlocListener<AuthCubit, AuthState>(
        listener: _handleState,
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) => SafeArea(
            child: Padding(
              padding: context.rAll(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: context.r(20)),

                  Text(
                    'auth_role_title'.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(26),
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),

                  SizedBox(height: context.r(8)),

                  Text(
                    'auth_role_subtitle'.tr(context),
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(15),
                      color: AppColors.primary.withValues(alpha: 0.65),
                    ),
                  ),

                  SizedBox(height: context.r(40)),

                  RoleCard(
                    titleKey: 'auth_role_user',
                    descriptionKey: 'auth_role_user_desc',
                    icon: Icons.person_outline,
                    isSelected: _selectedRole == 'user',
                    onTap: () => setState(() => _selectedRole = 'user'),
                  ),

                  SizedBox(height: context.r(16)),

                  RoleCard(
                    titleKey: 'auth_role_owner',
                    descriptionKey: 'auth_role_owner_desc',
                    icon: Icons.business_outlined,
                    isSelected: _selectedRole == 'owner',
                    onTap: () => setState(() => _selectedRole = 'owner'),
                  ),

                  const Spacer(),

                  LoadingButton(
                    isLoading: state is AuthLoading,
                    textKey: 'auth_btn_continue',
                    loadingTextKey: 'auth_loading',
                    icon: Icons.arrow_forward,
                    onPressed: _continue,
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
}
