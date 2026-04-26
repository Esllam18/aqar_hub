// ignore_for_file: unnecessary_non_null_assertion

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/enums/app_role.dart';
import 'package:aqar_hub/features/house_seeker/favorites/data/datasources/favorites_datasource.dart';
import 'package:aqar_hub/features/house_seeker/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:aqar_hub/features/house_seeker/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:aqar_hub/features/house_seeker/favorites/presentation/views/favorites_view.dart';
import 'package:aqar_hub/features/house_seeker/home/presentation/views/home_view.dart';
import 'package:aqar_hub/features/owner/home/presentation/views/owner_home_view.dart';
import 'package:aqar_hub/features/owner/owner_sale/presentation/view/owner_sale_properties_view.dart';
import 'package:aqar_hub/features/shared/chat/data/datasources/chat_remote_datasource.dart';
import 'package:aqar_hub/features/shared/chat/data/repositories/chat_repository_impl.dart';
import 'package:aqar_hub/features/shared/chat/presentation/cubit/conversation_list_cubit.dart';
import 'package:aqar_hub/features/shared/chat/presentation/views/conversation_list_view.dart';
import 'package:aqar_hub/features/shared/notifications/fcm_service.dart';
import 'package:aqar_hub/features/shared/notifications/notification_center/notification_center_cubit.dart';
import 'package:aqar_hub/features/shared/notifications/notification_center/notification_navigator.dart';
import 'package:aqar_hub/features/shared/profile/data/datasources/profile_datasource_impl.dart';
import 'package:aqar_hub/features/shared/profile/data/repositories/profile_repository_impl.dart';
import 'package:aqar_hub/features/shared/profile/presentation/cubit/profile_cubit.dart';
import 'package:aqar_hub/features/shared/profile/presentation/views/profile_view.dart';
import 'package:aqar_hub/layout/widgets/app_bottom_nav_bar.dart';
import 'package:aqar_hub/layout/widgets/app_fab_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainLayoutView extends StatefulWidget {
  final AppRole role;
  const MainLayoutView({super.key, required this.role});

  @override
  State<MainLayoutView> createState() => _MainLayoutViewState();
}

