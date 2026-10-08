/// نموذج المستخدم.
class User {
  const User({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.governorate,
    this.notificationsEnabled = true,
    this.locale,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      governorate: json['governorate'] as String?,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      locale: json['locale'] as String?,
    );
  }

  final String id;
  final String name;
  final String? phone;
  final String? email;

  /// مفتاح ترجمة المحافظة (`gov_*`).
  final String? governorate;
  final bool notificationsEnabled;

  /// لغة المستخدم المحفوظة على الخادم (`ar` | `en`).
  final String? locale;

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? governorate,
    bool? notificationsEnabled,
    String? locale,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      governorate: governorate ?? this.governorate,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      locale: locale ?? this.locale,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (governorate != null) 'governorate': governorate,
        'notifications_enabled': notificationsEnabled,
        if (locale != null) 'locale': locale,
      };
}
