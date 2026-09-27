import 'user.dart';

/// نتيجة المصادقة (توكن + مستخدم).
class AuthResult {
  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.expiresIn = 0,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return AuthResult(
      accessToken: json['accessToken'] as String? ??
          json['access_token'] as String? ??
          json['token'] as String? ??
          '',
      refreshToken: json['refresh_token'] as String? ?? '',
      user: userJson is Map<String, dynamic>
          ? User.fromJson(userJson)
          : const User(id: '', name: ''),
      expiresIn: json['expires_in'] as int? ?? 0,
    );
  }

  final String accessToken;
  final String refreshToken;
  final User user;
  final int expiresIn;

  bool get hasSession => accessToken.isNotEmpty;
}
