// lib/features/shared/comments/data/repositories/comments_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../datasources/comments_datasource.dart';
import '../models/comment_model.dart';

class CommentsRepository {
  final CommentsDatasource _ds;
  CommentsRepository(this._ds);

  String? get currentUserIdOrNull => _ds.currentUserIdOrNull;
  String get currentUserId => _ds.currentUserId;

  Future<List<CommentModel>> getComments({
    required String propertyId,
    DateTime? before,
  }) => _ds.fetchComments(propertyId: propertyId, before: before);

  Future<CommentModel> addComment({
    required String propertyId,
    required String content,
  }) => _ds.insertComment(propertyId: propertyId, content: content);

  Future<void> deleteComment(String commentId) =>
      _ds.softDeleteComment(commentId);

  RealtimeChannel subscribeToComments({
    required String propertyId,
    required void Function(CommentModel) onInsert,
    required void Function(String commentId) onDelete,
  }) => _ds.subscribeToComments(
    propertyId: propertyId,
    onInsert: onInsert,
    onDelete: onDelete,
  );
}
