import 'package:flutter/material.dart';

/// ألوان التطبيق الأساسية.
abstract final class AppColors {
  /// #574A24 — بني غامق (أساسي)
  static const Color primaryDark = Color(0xFF574A24);

  /// #80775C — بني متوسط
  static const Color primaryMedium = Color(0xFF80775C);

  /// #FAE8B4 — كريم فاتح
  static const Color primaryLight = Color(0xFFFAE8B4);

  /// #CBBD93 — بيج
  static const Color primaryBeige = Color(0xFFCBBD93);

  /// للخلفيات الفاتحة
  static const Color surface = Color(0xFFFFFBF5);

  /// للنصوص الأساسية
  static const Color textPrimary = Color(0xFF574A24);

  /// للنصوص الثانوية
  static const Color textSecondary = Color(0xFF80775C);

  /// للحدود والحواجز
  static const Color border = Color(0xFFCBBD93);

  /// للخطأ
  static const Color error = Color(0xFFB00020);

  // ——— من تصميم Onboarding (Gifts App) ———
  /// #402628 — نص الأساسي في شاشات التعريف
  static const Color onboardingText = Color(0xFF402628);

  /// #4D0F14 — زر CTA في شاشات التعريف
  static const Color onboardingCta = Color(0xFF4D0F14);

  /// #C7A49D — نقاط التنقل والعناصر الناعمة
  static const Color onboardingSoft = Color(0xFFC7A49D);

  /// #FFFEFB — خلفية شاشات التعريف
  static const Color onboardingBg = Color(0xFFFFFEFB);

  /// #585858 — نص فرعي في شاشات المصادقة
  static const Color authMuted = Color(0xFF585858);

  /// #AD8A83 — روابط المصادقة
  static const Color authLink = Color(0xFFAD8A83);

  /// دائرة الشعار في المصادقة
  static const Color authLogoCircle = Color(0xFFF5EAEA);

  /// حدود حقول المصادقة
  static const Color authFieldBorder = Color(0x423A3F41);

  /// #EB4214 / #ED3737 — خطأ حقل المصادقة
  static const Color authError = Color(0xFFED3737);
  static const Color authErrorBorder = Color(0xFFEB4214);

  /// #0E8A61 — أسعار وتوصيل مجاني في السلة
  static const Color successGreen = Color(0xFF0E8A61);

  // ——— الوضع الليلي ———
  static const Color surfaceDark = Color(0xFF1C1914);
  static const Color textPrimaryDark = Color(0xFFFAE8B4);
  static const Color textSecondaryDark = Color(0xFFCBBD93);
  static const Color borderDark = Color(0xFF3D3629);
}
