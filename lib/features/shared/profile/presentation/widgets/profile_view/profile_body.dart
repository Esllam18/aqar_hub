import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/enums/app_role.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/navigation/transition_type.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/shared/profile/data/models/profile_model.dart';
import 'package:aqar_hub/features/shared/profile/presentation/cubit/profile_cubit.dart';
import 'package:aqar_hub/features/shared/profile/presentation/views/about_view.dart';
import 'package:aqar_hub/features/shared/profile/presentation/views/change_password_view.dart';
import 'package:aqar_hub/features/shared/profile/presentation/views/contact_us_view.dart';
import 'package:aqar_hub/features/shared/profile/presentation/views/edit_profile_view.dart';
import 'package:aqar_hub/features/shared/profile/presentation/views/help_center_view.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/edit_profile/profile_animated_secation.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/profile_view/profile_favorites_tile.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/profile_view/profile_header.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/profile_view/profile_lang_badge.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/profile_view/profile_language_dialog.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/profile_view/profile_logout_button.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/profile_view/profile_menu_card.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/profile_view/profile_menu_tile.dart';
import 'package:aqar_hub/features/shared/notifications/notification_center/notification_center_cubit.dart';
import 'package:aqar_hub/features/shared/notifications/notification_center/notification_center_view.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/profile_view/property_list/profile_property_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileBody extends StatelessWidget {
  final ProfileModel profile;
  final AppRole role;
  final String uid;

  const ProfileBody({
    super.key,
    required this.profile,
    required this.role,
    required this.uid,
  });

  AppRole get _effectiveRole {
    if (profile.role == 'owner') return AppRole.owner;
    if (profile.role == 'seeker') return AppRole.seeker;
    return role;
  }

  void _pushEdit(BuildContext ctx) => Navigation.to(
    BlocProvider.value(
      value: ctx.read<ProfileCubit>(),
      child: EditProfileView(profile: profile),
    ),
    transition: TransitionType.slideFromBottom,
  );

  void _pushChangePassword(BuildContext ctx) => Navigation.to(
    BlocProvider.value(
      value: ctx.read<ProfileCubit>(),
      child: const ChangePasswordView(),
    ),
  );

  void _openFavoritesList(BuildContext ctx) => Navigator.push(
    ctx,
    MaterialPageRoute(
      builder: (_) => ProfilePropertyListView(
        title: 'profile_favorites_list'.tr(ctx),
        uid: uid,
        listType: ProfilePropertyListType.favorites,
      ),
    ),
  );

  void _openPropertiesList(BuildContext ctx) => Navigator.push(
    ctx,
    MaterialPageRoute(
      builder: (_) => ProfilePropertyListView(
        title: 'profile_my_properties'.tr(ctx),
        uid: uid,
        listType: ProfilePropertyListType.owned,
      ),
    ),
  );

  void _pushNotifications(BuildContext ctx) {
    final notifCubit = ctx.read<NotificationCenterCubit>();
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: notifCubit,
          child: NotificationCenterView(onSwitchTab: (_) {}),
        ),
      ),
    ).then((_) => notifCubit.load());
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRole = _effectiveRole;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          context.read<ProfileCubit>().loadProfile(uid, forceRefresh: true);
          await context.read<ProfileCubit>().stream.firstWhere(
            (s) => s is ProfileLoaded || s is ProfileError,
          );
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: ProfileHeaderWidget(profile: profile, role: effectiveRole),
            ),
            SliverToBoxAdapter(child: SizedBox(height: context.r(20))),

            // ── Account ──────────────────────────────────────────────────
            AnimationSecation(
              delay: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section label
                  Padding(
                    padding: context.rOnly(bottom: 10, left: 4, right: 4),
                    child: Text(
                      'profile_section_account'.tr(context),
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(11),
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  // Account card (strictly typed List<ProfileMenuTile>)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(context.r(18)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        ProfileMenuTile(
                          icon: Icons.person_outline_rounded,
                          iconColor: AppColors.primary,
                          labelKey: 'profile_menu_edit',
                          onTap: () => _pushEdit(context),
                        ),
                        ProfileMenuTile(
                          icon: Icons.lock_outline_rounded,
                          iconColor: const Color(0xFF43A047),
                          labelKey: 'profile_menu_change_password',
                          onTap: () => _pushChangePassword(context),
                        ),
                        if (effectiveRole == AppRole.seeker)
                          ProfileMenuTile(
                            icon: Icons.favorite_border_rounded,
                            iconColor: const Color(0xFFE53935),
                            labelKey: 'profile_menu_favorites',
                            trailing: ProfileCountBadge(
                              count: profile.favoritesCount,
                              color: const Color(0xFFE53935),
                            ),
                            onTap: () => _openFavoritesList(context),
                          ),
                        if (effectiveRole == AppRole.owner)
                          ProfileMenuTile(
                            icon: Icons.apartment_rounded,
                            iconColor: AppColors.primary,
                            labelKey: 'profile_menu_my_apartments',
                            trailing: ProfileCountBadge(
                              count: profile.apartmentsCount,
                              color: AppColors.primary,
                            ),
                            onTap: () => _openPropertiesList(context),
                          ),
                        // Notification tile — BlocBuilder wraps a ProfileMenuTile
                        // OUTSIDE the typed list, placed directly in Column children.
                        BlocBuilder<
                          NotificationCenterCubit,
                          NotificationCenterState
                        >(
                          builder: (ctx, notifState) {
                            final unread =
                                notifState is NotificationCenterLoaded
                                ? notifState.unreadCount
                                : 0;
                            return ProfileMenuTile(
                              icon: Icons.notifications_none_rounded,
                              iconColor: const Color(0xFFFF6B35),
                              labelKey: 'profile_menu_notifications',
                              trailing: unread > 0
                                  ? ProfileCountBadge(
                                      count: unread,
                                      color: const Color(0xFFFF6B35),
                                    )
                                  : null,
                              onTap: () => _pushNotifications(context),
                              showDivider: false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: context.r(14))),

            // ── Preferences ──────────────────────────────────────────────
            AnimationSecation(
              delay: 160,
              child: ProfileMenuCard(
                titleKey: 'profile_section_preferences',
                tiles: [
                  ProfileMenuTile(
                    icon: Icons.language_rounded,
                    iconColor: const Color(0xFF00897B),
                    labelKey: 'profile_menu_language',
                    trailing: const CurrentLangBadge(),
                    onTap: () => ProfileLanguageDialog.show(context),
                    showDivider: false,
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: context.r(14))),

            // ── Support ──────────────────────────────────────────────────
            AnimationSecation(
              delay: 240,
              child: ProfileMenuCard(
                titleKey: 'profile_section_support',
                tiles: [
                  ProfileMenuTile(
                    icon: Icons.help_outline_rounded,
                    iconColor: const Color(0xFF26A69A),
                    labelKey: 'profile_menu_help',
                    onTap: () => Navigation.to(const HelpCenterView()),
                  ),
                  ProfileMenuTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: const Color(0xFF039BE5),
                    labelKey: 'profile_menu_contact_us',
                    onTap: () => Navigation.to(const ContactUsView()),
                  ),
                  ProfileMenuTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: const Color(0xFF7E57C2),
                    labelKey: 'profile_menu_about',
                    onTap: () => Navigation.to(const AboutView()),
                    showDivider: false,
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: context.r(24))),

            const AnimationSecation(delay: 320, child: ProfileLogoutButton()),
            SliverToBoxAdapter(child: SizedBox(height: context.r(110))),
          ],
        ),
      ),
    );
  }
}
