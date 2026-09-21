import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// تحكم شاشة مشاركة التطبيق.
class ShareAppController extends GetxController {
  static const appLink = 'https://warda.app/download';

  String get shareMessage =>
      'share_message_body'.trParams({'link': appLink});

  Future<void> copyLink() async {
    await Clipboard.setData(const ClipboardData(text: appLink));
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
