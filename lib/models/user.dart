/// نموذج المستخدم.
class User {
  const User({
    required this.id,
    required this.name,
    this.phone,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );
  }

  final String id;
  final String name;
  final String? phone;
  final String? email;

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
      };
}
