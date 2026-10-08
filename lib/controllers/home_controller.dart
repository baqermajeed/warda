import 'package:get/get.dart';

import '../core/config/api_config.dart';
import '../core/errors/api_exception.dart';
import '../services/api_client.dart';
import '../utils/product_mapper.dart';
import 'auth_controller.dart';

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
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  final RxList<HomeCategory> categories = <HomeCategory>[].obs;
  final RxList<HomeProduct> latestGifts = <HomeProduct>[].obs;
  final RxList<HomeProduct> popularGifts = <HomeProduct>[].obs;
  final RxList<HomeProduct> allGifts = <HomeProduct>[].obs;
  final RxList<String> bannerImages = <String>[].obs;

  ApiClient get _api => Get.find<ApiClient>();

  @override
  void onInit() {
    super.onInit();
    loadHome();
  }

  Future<void> loadHome() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final data = await _api.getHome();
      final cats = (data['categories'] as List? ?? [])
          .whereType<Map>()
          .map((e) {
            final m = Map<String, dynamic>.from(e);
            final image = m['image'] as String?;
            return HomeCategory(
              id: '${m['id']}',
              title: (m['name_ar'] ?? m['slug'] ?? '') as String,
              imageAsset: ApiConfig.imageUrl(image) ?? image,
            );
          })
          .toList();
      categories.assignAll(
        cats.isEmpty
            ? const [
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
              ]
            : cats,
      );

      latestGifts.assignAll(mapHomeProductList(data['latest']));
      popularGifts.assignAll(mapHomeProductList(data['popular']));
      allGifts.assignAll(mapHomeProductList(data['all_gifts']));
      bannerImages.assignAll(
        (data['banners'] as List? ?? [])
            .whereType<Map>()
            .map((e) => ApiConfig.imageUrl('${e['image']}') ?? '${e['image']}')
            .where((e) => e.isNotEmpty)
            .toList(),
      );

      favoriteIds
        ..clear()
        ..addAll([
          ...latestGifts,
          ...popularGifts,
          ...allGifts,
        ].where((p) => p.isFavorite).map((p) => p.id));
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'auth_error_generic'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  void setBannerIndex(int index) => bannerIndex.value = index;

  Future<void> toggleFavorite(String productId) async {
    final id = int.tryParse(productId);
    if (id == null) return;
    if (!Get.find<AuthController>().requireAuth()) return;
    final wasFav = favoriteIds.contains(productId);
    if (wasFav) {
      favoriteIds.remove(productId);
    } else {
      favoriteIds.add(productId);
    }
    try {
      if (wasFav) {
        await _api.removeFavorite(id);
      } else {
        await _api.addFavorite(id);
      }
    } catch (_) {
      if (wasFav) {
        favoriteIds.add(productId);
      } else {
        favoriteIds.remove(productId);
      }
    }
  }

  bool isFavorite(String productId) => favoriteIds.contains(productId);
}
