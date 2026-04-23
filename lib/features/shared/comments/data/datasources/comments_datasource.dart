// lib/features/shared/comments/data/datasources/comments_datasource.dart
//
// FIX: The original code used a PostgREST FK hint
// (profiles!property_comments_user_id_fkey) that does not exist because the
// FK on property_comments.user_id points to auth.users (a different schema),
// not to public.profiles. PostgREST cannot traverse cross-schema foreign keys.
//
// Solution: fetch comments first, then batch-fetch the needed profiles in a
// single second query — exactly the same pattern used in chat_remote_datasource.

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';

class CommentsDatasource {
  SupabaseClient get _db => Supabase.instance.client;

  static const int _pageSize = 20;

  String? get currentUserIdOrNull => _db.auth.currentUser?.id;

  String get currentUserId {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated');
    return uid;
  }

  // ── Fetch paginated comments (two-step: comments + batch profiles) ─────────

  Future<List<CommentModel>> fetchComments({
    required String propertyId,
    DateTime? before,
  }) async {
    // Step 1 — fetch raw comment rows (no join)
    final List rawRows;
    if (before == null) {
      rawRows = await _db
          .from('property_comments')
          .select('id, property_id, user_id, content, is_deleted, created_at, updated_at')
          .eq('property_id', propertyId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .limit(_pageSize);
    } else {
      rawRows = await _db
          .from('property_comments')
          .select('id, property_id, user_id, content, is_deleted, created_at, updated_at')
          .eq('property_id', propertyId)
          .eq('is_deleted', false)
          .lt('created_at', before.toIso8601String())
          .order('created_at', ascending: false)
          .limit(_pageSize);
    }

    return _hydrateWithProfiles(List<Map<String, dynamic>>.from(rawRows));
  }

  // ── Insert new comment ────────────────────────────────────────────────────

  Future<CommentModel> insertComment({
    required String propertyId,
    required String content,
  }) async {
    final uid = currentUserId;

    // Insert and get back the raw row (no join needed here)
    final raw = await _db
        .from('property_comments')
        .insert({
          'property_id': propertyId,
          'user_id': uid,
          'content': content.trim(),
        })
        .select('id, property_id, user_id, content, is_deleted, created_at, updated_at')
        .single();

    final rows = await _hydrateWithProfiles(
      [Map<String, dynamic>.from(raw as Map)],
    );
    return rows.first;
  }

  // ── Soft-delete ───────────────────────────────────────────────────────────

  Future<void> softDeleteComment(String commentId) async {
    await _db
        .from('property_comments')
        .update({'is_deleted': true})
        .eq('id', commentId);
  }

  // ── Realtime subscription ─────────────────────────────────────────────────

  RealtimeChannel subscribeToComments({
    required String propertyId,
    required void Function(CommentModel) onInsert,
    required void Function(String commentId) onDelete,
  }) {
    final channel = _db.channel('comments:$propertyId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'property_comments',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'property_id',
        value: propertyId,
      ),
      callback: (payload) async {
        try {
          // Re-fetch the raw row then hydrate (two-step, same as above)
          final raw = await _db
              .from('property_comments')
              .select('id, property_id, user_id, content, is_deleted, created_at, updated_at')
              .eq('id', (payload.newRecord['id'] ?? '').toString())
              .maybeSingle();

          if (raw == null) return;
          final rows = await _hydrateWithProfiles(
            [Map<String, dynamic>.from(raw as Map)],
          );
          if (rows.isNotEmpty) onInsert(rows.first);
        } catch (e) {
          debugPrint('[Comments] realtime insert hydration error: $e');
          // Graceful fallback: emit without profile data
          onInsert(CommentModel.fromMap(payload.newRecord));
        }
      },
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'property_comments',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'property_id',
        value: propertyId,
      ),
      callback: (payload) {
        if (payload.newRecord['is_deleted'] == true) {
          onDelete((payload.newRecord['id'] ?? '').toString());
        }
      },
    );

    channel.subscribe();
    return channel;
  }

  // ── Private: batch-fetch profiles and merge into comment rows ─────────────
  // ONE extra query regardless of how many comments — no N+1.

  Future<List<CommentModel>> _hydrateWithProfiles(
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) return [];

    // Collect unique user IDs from this page of comments
    final userIds = rows
        .map((r) => r['user_id'].toString())
        .toSet()
        .toList();

    // Batch-fetch from public.profiles (same schema — no PostgREST issue)
    final profileRows = await _db
        .from('profiles')
        .select('id, first_name, last_name, profile_image_url')
        .inFilter('id', userIds);

    // Build id → profile lookup
    final profiles = <String, Map<String, dynamic>>{};
    for (final p in profileRows as List) {
      final m = Map<String, dynamic>.from(p as Map);
      profiles[m['id'].toString()] = m;
    }

    // Merge profile data into each comment row
    return rows.map((row) {
      final profile = profiles[row['user_id'].toString()];
      final first = (profile?['first_name'] ?? '').toString().trim();
      final last  = (profile?['last_name']  ?? '').toString().trim();
      final name  = '$first $last'.trim();

      return CommentModel.fromMap({
        ...row,
        'author_name':   name.isNotEmpty ? name : null,
        'author_avatar': profile?['profile_image_url'] as String?,
      });
    }).toList();
  }
}
