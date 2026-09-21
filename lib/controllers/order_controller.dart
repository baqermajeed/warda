import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'basket_controller.dart';

/// تحكم مراحل إكمال الطلب (معلومات المستلم → الدفع → النجاح).
class OrderController extends GetxController {
  final recipientName = ''.obs;
  final recipientPhone = ''.obs;
  final governorate = RxnString();
  final landmark = ''.obs;
  final unknownAddress = false.obs;
  final paymentMethod = 'cod'.obs;

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

  void goToPayment() => Get.toNamed('/order/payment');

  void confirmOrder() => Get.offNamed('/order/success');

  void cancelOrder() {
    Get.until((route) => route.settings.name == '/home' || route.isFirst);
  }

  void goHome() => Get.offAllNamed('/home');

  void viewOrders() {
    Get.offAllNamed('/home');
    Get.toNamed('/orders');
  }
}
