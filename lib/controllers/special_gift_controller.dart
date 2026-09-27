import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/config/api_config.dart';
import '../core/errors/api_exception.dart';
import '../services/api_client.dart';
import 'auth_controller.dart';
import 'home_controller.dart';

/// خيار اختيار في خطوات الهدية المخصصة.
class SpecialGiftOption {
  const SpecialGiftOption({
    required this.id,
    required this.label,
    required this.iconAsset,
    this.span = 1,
  });

  final String id;
  final String label;
  final String iconAsset;
  final int span;
}

/// Controller لتدفق هدية مخصصة (مقدمة + 4 خطوات + نتائج).
class SpecialGiftController extends GetxController {
  /// 0 = مقدمة «كوّن هديتك» ، ثم 1..4 خطوات الأسئلة
  final currentStep = 0.obs;
  final selectedRecipientId = RxnString();
  final selectedOccasionId = RxnString();
  final selectedTypeId = RxnString();
  final budgetFrom = ''.obs;
  final budgetTo = ''.obs;
  final favoriteIds = <String>{}.obs;
  final suggestions = <SpecialGiftSuggestion>[].obs;
  final isLoadingResults = false.obs;

  bool get isIntro => currentStep.value == 0;

  ApiClient get _api => Get.find<ApiClient>();

  static const stepColors = <Color>[
    Color(0xFFE3C226),
    Color(0xFFE38426),
    Color(0xFFE33F26),
    Color(0xFF0E8A61),
  ];

  Color get stepColor {
    if (isIntro) return stepColors.first;
    return stepColors[(currentStep.value - 1).clamp(0, 3)];
  }

  String get stepLabel {
    if (isIntro) return '';
    return '${currentStep.value} / 4';
  }

  String get stepTitle {
    switch (currentStep.value) {
      case 1:
        return 'sg_q_recipient'.tr;
      case 2:
        return 'sg_q_occasion'.tr;
      case 3:
        return 'sg_q_type'.tr;
      case 4:
        return 'sg_q_budget'.tr;
      default:
        return 'sg_title'.tr;
    }
  }

  String get primaryButtonLabel {
    if (isIntro) return 'sg_cta_start'.tr;
    if (currentStep.value == 4) return 'sg_cta_suggestions'.tr;
    return 'sg_cta_next'.tr;
  }

  final recipients = const [
    SpecialGiftOption(
      id: 'parents',
      label: 'sg_opt_parents',
      iconAsset: 'assets/icons/spicial-gift/who/parents.svg',
    ),
    SpecialGiftOption(
      id: 'sibling',
      label: 'sg_opt_sibling',
      iconAsset: 'assets/icons/spicial-gift/who/sibling.svg',
    ),
    SpecialGiftOption(
      id: 'spouse',
      label: 'sg_opt_spouse',
      iconAsset: 'assets/icons/spicial-gift/who/spouse.svg',
    ),
    SpecialGiftOption(
      id: 'friends',
      label: 'sg_opt_friends',
      iconAsset: 'assets/icons/spicial-gift/who/friends.svg',
    ),
    SpecialGiftOption(
      id: 'kids',
      label: 'opt_kids',
      iconAsset: 'assets/icons/spicial-gift/who/kids.svg',
    ),
    SpecialGiftOption(
      id: 'work',
      label: 'sg_opt_work',
      iconAsset: 'assets/icons/spicial-gift/who/work.svg',
    ),
    SpecialGiftOption(
      id: 'grandparents',
      label: 'sg_opt_grandparents',
      iconAsset: 'assets/icons/spicial-gift/who/grandparents.svg',
    ),
    SpecialGiftOption(
      id: 'other',
      label: 'sg_opt_other_person',
      iconAsset: 'assets/icons/spicial-gift/who/other.svg',
      span: 2,
    ),
  ];

