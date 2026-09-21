import 'package:get/get.dart';

import '../utils/app_utils.dart';

/// منطق شاشة تسجيل الدخول (رقم الهاتف أولاً حسب التصميم).
class LoginController extends GetxController {
  final RxString phone = ''.obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  void onPhoneChanged(String value) {
    phone.value = value;
    if (errorMessage.value != null) {
      errorMessage.value = null;
    }
  }

  Future<void> submit() async {
    errorMessage.value = null;
    final cleaned = phone.value.replaceAll(RegExp(r'\s+'), '');

    if (!AppUtils.isNotBlank(cleaned)) {
      errorMessage.value = 'auth_error_phone'.tr;
      return;
    }

    if (!_isValidIraqiPhone(cleaned)) {
      errorMessage.value = 'auth_error_phone'.tr;
      return;
    }

    isLoading.value = true;
    try {
      // تدفق الهاتف أولاً — الانتقال للرئيسية حتى تتوفر شاشة OTP.
      await Future<void>.delayed(const Duration(milliseconds: 250));
      Get.offAllNamed('/home');
    } finally {
      isLoading.value = false;
    }
  }

  void enterAsGuest() => Get.offAllNamed('/home');

  void goToSignup() => Get.toNamed('/signup');

  static bool _isValidIraqiPhone(String phone) {
    final normalized = phone.startsWith('+964')
        ? '0${phone.substring(4)}'
        : phone.startsWith('964')
            ? '0${phone.substring(3)}'
            : phone;
    return RegExp(r'^07[3-9]\d{8}$').hasMatch(normalized);
  }
}
