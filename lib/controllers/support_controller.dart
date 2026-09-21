import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// تحكم شاشة خدمة العملاء.
class SupportController extends GetxController {
  final subjectId = 'order'.obs;
  final message = ''.obs;
  final isSending = false.obs;
  final messageController = TextEditingController();

  static const subjects = <({String id, String labelKey})>[
    (id: 'order', labelKey: 'support_subject_order'),
    (id: 'delivery', labelKey: 'support_subject_delivery'),
    (id: 'payment', labelKey: 'support_subject_payment'),
    (id: 'other', labelKey: 'support_subject_other'),
  ];

  static const phone = '0770 000 0000';
  static const whatsapp = '0770 000 0000';
  static const email = 'support@warda.app';
  static const hours = 'support_hours_value';

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  void selectSubject(String id) => subjectId.value = id;

  bool get canSend => message.value.trim().length >= 10;

  Future<void> submitMessage() async {
    if (!canSend) {
      Get.snackbar(
        'common_app_name'.tr,
        'support_error_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    isSending.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 650));
    isSending.value = false;
    message.value = '';
    messageController.clear();
    subjectId.value = 'order';

    Get.snackbar(
      'common_app_name'.tr,
      'support_sent'.tr,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void contactPhone() {
    Get.snackbar(
      'support_phone'.tr,
      phone,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void contactWhatsApp() {
    Get.snackbar(
      'support_whatsapp'.tr,
      whatsapp,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void contactEmail() {
    Get.snackbar(
      'support_email'.tr,
      email,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void openFaq() => Get.toNamed('/faq');
}
