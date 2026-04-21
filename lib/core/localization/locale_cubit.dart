import 'package:aqar_hub/core/localization/language_cache_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'locale_state.dart';

class LocaleCubit extends Cubit<ChangeLocaleState> {
  LocaleCubit() : super(ChangeLocaleState(locale: const Locale('ar')));

  static const _supported = ['ar', 'en'];

  Future<void> getSavedLanguage() async {
    final code = await LanguageCacheHelper.getLanguage();
    final safeCode = _supported.contains(code) ? code! : 'ar';
    emit(ChangeLocaleState(locale: Locale(safeCode)));
  }

  Future<void> changeLanguage(String languageCode) async {
    if (!_supported.contains(languageCode)) return;
    await LanguageCacheHelper.setLanguage(languageCode);
    emit(ChangeLocaleState(locale: Locale(languageCode)));
  }
}
