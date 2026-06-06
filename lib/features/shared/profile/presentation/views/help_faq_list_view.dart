import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/shared/profile/data/models/help_content.dart';
import 'package:aqar_hub/features/shared/profile/data/models/help_topic_model.dart';
import 'package:aqar_hub/features/shared/profile/presentation/widgets/supports/help_center/help_faq_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dedicated FAQ screen with a live search bar and audience-aware filtering.
class HelpFaqListView extends StatefulWidget {
  final HelpAudience audience;

  const HelpFaqListView({super.key, required this.audience});

  @override
  State<HelpFaqListView> createState() => _HelpFaqListViewState();
}

class _HelpFaqListViewState extends State<HelpFaqListView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<FaqItem> get _filtered {
    final faqs = HelpContent.allFaqs.where((f) {
      return f.audience == HelpAudience.all || f.audience == widget.audience;
    }).toList();

    if (_query.isEmpty) return faqs;

    final q = _query.toLowerCase();
    return faqs.where((f) {
      final question = f.questionKey.tr(context).toLowerCase();
      final answer = f.answerKey.tr(context).toLowerCase();
      return question.contains(q) || answer.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF1B4B8C),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: context.r(20),
              ),
              onPressed: Navigation.back,
            ),
            title: Text(
              'help_faq_title'.tr(context),
              style: GoogleFonts.cairo(
                fontSize: context.sp(17),
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(context.r(60)),
              child: Padding(
                padding: context.rOnly(left: 16, right: 16, bottom: 12),
                child: Container(
                  height: context.r(44),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(context.r(12)),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontSize: context.sp(13),
                    ),
                    decoration: InputDecoration(
                      hintText: 'help_faq_search_hint'.tr(context),
                      hintStyle: GoogleFonts.tajawal(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: context.sp(13),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: context.r(18),
                      ),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: Colors.white.withValues(alpha: 0.7),
                                size: context.r(18),
                              ),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: context.rSymmetric(
                        horizontal: 4,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: context.rAll(16),
            sliver: items.isEmpty
                ? SliverFillRemaining(child: _EmptySearch(query: _query))
                : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index == items.length) {
                        return SizedBox(height: context.r(80));
                      }
                      return HelpFaqTile(
                        questionKey: items[index].questionKey,
                        answerKey: items[index].answerKey,
                      );
                    }, childCount: items.length + 1),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Empty search state ────────────────────────────────────────────────────────

class _EmptySearch extends StatelessWidget {
  final String query;

  const _EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: context.r(52),
            color: Colors.grey.shade300,
          ),
          SizedBox(height: context.r(12)),
          Text(
            'help_faq_no_results'.tr(context),
            style: GoogleFonts.cairo(
              fontSize: context.sp(15),
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: context.r(6)),
          Text(
            '"$query"',
            style: GoogleFonts.tajawal(
              fontSize: context.sp(13),
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
