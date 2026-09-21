/// إعدادات عنوان الـ API.
/// للمحاكي Android استخدم 10.0.2.2 بدلاً من localhost.
abstract final class ApiConfig {
  static const String baseUrl = _baseUrlDev;

  static const String _baseUrlDev = 'https://api.example.com';

  static const String authPrefix = '/api/auth';
  static const String usersPrefix = '/api/users';

  /// يُعيد الرابط الكامل لمسار صورة نسبي من الـ API.
  static String? imageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final p = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$p';
  }
}
