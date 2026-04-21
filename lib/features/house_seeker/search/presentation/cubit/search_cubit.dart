// lib/features/house_seeker/search/presentation/cubit/search_cubit.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../house_seeker/home/data/models/property_filter_model.dart';
import '../../data/repositories/search_repository.dart';
import '../../data/services/search_gemini_service.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepository _repo;

  SearchCubit(this._repo) : super(const SearchInitial());

  static const int _maxResults = 6;

  void _safeEmit(SearchState s) {
    if (!isClosed) emit(s);
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    // Step 1 — Gemini analyses the message
    _safeEmit(SearchAnalyzing(query: trimmed));

    final result = await SearchGeminiService.instance.extractFilters(trimmed);
    debugPrint('[SearchCubit] intent=${result.intent}');

    if (isClosed) return;

    // Step 2 — Route by intent
    switch (result.intent) {
      case SearchIntent.greeting:
      case SearchIntent.offTopic:
        _safeEmit(
          SearchReply(
            query: trimmed,
            reply: result.offTopicReply ?? '',
            intent: result.intent,
          ),
        );
        return;

      case SearchIntent.quotaExceeded:
        _safeEmit(const SearchQuotaError());
        return;

      case SearchIntent.error:
        _safeEmit(SearchError(query: trimmed));
        return;

      case SearchIntent.property:
        break; // continue to Supabase query below
    }

    // Step 3 — Query Supabase with extracted filters
    _safeEmit(SearchLoading(query: trimmed));

    try {
      final properties = await _repo.searchProperties(
        filter: result.filter ?? const PropertyFilterModel.empty(),
        limit: _maxResults,
      );
      _safeEmit(
        SearchLoaded(
          query: trimmed,
          properties: properties,
          filterSummaryAr: result.filterSummaryAr,
          filterSummaryEn: result.filterSummaryEn,
          filter: result.filter ?? const PropertyFilterModel.empty(),
        ),
      );
    } catch (e) {
      debugPrint('[SearchCubit] Supabase error: $e');
      _safeEmit(SearchError(query: trimmed));
    }
  }

  void reset() => _safeEmit(const SearchInitial());
}
