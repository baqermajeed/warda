import 'package:get/get.dart';

import 'home_controller.dart';

/// تصنيف فلتر في شاشة المفضلة.
class FavoriteCategory {
  const FavoriteCategory({required this.id, required this.label});

  final String id;
  final String label;
}

/// تحكم شاشة المفضلة — حسب تصميم Figma.
class FavoritesController extends GetxController {
  final selectedCategoryId = 'all'.obs;
  final items = <HomeProduct>[].obs;

  final categories = const [
    FavoriteCategory(id: 'all', label: 'common_all'),
    FavoriteCategory(id: 'bouquets', label: 'fav_cat_bouquets'),
    FavoriteCategory(id: 'cake', label: 'fav_cat_cake'),
    FavoriteCategory(id: 'chocolate', label: 'fav_cat_chocolate'),
    FavoriteCategory(id: 'cherry', label: 'fav_cat_cherry'),
    FavoriteCategory(id: 'lavender', label: 'fav_cat_lavender'),
  ];

  late final List<HomeProduct> _catalog;
  late final Map<String, String> _productCategories;

  @override
  void onInit() {
    super.onInit();
    const title = 'mock_orchid_bouquet';
    const price = '10,000';
    _catalog = const [
      HomeProduct(
        id: 'f1',
        title: title,
        priceLabel: price,
        imageAsset: 'assets/images/home/product_1.png',
        isFavorite: true,
      ),
      HomeProduct(
        id: 'f2',
        title: title,
        priceLabel: price,
        imageAsset: 'assets/images/home/product_2.png',
        isFavorite: true,
      ),
      HomeProduct(
        id: 'f3',
        title: title,
        priceLabel: price,
        imageAsset: 'assets/images/home/product_3.png',
        isFavorite: true,
      ),
      HomeProduct(
        id: 'f4',
        title: title,
        priceLabel: price,
        imageAsset: 'assets/images/home/product_4.png',
        isFavorite: true,
      ),
      HomeProduct(
        id: 'f5',
        title: title,
        priceLabel: price,
        imageAsset: 'assets/images/home/product_5.png',
        isFavorite: true,
      ),
      HomeProduct(
        id: 'f6',
        title: title,
        priceLabel: price,
        imageAsset: 'assets/images/home/product_6.png',
        isFavorite: true,
      ),
    ];
    _productCategories = {
      'f1': 'bouquets',
      'f2': 'bouquets',
      'f3': 'cake',
      'f4': 'chocolate',
      'f5': 'cherry',
      'f6': 'lavender',
      'l1': 'bouquets',
      'p2': 'bouquets',
      'a2': 'chocolate',
    };
    _loadItems();
  }

  void _loadItems() {
    if (Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      final catalog = [
        ...home.latestGifts,
        ...home.popularGifts,
        ...home.allGifts,
      ];
      final byId = {for (final p in catalog) p.id: p};
      final favs = <HomeProduct>[];
      for (final id in home.favoriteIds) {
        final p = byId[id];
        if (p != null) favs.add(p);
      }
      if (favs.isNotEmpty) {
        items.assignAll(favs);
        return;
      }
    }
    items.assignAll(_catalog);
  }

  List<HomeProduct> get filteredItems {
    final cat = selectedCategoryId.value;
    if (cat == 'all') return items.toList();
    return items
        .where((p) => (_productCategories[p.id] ?? 'bouquets') == cat)
        .toList();
  }

  void selectCategory(String id) {
    selectedCategoryId.value = id;
  }

  void removeFavorite(String productId) {
    items.removeWhere((p) => p.id == productId);
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().favoriteIds.remove(productId);
    }
  }
}
