import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/errors/api_exception.dart';
import '../services/api_client.dart';
import '../utils/product_mapper.dart';
import 'auth_controller.dart';
import 'home_controller.dart';

/// خيار داخل فلتر موسّع.
class CategoryOption {
  const CategoryOption({required this.id, required this.label});

  final String id;
  final String label;
}

/// فلتر تصنيفات قابل للطي.
class CategoryFilter {
  const CategoryFilter({
    required this.id,
    required this.title,
    this.options = const [],
  });

  final String id;
  final String title;
  final List<CategoryOption> options;
}

/// خيارات ترتيب نتائج البحث.
enum ResultsSort {
  newest,
  priceAsc,
  priceDesc,
  popular,
}

/// تحكم شاشات التصنيفات والبحث والنتائج.
class CategoriesController extends GetxController {
  static const _historyKey = 'search_history';

  final searchQuery = ''.obs;
  final expandedFilterId = RxnString();
  final selectedOptions = <String, String>{}.obs;
  final searchHistory = <String>[].obs;
  final resultsCount = 0.obs;
  final favoriteIds = <String>{}.obs;
  final sortBy = ResultsSort.newest.obs;
  final isGridView = true.obs;
  final results = <HomeProduct>[].obs;
  final isLoading = false.obs;

  final filters = const [
    CategoryFilter(
      id: 'person',
      title: 'filter_person',
      options: [
        CategoryOption(id: 'parents', label: 'أم / أب'),
        CategoryOption(id: 'sibling', label: 'أخ / أخت'),
        CategoryOption(id: 'spouse', label: 'زوج / زوجة'),
        CategoryOption(id: 'friends', label: 'أصدقاء'),
        CategoryOption(id: 'work', label: 'عمل'),
        CategoryOption(id: 'kids', label: 'opt_kids'),
        CategoryOption(id: 'grandparents', label: 'أجداد'),
        CategoryOption(id: 'other', label: 'شخص آخر'),
      ],
    ),
    CategoryFilter(
      id: 'occasion',
      title: 'filter_occasion',
      options: [
        CategoryOption(id: 'birthday', label: 'opt_birthday'),
        CategoryOption(id: 'wedding', label: 'opt_wedding'),
        CategoryOption(id: 'graduation', label: 'opt_graduation'),
        CategoryOption(id: 'thanks', label: 'opt_thanks'),
        CategoryOption(id: 'newborn', label: 'opt_newborn'),
        CategoryOption(id: 'other_occ', label: 'أخرى'),
      ],
    ),
    CategoryFilter(
      id: 'gift_type',
      title: 'filter_gift_type',
      options: [
        CategoryOption(id: 'flowers', label: 'opt_flowers'),
        CategoryOption(id: 'sweets', label: 'حلويات'),
        CategoryOption(id: 'perfume', label: 'opt_perfume'),
        CategoryOption(id: 'box', label: 'بوكسات'),
        CategoryOption(id: 'plants', label: 'opt_plants'),
        CategoryOption(id: 'custom', label: 'مخصص'),
      ],
    ),
    CategoryFilter(
      id: 'budget',
      title: 'filter_budget',
      options: [
        CategoryOption(id: 'b1', label: 'opt_budget_low'),
        CategoryOption(id: 'b2', label: 'opt_budget_mid'),
        CategoryOption(id: 'b3', label: 'opt_budget_high'),
        CategoryOption(id: 'b4', label: 'opt_budget_vip'),
      ],
    ),
    CategoryFilter(
      id: 'price',
      title: 'filter_price',
      options: [
        CategoryOption(id: 'asc', label: 'sort_price_asc'),
        CategoryOption(id: 'desc', label: 'sort_price_desc'),
      ],
    ),
    CategoryFilter(
      id: 'delivery',
      title: 'filter_delivery',
      options: [
        CategoryOption(id: 'same_day', label: 'opt_delivery_today'),
        CategoryOption(id: 'tomorrow', label: 'opt_delivery_tomorrow'),
        CategoryOption(id: 'pickup', label: 'opt_pickup'),
      ],
    ),
  ];

  ApiClient get _api => Get.find<ApiClient>();

  @override
  void onInit() {
    super.onInit();
    _loadHistory();
  }

  List<({String filterId, String label})> get activeFilterChips {
    final chips = <({String filterId, String label})>[];
    for (final filter in filters) {
      final label = selectedLabel(filter);
      if (label != null) {
        chips.add((
          filterId: filter.id,
          label: '${filter.title.tr}: ${label.tr}',
        ));
      }
    }
    return chips;
  }

