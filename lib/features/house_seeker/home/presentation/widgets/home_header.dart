import 'package:aqar_hub/core/animations/app_animations.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/home/helpers/property_helpers.dart';
import 'package:aqar_hub/features/shared/notifications/notification_center/notification_center_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final name = PropertyHelpers.currentUserFirstName();
    final greeting = PropertyHelpers.greeting(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B4B8C), Color(0xFF1E88E5), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: context.rOnly(left: 20, right: 20, top: 16, bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppAnimations.fade(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        name.isNotEmpty ? '$greeting, $name' : greeting,
                        style: GoogleFonts.tajawal(
                          fontSize: context.sp(13),
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AppAnimations.combined(
                      type: CombineType.fadeSlide,
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 80),
                      child: Text(
                        'homewelcomeline'.tr(context),
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(20),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(height: context.r(4)),
                    AppAnimations.fade(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 150),
                      child: Text(
                        'homewelcomesub'.tr(context),
                        style: GoogleFonts.tajawal(
                          fontSize: context.sp(12),
                          color: Colors.white.withValues(alpha: 0.78),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppAnimations.scale(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 100),
                child: Container(
                  width: context.r(44),
                  height: context.r(44),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(context.r(14)),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: context.r(22),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotificationCenterView(
                          onSwitchTab: (_) {},
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
