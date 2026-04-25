import 'package:aqar_hub/core/helpers/app_prefs.dart';
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

  // Prefix used to identify optimistic entries before the real DB id arrives.
  static const _optimisticPrefix = '__optimistic__';

  CommentsCubit({
    required CommentsRepository repo,
    required this.propertyId,
    required this.propertyOwnerId,
  }) : _repo = repo,
       super(const CommentsInitial());

  String? get myId => _repo.currentUserIdOrNull;

  bool canDelete(CommentModel comment) =>
      myId != null && (myId == comment.userId || myId == propertyOwnerId);

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> load() async {
    emit(const CommentsLoading());
    try {
      final comments = await _repo.getComments(propertyId: propertyId);
      if (!isClosed) {
        emit(
          CommentsLoaded(
            comments: comments,
            hasMore: comments.length >= _pageSize,
          ),
        );
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
        emit(
          loaded.copyWith(
            comments: [...loaded.comments, ...more],
            hasMore: more.length >= _pageSize,
            loadingMore: false,
          ),
        );
      }
    } catch (e) {
      debugPrint('[CommentsCubit] loadMore error: $e');
      if (!isClosed && state is CommentsLoaded) {
        emit((state as CommentsLoaded).copyWith(loadingMore: false));
      }
    }
  }

  Future<void> addComment(String content) async {
    final loaded = state;
    if (loaded is! CommentsLoaded) return;
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    final uid = _repo.currentUserId;
    final optimisticId =
        '$_optimisticPrefix${DateTime.now().millisecondsSinceEpoch}';

    // Build optimistic entry from cached profile data
    final optimistic = CommentModel(
      id: optimisticId,
      propertyId: propertyId,
      userId: uid,
      content: trimmed,
      isDeleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      authorName: AppPrefs.userName.isNotEmpty ? AppPrefs.userName : null,
      authorAvatar: AppPrefs.userAvatar.isNotEmpty ? AppPrefs.userAvatar : null,
    );

    // Show instantly — newest first
    emit(
      loaded.copyWith(
        comments: [optimistic, ...loaded.comments],
        submitting: true,
      ),
    );

    try {
      final real = await _repo.addComment(
        propertyId: propertyId,
        content: trimmed,
      );

      // Replace optimistic entry with the real DB row
      if (!isClosed && state is CommentsLoaded) {
        final current = (state as CommentsLoaded).comments;
        emit(
          (state as CommentsLoaded).copyWith(
            comments: current
                .map((c) => c.id == optimisticId ? real : c)
                .toList(),
            submitting: false,
          ),
        );
      }
    } catch (e) {
      debugPrint('[CommentsCubit] addComment error: $e');
      if (!isClosed && state is CommentsLoaded) {
        // Remove the optimistic entry so nothing fake stays in the list
        final current = (state as CommentsLoaded).comments;
        final reverted = loaded.copyWith(
          submitting: false,
          comments: current.where((c) => c.id != optimisticId).toList(),
        );
        emit(
          CommentsSubmitError(previousState: reverted, message: e.toString()),
        );
        emit(reverted);
      }
    }
  }

  // ── Delete comment ────────────────────────────────────────────────────────

  Future<void> deleteComment(String commentId) async {
    final loaded = state;
    if (loaded is! CommentsLoaded) return;

    // Optimistic removal
    final without = loaded.comments.where((c) => c.id != commentId).toList();
    emit(loaded.copyWith(comments: without));

    try {
      await _repo.deleteComment(commentId);
      // Realtime UPDATE (is_deleted = true) will fire _onCommentDeleted,
      // which is a no-op because the comment is already gone from the list.
    } catch (e) {
      debugPrint('[CommentsCubit] deleteComment error: $e');
      if (!isClosed) emit(loaded); // revert optimistic removal
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

    // Skip if a comment with this real ID already exists (normal case after
    // optimistic insert was replaced), OR if this is our own optimistic entry
    // coming back from realtime before replaceOptimistic ran.
    if (loaded.comments.any((c) => c.id == comment.id)) return;

    // Also skip if there is an optimistic entry with the same content+userId
    // that hasn't been replaced yet (race: realtime beat the await).
    // We'll let replaceOptimistic handle the swap instead.
    final hasMatchingOptimistic = loaded.comments.any(
      (c) =>
          c.id.startsWith(_optimisticPrefix) &&
          c.userId == comment.userId &&
          c.content == comment.content,
    );
    if (hasMatchingOptimistic) {
      // Swap the optimistic entry for the real one right now
      emit(
        loaded.copyWith(
          comments: loaded.comments.map((c) {
            if (c.id.startsWith(_optimisticPrefix) &&
                c.userId == comment.userId &&
                c.content == comment.content) {
              return comment;
            }
            return c;
          }).toList(),
        ),
      );
      return;
    }

    // Genuine new comment from another user
    emit(loaded.copyWith(comments: [comment, ...loaded.comments]));
  }

  void _onCommentDeleted(String commentId) {
    if (isClosed) return;
    final loaded = state;
    if (loaded is! CommentsLoaded) return;
    final updated = loaded.comments.where((c) => c.id != commentId).toList();
    emit(loaded.copyWith(comments: updated));
  }

  @override
  Future<void> close() {
    _channel?.unsubscribe();
    return super.close();
  }
}