  String get sortLabel {
    switch (sortBy.value) {
      case ResultsSort.newest:
        return 'sort_newest'.tr;
      case ResultsSort.priceAsc:
        return 'sort_price_asc'.tr;
      case ResultsSort.priceDesc:
        return 'sort_price_desc'.tr;
      case ResultsSort.popular:
        return 'sort_popular'.tr;
    }
  }

  String get _apiSort {
    final price = selectedOptions['price'];
    if (price == 'asc') return 'priceAsc';
    if (price == 'desc') return 'priceDesc';
    switch (sortBy.value) {
      case ResultsSort.newest:
        return 'newest';
      case ResultsSort.priceAsc:
        return 'priceAsc';
      case ResultsSort.priceDesc:
        return 'priceDesc';
      case ResultsSort.popular:
        return 'popular';
    }
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    searchHistory.assignAll(prefs.getStringList(_historyKey) ?? []);
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, searchHistory.toList());
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  Future<void> loadResults() async {
    isLoading.value = true;
    try {
      final data = await _api.getProducts(
        q: searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim(),
        person: selectedOptions['person'],
        occasion: selectedOptions['occasion'],
        giftType: selectedOptions['gift_type'],
        budget: selectedOptions['budget'],
        delivery: selectedOptions['delivery'],
        sort: _apiSort,
        pageSize: 40,
      );
      final mapped = mapHomeProductList(data['items']);
      results.assignAll(mapped);
      resultsCount.value = (data['total'] as num?)?.toInt() ?? mapped.length;
      favoriteIds
        ..clear()
        ..addAll(mapped.where((p) => p.isFavorite).map((p) => p.id));
    } on ApiException catch (e) {
      Get.snackbar('common_app_name'.tr, e.message);
    } catch (_) {
      Get.snackbar('common_app_name'.tr, 'auth_error_generic'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitSearch([String? raw]) async {
    final q = (raw ?? searchQuery.value).trim();
    if (q.isEmpty) return;
    searchQuery.value = q;
    searchHistory.remove(q);
    searchHistory.insert(0, q);
    if (searchHistory.length > 8) {
      searchHistory.removeRange(8, searchHistory.length);
    }
    await _saveHistory();
    await loadResults();
    Get.offNamed('/search-results');
  }

  Future<void> clearHistory() async {
    searchHistory.clear();
    await _saveHistory();
  }

  Future<void> removeHistoryItem(String item) async {
    searchHistory.remove(item);
    await _saveHistory();
  }

  void toggleFilter(String filterId) {
    if (expandedFilterId.value == filterId) {
      expandedFilterId.value = null;
    } else {
      expandedFilterId.value = filterId;
    }
  }

  void selectOption(String filterId, String optionId) {
    selectedOptions[filterId] = optionId;
    selectedOptions.refresh();
  }

  void clearFilter(String filterId) {
    selectedOptions.remove(filterId);
    selectedOptions.refresh();
  }

  void clearAllFilters() {
    selectedOptions.clear();
    selectedOptions.refresh();
  }

  String? selectedLabel(CategoryFilter filter) {
    final optionId = selectedOptions[filter.id];
    if (optionId == null) return null;
    for (final o in filter.options) {
      if (o.id == optionId) return o.label;
    }
    return null;
  }

  Future<void> setSort(ResultsSort value) async {
    sortBy.value = value;
    await loadResults();
  }

  void toggleGridView() {
    isGridView.value = !isGridView.value;
  }

  Future<void> toggleFavorite(String productId) async {
    if (!Get.find<AuthController>().requireAuth()) return;
    final id = int.tryParse(productId);
    if (id == null) return;
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
      if (Get.isRegistered<HomeController>()) {
        final home = Get.find<HomeController>();
        if (wasFav) {
          home.favoriteIds.remove(productId);
        } else {
          home.favoriteIds.add(productId);
        }
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

  Future<void> showResults() async {
    await loadResults();
    openResults();
  }

  void openSearch() => Get.toNamed('/search');

  void openResults() {
    if (Get.currentRoute == '/search-results') return;
    Get.toNamed('/search-results');
  }

  void openFilterSort() => Get.toNamed('/filter-sort');

  Future<void> applyFiltersFromSheet() async {
    await loadResults();
    if (Get.previousRoute == '/search-results') {
      Get.back();
    } else {
      Get.offNamed('/search-results');
    }
  }
}
