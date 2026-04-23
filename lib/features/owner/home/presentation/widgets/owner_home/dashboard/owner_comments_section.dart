// ignore_for_file: unnecessary_cast, deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/home/data/datasources/property_datasource_impl.dart';
import 'package:aqar_hub/features/house_seeker/home/data/repositories/property_repository_impl.dart';
import 'package:aqar_hub/features/house_seeker/home/presentation/views/property_details_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class _OwnerCommentRow {
  final String commentId;
  final String propertyId;
  final String propertyTitle;
  final String? propertyImage;
  final String? authorName;
  final String? authorAvatar;
  final String content;
  final DateTime createdAt;

  const _OwnerCommentRow({
    required this.commentId,
    required this.propertyId,
    required this.propertyTitle,
    this.propertyImage,
    this.authorName,
    this.authorAvatar,
    required this.content,
    required this.createdAt,
  });
}

// ── Public widget ─────────────────────────────────────────────────────────────

class OwnerCommentsSection extends StatefulWidget {
  const OwnerCommentsSection({super.key});

  @override
  State<OwnerCommentsSection> createState() => _OwnerCommentsSectionState();
}

class _OwnerCommentsSectionState extends State<OwnerCommentsSection> {
  final _supabase = Supabase.instance.client;

  List<_OwnerCommentRow> _rows = [];
  bool _loading = true;
  bool _expanded = false; // show only 3 initially, expand on tap

  static const _previewCount = 3;
  static const _maxFetch = 20;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      // 1. Get the owner's property IDs
      final propRows = await _supabase
          .from('properties')
          .select('id, title, image_urls')
          .eq('owner_id', uid)
          .order('created_at', ascending: false);

      final props = Map.fromEntries(
        (propRows as List).map((r) {
          final m = Map<String, dynamic>.from(r as Map);
          final images = m['image_urls'] as List? ?? [];
          return MapEntry(m['id'] as String, {
            'title': m['title'] as String? ?? '',
            'image': images.isNotEmpty ? images.first as String : null,
          });
        }),
      );