  final occasions = const [
    SpecialGiftOption(
      id: 'birthday',
      label: 'opt_birthday',
      iconAsset: 'assets/icons/spicial-gift/occasion/birthday.svg',
    ),
    SpecialGiftOption(
      id: 'fathers',
      label: 'sg_opt_fathers',
      iconAsset: 'assets/icons/spicial-gift/occasion/fathers.svg',
    ),
    SpecialGiftOption(
      id: 'wedding',
      label: 'sg_opt_wedding_engagement',
      iconAsset: 'assets/icons/spicial-gift/occasion/wedding.svg',
    ),
    SpecialGiftOption(
      id: 'newborn',
      label: 'opt_newborn',
      iconAsset: 'assets/icons/spicial-gift/occasion/newborn.svg',
    ),
    SpecialGiftOption(
      id: 'love',
      label: 'sg_opt_valentines',
      iconAsset: 'assets/icons/spicial-gift/occasion/love.svg',
    ),
    SpecialGiftOption(
      id: 'mothers',
      label: 'sg_opt_mothers',
      iconAsset: 'assets/icons/spicial-gift/occasion/mothers.svg',
    ),
    SpecialGiftOption(
      id: 'thanks',
      label: 'opt_thanks',
      iconAsset: 'assets/icons/spicial-gift/occasion/thanks.svg',
    ),
    SpecialGiftOption(
      id: 'work',
      label: 'sg_opt_work_congrats',
      iconAsset: 'assets/icons/spicial-gift/occasion/work_congrats.svg',
    ),
    SpecialGiftOption(
      id: 'graduation',
      label: 'sg_opt_grad_success',
      iconAsset: 'assets/icons/spicial-gift/occasion/graduation.svg',
    ),
    SpecialGiftOption(
      id: 'formal',
      label: 'sg_opt_formal',
      iconAsset: 'assets/icons/spicial-gift/occasion/formal.svg',
    ),
    SpecialGiftOption(
      id: 'none',
      label: 'sg_opt_no_occasion',
      iconAsset: 'assets/icons/spicial-gift/occasion/no_occasion.svg',
      span: 2,
    ),
  ];

  final giftTypes = const [
    SpecialGiftOption(
      id: 'flowers',
      label: 'sg_opt_flower_bouquets',
      iconAsset: 'assets/icons/spicial-gift/type/flowers.svg',
    ),
    SpecialGiftOption(
      id: 'cake',
      label: 'opt_cake',
      iconAsset: 'assets/icons/spicial-gift/type/cake.svg',
    ),
    SpecialGiftOption(
      id: 'chocolate',
      label: 'opt_chocolate',
      iconAsset: 'assets/icons/spicial-gift/type/chocolate.svg',
    ),
    SpecialGiftOption(
      id: 'plants',
      label: 'opt_plants',
      iconAsset: 'assets/icons/spicial-gift/type/plants.svg',
    ),
    SpecialGiftOption(
      id: 'jewelry',
      label: 'sg_opt_jewelry',
      iconAsset: 'assets/icons/spicial-gift/type/jewelry.svg',
    ),
    SpecialGiftOption(
      id: 'candles',
      label: 'sg_opt_candles',
      iconAsset: 'assets/icons/spicial-gift/type/candles.svg',
    ),
    SpecialGiftOption(
      id: 'home',
      label: 'sg_opt_home',
      iconAsset: 'assets/icons/spicial-gift/type/home.svg',
    ),
    SpecialGiftOption(
      id: 'men',
      label: 'sg_opt_gifts_men',
      iconAsset: 'assets/icons/spicial-gift/type/men.svg',
    ),
    SpecialGiftOption(
      id: 'women',
      label: 'sg_opt_gifts_women',
      iconAsset: 'assets/icons/spicial-gift/type/women.svg',
    ),
    SpecialGiftOption(
      id: 'care',
      label: 'sg_opt_care',
      iconAsset: 'assets/icons/spicial-gift/type/care.svg',
    ),
    SpecialGiftOption(
      id: 'toys',
      label: 'opt_toys',
      iconAsset: 'assets/icons/spicial-gift/type/toys.svg',
      span: 2,
    ),
  ];

  List<SpecialGiftOption> get currentOptions {
    switch (currentStep.value) {
      case 1:
        return recipients;
      case 2:
        return occasions;
      case 3:
        return giftTypes;
      default:
        return const [];
    }
  }

  String? get selectedOptionId {
    switch (currentStep.value) {
      case 1:
        return selectedRecipientId.value;
      case 2:
        return selectedOccasionId.value;
      case 3:
        return selectedTypeId.value;
      default:
        return null;
    }
  }

