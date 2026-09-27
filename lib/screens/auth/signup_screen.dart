import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/signup_controller.dart';
import '../../widgets/auth/auth_input_field.dart';
import '../../widgets/auth/auth_scaffold.dart';
import '../../widgets/common/app_spacing.dart';

/// شاشة إنشاء الحساب — حسب تصميم Figma.
class SignupScreen extends GetView<SignupController> {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AuthScaffold(
        title: 'auth_signup_title'.tr,
        subtitle: 'auth_signup_subtitle'.tr,
        fields: [
          AuthInputField(
            hint: 'auth_name_hint'.tr,
            iconAsset: 'assets/icons/auth/user.svg',
            textInputAction: TextInputAction.next,
            hasError: controller.errorMessage.value != null &&
                controller.name.value.trim().isEmpty,
            onChanged: (v) {
              controller.name.value = v;
              controller.clearError();
            },
          ),
          AppSpacing.verticalMd,
          AuthInputField(
            hint: 'auth_phone_hint_signup'.tr,
            iconAsset: 'assets/icons/auth/phone.svg',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            hasError: controller.errorMessage.value != null &&
                controller.phone.value.trim().isNotEmpty,
            onChanged: (v) {
              controller.phone.value = v;
              controller.clearError();
            },
          ),
          AppSpacing.verticalMd,
          AuthInputField(
            hint: 'auth_password_hint'.tr,
            iconAsset: 'assets/icons/auth/user.svg',
            obscureText: true,
            textInputAction: TextInputAction.next,
            hasError: controller.errorMessage.value != null &&
                controller.password.value.trim().length < 6,
            onChanged: (v) {
              controller.password.value = v;
              controller.clearError();
            },
          ),
          AppSpacing.verticalMd,
          AuthInputField(
            hint: controller.governorate.value?.tr ?? 'auth_governorate_hint'.tr,
            iconAsset: 'assets/icons/auth/map_pin.svg',
            readOnly: true,
            onTap: controller.pickGovernorate,
            hasError: controller.errorMessage.value != null &&
                controller.governorate.value == null,
            leading: SvgPicture.asset(
              'assets/icons/auth/caret_down.svg',
              width: 32.w,
              height: 32.w,
            ),
          ),
        ],
        errorMessage: controller.errorMessage.value,
        isLoading: controller.isLoading.value,
        onNext: controller.submit,
        footer: AuthFooterLinks(
          prompt: 'auth_have_account'.tr,
          actionLabel: 'auth_go_login'.tr,
          onAction: controller.goToLogin,
          onGuest: controller.enterAsGuest,
        ),
      ),
    );
  }
}