class _MainLayoutViewState extends State<MainLayoutView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  late final PageController _pageController;
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;
  late final AnimationController _fabCtrl;
  late final Animation<double> _fabScale;

  late final ConversationListCubit _chatCubit;
  late final FavoritesCubit? _favCubit;
  // Global notification cubit — shared across all tabs and profile
  late final NotificationCenterCubit _notifCubit;

  late final ChatRepositoryImpl _chatRepo;

  String get _uid => Supabase.instance.client.auth.currentUser?.id ?? '';
  bool get _isOwner => widget.role == AppRole.owner;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pageController = PageController();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _entryCtrl.forward();

    _fabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fabScale = CurvedAnimation(parent: _fabCtrl, curve: Curves.easeOutBack);
    if (_isOwner) _fabCtrl.forward();

    _chatRepo = ChatRepositoryImpl(ChatRemoteDatasource());
    _chatCubit = ConversationListCubit(_chatRepo)..load();

    // Load notification count immediately so badges are ready
    _notifCubit = NotificationCenterCubit()..load();

    FcmService.instance.setOnTap(_handleNotificationTap);

    _favCubit = _isOwner
        ? null
        : (FavoritesCubit(FavoritesRepositoryImpl(FavoritesDatasourceImpl()))
            ..loadFavoriteIds());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _chatRepo.goOnline();
        // Refresh notification count when app comes back to foreground
        _notifCubit.load();
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _chatRepo.goOffline();
      default:
        break;
    }
  }

  // FIX: Separate the tab-switch from the post-navigation push.
  // The old _handleNotificationTap passed _onNavTapped which has an
  // early-return guard "if (_currentIndex == index) return" — so if the
  // user was already on the Home tab and tapped a property notification,
  // _onNavTapped returned immediately and the property detail screen was
  // never pushed. We now use _switchTabForNotification which always jumps
  // to the tab AND always lets NotificationNavigator push its route after.
  void _handleNotificationTap(NotificationPayload payload) {
    _notifCubit.load();
    if (!mounted) return;
    NotificationNavigator.navigateFromPayload(
      context,
      payload,
      onSwitchTab: _switchTabForNotification,
    );
  }

  // Like _onNavTapped but WITHOUT the early-return guard.
  // This ensures the tab is switched even when we are already on it,
  // so NotificationNavigator can then push the correct detail screen on top.
  void _switchTabForNotification(int index) {
    HapticFeedback.selectionClick();
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
      _pageController.jumpToPage(index); // jumpToPage — no animation delay
    }
    // No early return: NotificationNavigator will push its route right after.
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _entryCtrl.dispose();
    _fabCtrl.dispose();
    _chatCubit.close();
    _favCubit?.close();
    _notifCubit.close();
    super.dispose();
  }

  int _unreadCount(ConversationListState state) {
    if (state is! ConversationListLoaded) return 0;
    final myId = _chatCubit.myIdOrNull;
    if (myId == null) return 0;
    return state.conversations.fold(0, (sum, c) => sum + c.unreadFor(myId));
  }

  int _favCount(FavoritesState? state) {
    if (state == null) return 0;
    return switch (state) {
      FavoritesIdsLoaded s => s.ids.length,
      FavoritesLoaded s => s.ids.length,
      _ => 0,
    };
  }

  int _notifUnreadCount(NotificationCenterState state) {
    if (state is NotificationCenterLoaded) return state.unreadCount;
    return 0;
  }

  List<Widget> _buildScreens() {
    final profilePage = BlocProvider(
      create: (_) =>
          ProfileCubit(ProfileRepositoryImpl(ProfileDatasourceImpl()))
            ..loadProfile(_uid),
      child: ProfileView(role: widget.role, uid: _uid),
    );

    final chatPage = BlocProvider.value(
      value: _chatCubit,
      child: const ConversationListView(),
    );

    if (_isOwner) {
      return [
        const OwnerHomeView(),
        chatPage,
        const OwnerSalePropertiesView(),
        profilePage,
      ];
    }

    final favPage = BlocProvider.value(
      value: _favCubit!,
      child: const FavoritesView(),
    );

    return [const HomeView(), chatPage, favPage, profilePage];
  }

  void _onNavTapped(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onOwnerFabPressed() => HapticFeedback.mediumImpact();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _chatCubit),
          BlocProvider.value(value: _notifCubit),
          if (_favCubit != null) BlocProvider.value(value: _favCubit!),
        ],
        child: Builder(
          builder: (ctx) {
            final chatState = ctx.watch<ConversationListCubit>().state;
            final notifState = ctx.watch<NotificationCenterCubit>().state;
            final favState = _favCubit != null
                ? ctx.watch<FavoritesCubit>().state
                : null;

            return Scaffold(
              backgroundColor: AppColors.background,
              extendBody: true,
              body: FadeTransition(
                opacity: _entryFade,
                child: SlideTransition(
                  position: _entrySlide,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentIndex = i),
                    children: _buildScreens(),
                  ),
                ),
              ),
              bottomNavigationBar: AppBottomNavBar(
                currentIndex: _currentIndex,
                onTap: _onNavTapped,
                role: widget.role,
                unreadChatCount: _unreadCount(chatState),
                favCount: _favCount(favState),
                unreadNotifCount: _notifUnreadCount(notifState),
              ),
              floatingActionButton: _isOwner
                  ? AppFabButton(
                      scale: _fabScale,
                      onPressed: _onOwnerFabPressed,
                    )
                  : null,
              floatingActionButtonLocation:
                  Directionality.of(context) == TextDirection.ltr
                  ? FloatingActionButtonLocation.startDocked
                  : FloatingActionButtonLocation.endContained,
            );
          },
        ),
      ),
    );
  }
}
