import 'package:get/get.dart';

/// عنصر تصنيف في الصفحة الرئيسية.
class HomeCategory {
  const HomeCategory({
    required this.id,
    required this.title,
    this.imageAsset,
  });

  final String id;
  final String title;
  final String? imageAsset;
}

/// منتج معروض في الصفحة الرئيسية.
class HomeProduct {
  const HomeProduct({
    required this.id,
    required this.title,
    required this.priceLabel,
    required this.imageAsset,
    this.rating = 4.5,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String priceLabel;
  final String imageAsset;
  final double rating;
  final bool isFavorite;
}

/// تحكم الصفحة الرئيسية.
class HomeController extends GetxController {
  final RxString locationLabel = 'home_location_sample'.obs;
  final RxInt bannerIndex = 0.obs;
  final RxSet<String> favoriteIds = <String>{}.obs;

  final categories = const [
    HomeCategory(
      id: 'person',
      title: 'home_cat_person',
      imageAsset: 'assets/images/home/cat_person.png',
    ),
    HomeCategory(
      id: 'occasion',
      title: 'home_cat_occasion',
      imageAsset: 'assets/images/home/cat_occasion.png',
    ),
    HomeCategory(
      id: 'gift_type',
      title: 'home_cat_gift_type',
      imageAsset: 'assets/images/home/cat_gift.png',
    ),
    HomeCategory(id: 'delivery', title: 'home_cat_delivery'),
    HomeCategory(id: 'more', title: 'home_cat_more'),
  ];

  late final List<HomeProduct> latestGifts;
  late final List<HomeProduct> popularGifts;
  late final List<HomeProduct> allGifts;

  @override
  void onInit() {
    super.onInit();
    const title = 'mock_orchid_bouquet';
    const price = '10,000';
    latestGifts = const [
      HomeProduct(
        id: 'l1',
        title: title,
        priceLabel: price,
        imageAsset: 'assets/images/home/product_1.png',
        isFavorite: true,
      ),
      HomeProduct(
        id: 'l2',
        title: title,
        priceLabel: price,
        imageAsset: 'assets/images/home/product_2.png',
      ),
      HomeProduct(
        id: 'l3',
        title: title,
        priceLabel: price,
        imageAsset: 'assets/images/home/product_3.png',
      ),
      HomeProduct(
        id: 'l4',
        title: title,
        priceLabel: price,
        imageAsset: 'assets/images/home/product_4.png',
      ),
    ];
    popularGifts = const [
      HomeProduct(
        id: 'p1',
        title: title,
        priceLabel: price,
        imageAsset: 'assets/images/home/product_4.png',
      ),
      HomeProduct(
        id: 'p2',
        title: title,
        priceLabel: price,
        imageAsset: 'assets/images/home/product_2.png',
        isFavorite: true,
      ),
      HomeProduct(
        id: 'p3',
        title: title,
        priceLabel: price,
        imageAsset: 'assets/images/home/product_1.png',
      ),
      HomeProduct(
        id: 'p4',
        title: title,
        priceLabel: price,
        imageAsset: 'assets/images/home/product_3.png',
      ),
    ];
    allGifts = const [
      HomeProduct(
        id: 'a1',
        title: title,
        priceLabel: price,
        imageAsset: 'assets/images/home/product_5.png',
      ),
      HomeProduct(
        id: 'a2',
        title: title,
        priceLabel: price,
        imageAsset: 'assets/images/home/product_6.png',
        isFavorite: true,
      ),
      HomeProduct(
        id: 'a3',
        title: title,
        priceLabel: price,
        imageAsset: 'assets/images/home/product_7.png',
      ),
      HomeProduct(
        id: 'a4',
        title: title,
        priceLabel: price,
        imageAsset: 'assets/images/home/product_8.png',
      ),
    ];

    for (final p in [...latestGifts, ...popularGifts, ...allGifts]) {
      if (p.isFavorite) favoriteIds.add(p.id);
    }
  }

  void setBannerIndex(int index) => bannerIndex.value = index;

  void toggleFavorite(String productId) {
    if (favoriteIds.contains(productId)) {
      favoriteIds.remove(productId);
    } else {
      favoriteIds.add(productId);
    }
  }

  bool isFavorite(String productId) => favoriteIds.contains(productId);
}
