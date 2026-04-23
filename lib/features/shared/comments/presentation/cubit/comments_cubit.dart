// lib/features/shared/comments/presentation/cubit/comments_cubit.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/comment_model.dart';
import '../../data/repositories/comments_repository.dart';

part 'comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  final CommentsRepository _repo;
  final String propertyId;
  final String propertyOwnerId;

  RealtimeChannel? _channel;
  static const int _pageSize = 20;

  CommentsCubit({
    required CommentsRepository repo,
    required this.propertyId,
    required this.propertyOwnerId,
  })  : _repo = repo,
        super(const CommentsInitial());

  String? get myId => _repo.currentUserIdOrNull;

  bool canDelete(CommentModel comment) =>
      myId != null &&
      (myId == comment.userId || myId == propertyOwnerId);

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> load() async {
    emit(const CommentsLoading());
    try {
      final comments = await _repo.getComments(propertyId: propertyId);
      if (!isClosed) {
        emit(CommentsLoaded(
          comments: comments,
          hasMore: comments.length >= _pageSize,
        ));
        _subscribe();
      }
    } catch (e, s) {
      debugPrint('[CommentsCubit] load error: $e');
      debugPrintStack(stackTrace: s);
      if (!isClosed) emit(CommentsError(e.toString()));
    }
  }

  // ── Load more (pagination) ────────────────────────────────────────────────

  Future<void> loadMore() async {
    final loaded = state;
    if (loaded is! CommentsLoaded) return;
    if (!loaded.hasMore || loaded.loadingMore) return;

    emit(loaded.copyWith(loadingMore: true));
    try {
      final oldest = loaded.comments.last.createdAt;
      final more = await _repo.getComments(
        propertyId: propertyId,
        before: oldest,
      );
      if (!isClosed) {
        emit(loaded.copyWith(
          comments: [...loaded.comments, ...more],
          hasMore: more.length >= _pageSize,
          loadingMore: false,
        ));
      }
    } catch (e) {
      debugPrint('[CommentsCubit] loadMore error: $e');
      if (!isClosed && state is CommentsLoaded) {
        emit((state as CommentsLoaded).copyWith(loadingMore: false));
      }
    }
  }

  // ── Add comment ───────────────────────────────────────────────────────────

  Future<void> addComment(String content) async {
    final loaded = state;
    if (loaded is! CommentsLoaded) return;
    if (content.trim().isEmpty) return;

    emit(loaded.copyWith(submitting: true));
    try {
      await _repo.addComment(
        propertyId: propertyId,
        content: content.trim(),
      );
      // Realtime subscription delivers the new comment — just clear submitting
      if (!isClosed && state is CommentsLoaded) {
        emit((state as CommentsLoaded).copyWith(submitting: false));
      }
    } catch (e) {
      debugPrint('[CommentsCubit] addComment error: $e');
      if (!isClosed) {
        final reverted = loaded.copyWith(submitting: false);
        // Emit error for the listener to show a snackbar…
        emit(CommentsSubmitError(previousState: reverted, message: e.toString()));
        // …then immediately revert to the loaded state so the UI recovers
        emit(reverted);
      }
    }
  }

  // ── Delete comment ────────────────────────────────────────────────────────

  Future<void> deleteComment(String commentId) async {
    final loaded = state;
    if (loaded is! CommentsLoaded) return;

    // Optimistic removal
    final updated = loaded.comments
        .where((c) => c.id != commentId)
        .toList();
    emit(loaded.copyWith(comments: updated));

    try {
      await _repo.deleteComment(commentId);
      // Realtime will confirm. If it fails, revert.
    } catch (e) {
      debugPrint('[CommentsCubit] deleteComment error: $e');
      // Revert optimistic update
      if (!isClosed) emit(loaded);
    }
  }

  // ── Realtime ──────────────────────────────────────────────────────────────

  void _subscribe() {
    _channel?.unsubscribe();
    _channel = _repo.subscribeToComments(
      propertyId: propertyId,
      onInsert: _onCommentInserted,
      onDelete: _onCommentDeleted,
    );
  }

  void _onCommentInserted(CommentModel comment) {
    if (isClosed) return;
    final loaded = state;
    if (loaded is! CommentsLoaded) return;

    // Avoid duplicates (our own optimistic insert may already be there)
    if (loaded.comments.any((c) => c.id == comment.id)) return;

    // New comments go to the top (newest-first order)
    emit(loaded.copyWith(comments: [comment, ...loaded.comments]));
  }

  void _onCommentDeleted(String commentId) {
    if (isClosed) return;
    final loaded = state;
    if (loaded is! CommentsLoaded) return;

    final updated =
        loaded.comments.where((c) => c.id != commentId).toList();
    emit(loaded.copyWith(comments: updated));
  }

  @override
  Future<void> close() {
    _channel?.unsubscribe();
    return super.close();
  }
}
