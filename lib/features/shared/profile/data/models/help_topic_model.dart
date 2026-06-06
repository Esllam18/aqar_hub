import 'package:flutter/material.dart';

// ── Audience filter ───────────────────────────────────────────────────────────

enum HelpAudience { all, seeker, owner }

// ── A single step in a how-to guide ──────────────────────────────────────────

class HelpStep {
  final IconData icon;
  final String titleKey;
  final String bodyKey;

  const HelpStep({
    required this.icon,
    required this.titleKey,
    required this.bodyKey,
  });
}

// ── A how-to guide card (e.g. "How to add a property") ───────────────────────

class HelpGuide {
  final IconData icon;
  final List<Color> gradient;
  final String titleKey;
  final String subtitleKey;
  final HelpAudience audience;
  final List<HelpStep> steps;

  const HelpGuide({
    required this.icon,
    required this.gradient,
    required this.titleKey,
    required this.subtitleKey,
    required this.audience,
    required this.steps,
  });
}

// ── A single FAQ entry ────────────────────────────────────────────────────────

class FaqItem {
  final String questionKey;
  final String answerKey;
  final HelpAudience audience;
  final String categoryKey;

  const FaqItem({
    required this.questionKey,
    required this.answerKey,
    this.audience = HelpAudience.all,
    required this.categoryKey,
  });
}

// ── A help category for the home screen grid ─────────────────────────────────

class HelpCategory {
  final IconData icon;
  final List<Color> gradient;
  final String titleKey;
  final String subtitleKey;
  final HelpAudience audience;

  const HelpCategory({
    required this.icon,
    required this.gradient,
    required this.titleKey,
    required this.subtitleKey,
    this.audience = HelpAudience.all,
  });
}
