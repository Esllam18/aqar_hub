import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale? locale;

  AppLocalizations({this.locale});

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  late Map<String, String> localizedStrings;

  Future<void> loadJsonLanguage() async {
    final jsonString = await rootBundle.loadString(
      'assets/lang/${locale!.languageCode}.json',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    localizedStrings = jsonMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );
  }

  String translate(String key) {
    final direct = localizedStrings[key];
    if (direct != null && direct.trim().isNotEmpty) {
      return direct;
    }

    final normalized = _normalizeKey(key);

    for (final entry in localizedStrings.entries) {
      if (_normalizeKey(entry.key) == normalized &&
          entry.value.trim().isNotEmpty) {
        return entry.value;
      }
    }

    return key;
  }

  String translateWithArgs(String key, [Map<String, Object?> args = const {}]) {
    var value = translate(key);
    args.forEach((k, v) {
      value = value.replaceAll('{$k}', '${v ?? ''}');
    });
    return value;
  }

  String _normalizeKey(String value) {
    return value.replaceAll(RegExp(r'[_\s-]'), '').toLowerCase().trim();
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale: locale);
    await localizations.loadJsonLanguage();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension TranslateX on String {
  String tr(BuildContext context) {
    return AppLocalizations.of(context)!.translate(this);
  }

  String trArgs(BuildContext context, [Map<String, Object?> args = const {}]) {
    return AppLocalizations.of(context)!.translateWithArgs(this, args);
  }
}
