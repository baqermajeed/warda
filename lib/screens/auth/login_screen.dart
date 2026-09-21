import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/login_controller.dart';
import '../../widgets/auth/auth_input_field.dart';
import '../../widgets/auth/auth_scaffold.dart';

/// شاشة تسجيل الدخول — حسب تصميم Figma.
class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AuthScaffold(
        title: 'auth_login_title'.tr,
        subtitle: 'auth_login_subtitle'.tr,
        fields: [
          AuthInputField(
            hint: 'auth_phone_hint'.tr,
            iconAsset: 'assets/icons/auth/phone.svg',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            hasError: controller.errorMessage.value != null,
            onChanged: controller.onPhoneChanged,
          ),
        ],
        errorMessage: controller.errorMessage.value,
        isLoading: controller.isLoading.value,
        onNext: controller.submit,
        footer: AuthFooterLinks(
          prompt: 'auth_no_account'.tr,
          actionLabel: 'auth_create_one'.tr,
          onAction: controller.goToSignup,
          onGuest: controller.enterAsGuest,
        ),
      ),
    );
  }
}
