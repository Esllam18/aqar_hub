// lib/.../search/presentation/views/search_view.dart
// Was 1,509 lines → now 90 lines. All widgets in search/ subfolder.

import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/features/house_seeker/search/data/datasources/search_datasource.dart';
import 'package:aqar_hub/features/house_seeker/search/data/repositories/search_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/search/search_header.dart';
import '../widgets/search/search_results_view.dart';
import '../widgets/search/search_states_ui.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => SearchCubit(SearchRepositoryImpl(SearchDatasourceImpl())),
    child: const _Body(),
  );
}

class _Body extends StatefulWidget {
  const _Body();
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();
  bool _hasText = false;

  static const _chips = [
    'search_chip_economic',
    'search_chip_family',
    'search_chip_studio',
    'search_chip_villa',
    'search_chip_furnished',
    'search_chip_chalet',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final h = _ctrl.text.isNotEmpty;
      if (h != _hasText) setState(() => _hasText = h);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _focus.unfocus();
    HapticFeedback.lightImpact();
    context.read<SearchCubit>().search(text);
  }

  void _fillChip(String key) {
    // Translate the localization key → human-readable text before filling the field
    final translated = key.tr(context);
    _ctrl.text = translated;
    _ctrl.selection = TextSelection.fromPosition(
      TextPosition(offset: translated.length),
    );
    _focus.requestFocus();
    HapticFeedback.selectionClick();
  }

  void _clear() {
    _ctrl.clear();
    context.read<SearchCubit>().reset();
  }

  void _scrollTop() {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _bodyFor(SearchState state) => switch (state) {
    SearchInitial() => SearchWelcome(
      key: const ValueKey('welcome'),
      onExampleTap: _fillChip,
    ),
    SearchAnalyzing() => const SearchThinking(
      key: ValueKey('thinking'),
      phase: 1,
    ),
    SearchLoading() => const SearchThinking(key: ValueKey('loading'), phase: 2),
    SearchReply(:final reply) => SearchReplyView(
      key: const ValueKey('reply'),
      reply: reply,
      onReset: _clear,
    ),
    SearchLoaded(
      :final properties,
      :final filterSummaryAr,
      :final filterSummaryEn,
    ) =>
      SearchResultsView(
        key: ValueKey('res_${state.query}'),
        properties: properties,
        summaryAr: filterSummaryAr,
        summaryEn: filterSummaryEn,
        scrollCtrl: _scroll,
        onReset: _clear,
      ),
    SearchQuotaError() => const SearchQuotaView(key: ValueKey('quota')),
    SearchError() => SearchErrorView(
      key: const ValueKey('error'),
      onRetry: _submit,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SearchHeader(
                ctrl: _ctrl,
                focus: _focus,
                hasText: _hasText,
                onSubmit: _submit,
                onClear: _clear,
                onBack: () => Navigator.pop(context),
              ),
              SearchChipBar(chips: _chips, onChipTap: _fillChip),
              Expanded(
                child: BlocConsumer<SearchCubit, SearchState>(
                  listenWhen: (_, curr) =>
                      curr is SearchLoaded || curr is SearchError,
                  listener: (_, state) {
                    if (state is SearchLoaded || state is SearchError) {
                      _scrollTop();
                    }
                  },
                  builder: (_, state) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.03),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _bodyFor(state),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
