import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core/config/api_config.dart';
import '../core/errors/api_exception.dart';
import '../services/api_client.dart';
import '../utils/product_mapper.dart';
import 'auth_controller.dart';
import 'basket_controller.dart';
import 'home_controller.dart';

/// بيانات شارة ميزة تحت عنوان المنتج.
class ProductBadge {
  const ProductBadge({required this.label, required this.iconAsset});

  final String label;
  final String iconAsset;
}

/// تحكم شاشة تفاصيل المنتج.
class ProductDetailsController extends GetxController {
  final imageIndex = 0.obs;
  final isFavorite = false.obs;
  final isLoading = true.obs;
  late final PageController pageController;

  String productId = '';
  String title = '';
  String priceLabel = '';
  int priceValue = 0;
  double rating = 4.5;
  List<String> images = [];
  List<HomeProduct> similar = [];
  String description = '';
  String heightLabel = '';
  String widthLabel = '';
  List<String> careSteps = [];
  List<ProductBadge> badges = const [];

  ApiClient get _api => Get.find<ApiClient>();

  /// أيقونات الشارات المتاحة (تُختار من لوحة التحكم).
  static const _badgeIcons = {'truck', 'map', 'card', 'star', 'heart'};

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final args = Get.arguments;
    if (args is HomeProduct) {
      productId = args.id;
      title = args.title;
      priceLabel = args.priceLabel;
      rating = args.rating;
      images = [args.imageAsset];
      priceValue = _parsePrice(priceLabel);
      if (Get.isRegistered<HomeController>()) {
        isFavorite.value = Get.find<HomeController>().isFavorite(args.id);
      }
    } else if (args is Map && args['id'] != null) {
      productId = '${args['id']}';
    }
    await loadDetails();
  }

  Future<void> loadDetails() async {
    final id = int.tryParse(productId);
    if (id == null) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    try {
      final data = await _api.getProduct(id);
      title = (data['title'] ?? data['title_ar'] ?? title) as String;
      priceLabel = (data['price_label'] ?? priceLabel) as String;
      priceValue = (data['price'] as num?)?.toInt() ?? _parsePrice(priceLabel);
      rating = double.tryParse('${data['rating']}') ?? rating;
      description = (data['description_ar'] ?? description) as String;
      heightLabel = (data['height_label'] ?? heightLabel) as String? ?? '';
      widthLabel = (data['width_label'] ?? widthLabel) as String? ?? '';
      isFavorite.value = data['is_favorite'] as bool? ?? isFavorite.value;

      final imgs = (data['images'] as List? ?? [])
          .map((e) => ApiConfig.imageUrl('$e') ?? '$e')
          .where((e) => e.isNotEmpty)
          .toList();
      if (imgs.isNotEmpty) images = imgs;

      careSteps = (data['care_steps_ar'] as List? ?? [])
          .map((e) => '$e')
          .toList();
      badges = (data['badges'] as List? ?? []).whereType<Map>().map((e) {
        final label = '${e['label'] ?? ''}';
        final icon = '${e['icon'] ?? ''}';
        return ProductBadge(
          label: label,
          iconAsset: _badgeIcons.contains(icon)
              ? 'assets/icons/product/$icon.svg'
              : 'assets/icons/product/truck.svg',
        );
      }).toList();
      similar = mapHomeProductList(data['similar']);
    } on ApiException catch (_) {
      // keep bootstrap values
    } finally {
      isLoading.value = false;
    }
  }

  int _parsePrice(String label) {
    final digits = label.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  void onPageChanged(int index) => imageIndex.value = index;

  Future<void> toggleFavorite() async {
    if (!Get.find<AuthController>().isAuthenticated) {
      Get.toNamed('/login');
      return;
    }
    isFavorite.toggle();
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().toggleFavorite(productId);
      return;
    }
    final id = int.tryParse(productId);
    if (id == null) return;
    try {
      if (isFavorite.value) {
        await _api.addFavorite(id);
      } else {
        await _api.removeFavorite(id);
      }
    } catch (_) {
      isFavorite.toggle();
    }
  }

  Future<void> addToBasket() async {
    if (!Get.find<AuthController>().isAuthenticated) {
      Get.toNamed('/login');
      return;
    }
    final id = int.tryParse(productId);
    if (id == null) return;
    try {
      if (!Get.isRegistered<BasketController>()) {
        Get.put(BasketController());
      }
      await Get.find<BasketController>().addProductFromApi(id);
      Get.snackbar(
        'common_app_name'.tr,
        'product_snack_added'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (e) {
      Get.snackbar('common_app_name'.tr, e.message);
    }
  }

  /// يجلب نص المشاركة من `GET /products/{id}/share` وينسخه للحافظة.
  Future<void> shareProduct() async {
    final id = int.tryParse(productId);
    if (id == null) return;
    try {
      final data = await _api.getProductShare(id);
      final isAr = (Get.locale?.languageCode ?? 'ar') == 'ar';
      final message =
          (isAr ? data['message_ar'] : data['message_en']) ?? data['url'] ?? '';
      await Clipboard.setData(ClipboardData(text: '$message'));
      Get.snackbar(
        'common_app_name'.tr,
        'product_share_copied'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (e) {
      Get.snackbar('common_app_name'.tr, e.message);
    } catch (_) {
      Get.snackbar('common_app_name'.tr, 'auth_error_generic'.tr);
    }
  }

  void openSimilar(HomeProduct product) {
    Get.offNamed('/product-details', arguments: product);
  }

  void viewMoreSimilar() {
    Get.back();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
