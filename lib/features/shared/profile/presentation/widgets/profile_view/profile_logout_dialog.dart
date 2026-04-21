// ignore_for_file: use_build_context_synchronously

import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/navigation/transition_type.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/auth/data/datasource/auth_remote_data_source_impl.dart';
import 'package:aqar_hub/features/shared/notifications/fcm_service.dart';
import 'package:aqar_hub/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqar_hub/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aqar_hub/features/auth/presentation/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileLogoutDialog extends StatelessWidget {
  const ProfileLogoutDialog({super.key});

  static Future<void> show(BuildContext context) => showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => BlocProvider.value(
      value: context.read<AuthCubit>(),
      child: const ProfileLogoutDialog(),
    ),
  );

  Future<void> _doLogout(BuildContext context) async {
    Navigator.of(context).pop();

    await FcmService.instance.removeToken();
    try {
      await context.read<AuthCubit>().signOut();
    } catch (_) {}
    Navigation.offAll(
      BlocProvider(
        create: (_) =>
            AuthCubit(AuthRepositoryImpl(AuthRemoteDataSourceImpl())),
        child: const LoginView(),
      ),
      transition: TransitionType.fade,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.r(24)),
      ),
      child: Padding(
        padding: context.rOnly(top: 32, bottom: 24, left: 24, right: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon ──────────────────────────────────────────────────────
            Container(
              width: context.r(76),
              height: context.r(76),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: const Color(0xFFE53935),
                size: context.r(36),
              ),
            ),

            SizedBox(height: context.r(20)),

            // ── Title ─────────────────────────────────────────────────────
            Text(
              'logout_dialog_title'.tr(context),
              style: GoogleFonts.cairo(
                fontSize: context.sp(19),
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade800,
              ),
            ),

            SizedBox(height: context.r(8)),

            // ── Subtitle ──────────────────────────────────────────────────
            Padding(
              padding: context.rSymmetric(horizontal: 8),
              child: Text(
                'logout_dialog_subtitle'.tr(context),
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(14),
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
            ),

            SizedBox(height: context.r(28)),

            // ── Buttons ───────────────────────────────────────────────────
            Row(
              children: [
                // Cancel
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: context.rSymmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.r(14)),
                      ),
                    ),
                    child: Text(
                      'btn_cancel'.tr(context),
                      style: GoogleFonts.tajawal(
                        fontSize: context.sp(14),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: context.r(12)),

                // Confirm
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _doLogout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      elevation: 0,
                      padding: context.rSymmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.r(14)),
                      ),
                    ),
                    child: Text(
                      'btn_logout'.tr(context),
                      style: GoogleFonts.tajawal(
                        fontSize: context.sp(14),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
