/// أدوات مساعدة عامة للمشروع.
abstract final class AppUtils {
  /// يتحقق أن النص ليس فارغاً بعد التنظيف.
  static bool isNotBlank(String? value) =>
      value != null && value.trim().isNotEmpty;
}
