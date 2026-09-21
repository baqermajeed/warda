import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// تحكم لغة التطبيق واتجاه النص.
class LocaleController extends GetxController {
  static const languageKey = 'app_language';

  final languageCode = 'ar'.obs;

  Locale get locale => Locale(languageCode.value);

  bool get isArabic => languageCode.value == 'ar';

  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  Future<void> ensureLoaded() => _load();

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(languageKey) ?? 'ar';
    languageCode.value = code;
    Get.updateLocale(Locale(code));
  }

  Future<void> setLanguage(String code) async {
    if (code != 'ar' && code != 'en') return;
    languageCode.value = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(languageKey, code);
    Get.updateLocale(Locale(code));
  }
}
