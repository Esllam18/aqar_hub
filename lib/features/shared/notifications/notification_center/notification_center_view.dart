import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notification_center_cubit.dart';
import 'notification_log_model.dart';
import 'notification_navigator.dart';

class NotificationCenterView extends StatelessWidget {
  final void Function(int) onSwitchTab;

  const NotificationCenterView({super.key, required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationCenterCubit()..load(),
      child: _NotificationCenterBody(onSwitchTab: onSwitchTab),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _NotificationCenterBody extends StatefulWidget {
  final void Function(int) onSwitchTab;
  const _NotificationCenterBody({required this.onSwitchTab});

  @override
  State<_NotificationCenterBody> createState() =>
      _NotificationCenterBodyState();
}

class _NotificationCenterBodyState extends State<_NotificationCenterBody> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<NotificationCenterCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'nav_notifications'.tr(context),
          style: GoogleFonts.cairo(
            fontSize: context.sp(17),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1B2D5E),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1B2D5E),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          BlocBuilder<NotificationCenterCubit, NotificationCenterState>(
            builder: (ctx, state) {
              if (state is! NotificationCenterLoaded) return const SizedBox();
              final hasUnread = state.items.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox();
              return TextButton(
                onPressed: () =>
                    ctx.read<NotificationCenterCubit>().markAllRead(),
                child: Text(
                  'notif_mark_all_read'.tr(context),
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(12),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationCenterCubit, NotificationCenterState>(
        builder: (ctx, state) {
          if (state is NotificationCenterLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is NotificationCenterError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    'notif_load_error'.tr(context),
                    style: GoogleFonts.cairo(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () => ctx.read<NotificationCenterCubit>().load(),
                    child: Text('btn_retry'.tr(context)),
                  ),
                ],
              ),
            );
          }
          if (state is NotificationCenterLoaded) {
            if (state.items.isEmpty) return _EmptyState();
            return ListView.separated(
              controller: _scrollCtrl,
              padding: context.rSymmetric(vertical: 12),
              itemCount: state.items.length + (state.hasMore ? 1 : 0),
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 72, endIndent: 16),
              itemBuilder: (_, i) {
                if (i >= state.items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }
                final item = state.items[i];
                return _NotificationTile(
                  item: item,
                  onTap: () {
                    ctx.read<NotificationCenterCubit>().markAsRead(item.id);
                    // Deep-link: navigateFromLog closes the sheet, switches tab,
                    // then pushes the correct screen (chat, property, or comment property)
                    NotificationNavigator.navigateFromLog(
                      context,
                      item,
                      onSwitchTab: widget.onSwitchTab,
                    );
                  },
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final NotificationLogModel item;
  final VoidCallback onTap;
  const _NotificationTile({required this.item, required this.onTap});

  IconData get _icon {
    if (item.isChat) return Icons.chat_bubble_outline_rounded;
    if (item.isProperty) return Icons.apartment_rounded;
    if (item.isComment) return Icons.comment_outlined;
    return Icons.notifications_none_rounded;
  }

  Color get _iconColor {
    if (item.isChat) return const Color(0xFF039BE5);
    if (item.isProperty) return AppColors.primary;
    if (item.isComment) return const Color(0xFF059669);
    return const Color(0xFFFF6B35);
  }

  String _timeLabel(BuildContext context) {
    final diff = DateTime.now().difference(item.sentAt);
    if (diff.inMinutes < 1) return 'notif_time_now'.tr(context);
    if (diff.inHours < 1) {
      return '${diff.inMinutes} ${'notif_time_minutes'.tr(context)}';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours} ${'notif_time_hours'.tr(context)}';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} ${'notif_time_days'.tr(context)}';
    }
    return '${item.sentAt.day}/${item.sentAt.month}/${item.sentAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: item.isRead
            ? Colors.transparent
            : AppColors.primary.withValues(alpha: 0.04),
        padding: context.rSymmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon circle
            Container(
              width: context.r(44),
              height: context.r(44),
              decoration: BoxDecoration(
                color: _iconColor.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _iconColor, size: context.r(20)),
            ),
            SizedBox(width: context.r(12)),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: GoogleFonts.cairo(
                            fontSize: context.sp(13.5),
                            fontWeight: item.isRead
                                ? FontWeight.w600
                                : FontWeight.w800,
                            color: const Color(0xFF1B2D5E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: context.r(8),
                          height: context.r(8),
                          margin: EdgeInsets.only(left: context.r(6)),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: context.r(3)),
                  Text(
                    item.body,
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(12),
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: context.r(4)),
                  Text(
                    _timeLabel(context),
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(10.5),
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: context.r(64),
            color: Colors.grey.shade300,
          ),
          SizedBox(height: context.r(16)),
          Text(
            'notif_empty_title'.tr(context),
            style: GoogleFonts.cairo(
              fontSize: context.sp(16),
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: context.r(6)),
          Text(
            'notif_empty_body'.tr(context),
            style: GoogleFonts.tajawal(
              fontSize: context.sp(13),
              color: Colors.grey.shade400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
