import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/errors/api_exception.dart';
import '../models/occasion_reminder.dart';
import '../services/api_client.dart';
import 'auth_controller.dart';

/// تحكم شاشة تذكير المناسبات.
class RemindersController extends GetxController {
  final reminders = <OccasionReminder>[].obs;
  final isLoading = true.obs;

  final personName = ''.obs;
  final selectedTypeId = 'birthday'.obs;
  final selectedDate = Rxn<DateTime>();
  final remindDaysBefore = 3.obs;
  final note = ''.obs;
  final editingId = RxnString();

  ApiClient get _api => Get.find<ApiClient>();

  static const occasionTypes = <OccasionType>[
    OccasionType(
      id: 'birthday',
      labelKey: 'opt_birthday',
      iconAsset: 'assets/icons/spicial-gift/occasion/birthday.svg',
    ),
    OccasionType(
      id: 'anniversary',
      labelKey: 'opt_anniversary',
      iconAsset: 'assets/icons/spicial-gift/occasion/love.svg',
    ),
    OccasionType(
      id: 'wedding',
      labelKey: 'opt_wedding',
      iconAsset: 'assets/icons/spicial-gift/occasion/wedding.svg',
    ),
    OccasionType(
      id: 'newborn',
      labelKey: 'opt_newborn',
      iconAsset: 'assets/icons/spicial-gift/occasion/newborn.svg',
    ),
    OccasionType(
      id: 'graduation',
      labelKey: 'opt_graduation',
      iconAsset: 'assets/icons/spicial-gift/occasion/graduation.svg',
    ),
    OccasionType(
      id: 'mothers',
      labelKey: 'rem_type_mothers',
      iconAsset: 'assets/icons/spicial-gift/occasion/mothers.svg',
    ),
    OccasionType(
      id: 'fathers',
      labelKey: 'rem_type_fathers',
      iconAsset: 'assets/icons/spicial-gift/occasion/fathers.svg',
    ),
    OccasionType(
      id: 'thanks',
      labelKey: 'opt_thanks',
      iconAsset: 'assets/icons/spicial-gift/occasion/thanks.svg',
    ),
    OccasionType(
      id: 'formal',
      labelKey: 'rem_type_formal',
      iconAsset: 'assets/icons/spicial-gift/occasion/formal.svg',
    ),
  ];

  static const remindDayOptions = [1, 3, 7];

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  bool _requireAuth() => Get.find<AuthController>().requireAuth();

  List<OccasionReminder> get upcoming {
    final sorted = List<OccasionReminder>.from(reminders);
    sorted.sort((a, b) => _nextOccurrence(a.date).compareTo(_nextOccurrence(b.date)));
    return sorted;
  }

  OccasionType typeOf(String typeId) {
    return occasionTypes.firstWhere(
      (e) => e.id == typeId,
      orElse: () => occasionTypes.first,
    );
  }

  String typeLabel(String typeId) => typeOf(typeId).labelKey.tr;

  String typeIcon(String typeId) => typeOf(typeId).iconAsset;

  /// عدد الأيام حتى أقرب تكرار للمناسبة.
  int daysUntil(DateTime date) {
    final next = _nextOccurrence(date);
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    return next.difference(start).inDays;
  }

  String daysUntilLabel(DateTime date) {
    final days = daysUntil(date);
    if (days == 0) return 'rem_today'.tr;
    if (days == 1) return 'rem_tomorrow'.tr;
    return 'rem_days_left'.trParams({'days': '$days'});
  }

