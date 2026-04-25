import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_log_model.dart';

// ── States ────────────────────────────────────────────────────────────────────

abstract class NotificationCenterState {}

class NotificationCenterInitial extends NotificationCenterState {}

class NotificationCenterLoading extends NotificationCenterState {}

class NotificationCenterLoaded extends NotificationCenterState {
  final List<NotificationLogModel> items;
  final bool hasMore;
  final int unreadCount;

  NotificationCenterLoaded({
    required this.items,
    required this.hasMore,
    required this.unreadCount,
  });
}

class NotificationCenterError extends NotificationCenterState {
  final String message;
  NotificationCenterError(this.message);
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class NotificationCenterCubit extends Cubit<NotificationCenterState> {
  static const _pageSize = 20;

  NotificationCenterCubit() : super(NotificationCenterInitial());

  final _db = Supabase.instance.client;
  final List<NotificationLogModel> _items = [];

  int get unreadCount => _items.where((n) => !n.isRead).length;

  // ── Load first page ────────────────────────────────────────────────────────

  Future<void> load() async {
    emit(NotificationCenterLoading());
    _items.clear();
    await _fetchPage(offset: 0, isFirstLoad: true);
  }

  // ── Load next page ─────────────────────────────────────────────────────────

  Future<void> loadMore() async {
    if (state is! NotificationCenterLoaded) return;
    if (!(state as NotificationCenterLoaded).hasMore) return;
    await _fetchPage(offset: _items.length, isFirstLoad: false);
  }

  // ── Internal fetch ─────────────────────────────────────────────────────────

  Future<void> _fetchPage({
    required int offset,
    required bool isFirstLoad,
  }) async {
    try {
      final uid = _db.auth.currentUser?.id;
      if (uid == null) {
        emit(NotificationCenterError('not_signed_in'));
        return;
      }

      final rows = await _db
          .from('notification_log')
          .select()
          .eq('recipient_id', uid)
          .order('sent_at', ascending: false)
          .range(offset, offset + _pageSize - 1);

      final fetched = (rows as List)
          .map((r) => NotificationLogModel.fromMap(r))
          .toList();

      _items.addAll(fetched);
      _emitLoaded(fetched.length == _pageSize);
    } catch (e) {
      debugPrint('[NotifCenter] fetch error: $e');
      if (isFirstLoad) emit(NotificationCenterError(e.toString()));
    }
  }

  void _emitLoaded(bool hasMore) {
    emit(
      NotificationCenterLoaded(
        items: List.unmodifiable(_items),
        hasMore: hasMore,
        unreadCount: unreadCount,
      ),
    );
  }

  // ── Mark one as read ───────────────────────────────────────────────────────

  Future<void> markAsRead(String id) async {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx == -1 || _items[idx].isRead) return;

    _items[idx] = _items[idx].copyWith(isRead: true);
    if (state is NotificationCenterLoaded) {
      _emitLoaded((state as NotificationCenterLoaded).hasMore);
    }

    try {
      await _db.from('notification_log').update({'is_read': true}).eq('id', id);
    } catch (e) {
      debugPrint('[NotifCenter] markAsRead error: $e');
    }
  }

  // ── Mark all as read ───────────────────────────────────────────────────────

  Future<void> markAllRead() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return;

    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
    if (state is NotificationCenterLoaded) {
      _emitLoaded((state as NotificationCenterLoaded).hasMore);
    }

    try {
      await _db
          .from('notification_log')
          .update({'is_read': true})
          .eq('recipient_id', uid)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('[NotifCenter] markAllRead error: $e');
    }
  }
}
