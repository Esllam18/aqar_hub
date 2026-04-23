// lib/features/shared/comments/presentation/cubit/comments_state.dart

part of 'comments_cubit.dart';

sealed class CommentsState {
  const CommentsState();
}

final class CommentsInitial extends CommentsState {
  const CommentsInitial();
}

final class CommentsLoading extends CommentsState {
  const CommentsLoading();
}

final class CommentsLoaded extends CommentsState {
  final List<CommentModel> comments;
  final bool hasMore;
  final bool loadingMore;
  final bool submitting;

  const CommentsLoaded({
    required this.comments,
    this.hasMore = false,
    this.loadingMore = false,
    this.submitting = false,
  });

  CommentsLoaded copyWith({
    List<CommentModel>? comments,
    bool? hasMore,
    bool? loadingMore,
    bool? submitting,
  }) => CommentsLoaded(
    comments: comments ?? this.comments,
    hasMore: hasMore ?? this.hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
    submitting: submitting ?? this.submitting,
  );
}

final class CommentsError extends CommentsState {
  final String message;
  const CommentsError(this.message);
}

/// Emitted briefly when submit fails — UI shows snackbar then reverts to loaded
final class CommentsSubmitError extends CommentsState {
  final CommentsLoaded previousState;
  final String message;
  const CommentsSubmitError({
    required this.previousState,
    required this.message,
  });
}
