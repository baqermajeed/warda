import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  late final PageController pageController;

  late String productId;
  late String title;
  late String priceLabel;
  late int priceValue;
  late double rating;
  late List<String> images;
  late List<HomeProduct> similar;

  final description =
      'باقة رائعة من التوليب والأقحوان، تنبض بالحب والجمال. الألوان الزاهية للتوليب تضفي لمسة من الأناقة، بينما تضيف الأقحوان لمسة من العفوية والبهجة. إنها تعبير مثالي عن المشاعر الدافئة، وتناسب كل المناسبات الخاصة.';

  final heightLabel = '10.5cm';
  final widthLabel = '17.5cm';

  final careSteps = const [
    'ضع الباقة في ماء نظيف وعذب، مع تغيير الماء كل يومين.',
    'قص أطراف السيقان بزاوية مائلة لتحسين امتصاص الماء',
    'ابعد الباقة عن أشعة الشمس المباشرة والحرارة العالية',
    'أضف مغذيات الزهور إلى الماء لتعزيز عمرها',
    'قم بإزالة الأوراق الذابلة بانتظام للحفاظ على مظهرها',
  ];

  final badges = const [
    ProductBadge(
      label: 'product_badge_natural',
      iconAsset: 'assets/icons/product/truck.svg',
    ),
    ProductBadge(
      label: 'product_badge_free_delivery',
      iconAsset: 'assets/icons/product/map.svg',
    ),
    ProductBadge(
      label: 'product_badge_mastercard',
      iconAsset: 'assets/icons/product/card.svg',
    ),
    ProductBadge(
      label: 'product_badge_fast',
      iconAsset: 'assets/icons/product/truck.svg',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    _loadFromArgs();
  }

  void _loadFromArgs() {
    final args = Get.arguments;
    if (args is HomeProduct) {
      productId = args.id;
      title = args.title;
      priceLabel = args.priceLabel;
      rating = args.rating;
      images = [
        args.imageAsset,
        'assets/images/product/hero.jpg',
        'assets/images/product/hero_3.jpg',
      ];
      if (Get.isRegistered<HomeController>()) {
        isFavorite.value = Get.find<HomeController>().isFavorite(args.id);
      }
    } else {
      productId = 'pd1';
      title = 'mock_tulip_daisy';
      priceLabel = '126,000';
      rating = 4.5;
      images = [
        'assets/images/product/hero.jpg',
        'assets/images/product/hero_2.jpg',
        'assets/images/product/hero_3.jpg',
      ];
    }
    priceValue = _parsePrice(priceLabel);
    similar = [
      const HomeProduct(
        id: 's1',
        title: 'mock_orchid_bouquet',
        priceLabel: '10,000',
        imageAsset: 'assets/images/product/similar_1.jpg',
      ),
      const HomeProduct(
        id: 's2',
        title: 'mock_orchid_bouquet',
        priceLabel: '10,000',
        imageAsset: 'assets/images/product/similar_2.jpg',
      ),
      const HomeProduct(
        id: 's3',
        title: 'mock_orchid_bouquet',
        priceLabel: '10,000',
        imageAsset: 'assets/images/product/similar_3.jpg',
      ),
      const HomeProduct(
        id: 's4',
        title: 'mock_orchid_bouquet',
        priceLabel: '10,000',
        imageAsset: 'assets/images/product/similar_4.jpg',
      ),
    ];
  }

  int _parsePrice(String label) {
    final digits = label.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 126000;
  }

  void onPageChanged(int index) => imageIndex.value = index;

  void toggleFavorite() {
    isFavorite.toggle();
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().toggleFavorite(productId);
    }
  }

  void addToBasket() {
    if (!Get.isRegistered<BasketController>()) {
      Get.put(BasketController());
    }
    final basket = Get.find<BasketController>();
    final existing = basket.items.indexWhere((e) => e.id == productId);
    if (existing >= 0) {
      basket.incrementQty(productId);
    } else {
      basket.items.add(
        BasketItem(
          id: productId,
          code: '#${productId.toUpperCase()}',
          title: title,
          subtitle: 'من تفاصيل المنتج',
          imageAsset: images.first,
          unitPrice: priceValue,
          qty: 1,
        ),
      );
    }
    Get.snackbar(
      'common_app_name'.tr,
      'product_snack_added'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void shareProduct() {
    Get.snackbar(
      'common_app_name'.tr,
      'product_snack_share_soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openSimilar(HomeProduct product) {
    Get.offNamed('/product-details', arguments: product);
  }

  void viewMoreSimilar() {
    Get.snackbar(
      'common_app_name'.tr,
      'product_snack_more_soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