  void selectOption(String id) {
    switch (currentStep.value) {
      case 1:
        selectedRecipientId.value = id;
      case 2:
        selectedOccasionId.value = id;
      case 3:
        selectedTypeId.value = id;
    }
  }

  String get recipientLabel {
    final id = selectedRecipientId.value;
    if (id == null) return 'زوج / زوجة';
    return recipients.firstWhere((e) => e.id == id).label.tr;
  }

  String get occasionLabel {
    final id = selectedOccasionId.value;
    if (id == null) return 'بدون مناسبة';
    return occasions.firstWhere((e) => e.id == id).label.tr;
  }

  String get budgetChipLabel {
    final to = budgetTo.value.trim();
    final currency = 'common_currency_iqd'.tr;
    if (to.isEmpty) return '100,000 $currency';
    return '$to $currency';
  }

  int? _parseBudget(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  Future<void> loadRecommendations() async {
    isLoadingResults.value = true;
    try {
      final data = await _api.specialGiftRecommend({
        'recipient_id': selectedRecipientId.value,
        'occasion_id': selectedOccasionId.value,
        'type_id': selectedTypeId.value,
        'budget_from': _parseBudget(budgetFrom.value),
        'budget_to': _parseBudget(budgetTo.value),
      });
      final mapped = (data['items'] as List? ?? []).whereType<Map>().map((e) {
        final m = Map<String, dynamic>.from(e);
        final image = m['image'] as String? ?? '';
        return SpecialGiftSuggestion(
          id: '${m['id']}',
          title: (m['title'] ?? m['title_ar'] ?? '') as String,
          price: (m['price_label'] ?? '${m['price'] ?? 0}') as String,
          rating: '${m['rating'] ?? 4.5}',
          imageAsset: ApiConfig.imageUrl(image) ??
              (image.isEmpty ? 'assets/images/home/product_1.png' : image),
        );
      }).toList();
      suggestions.assignAll(mapped);
      favoriteIds
        ..clear()
        ..addAll(
          (data['items'] as List? ?? [])
              .whereType<Map>()
              .where((e) => e['is_favorite'] == true)
              .map((e) => '${e['id']}'),
        );
    } on ApiException catch (e) {
      Get.snackbar('common_app_name'.tr, e.message);
    } catch (_) {
      Get.snackbar('common_app_name'.tr, 'auth_error_generic'.tr);
    } finally {
      isLoadingResults.value = false;
    }
  }

  Future<void> toggleFavorite(String id) async {
    if (!Get.find<AuthController>().isAuthenticated) {
      Get.toNamed('/login');
      return;
    }
    final productId = int.tryParse(id);
    if (productId == null) return;
    final wasFav = favoriteIds.contains(id);
    if (wasFav) {
      favoriteIds.remove(id);
    } else {
      favoriteIds.add(id);
    }
    try {
      if (wasFav) {
        await _api.removeFavorite(productId);
      } else {
        await _api.addFavorite(productId);
      }
      if (Get.isRegistered<HomeController>()) {
        final home = Get.find<HomeController>();
        if (wasFav) {
          home.favoriteIds.remove(id);
        } else {
          home.favoriteIds.add(id);
        }
      }
    } catch (_) {
      if (wasFav) {
        favoriteIds.add(id);
      } else {
        favoriteIds.remove(id);
      }
    }
  }

  Future<void> next() async {
    if (currentStep.value < 4) {
      currentStep.value++;
      return;
    }
    await loadRecommendations();
    if (Get.isDialogOpen ?? false) {
      Get.back();
    } else {
      Get.back();
    }
    Future.microtask(() => Get.toNamed('/special-gift/results'));
  }

  void closeFlow() {
    Get.back();
  }

  void reset() {
    currentStep.value = 0;
    selectedRecipientId.value = null;
    selectedOccasionId.value = null;
    selectedTypeId.value = null;
    budgetFrom.value = '';
    budgetTo.value = '';
    suggestions.clear();
    favoriteIds.clear();
  }
}

class SpecialGiftSuggestion {
  const SpecialGiftSuggestion({
    required this.id,
    required this.title,
    required this.price,
    required this.rating,
    required this.imageAsset,
  });

  final String id;
  final String title;
  final String price;
  final String rating;
  final String imageAsset;
}
