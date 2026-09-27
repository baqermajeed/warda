import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/errors/api_exception.dart';
import '../services/api_client.dart';
import '../utils/app_utils.dart';
import 'auth_controller.dart';

/// محافظات العراق — مفاتيح ترجمة (`gov_*`).
const kIraqGovernorates = <String>[
  'gov_baghdad',
  'gov_basra',
  'gov_nineveh',
  'gov_erbil',
  'gov_najaf',
  'gov_karbala',
  'gov_babylon',
  'gov_anbar',
  'gov_diyala',
  'gov_dhi_qar',
  'gov_saladin',
  'gov_wasit',
  'gov_maysan',
  'gov_muthanna',
  'gov_qadisiyyah',
  'gov_duhok',
  'gov_sulaymaniyah',
  'gov_kirkuk',
];

/// منطق شاشة إنشاء الحساب.
class SignupController extends GetxController {
  final RxString name = ''.obs;
  final RxString phone = ''.obs;
  final RxString password = ''.obs;
  final RxnString governorate = RxnString();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  void clearError() {
    if (errorMessage.value != null) errorMessage.value = null;
  }

  Future<void> submit() async {
    errorMessage.value = null;

    if (!AppUtils.isNotBlank(name.value)) {
      errorMessage.value = 'auth_error_name'.tr;
      return;
    }

    final cleaned = phone.value.replaceAll(RegExp(r'\s+'), '');
    if (!_isValidIraqiPhone(cleaned)) {
      errorMessage.value = 'auth_error_phone'.tr;
      return;
    }

    if (password.value.trim().length < 6) {
      errorMessage.value = 'auth_error_password'.tr;
      return;
    }

    if (governorate.value == null || governorate.value!.isEmpty) {
      errorMessage.value = 'auth_error_governorate'.tr;
      return;
    }

    isLoading.value = true;
    try {
      final api = Get.find<ApiClient>();
      final auth = Get.find<AuthController>();
      final result = await api.register(
        phone: cleaned,
        password: password.value,
        name: name.value.trim(),
        governorate: governorate.value!,
      );
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

  void goToLogin() => Get.offNamed('/login');

  Future<void> pickGovernorate() async {
    final selected = await Get.bottomSheet<String>(
      SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: kIraqGovernorates.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = kIraqGovernorates[index];
              return ListTile(
                title: Text(item.tr, textAlign: TextAlign.center),
                onTap: () => Get.back(result: item),
              );
            },
          ),
        ),
      ),
      isScrollControlled: true,
    );

    if (selected != null) {
      governorate.value = selected;
      clearError();
    }
  }

  static bool _isValidIraqiPhone(String phone) {
    final normalized = phone.startsWith('+964')
        ? '0${phone.substring(4)}'
        : phone.startsWith('964')
            ? '0${phone.substring(3)}'
            : phone;
    return RegExp(r'^07[3-9]\d{8}$').hasMatch(normalized);
  }
}
