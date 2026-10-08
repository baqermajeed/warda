/// إعدادات عنوان الـ API أثناء التطوير.
///
/// - محاكي Android: `http://10.0.2.2:8000`
/// - هاتف حقيقي (نفس Wi‑Fi): IP جهاز الكمبيوتر مثل `http://192.168.1.221:8000`
/// - ويندوز / محاكي iOS: `http://127.0.0.1:8000`
abstract final class ApiConfig {
  static const String baseUrl = 'http://192.168.0.84:8000';

  static const String apiPrefix = '/api/v1';
  static const String authPrefix = '/api/v1/auth';
  static const String usersPrefix = '/api/v1/users';

  /// يُعيد الرابط الكامل لمسار صورة نسبي من الـ API.
  static String? imageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final p = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$p';
  }
}
