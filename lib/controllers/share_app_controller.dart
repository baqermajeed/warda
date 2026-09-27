import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../services/api_client.dart';

/// تحكم شاشة مشاركة التطبيق.
class ShareAppController extends GetxController {
  final appLink = 'https://warda.app/download'.obs;
  final _messageAr = 'جرب تطبيق وردة للهدايا والزهور!'.obs;
  final _messageEn = 'Try Warda — gifts and flowers delivered!'.obs;

  ApiClient get _api => Get.find<ApiClient>();

  String get shareMessage {
    final isAr = (Get.locale?.languageCode ?? 'ar') == 'ar';
    final base = isAr ? _messageAr.value : _messageEn.value;
    if (base.contains(appLink.value)) return base;
    return '$base\n${appLink.value}';
  }

  @override
  void onInit() {
    super.onInit();
    loadShare();
  }

  Future<void> loadShare() async {
    try {
      final data = await _api.getShare();
      appLink.value = (data['url'] as String?) ?? appLink.value;
      _messageAr.value =
          (data['message_ar'] as String?) ?? _messageAr.value;
      _messageEn.value =
          (data['message_en'] as String?) ?? _messageEn.value;
    } catch (_) {
      // keep defaults
    }
  }

  Future<void> copyLink() async {
    await Clipboard.setData(ClipboardData(text: appLink.value));
    _toast('share_copied_link'.tr);
  }

  Future<void> copyMessage() async {
    await Clipboard.setData(ClipboardData(text: shareMessage));
    _toast('share_copied_message'.tr);
  }

  void shareViaWhatsApp() {
    _toast('share_whatsapp_hint'.tr);
  }

  void shareViaSms() {
    _toast('share_sms_hint'.tr);
  }

  void shareMore() {
    _toast('share_more_hint'.tr);
  }

  void _toast(String message) {
    Get.snackbar(
      'common_app_name'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
