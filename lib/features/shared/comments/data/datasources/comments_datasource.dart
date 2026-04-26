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

  // ── Fetch paginated comments ───────────────────────────────────────────────

  Future<List<CommentModel>> fetchComments({
    required String propertyId,
    DateTime? before,
  }) async {
    final List rawRows;
    if (before == null) {
      rawRows = await _db
          .from('property_comments')
          .select(
            'id, property_id, user_id, content, is_deleted, created_at, updated_at',
          )
          .eq('property_id', propertyId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .limit(_pageSize);
    } else {
      rawRows = await _db
          .from('property_comments')
          .select(
            'id, property_id, user_id, content, is_deleted, created_at, updated_at',
          )
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

    final raw = await _db
        .from('property_comments')
        .insert({
          'property_id': propertyId,
          'user_id': uid,
          'content': content.trim(),
        })
        .select(
          'id, property_id, user_id, content, is_deleted, created_at, updated_at',
        )
        .single();

    final rows = await _hydrateWithProfiles([
      Map<String, dynamic>.from(raw as Map),
    ]);
    return rows.first;
  }

  Future<void> softDeleteComment(String commentId) async {
    debugPrint('[Comments] softDeleteComment: $commentId');

    try {
      final result = await _db.rpc(
        'soft_delete_comment',
        params: {'p_comment_id': commentId},
      );

      // The function returns TRUE on success, FALSE if not found,
      // and throws an exception if not authorized.
      final success = result as bool? ?? false;
      if (!success) {
        debugPrint(
          '[Comments] softDeleteComment: comment not found or already deleted',
        );
        throw Exception('comment_not_found');
      }

      debugPrint('[Comments] softDeleteComment: success');
    } on PostgrestException catch (e) {
      debugPrint(
        '[Comments] softDeleteComment PostgrestException: ${e.message}',
      );
      // Map RPC exceptions back to meaningful errors
      if (e.message.contains('not_authorized')) {
        throw Exception('comment_delete_not_permitted');
      } else if (e.message.contains('not_authenticated')) {
        throw Exception('not_authenticated');
      }
      rethrow;
    }
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
          final raw = await _db
              .from('property_comments')
              .select(
                'id, property_id, user_id, content, is_deleted, created_at, updated_at',
              )
              .eq('id', (payload.newRecord['id'] ?? '').toString())
              .maybeSingle();

          if (raw == null) return;
          final rows = await _hydrateWithProfiles([
            Map<String, dynamic>.from(raw as Map),
          ]);
          if (rows.isNotEmpty) onInsert(rows.first);
        } catch (e) {
          debugPrint('[Comments] realtime insert hydration error: $e');
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

  // ── Private: batch-fetch profiles ────────────────────────────────────────

  Future<List<CommentModel>> _hydrateWithProfiles(
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) return [];

    final userIds = rows.map((r) => r['user_id'].toString()).toSet().toList();

    final profileRows = await _db
        .from('profiles')
        .select('id, first_name, last_name, profile_image_url')
        .inFilter('id', userIds);

    final profiles = <String, Map<String, dynamic>>{};
    for (final p in profileRows as List) {
      final m = Map<String, dynamic>.from(p as Map);
      profiles[m['id'].toString()] = m;
    }

    return rows.map((row) {
      final profile = profiles[row['user_id'].toString()];
      final first = (profile?['first_name'] ?? '').toString().trim();
      final last = (profile?['last_name'] ?? '').toString().trim();
      final name = '$first $last'.trim();

      return CommentModel.fromMap({
        ...row,
        'author_name': name.isNotEmpty ? name : null,
        'author_avatar': profile?['profile_image_url'] as String?,
      });
    }).toList();
  }
}
