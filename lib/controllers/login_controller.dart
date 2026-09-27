import 'package:get/get.dart';

import '../core/errors/api_exception.dart';
import '../services/api_client.dart';
import '../utils/app_utils.dart';
import 'auth_controller.dart';

/// منطق شاشة تسجيل الدخول (هاتف + كلمة مرور).
class LoginController extends GetxController {
  final RxString phone = ''.obs;
  final RxString password = ''.obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  void onPhoneChanged(String value) {
    phone.value = value;
    _clearError();
  }

  void onPasswordChanged(String value) {
    password.value = value;
    _clearError();
  }

  void _clearError() {
    if (errorMessage.value != null) errorMessage.value = null;
  }

  Future<void> submit() async {
    errorMessage.value = null;
    final cleaned = phone.value.replaceAll(RegExp(r'\s+'), '');

    if (!AppUtils.isNotBlank(cleaned) || !_isValidIraqiPhone(cleaned)) {
      errorMessage.value = 'auth_error_phone'.tr;
      return;
    }
    if (password.value.trim().length < 6) {
      errorMessage.value = 'auth_error_password'.tr;
      return;
    }

    isLoading.value = true;
    try {
      final api = Get.find<ApiClient>();
      final auth = Get.find<AuthController>();
      final result = await api.login(phone: cleaned, password: password.value);
      await auth.setSession(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        loggedInUser: result.user,
      );
      Get.offAllNamed('/home');
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'auth_error_generic'.tr;
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
