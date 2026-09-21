import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/occasion_reminder.dart';

/// تحكم شاشة تذكير المناسبات.
class RemindersController extends GetxController {
  static const _storageKey = 'occasion_reminders_v1';

  final reminders = <OccasionReminder>[].obs;
  final isLoading = true.obs;

  final personName = ''.obs;
  final selectedTypeId = 'birthday'.obs;
  final selectedDate = Rxn<DateTime>();
  final remindDaysBefore = 3.obs;
  final note = ''.obs;
  final editingId = RxnString();

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

  Future<void> saveReminder() async {
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
    if (id == null) {
      reminders.add(
        OccasionReminder(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          personName: personName.value.trim(),
          typeId: selectedTypeId.value,
          date: selectedDate.value!,
          remindDaysBefore: remindDaysBefore.value,
          note: note.value.trim(),
        ),
      );
    } else {
      final index = reminders.indexWhere((e) => e.id == id);
      if (index >= 0) {
        reminders[index] = reminders[index].copyWith(
          personName: personName.value.trim(),
          typeId: selectedTypeId.value,
          date: selectedDate.value!,
          remindDaysBefore: remindDaysBefore.value,
          note: note.value.trim(),
        );
      }
    }

    await _persist();
    Get.back();
    Get.snackbar(
      'common_app_name'.tr,
      id == null ? 'rem_saved'.tr : 'rem_updated'.tr,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  Future<void> toggleNotify(String id, bool value) async {
    final index = reminders.indexWhere((e) => e.id == id);
    if (index < 0) return;
    reminders[index] = reminders[index].copyWith(notifyEnabled: value);
    await _persist();
  }

  Future<void> deleteReminder(String id) async {
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
    reminders.removeWhere((e) => e.id == id);
    await _persist();
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
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) {
        reminders.assignAll(_seedReminders());
        await _persist();
      } else {
        final list = (jsonDecode(raw) as List)
            .cast<Map<String, dynamic>>()
            .map(OccasionReminder.fromJson)
            .toList();
        reminders.assignAll(list);
      }
    } catch (_) {
      reminders.assignAll(_seedReminders());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(reminders.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  List<OccasionReminder> _seedReminders() {
    final now = DateTime.now();
    return [
      OccasionReminder(
        id: 'seed_1',
        personName: 'أحمد',
        typeId: 'birthday',
        date: DateTime(now.year, now.month, now.day).add(const Duration(days: 5)),
        remindDaysBefore: 3,
      ),
      OccasionReminder(
        id: 'seed_2',
        personName: 'سارة',
        typeId: 'anniversary',
        date: DateTime(now.year, now.month, now.day).add(const Duration(days: 18)),
        remindDaysBefore: 7,
      ),
    ];
  }
}
