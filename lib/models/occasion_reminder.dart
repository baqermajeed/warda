/// مناسبة محفوظة للتذكير.
class OccasionReminder {
  const OccasionReminder({
    required this.id,
    required this.personName,
    required this.typeId,
    required this.date,
    this.notifyEnabled = true,
    this.remindDaysBefore = 3,
    this.note = '',
  });

  final String id;
  final String personName;
  final String typeId;
  final DateTime date;
  final bool notifyEnabled;
  final int remindDaysBefore;
  final String note;

  OccasionReminder copyWith({
    String? id,
    String? personName,
    String? typeId,
    DateTime? date,
    bool? notifyEnabled,
    int? remindDaysBefore,
    String? note,
  }) {
    return OccasionReminder(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      typeId: typeId ?? this.typeId,
      date: date ?? this.date,
      notifyEnabled: notifyEnabled ?? this.notifyEnabled,
      remindDaysBefore: remindDaysBefore ?? this.remindDaysBefore,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'personName': personName,
        'typeId': typeId,
        'date': date.toIso8601String(),
        'notifyEnabled': notifyEnabled,
        'remindDaysBefore': remindDaysBefore,
        'note': note,
      };

  factory OccasionReminder.fromJson(Map<String, dynamic> json) {
    return OccasionReminder(
      id: json['id'] as String,
      personName: json['personName'] as String,
      typeId: json['typeId'] as String,
      date: DateTime.parse(json['date'] as String),
      notifyEnabled: json['notifyEnabled'] as bool? ?? true,
      remindDaysBefore: json['remindDaysBefore'] as int? ?? 3,
      note: json['note'] as String? ?? '',
    );
  }
}

/// نوع مناسبة مع أيقونة وترجمة.
class OccasionType {
  const OccasionType({
    required this.id,
    required this.labelKey,
    required this.iconAsset,
  });

  final String id;
  final String labelKey;
  final String iconAsset;
}
