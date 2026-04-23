// lib/features/shared/comments/data/models/comment_model.dart

// ignore_for_file: unused_element

class CommentModel {
  final String id;
  final String propertyId;
  final String userId;
  final String content;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined from profiles — populated by repository
  final String? authorName;
  final String? authorAvatar;

  const CommentModel({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.content,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorAvatar,
  });

  bool get isVisible => !isDeleted;

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    // Support both flat maps (from datasource join) and raw DB rows
    String resolveName() {
      final joined = map['author_name'] as String?;
      if (joined != null && joined.trim().isNotEmpty) return joined.trim();
      final first = (map['first_name'] ?? '').toString().trim();
      final last = (map['last_name'] ?? '').toString().trim();
      final full = '$first $last'.trim();
      return full.isNotEmpty ? full : 'Unknown';
    }

    return CommentModel(
      id: (map['id'] ?? '').toString(),
      propertyId: (map['property_id'] ?? '').toString(),
      userId: (map['user_id'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      isDeleted: (map['is_deleted'] as bool?) ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
      authorName: map['author_name'] as String?,
      authorAvatar: map['author_avatar'] as String?,
    );
  }

  Map<String, dynamic> toInsertMap() => {
    'property_id': propertyId,
    'user_id': userId,
    'content': content,
  };

  CommentModel copyWith({
    String? content,
    bool? isDeleted,
    String? authorName,
    String? authorAvatar,
  }) => CommentModel(
    id: id,
    propertyId: propertyId,
    userId: userId,
    content: content ?? this.content,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt,
    updatedAt: updatedAt,
    authorName: authorName ?? this.authorName,
    authorAvatar: authorAvatar ?? this.authorAvatar,
  );
}
