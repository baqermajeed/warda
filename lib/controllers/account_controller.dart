import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/account/account_action_dialog.dart';
import '../widgets/account/edit_profile_dialog.dart';
import '../widgets/account/language_dialog.dart';
import 'auth_controller.dart';
import 'locale_controller.dart';

/// تحكم شاشة الحساب والإعدادات.
class AccountController extends GetxController {
  final notificationsEnabled = true.obs;

  LocaleController get _locale => Get.find<LocaleController>();
  AuthController get _auth => Get.find<AuthController>();

  /// اللغة المحفوظة للتطبيق (`ar` | `en`).
  String get selectedLanguage => _locale.languageCode.value;

  /// الاختيار المؤقت داخل دايلوج اللغة.
  final pendingLanguage = 'ar'.obs;

  /// حقول تعديل الملف الشخصي.
  final pendingName = ''.obs;
  final pendingPhone = ''.obs;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    pendingLanguage.value = _locale.languageCode.value;
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  String get displayName {
    final user = _auth.user.value;
    if (user == null || user.name.isEmpty) {
      return 'account_display_name_fallback'.tr;
    }
    return user.name;
  }

  String get displayPhone {
    final user = _auth.user.value;
    final phone = user?.phone;
    if (phone == null || phone.isEmpty) return '0770 000 0000';
    return phone;
  }

  void toggleNotifications(bool value) => notificationsEnabled.value = value;

  void editProfile() {
    final user = _auth.user.value;
    final name = (user?.name.isNotEmpty ?? false)
        ? user!.name
        : '';
    final phone = user?.phone ?? '';
    pendingName.value = name;
    pendingPhone.value = phone;
    nameController.text = name;
    phoneController.text = phone;
    EditProfileDialog.show();
  }

  void confirmEditProfile() {
    final name = pendingName.value.trim();
    final phone = pendingPhone.value.trim();

    if (name.length < 2) {
      Get.snackbar(
        'common_app_name'.tr,
        'edit_profile_error_name'.tr,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    if (phone.replaceAll(RegExp(r'\s'), '').length < 10) {
      Get.snackbar(
        'common_app_name'.tr,
        'edit_profile_error_phone'.tr,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    _auth.updateProfile(name: name, phone: phone);
    Get.back();
    Get.snackbar(
      'common_app_name'.tr,
      'edit_profile_saved'.tr,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void openLanguage() {
    pendingLanguage.value = _locale.languageCode.value;
    LanguageDialog.show();
  }

  Future<void> confirmLanguage() async {
    final code = pendingLanguage.value;
    await _locale.setLanguage(code);
    Get.back();
    Get.snackbar(
      'common_app_name'.tr,
      code == 'ar' ? 'lang_selected_ar'.tr : 'lang_selected_en'.tr,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void openReminders() => Get.toNamed('/reminders');

  void openOrders() => Get.toNamed('/orders');

  void openFaq() => Get.toNamed('/faq');

  void openSupport() => Get.toNamed('/support');

  void openPrivacy() => Get.toNamed('/privacy');

  void shareApp() => Get.toNamed('/share');

  Future<void> logout() async {
    final confirm = await AccountActionDialog.showLogout();
    if (confirm == true) {
      await _auth.logout();
    }
  }

  Future<void> deleteAccount() async {
    final confirm = await AccountActionDialog.showDelete();
    if (confirm == true) {
      await _auth.logout();
    }
  }
}
