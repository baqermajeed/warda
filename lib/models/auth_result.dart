import 'user.dart';

/// نتيجة المصادقة (توكن + مستخدم).
class AuthResult {
  const AuthResult({
    required this.accessToken,
    required this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      accessToken: json['accessToken'] as String? ?? json['token'] as String? ?? '',
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  final String accessToken;
  final User user;
}