  String formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  void resetForm({OccasionReminder? reminder}) {
    if (reminder == null) {
      editingId.value = null;
      personName.value = '';
      selectedTypeId.value = 'birthday';
      selectedDate.value = null;
      remindDaysBefore.value = 3;
      note.value = '';
      return;
    }
    editingId.value = reminder.id;
    personName.value = reminder.personName;
    selectedTypeId.value = reminder.typeId;
    selectedDate.value = reminder.date;
    remindDaysBefore.value = reminder.remindDaysBefore;
    note.value = reminder.note;
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initial = selectedDate.value ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4D0F14),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF402628),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) selectedDate.value = picked;
  }

  bool get canSave {
    return personName.value.trim().isNotEmpty && selectedDate.value != null;
  }

  Map<String, dynamic> _body({bool? notifyEnabled}) {
    final date = selectedDate.value!;
    final iso =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return {
      'person_name': personName.value.trim(),
      'type_id': selectedTypeId.value,
      'date': iso,
      'notify_enabled': notifyEnabled ?? true,
      'remind_days_before': remindDaysBefore.value,
      'note': note.value.trim(),
    };
  }

  OccasionReminder _fromApi(Map<String, dynamic> json) {
    return OccasionReminder(
      id: '${json['id']}',
      personName: (json['person_name'] as String?) ?? '',
      typeId: (json['type_id'] as String?) ?? 'birthday',
      date: DateTime.parse(json['date'] as String),
      notifyEnabled: json['notify_enabled'] as bool? ?? true,
      remindDaysBefore: json['remind_days_before'] as int? ?? 3,
      note: (json['note'] as String?) ?? '',
    );
  }

  Future<void> saveReminder() async {
    if (!_requireAuth()) return;
    if (!canSave) {
      Get.snackbar(
        'common_app_name'.tr,
        'rem_error_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    final id = editingId.value;
    try {
      if (id == null) {
        final created = await _api.createReminder(_body());
        reminders.add(_fromApi(created));
      } else {
        final existing = reminders.firstWhereOrNull((e) => e.id == id);
        final updated = await _api.updateReminder(
          int.parse(id),
          _body(notifyEnabled: existing?.notifyEnabled),
        );
        final index = reminders.indexWhere((e) => e.id == id);
        if (index >= 0) {
          reminders[index] = _fromApi(updated);
        }
      }
      Get.back();
      Get.snackbar(
        'common_app_name'.tr,
        id == null ? 'rem_saved'.tr : 'rem_updated'.tr,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } on ApiException catch (e) {
      Get.snackbar('common_app_name'.tr, e.message);
    } catch (_) {
      Get.snackbar('common_app_name'.tr, 'auth_error_generic'.tr);
    }
  }

  Future<void> toggleNotify(String id, bool value) async {
    if (!_requireAuth()) return;
    final index = reminders.indexWhere((e) => e.id == id);
    if (index < 0) return;
    final prev = reminders[index];
    reminders[index] = prev.copyWith(notifyEnabled: value);
    try {
      final date = prev.date;
      final iso =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      await _api.updateReminder(int.parse(id), {
        'person_name': prev.personName,
        'type_id': prev.typeId,
        'date': iso,
        'notify_enabled': value,
        'remind_days_before': prev.remindDaysBefore,
        'note': prev.note,
      });
    } catch (_) {
      reminders[index] = prev;
    }
  }

  Future<void> deleteReminder(String id) async {
    if (!_requireAuth()) return;
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('rem_delete_title'.tr),
        content: Text('rem_delete_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common_cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEB0101),
            ),
            child: Text('common_delete'.tr),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final removed = reminders.firstWhereOrNull((e) => e.id == id);
    reminders.removeWhere((e) => e.id == id);
    try {
      await _api.deleteReminder(int.parse(id));
    } catch (_) {
      if (removed != null) reminders.add(removed);
    }
  }

  DateTime _nextOccurrence(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var next = DateTime(today.year, date.month, date.day);
    if (next.isBefore(today)) {
      next = DateTime(today.year + 1, date.month, date.day);
    }
    return next;
  }

  Future<void> _load() async {
    if (!_requireAuth()) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    try {
      final rows = await _api.getReminders();
      reminders.assignAll(
        rows
            .whereType<Map>()
            .map((e) => _fromApi(Map<String, dynamic>.from(e))),
      );
    } on ApiException catch (e) {
      Get.snackbar('common_app_name'.tr, e.message);
    } catch (_) {
      // keep empty
    } finally {
      isLoading.value = false;
    }
  }
}
