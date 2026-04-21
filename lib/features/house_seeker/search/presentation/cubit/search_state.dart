import '../../../../house_seeker/home/data/models/property_filter_model.dart';
import '../../../../house_seeker/home/data/models/property_model.dart';
import '../../data/services/search_gemini_service.dart';

sealed class SearchState {
  const SearchState();
}

/// Nothing has been searched yet — shows the empty / welcome state
final class SearchInitial extends SearchState {
  const SearchInitial();
}

/// AI is analysing the message
final class SearchAnalyzing extends SearchState {
  final String query;
  const SearchAnalyzing({required this.query});
}

/// AI returned filters — Supabase query in progress
final class SearchLoading extends SearchState {
  final String query;
  const SearchLoading({required this.query});
}

/// AI says the message was a greeting or off-topic
final class SearchReply extends SearchState {
  final String query;
  final String reply;
  final SearchIntent intent;
  const SearchReply({
    required this.query,
    required this.reply,
    required this.intent,
  });
}

/// Supabase returned results (may be empty)
final class SearchLoaded extends SearchState {
  final String query;
  final List<PropertyModel> properties;
  final String filterSummaryAr;
  final String filterSummaryEn;
  final PropertyFilterModel filter;

  const SearchLoaded({
    required this.query,
    required this.properties,
    required this.filterSummaryAr,
    required this.filterSummaryEn,
    required this.filter,
  });

  bool get isEmpty => properties.isEmpty;
}

/// AI API quota exceeded — user needs to wait or get a new key
final class SearchQuotaError extends SearchState {
  const SearchQuotaError();
}

/// Network / Supabase error
final class SearchError extends SearchState {
  final String query;
  const SearchError({required this.query});
}
