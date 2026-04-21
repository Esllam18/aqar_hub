// lib/layout/widgets/app_bottom_nav_bar.dart

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/enums/app_role.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final AppRole role;
  final int unreadChatCount;
  final int favCount;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.role,
    this.unreadChatCount = 0,
    this.favCount = 0,
  });

  bool get _isOwner => role == AppRole.owner;

  // Seeker:  [Home, Chat, Favorites, Profile]
  // Owner:   [Home, Chat, Sales,     Profile]
  List<_NavItem> _items(BuildContext context) {
    if (_isOwner) {
      return [
        _NavItem(icon: Icons.home_rounded, label: 'nav_home'.tr(context)),
        _NavItem(
          icon: Icons.chat_bubble_rounded,
          label: 'nav_chat'.tr(context),
          badge: unreadChatCount,
        ),
        _NavItem(icon: Icons.sell_rounded, label: 'nav_sales'.tr(context)),
        _NavItem(icon: Icons.person_rounded, label: 'nav_profile'.tr(context)),
      ];
    }
    return [
      _NavItem(icon: Icons.home_rounded, label: 'nav_home'.tr(context)),
      _NavItem(
        icon: Icons.chat_bubble_rounded,
        label: 'nav_chat'.tr(context),
        badge: unreadChatCount,
      ),
      _NavItem(
        icon: Icons.favorite_rounded,
        label: 'nav_favorites'.tr(context),
        badge: favCount,
      ),
      _NavItem(icon: Icons.person_rounded, label: 'nav_profile'.tr(context)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _items(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final active = i == currentIndex;
              final color = active ? AppColors.primary : Colors.grey.shade400;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  splashColor: AppColors.primary.withValues(alpha: 0.08),
                  highlightColor: Colors.transparent,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with badge
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              padding: const EdgeInsets.all(6),
                              decoration: active
                                  ? BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.10,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    )
                                  : null,
                              child: Icon(item.icon, color: color, size: 22),
                            ),
                            if (item.badge > 0)
                              Positioned(
                                top: -2,
                                right: -4,
                                child: _Badge(count: item.badge),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: GoogleFonts.tajawal(
                            fontSize: 10,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Badge ─────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return AnimatedScale(
      scale: count > 0 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int badge;
  const _NavItem({required this.icon, required this.label, this.badge = 0});
}