      if (props.isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      // 2. Fetch recent non-deleted comments on those properties
      final commentRows = await _supabase
          .from('property_comments')
          .select('id, property_id, user_id, content, created_at')
          .inFilter('property_id', props.keys.toList())
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .limit(_maxFetch);

      final comments = List<Map<String, dynamic>>.from(commentRows as List);
      if (comments.isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      // 3. Batch-fetch commenter profiles (one query, no N+1)
      final userIds = comments
          .map((c) => c['user_id'].toString())
          .toSet()
          .toList();
      final profileRows = await _supabase
          .from('profiles')
          .select('id, first_name, last_name, profile_image_url')
          .inFilter('id', userIds);

      final profiles = Map.fromEntries(
        (profileRows as List).map((p) {
          final m = Map<String, dynamic>.from(p as Map);
          final first = (m['first_name'] ?? '').toString().trim();
          final last = (m['last_name'] ?? '').toString().trim();
          return MapEntry(m['id'] as String, {
            'name': '$first $last'.trim(),
            'avatar': m['profile_image_url'] as String?,
          });
        }),
      );

      // 4. Merge everything
      final rows = comments.map((c) {
        final pid = c['property_id'].toString();
        final prop = props[pid] ?? {};
        final profile = profiles[c['user_id'].toString()] ?? {};
        return _OwnerCommentRow(
          commentId: c['id'].toString(),
          propertyId: pid,
          propertyTitle: prop['title'] as String? ?? '',
          propertyImage: prop['image'] as String?,
          authorName: (profile['name'] as String?)?.isNotEmpty == true
              ? profile['name'] as String
              : null,
          authorAvatar: profile['avatar'] as String?,
          content: c['content'].toString(),
          createdAt: DateTime.parse(c['created_at'].toString()),
        );
      }).toList();

      if (mounted)
        setState(() {
          _rows = rows;
          _loading = false;
        });
    } catch (e) {
      debugPrint('[OwnerCommentsSection] load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openProperty(BuildContext context, String propertyId) async {
    try {
      final repo = PropertyRepositoryImpl(PropertyDatasourceImpl());
      final property = await repo.getPropertyById(propertyId);
      if (property == null || !context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PropertyDetailsView(property: property),
        ),
      );
    } catch (e) {
      debugPrint('[OwnerCommentsSection] _openProperty error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _CommentsSkeletonSliver();
    if (_rows.isEmpty) return const SizedBox.shrink();

    final visible = _expanded ? _rows : _rows.take(_previewCount).toList();

    return Container(
      margin: context.rOnly(left: 16, right: 16, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(18)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: context.rOnly(left: 16, right: 16, top: 16, bottom: 4),
            child: Row(
              children: [
                Container(
                  width: context.r(4),
                  height: context.r(18),
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: context.r(8)),
                Expanded(
                  child: Text(
                    'owner_comments_title'.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: context.rSymmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(context.r(8)),
                  ),
                  child: Text(
                    '${_rows.length}',
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.w700,
                      color: AppColors.info,
                    ),
                  ),
                ),
                // Refresh
                SizedBox(width: context.r(4)),
                GestureDetector(
                  onTap: () {
                    setState(() => _loading = true);
                    _load();
                  },
                  child: Icon(
                    Icons.refresh_rounded,
                    size: context.r(18),
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // ── Comment rows ─────────────────────────────────────────────────
          ...visible.map(
            (row) => _CommentRowTile(
              row: row,
              onTap: () => _openProperty(context, row.propertyId),
            ),
          ),

          // ── Show more / less ─────────────────────────────────────────────
          if (_rows.length > _previewCount)
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(context.r(18)),
              ),
              child: Container(
                width: double.infinity,
                padding: context.rSymmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.04),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(context.r(18)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _expanded
                          ? 'owner_comments_show_less'.tr(context)
                          : 'owner_comments_show_more'
                                .tr(context)
                                .replaceAll(
                                  '{n}',
                                  '${_rows.length - _previewCount}',
                                ),
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(12),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: context.r(4)),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: context.r(16),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(height: context.r(12)),
        ],
      ),
    );
  }
}

// ── Single comment row tile ───────────────────────────────────────────────────

class _CommentRowTile extends StatelessWidget {
  final _OwnerCommentRow row;
  final VoidCallback onTap;

  const _CommentRowTile({required this.row, required this.onTap});

  String _timeLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final diff = DateTime.now().difference(row.createdAt.toLocal());
    if (diff.inMinutes < 1) return 'comment_just_now'.tr(context);
    if (diff.inHours < 1) {
      return 'comment_minutes_ago'
          .tr(context)
          .replaceAll('{n}', '${diff.inMinutes}');
    }
    if (diff.inDays < 1) {
      return 'comment_hours_ago'
          .tr(context)
          .replaceAll('{n}', '${diff.inHours}');
    }
    if (diff.inDays < 7) {
      return 'comment_days_ago'.tr(context).replaceAll('{n}', '${diff.inDays}');
    }
    return DateFormat('d MMM yyyy', locale).format(row.createdAt.toLocal());
  }

  String get _initials {
    if (row.authorName == null || row.authorName!.trim().isEmpty) return '?';
    final parts = row.authorName!.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: context.rOnly(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author avatar
            Container(
              width: context.r(36),
              height: context.r(36),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.10),
              ),
              clipBehavior: Clip.antiAlias,
              child: row.authorAvatar?.isNotEmpty == true
                  ? CachedNetworkImage(
                      imageUrl: row.authorAvatar!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          _Initials(initials: _initials),
                    )
                  : _Initials(initials: _initials),
            ),
            SizedBox(width: context.r(10)),

            // Text column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author + time
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          row.authorName ??
                              'comment_unknown_author'.tr(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: context.sp(12.5),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        _timeLabel(context),
                        style: GoogleFonts.tajawal(
                          fontSize: context.sp(10),
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.r(2)),

                  // Comment text
                  Text(
                    row.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(12.5),
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: context.r(4)),

                  // Property chip
                  Row(
                    children: [
                      Icon(
                        Icons.apartment_rounded,
                        size: context.r(11),
                        color: AppColors.primary.withOpacity(0.60),
                      ),
                      SizedBox(width: context.r(4)),
                      Expanded(
                        child: Text(
                          row.propertyTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(
                            fontSize: context.sp(10.5),
                            color: AppColors.primary.withOpacity(0.80),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: context.r(10),
                        color: AppColors.textMuted,
                      ),
                    ],
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

class _Initials extends StatelessWidget {
  final String initials;
  const _Initials({required this.initials});

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      initials,
      style: GoogleFonts.cairo(
        fontSize: context.sp(13),
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      ),
    ),
  );
}

// ── Loading skeleton ──────────────────────────────────────────────────────────

class _CommentsSkeletonSliver extends StatelessWidget {
  const _CommentsSkeletonSliver();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: context.rOnly(left: 16, right: 16, top: 4, bottom: 4),
      padding: context.rAll(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(18)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: List.generate(
          2,
          (_) => Padding(
            padding: context.rOnly(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: context.r(36),
                  height: context.r(36),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: context.r(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: context.r(9),
                        width: context.r(80),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: context.r(6)),
                      Container(
                        height: context.r(9),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
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
