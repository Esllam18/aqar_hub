// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../../house_seeker/home/data/models/property_filter_model.dart';

// ── Result ────────────────────────────────────────────────────────────────────

enum SearchIntent { property, offTopic, greeting, error, quotaExceeded }

class SearchFiltersResult {
  final SearchIntent intent;
  final PropertyFilterModel? filter;
  final String? offTopicReply;
  final String filterSummaryAr;
  final String filterSummaryEn;

  const SearchFiltersResult({
    required this.intent,
    this.filter,
    this.offTopicReply,
    this.filterSummaryAr = '',
    this.filterSummaryEn = '',
  });

  bool get isProperty => intent == SearchIntent.property;
}

// ── Service ───────────────────────────────────────────────────────────────────

class SearchGeminiService {
  SearchGeminiService._();
  static final SearchGeminiService instance = SearchGeminiService._();

  static final String _apiKey = dotenv.env['GROQ_API_KEY']!;
  static const _url = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  // ── Public ────────────────────────────────────────────────────────────────

  Future<SearchFiltersResult> extractFilters(String userMessage) async {
    try {
      final json = await _callGroq(userMessage);
      if (json == null) {
        debugPrint('[Search] null response from Groq');
        return const SearchFiltersResult(intent: SearchIntent.error);
      }
      return _parse(json, userMessage);
    } on _QuotaException {
      debugPrint('[Search] Quota exceeded');
      return const SearchFiltersResult(intent: SearchIntent.quotaExceeded);
    } catch (e, st) {
      debugPrint('[Search] exception: $e\n$st');
      return const SearchFiltersResult(intent: SearchIntent.error);
    }
  }

