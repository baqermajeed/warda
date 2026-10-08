import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/errors/api_exception.dart';
import '../services/api_client.dart';
import 'auth_controller.dart';
import 'basket_controller.dart';

/// تحكم مراحل إكمال الطلب (معلومات المستلم → الدفع → النجاح).
class OrderController extends GetxController {
  final recipientName = ''.obs;
  final recipientPhone = ''.obs;
  final governorate = RxnString();
  final landmark = ''.obs;
  final unknownAddress = false.obs;
  final paymentMethod = 'cod'.obs;
  final isSubmitting = false.obs;

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController governorateController;
  late final TextEditingController landmarkController;

  static const governorates = [
    'gov_baghdad',
    'gov_basra',
    'gov_nineveh',
    'gov_erbil',
    'gov_najaf',
    'gov_karbala',
    'gov_anbar',
    'gov_diyala',
    'gov_wasit',
    'gov_maysan',
    'gov_muthanna',
    'gov_qadisiyyah',
    'gov_dhi_qar',
    'gov_saladin',
    'gov_kirkuk',
    'gov_duhok',
    'gov_sulaymaniyah',
    'gov_babylon',
  ];

  ApiClient get _api => Get.find<ApiClient>();

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    governorateController = TextEditingController();
    landmarkController = TextEditingController();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    governorateController.dispose();
    landmarkController.dispose();
    super.onClose();
  }

  BasketController get basket {
    if (!Get.isRegistered<BasketController>()) {
      Get.put(BasketController());
    }
    return Get.find<BasketController>();
  }

  void onNameChanged(String v) => recipientName.value = v;
  void onPhoneChanged(String v) => recipientPhone.value = v;
  void onLandmarkChanged(String v) => landmark.value = v;

  void toggleUnknownAddress() {
    unknownAddress.toggle();
    if (unknownAddress.value) {
      governorate.value = null;
      governorateController.clear();
      landmark.value = '';
      landmarkController.clear();
    }
  }

  void selectGovernorate(String value) {
    if (unknownAddress.value) return;
    governorate.value = value;
    governorateController.text = value.tr;
  }

  void selectPayment(String id) => paymentMethod.value = id;

  void goToPayment() {
    final name = recipientName.value.trim();
    final phone = recipientPhone.value.replaceAll(RegExp(r'\s'), '');
    if (name.length < 2) {
      Get.snackbar(
        'common_app_name'.tr,
        'edit_profile_error_name'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (phone.length < 10) {
      Get.snackbar(
        'common_app_name'.tr,
        'edit_profile_error_phone'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.toNamed('/order/payment');
  }

  Future<void> confirmOrder() async {
    if (!Get.find<AuthController>().requireAuth()) return;
    final name = recipientName.value.trim();
    final phone = recipientPhone.value.replaceAll(RegExp(r'\s'), '');
    if (name.length < 2) {
      Get.snackbar(
        'common_app_name'.tr,
        'edit_profile_error_name'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (phone.length < 10) {
      Get.snackbar(
        'common_app_name'.tr,
        'edit_profile_error_phone'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      await _api.createOrder({
        'recipient_name': name,
        'recipient_phone': phone,
        'governorate': unknownAddress.value ? null : governorate.value,
        'landmark': unknownAddress.value ? '' : landmark.value.trim(),
        'unknown_address': unknownAddress.value,
        'payment_method': paymentMethod.value == 'card' ? 'card' : 'cod',
      });
      if (Get.isRegistered<BasketController>()) {
        await Get.find<BasketController>().loadCart();
      }
      Get.offNamed('/order/success');
    } on ApiException catch (e) {
      Get.snackbar(
        'common_app_name'.tr,
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'common_app_name'.tr,
        'auth_error_generic'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void cancelOrder() {
    Get.until((route) => route.settings.name == '/home' || route.isFirst);
  }

  void goHome() => Get.offAllNamed('/home');

  void viewOrders() {
    Get.offAllNamed('/home');
    Get.toNamed('/orders');
  }
}
