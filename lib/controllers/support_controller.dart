import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/errors/api_exception.dart';
import '../services/api_client.dart';
import 'auth_controller.dart';

/// تحكم شاشة خدمة العملاء.
class SupportController extends GetxController {
  final subjectId = 'order'.obs;
  final message = ''.obs;
  final isSending = false.obs;
  final isLoading = false.obs;
  final messageController = TextEditingController();

  final phone = '+9647700000000'.obs;
  final whatsapp = '+9647700000000'.obs;
  final email = 'support@warda.app'.obs;
  final hours = 'support_hours_value'.obs;

  ApiClient get _api => Get.find<ApiClient>();

  static const subjects = <({String id, String labelKey})>[
    (id: 'order', labelKey: 'support_subject_order'),
    (id: 'delivery', labelKey: 'support_subject_delivery'),
    (id: 'payment', labelKey: 'support_subject_payment'),
    (id: 'other', labelKey: 'support_subject_other'),
  ];

  @override
  void onInit() {
    super.onInit();
    loadContact();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  Future<void> loadContact() async {
    isLoading.value = true;
    try {
      final data = await _api.getSupportContact();
      phone.value = (data['phone'] as String?) ?? phone.value;
      whatsapp.value = (data['whatsapp'] as String?) ?? whatsapp.value;
      email.value = (data['email'] as String?) ?? email.value;
      final isAr = (Get.locale?.languageCode ?? 'ar') == 'ar';
      hours.value = isAr
          ? ((data['hours_ar'] as String?) ?? hours.value)
          : ((data['hours_en'] as String?) ??
              data['hours_ar'] as String? ??
              hours.value);
    } catch (_) {
      // keep defaults
    } finally {
      isLoading.value = false;
    }
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
    try {
      final user = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>().user.value
          : null;
      final subjectLabel = subjects
          .firstWhere(
            (s) => s.id == subjectId.value,
            orElse: () => subjects.last,
          )
          .labelKey
          .tr;
      await _api.createSupportTicket({
        'subject': subjectLabel,
        'message': message.value.trim(),
        'name': user?.name ?? '',
        'phone': user?.phone ?? '',
      });
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
    } on ApiException catch (e) {
      Get.snackbar(
        'common_app_name'.tr,
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (_) {
      Get.snackbar(
        'common_app_name'.tr,
        'auth_error_generic'.tr,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isSending.value = false;
    }
  }

  void contactPhone() {
    Get.snackbar(
      'support_phone'.tr,
      phone.value,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void contactWhatsApp() {
    Get.snackbar(
      'support_whatsapp'.tr,
      whatsapp.value,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void contactEmail() {
    Get.snackbar(
      'support_email'.tr,
      email.value,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void openFaq() => Get.toNamed('/faq');
}