  // ── Groq HTTP call ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> _callGroq(String message) async {
    final resp = await http
        .post(
          Uri.parse(_url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode({
            'model': _model,
            'temperature': 0.05,
            'max_tokens': 400,
            'messages': [
              {'role': 'system', 'content': _systemPrompt},
              {'role': 'user', 'content': message},
            ],
          }),
        )
        .timeout(const Duration(seconds: 20));

    debugPrint('[Search] Groq HTTP ${resp.statusCode}');

    if (resp.statusCode == 429) throw const _QuotaException();
    if (resp.statusCode != 200) {
      debugPrint('[Search] body: ${resp.body}');
      throw Exception('Groq HTTP ${resp.statusCode}');
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List?;
    if (choices == null || choices.isEmpty) return null;

    final text = (choices.first['message']['content'] as String? ?? '').trim();
    debugPrint('[Search] Groq raw: $text');
    if (text.isEmpty) return null;

    final clean = text
        .replaceAll(RegExp(r'```json\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    try {
      return jsonDecode(clean) as Map<String, dynamic>;
    } catch (_) {
      final match = RegExp(r'\{.*\}', dotAll: true).firstMatch(clean);
      if (match != null) {
        try {
          return jsonDecode(match.group(0)!) as Map<String, dynamic>;
        } catch (_) {}
      }
      debugPrint('[Search] JSON parse failed: $clean');
      return null;
    }
  }

  // ── System prompt ─────────────────────────────────────────────────────────

  static const _systemPrompt = '''
You are an Egyptian real-estate filter extractor. Your ONLY job is to read the user message and return a valid JSON object. No explanation. No markdown. No code fences. Return ONLY the raw JSON.

OUTPUT SCHEMA:
{
  "intent": "search" | "greeting" | "other",
  "listing_type": "rent" | "sale" | null,
  "property_type": "apartment" | "villa" | "studio" | "duplex" | "chalet" | null,
  "governorate_slug": <slug from list> | null,
  "city_slug": null,
  "price_min": <number EGP> | null,
  "price_max": <number EGP> | null,
  "rooms": <minimum integer> | null,
  "beds": <minimum integer> | null,
  "is_furnished": true | false | null,
  "target_audience": "male" | "female" | "family" | null
}

GOVERNORATE SLUGS:
القاهرة→cairo, الجيزة→giza, الإسكندرية→alexandria, القليوبية→qalyubia,
الدقهلية→dakahlia, الغربية→gharbia, المنوفية→monufia, البحيرة→beheira,
دمياط→damietta, الشرقية→sharkia, كفر الشيخ→kafr_el_sheikh,
الإسماعيلية→ismailia, السويس→suez, بورسعيد→port_said,
بني سويف→beni_suef, الفيوم→fayoum, المنيا→minya, أسيوط→asyut,
سوهاج→sohag, قنا→qena, الأقصر→luxor, أسوان→aswan,
البحر الأحمر→red_sea, جنوب سيناء→south_sinai, شمال سيناء→north_sinai,
مطروح→matrouh, الوادي الجديد→new_valley

ARABIC → ENGLISH GLOSSARY:
شقة/شقه→apartment  فيلا→villa  استوديو/استديو→studio  دوبلكس→duplex  شاليه→chalet
إيجار/أيجار/للإيجار→rent  بيع/للبيع→sale
مفروش/مفروشة→is_furnished:true    غير مفروش/خالي/بدون فرش→is_furnished:false
غرفة/أوضة/أوض/غرف→rooms    سرير/أسرة→beds
بحد أقصى / مش أكتر من / لا يتجاوز / أقل من → price_max
ابتداء من / من / على الأقل / أكتر من → price_min
ألف / k → multiply by 1000    مليون / m → multiply by 1000000
بنات / ستات / إناث / بنات فقط → target_audience:"female"
شباب / عزاب / ذكور → target_audience:"male"
عائلات / للعائلات / عيلات → target_audience:"family"
المنصورة → governorate_slug:"dakahlia"
طنطا / المحلة → governorate_slug:"gharbia"
الزقازيق → governorate_slug:"sharkia"
مصر الجديدة / هليوبوليس / المعادي / التجمع / الشيخ زايد / أكتوبر → governorate_slug:"cairo" or "giza"
بني سويف / بنى سويف → governorate_slug:"beni_suef"

RULES:
1. If message is a greeting (أهلاً, مرحبا, hello, hi, السلام عليكم, ازيك) → intent:"greeting"
2. If message has NOTHING to do with real estate → intent:"other"
3. Convert: 5 آلاف = 5000, 3k = 3000, مليون = 1000000, 2.5 مليون = 2500000
4. Never invent data not in the message. Missing = null.
5. Return ONLY the JSON object. Nothing else.

EXAMPLES:
User: "عايز شقة إيجار في القاهرة بسعر مش أكتر من 5000"
{"intent":"search","listing_type":"rent","property_type":"apartment","governorate_slug":"cairo","price_max":5000,"price_min":null,"rooms":null,"beds":null,"is_furnished":null,"target_audience":null,"city_slug":null}

User: "بنات في الجيزة بحد أقصى 3000 جنيه"
{"intent":"search","listing_type":"rent","property_type":"apartment","governorate_slug":"giza","price_max":3000,"price_min":null,"rooms":null,"beds":null,"is_furnished":null,"target_audience":"female","city_slug":null}

User: "كيف حالك"
{"intent":"greeting"}

User: "عايز أشتري سيارة"
{"intent":"other"}''';

  // ── Parser ────────────────────────────────────────────────────────────────

  SearchFiltersResult _parse(Map<String, dynamic> j, String msg) {
    final intent = (j['intent'] as String? ?? 'other').toLowerCase().trim();
    debugPrint('[Search] intent=$intent filters=$j');

    if (intent == 'greeting') {
      return SearchFiltersResult(
        intent: SearchIntent.greeting,
        offTopicReply: _greetingReply(msg),
      );
    }
    if (intent != 'search') {
      return SearchFiltersResult(
        intent: SearchIntent.offTopic,
        offTopicReply: _offTopicReply(),
      );
    }

    final lt = _s(j['listing_type']);
    final pt = _s(j['property_type']);
    final gov = _s(j['governorate_slug']);
    final city = _s(j['city_slug']);
    final maxP = _d(j['price_max']);
    final minP = _d(j['price_min']);
    final rooms = _i(j['rooms']);
    final beds = _i(j['beds']);
    final furnished = j['is_furnished'] is bool
        ? j['is_furnished'] as bool
        : null;
    final audience = _s(j['target_audience']);

    final filter = PropertyFilterModel(
      listingType: lt.isEmpty ? null : lt,
      propertyType: pt.isEmpty ? null : pt,
      governorateSlug: gov.isEmpty ? null : gov,
      citySlug: city.isEmpty ? null : city,
      maxPrice: maxP,
      minPrice: minP,
      minRooms: rooms,
      minBeds: beds,
      isFurnished: furnished,
      targetAudience: audience.isEmpty ? null : audience,
    );

    return SearchFiltersResult(
      intent: SearchIntent.property,
      filter: filter,
      filterSummaryAr: _summaryAr(filter),
      filterSummaryEn: _summaryEn(filter),
    );
  }

  // ── Summary builders ──────────────────────────────────────────────────────

  String _summaryAr(PropertyFilterModel f) {
    final p = <String>[];
    const pt = {
      'apartment': 'شقة',
      'villa': 'فيلا',
      'studio': 'استوديو',
      'duplex': 'دوبلكس',
      'chalet': 'شاليه',
    };
    const gv = {
      'cairo': 'القاهرة',
      'giza': 'الجيزة',
      'alexandria': 'الإسكندرية',
      'qalyubia': 'القليوبية',
      'dakahlia': 'الدقهلية',
      'gharbia': 'الغربية',
      'monufia': 'المنوفية',
      'beheira': 'البحيرة',
      'damietta': 'دمياط',
      'sharkia': 'الشرقية',
      'kafr_el_sheikh': 'كفر الشيخ',
      'ismailia': 'الإسماعيلية',
      'suez': 'السويس',
      'port_said': 'بورسعيد',
      'beni_suef': 'بني سويف',
      'fayoum': 'الفيوم',
      'minya': 'المنيا',
      'asyut': 'أسيوط',
      'sohag': 'سوهاج',
      'qena': 'قنا',
      'luxor': 'الأقصر',
      'aswan': 'أسوان',
      'red_sea': 'البحر الأحمر',
      'south_sinai': 'جنوب سيناء',
      'north_sinai': 'شمال سيناء',
      'matrouh': 'مطروح',
      'new_valley': 'الوادي الجديد',
    };
    if (f.propertyType != null) p.add(pt[f.propertyType] ?? f.propertyType!);
    if (f.listingType == 'rent') p.add('للإيجار');
    if (f.listingType == 'sale') p.add('للبيع');
    if (f.governorateSlug != null) {
      p.add('في ${gv[f.governorateSlug] ?? f.governorateSlug!}');
    }
    if (f.maxPrice != null) {
      p.add('حتى ${_fmt(f.maxPrice!)} ج');
    } else if (f.minPrice != null)
      p.add('من ${_fmt(f.minPrice!)} ج');
    if (f.minRooms != null) p.add('${f.minRooms}+ غرف');
    if (f.minBeds != null) p.add('${f.minBeds}+ أسرة');
    if (f.isFurnished == true) p.add('مفروشة');
    if (f.isFurnished == false) p.add('غير مفروشة');
    const au = {'male': 'شباب', 'female': 'بنات', 'family': 'عائلات'};
    if (f.targetAudience != null) p.add(au[f.targetAudience] ?? '');
    return p.where((e) => e.isNotEmpty).join(' • ');
  }

  String _summaryEn(PropertyFilterModel f) {
    final p = <String>[];
    if (f.propertyType != null) p.add(_cap(f.propertyType!));
    if (f.listingType == 'rent') p.add('for Rent');
    if (f.listingType == 'sale') p.add('for Sale');
    if (f.governorateSlug != null) {
      p.add('in ${_cap(f.governorateSlug!.replaceAll('_', ' '))}');
    }
    if (f.maxPrice != null) {
      p.add('up to ${_fmt(f.maxPrice!)} EGP');
    } else if (f.minPrice != null)
      p.add('from ${_fmt(f.minPrice!)} EGP');
    if (f.minRooms != null) p.add('${f.minRooms}+ rooms');
    if (f.isFurnished == true) p.add('Furnished');
    if (f.isFurnished == false) p.add('Unfurnished');
    return p.where((e) => e.isNotEmpty).join(' • ');
  }

  // ── Off-topic replies ─────────────────────────────────────────────────────

  String _offTopicReply() =>
      'أنا مساعد عقاري متخصص في إيجاد العقارات في مصر. 🏠\n\n'
      'جرّب مثلاً:\n'
      '• "شقة للإيجار في القاهرة بحد أقصى 5000 جنيه"\n'
      '• "فيلا للبيع في الإسكندرية بـ 4 غرف"\n'
      '• "استوديو مفروش للبنات في الجيزة"';

  String _greetingReply(String msg) {
    final isEn = RegExp(r'[a-zA-Z]').hasMatch(msg);
    return isEn
        ? 'Hello! 👋 I\'m your smart real-estate assistant for Egypt.\n\n'
              'Tell me what you\'re looking for and I\'ll find the best options! 🏡'
        : 'أهلاً! 👋 أنا مساعدك الذكي لإيجاد العقارات في مصر.\n\n'
              'أخبرني بما تبحث عنه وسأجد لك أفضل الخيارات فوراً! 🏡';
  }

  // ── Type helpers ──────────────────────────────────────────────────────────

  String _s(dynamic v) => (v is String) ? v.trim().toLowerCase() : '';
  double? _d(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  int? _i(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  String _cap(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class _QuotaException implements Exception {
  const _QuotaException();
}
