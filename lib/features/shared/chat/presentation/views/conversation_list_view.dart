import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/conversation_model.dart';
import '../cubit/conversation_list_cubit.dart';
import 'chat_conversation_view.dart';

class ConversationListView extends StatelessWidget {
  const ConversationListView({super.key});

  @override
  Widget build(BuildContext context) => const _ConversationListContent();
}

// ── Shell ─────────────────────────────────────────────────────────────────────

class _ConversationListContent extends StatelessWidget {
  const _ConversationListContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Column(
        children: [
          _ChatHeader(),
          Expanded(
            child: BlocBuilder<ConversationListCubit, ConversationListState>(
              builder: (context, state) => switch (state) {
                ConversationListInitial() ||
                ConversationListLoading() => const _ChatListSkeleton(),
                ConversationListError(:final message) => _ErrorView(
                  message: message,
                  onRetry: () => context.read<ConversationListCubit>().load(),
                ),
                ConversationListLoaded(:final conversations) =>
                  conversations.isEmpty
                      ? const _EmptyChats()
                      : _ConversationList(conversations: conversations),
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A2656), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: context.rOnly(left: 20, right: 20, top: 18, bottom: 20),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'chat_title'.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(24),
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  BlocBuilder<ConversationListCubit, ConversationListState>(
                    builder: (_, state) {
                      final count = state is ConversationListLoaded
                          ? state.conversations.length
                          : 0;
                      return Text(
                        '$count ${'chat_conversations'.tr(context)}',
                        style: GoogleFonts.tajawal(
                          fontSize: context.sp(12),
                          color: Colors.white60,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const Spacer(),
              // Live dot
              BlocBuilder<ConversationListCubit, ConversationListState>(
                builder: (_, state) {
                  final live = state is ConversationListLoaded;
                  return Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: context.r(8),
                        height: context.r(8),
                        decoration: BoxDecoration(
                          color: live
                              ? const Color(0xFF4CAF50)
                              : Colors.white24,
                          shape: BoxShape.circle,
                          boxShadow: live
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF4CAF50,
                                    ).withValues(alpha: 0.6),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      SizedBox(width: context.r(6)),
                      Text(
                        live ? 'chat_live'.tr(context) : '...',
                        style: GoogleFonts.tajawal(
                          fontSize: context.sp(11),
                          color: live
                              ? const Color(0xFF4CAF50)
                              : Colors.white38,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── List ──────────────────────────────────────────────────────────────────────

class _ConversationList extends StatelessWidget {
  final List<ConversationModel> conversations;
  const _ConversationList({required this.conversations});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: context.rOnly(top: 16, bottom: 32, left: 14, right: 14),
      itemCount: conversations.length,
      itemBuilder: (_, i) => _ConversationTile(conv: conversations[i]),
    );
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final ConversationModel conv;
  const _ConversationTile({required this.conv});

  String _lastMessagePreview(BuildContext context) {
    final raw = conv.lastMessage;
    if (raw == null || raw.isEmpty) return 'chat_no_messages'.tr(context);
    if (raw.startsWith('property_card:')) {
      return '🏠  ${'chat_property_card'.tr(context)}';
    }
    if (raw.startsWith('[image]') ||
        raw.contains('storage') && raw.contains('.jpg')) {
      return '📷  ${'chat_image'.tr(context)}';
    }
    if (raw.startsWith('[voice]') ||
        raw.endsWith('.m4a') ||
        raw.endsWith('.aac')) {
      return '🎙  ${'chat_voice'.tr(context)}';
    }
    return raw;
  }

  String _formatTime(BuildContext context, DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(local.year, local.month, local.day);
    final locale = Localizations.localeOf(context).languageCode;
    if (msgDay == today) return DateFormat.jm(locale).format(local);
    if (today.difference(msgDay).inDays == 1) {
      return 'chat_yesterday'.tr(context);
    }
    if (today.difference(msgDay).inDays < 7) {
      return DateFormat.E(locale).format(local);
    }
    return DateFormat('d/M', locale).format(local);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ConversationListCubit>();
    // Use myIdOrNull to avoid crash when Supabase session is not yet restored
    final myId = cubit.myIdOrNull;
    if (myId == null) return const SizedBox.shrink();
    final unread = conv.unreadFor(myId);
    final otherId = conv.otherUserId(myId);
    final hasUnread = unread > 0;

    return Padding(
      padding: context.rOnly(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(18)),
        elevation: hasUnread ? 3 : 1,
        shadowColor: hasUnread
            ? AppColors.primary.withValues(alpha: 0.15)
            : Colors.black.withValues(alpha: 0.06),
        child: InkWell(
          borderRadius: BorderRadius.circular(context.r(18)),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatConversationView(
                conversationId: conv.id,
                otherUserId: otherId,
                otherUserName: conv.otherUserName ?? '',
                otherUserAvatar: conv.otherUserAvatar,
              ),
            ),
          ).then((_) => cubit.load()),
          child: Padding(
            padding: context.rAll(14),
            child: Row(
              children: [
                // Avatar
                _AvatarStack(
                  name: conv.otherUserName ?? '?',
                  avatarUrl: conv.otherUserAvatar,
                  size: context.r(54),
                  hasUnread: hasUnread,
                ),
                SizedBox(width: context.r(12)),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conv.otherUserName ??
                                  'chat_unknown_user'.tr(context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: context.sp(15),
                                fontWeight: hasUnread
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: const Color(0xFF1B2D5E),
                              ),
                            ),
                          ),
                          if (conv.lastMessageAt != null)
                            Text(
                              _formatTime(context, conv.lastMessageAt!),
                              style: GoogleFonts.tajawal(
                                fontSize: context.sp(11),
                                color: hasUnread
                                    ? AppColors.primary
                                    : Colors.grey.shade400,
                                fontWeight: hasUnread
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: context.r(5)),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _lastMessagePreview(context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.tajawal(
                                fontSize: context.sp(12.5),
                                color: hasUnread
                                    ? const Color(0xFF333333)
                                    : Colors.grey.shade500,
                                fontWeight: hasUnread
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (hasUnread)
                            Container(
                              constraints: BoxConstraints(
                                minWidth: context.r(22),
                              ),
                              padding: context.rSymmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    Color(0xFF1E88E5),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  context.r(12),
                                ),
                              ),
                              child: Text(
                                unread > 99 ? '99+' : '$unread',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  fontSize: context.sp(11),
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Avatar with unread ring ───────────────────────────────────────────────────

class _AvatarStack extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double size;
  final bool hasUnread;

  const _AvatarStack({
    required this.name,
    required this.avatarUrl,
    required this.size,
    required this.hasUnread,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.primary.withValues(alpha: 0.10),
      child: (avatarUrl != null && avatarUrl!.isNotEmpty)
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: avatarUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Text(
                  _initials,
                  style: TextStyle(
                    fontSize: size * 0.36,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          : Text(
              _initials,
              style: TextStyle(
                fontSize: size * 0.36,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (hasUnread)
          Container(
            width: size + 4,
            height: size + 4,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, Color(0xFF42A5F5)],
              ),
            ),
            child: Padding(padding: const EdgeInsets.all(2), child: avatar),
          )
        else
          avatar,
        // Online dot (placeholder — can wire to presence later)
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: context.r(12),
            height: context.r(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF9E9E9E),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyChats extends StatelessWidget {
  const _EmptyChats();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: context.r(96),
            height: context.r(96),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primary.withValues(alpha: 0.14),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: context.r(44),
              color: AppColors.primary.withValues(alpha: 0.45),
            ),
          ),
          SizedBox(height: context.r(20)),
          Text(
            'chat_empty_title'.tr(context),
            style: GoogleFonts.cairo(
              fontSize: context.sp(18),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B2D5E),
            ),
          ),
          SizedBox(height: context.r(8)),
          Padding(
            padding: context.rSymmetric(horizontal: 40),
            child: Text(
              'chat_empty_subtitle'.tr(context),
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(13),
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton loader ───────────────────────────────────────────────────────────

class _ChatListSkeleton extends StatefulWidget {
  const _ChatListSkeleton();
  @override
  State<_ChatListSkeleton> createState() => _ChatListSkeletonState();
}

class _ChatListSkeletonState extends State<_ChatListSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _bone(
    BuildContext context, {
    double? size,
    double? w,
    double? h,
    double radius = 8,
  }) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: size ?? w,
          height: size ?? h,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: context.rOnly(top: 16, left: 14, right: 14),
      itemCount: 7,
      itemBuilder: (_, __) => Padding(
        padding: context.rOnly(bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.r(18)),
          ),
          padding: context.rAll(14),
          child: Row(
            children: [
              _bone(context, size: context.r(54), radius: 100),
              SizedBox(width: context.r(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _bone(context, w: context.r(130), h: context.r(13)),
                        _bone(context, w: context.r(38), h: context.r(11)),
                      ],
                    ),
                    SizedBox(height: context.r(8)),
                    _bone(context, w: context.r(190), h: context.r(11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: context.r(48),
            color: Colors.redAccent,
          ),
          SizedBox(height: context.r(12)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(fontSize: context.sp(13)),
          ),
          SizedBox(height: context.r(20)),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('retry'.tr(context)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
