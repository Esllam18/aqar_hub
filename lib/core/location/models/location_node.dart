import 'package:flutter/widgets.dart';

class EgyptLocationNode {
  final String slug;
  final String enName;
  final String arName;
  final List<String> aliases;
  final List<EgyptLocationNode> children;

  const EgyptLocationNode({
    required this.slug,
    required this.enName,
    required this.arName,
    this.aliases = const [],
    this.children = const [],
  });

  String label(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    return lang == 'ar' ? arName : enName;
  }

  bool matches(String normalizedText) {
    final pool = <String>{slug, enName, arName, ...aliases};

    for (final item in pool) {
      if (_normalize(item).isEmpty) continue;
      if (normalizedText.contains(_normalize(item))) return true;
    }
    return false;
  }

  static String _normalize(String value) {
    var s = value.toLowerCase().trim();

    const replacements = {
      'أ': 'ا',
      'إ': 'ا',
      'آ': 'ا',
      'ة': 'ه',
      'ى': 'ي',
      'ؤ': 'و',
      'ئ': 'ي',
    };

    replacements.forEach((from, to) {
      s = s.replaceAll(from, to);
    });

    s = s.replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF\s-]'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }
}
