import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/config/api_config.dart';
import '../core/errors/api_exception.dart';
import '../services/api_client.dart';
import '../services/lookups_service.dart';
import '../utils/app_links.dart';
import '../utils/product_mapper.dart';
import 'auth_controller.dart';
import 'categories_controller.dart';
import 'main_shell_controller.dart';
import 'notifications_controller.dart';

/// عنصر تصنيف في الصفحة الرئيسية.
class HomeCategory {
  const HomeCategory({
    required this.id,
    required this.title,
    this.imageAsset,
    this.slug,
  });

  final String id;
  final String title;
  final String? imageAsset;

  /// معرّف نصي من الـ API (`person`, `occasion`, `gift_type`, `flowers`...).
  final String? slug;
}

/// بانر الصفحة الرئيسية من `GET /home`.
class HomeBanner {
  const HomeBanner({required this.image, this.link});

  final String image;

  /// رابط داخلي (انظر `openAppLink`).
  final String? link;
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
  final RxList<HomeBanner> banners = <HomeBanner>[].obs;

  ApiClient get _api => Get.find<ApiClient>();
  AuthController get _auth => Get.find<AuthController>();

  /// صور محلية للتصنيفات التي لا تملك صورة في الـ API.
  static const _categoryAssets = {
    'person': 'assets/images/home/cat_person.png',
    'occasion': 'assets/images/home/cat_occasion.png',
    'gift_type': 'assets/images/home/cat_gift.png',
  };

  @override
  void onInit() {
    super.onInit();
    _syncLocation();
    ever(_auth.user, (_) => _syncLocation());
    loadHome();
  }

  /// يعرض محافظة المستخدم (من الـ API) بدل النص التجريبي.
  void _syncLocation() {
    final gov = _auth.user.value?.governorate;
    locationLabel.value =
        (gov == null || gov.isEmpty) ? 'home_location_sample' : gov;
  }

  Future<void> loadHome() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final data = await _api.getHome();
      final cats = (data['categories'] as List? ?? []).whereType<Map>().map((
        e,
      ) {
        final m = Map<String, dynamic>.from(e);
        final image = m['image'] as String?;
        final slug = m['slug'] as String?;
        final isAr = (Get.locale?.languageCode ?? 'ar') == 'ar';
        return HomeCategory(
          id: '${m['id']}',
          slug: slug,
          title: ((isAr ? m['name_ar'] : m['name_en']) ??
              m['name_ar'] ??
              slug ??
              '') as String,
          imageAsset: ApiConfig.imageUrl(image) ?? _categoryAssets[slug],
        );
      }).toList();
      categories.assignAll(
        cats.isEmpty
            ? const [
                HomeCategory(
                  id: 'person',
                  slug: 'person',
                  title: 'home_cat_person',
                  imageAsset: 'assets/images/home/cat_person.png',
                ),
                HomeCategory(
                  id: 'occasion',
                  slug: 'occasion',
                  title: 'home_cat_occasion',
                  imageAsset: 'assets/images/home/cat_occasion.png',
                ),
                HomeCategory(
                  id: 'gift_type',
                  slug: 'gift_type',
                  title: 'home_cat_gift_type',
                  imageAsset: 'assets/images/home/cat_gift.png',
                ),
              ]
            : cats,
      );

      latestGifts.assignAll(mapHomeProductList(data['latest']));
      popularGifts.assignAll(mapHomeProductList(data['popular']));
      allGifts.assignAll(mapHomeProductList(data['all_gifts']));
      banners.assignAll(
        (data['banners'] as List? ?? [])
            .whereType<Map>()
            .where((e) => '${e['image'] ?? ''}'.isNotEmpty)
            .map(
              (e) => HomeBanner(
                image: ApiConfig.imageUrl('${e['image']}') ?? '${e['image']}',
                link: e['link'] as String?,
              ),
            )
            .toList(),
      );
      bannerImages.assignAll(banners.map((b) => b.image));
      if (bannerIndex.value >= banners.length) bannerIndex.value = 0;

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

  /// زر «استكشف» على البانر: يفتح رابط البانر الحالي أو تبويب التصنيفات.
  Future<void> exploreBanner() async {
    final index = bannerIndex.value;
    final link = index < banners.length ? banners[index].link : null;
    if (link != null && link.isNotEmpty) {
      await openAppLink(link);
      return;
    }
    if (Get.isRegistered<MainShellController>()) {
      Get.find<MainShellController>().changeTab(1);
    }
  }

  Future<void> openCategory(HomeCategory category) async {
    if (!Get.isRegistered<CategoriesController>()) {
      Get.lazyPut<CategoriesController>(
        () => CategoriesController(),
        fenix: true,
      );
    }
    await Get.find<CategoriesController>().openHomeCategory(
      slug: category.slug ?? category.id,
      id: int.tryParse(category.id),
      title: category.title,
    );
  }

  void openNotifications() {
    if (!Get.isRegistered<NotificationsController>()) {
      Get.lazyPut<NotificationsController>(
        () => NotificationsController(),
        fenix: true,
      );
    }
    Get.find<NotificationsController>().open();
  }

  /// اختيار المحافظة من شريط الموقع وحفظها في الملف الشخصي.
  Future<void> pickLocation() async {
    if (!_auth.isAuthenticated) {
      Get.toNamed('/login');
      return;
    }
    final governorates = LookupsService.to.governorates;
    final selected = await Get.bottomSheet<String>(
      SafeArea(
        child: Container(
          constraints: BoxConstraints(maxHeight: Get.height * 0.6),
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: governorates.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = governorates[index];
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
    if (selected == null) return;
    final previous = locationLabel.value;
    locationLabel.value = selected;
    try {
      _auth.user.value = await _api.updateProfile({'governorate': selected});
    } on ApiException catch (e) {
      locationLabel.value = previous;
      Get.snackbar('common_app_name'.tr, e.message);
    } catch (_) {
      locationLabel.value = previous;
      Get.snackbar('common_app_name'.tr, 'auth_error_generic'.tr);
    }
  }

  Future<void> toggleFavorite(String productId) async {
    final id = int.tryParse(productId);
    if (id == null) return;
    if (!Get.find<AuthController>().isAuthenticated) {
      Get.toNamed('/login');
      return;
    }
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
