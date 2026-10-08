import 'package:get/get.dart';

import '../core/errors/api_exception.dart';
import '../services/api_client.dart';
import '../utils/product_mapper.dart';
import 'auth_controller.dart';
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
  final isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  final categories = const [
    FavoriteCategory(id: 'all', label: 'common_all'),
    FavoriteCategory(id: 'bouquets', label: 'fav_cat_bouquets'),
    FavoriteCategory(id: 'cake', label: 'fav_cat_cake'),
    FavoriteCategory(id: 'chocolate', label: 'fav_cat_chocolate'),
    FavoriteCategory(id: 'cherry', label: 'fav_cat_cherry'),
    FavoriteCategory(id: 'lavender', label: 'fav_cat_lavender'),
  ];

  ApiClient get _api => Get.find<ApiClient>();

  List<HomeProduct> get filteredItems => items.toList();

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  bool _requireAuth() => Get.find<AuthController>().requireAuth();

  Future<void> loadFavorites() async {
    if (!_requireAuth()) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final cat = selectedCategoryId.value;
      final data = await _api.getFavorites(
        category: cat == 'all' ? null : cat,
      );
      final mapped = mapHomeProductList(data['items']);
      items.assignAll(mapped);
      if (Get.isRegistered<HomeController>()) {
        final home = Get.find<HomeController>();
        home.favoriteIds
          ..clear()
          ..addAll(mapped.map((p) => p.id));
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      items.clear();
    } catch (_) {
      errorMessage.value = 'auth_error_generic'.tr;
      items.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectCategory(String id) async {
    selectedCategoryId.value = id;
    await loadFavorites();
  }

  Future<void> removeFavorite(String productId) async {
    if (!_requireAuth()) return;
    final id = int.tryParse(productId);
    if (id == null) return;
    final removed = items.firstWhereOrNull((p) => p.id == productId);
    items.removeWhere((p) => p.id == productId);
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().favoriteIds.remove(productId);
    }
    try {
      await _api.removeFavorite(id);
    } on ApiException catch (e) {
      if (removed != null) items.add(removed);
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().favoriteIds.add(productId);
      }
      Get.snackbar('common_app_name'.tr, e.message);
    } catch (_) {
      if (removed != null) items.add(removed);
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().favoriteIds.add(productId);
      }
    }
  }
}
