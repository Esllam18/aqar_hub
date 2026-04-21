import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/owner/home/presentation/views/add_property_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class OwnerQuickActions extends StatelessWidget {
  /// Called when "Alerts" action is tapped — switches filter to attention tab.
  final VoidCallback onAlertsTap;

  const OwnerQuickActions({super.key, required this.onAlertsTap});

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — ${'owner_coming_soon'.tr(context)}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _shareApp(BuildContext context) async {
    // Share the app via a generic intent using url_launcher
    final uri = Uri.parse(
      'https://wa.me/?text=${'owner_share_text'.tr(context)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action(
        icon: Icons.add_home_work_rounded,
        label: 'owner_add_property'.tr(context),
        color: AppColors.primary,
        onTap: () => Navigation.to(const AddPropertyView()),
      ),
      _Action(
        icon: Icons.notifications_active_rounded,
        label: 'owner_stats_alerts'.tr(context),
        color: AppColors.warning,
        onTap: onAlertsTap,
      ),
      _Action(
        icon: Icons.bar_chart_rounded,
        label: 'owner_action_stats'.tr(context),
        color: AppColors.info,
        onTap: () => _showComingSoon(context, 'owner_action_stats'.tr(context)),
      ),
      _Action(
        icon: Icons.share_rounded,
        label: 'owner_action_share'.tr(context),
        color: AppColors.success,
        onTap: () => _shareApp(context),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: context.rOnly(left: 18, right: 18, top: 16, bottom: 8),
          child: Text(
            'owner_quick_actions'.tr(context),
            style: GoogleFonts.cairo(
              fontSize: context.sp(13.5),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: context.r(88),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: context.rSymmetric(horizontal: 16),
            itemCount: actions.length,
            separatorBuilder: (_, __) => SizedBox(width: context.r(10)),
            itemBuilder: (_, i) => _ActionTile(action: actions[i]),
          ),
        ),
      ],
    );
  }
}

class _Action {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Action({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _ActionTile extends StatelessWidget {
  final _Action action;
  const _ActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        width: context.r(80),
        padding: context.rAll(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(16)),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: context.r(38),
              height: context.r(38),
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(context.r(11)),
              ),
              child: Icon(
                action.icon,
                color: action.color,
                size: context.r(20),
              ),
            ),
            SizedBox(height: context.r(6)),
            Text(
              action.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(9.5),
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
