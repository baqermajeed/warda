import 'package:get/get.dart';

import '../core/config/api_config.dart';
import '../core/errors/api_exception.dart';
import '../services/api_client.dart';
import 'auth_controller.dart';

/// عنصر داخل السلة.
class BasketItem {
  BasketItem({
    required this.id,
    required this.code,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.unitPrice,
    this.qty = 1,
    this.productId,
  });

  final String id;
  final String code;
  final String title;
  final String subtitle;
  final String imageAsset;
  final int unitPrice;
  int qty;
  final int? productId;

  int get lineTotal => unitPrice * qty;
}

/// خيار تغليف / إضافة / بطاقة.
class BasketOption {
  const BasketOption({
    required this.id,
    required this.title,
    required this.price,
    required this.imageAsset,
    this.category = 'all',
  });

  final String id;
  final String title;
  final int price;
  final String imageAsset;
  final String category;
}

/// تحكم شاشات السلة والمتفرعات.
class BasketController extends GetxController {
  final items = <BasketItem>[].obs;
  final isLoading = false.obs;
  final priceExpanded = false.obs;
  final selectedCardId = ''.obs;
  final selectedWrapId = RxnString();
  final selectedAddonIds = <String>{}.obs;
  final addonCategoryId = 'all'.obs;

  final giftFrom = ''.obs;
  final giftTo = ''.obs;
  final giftMessage = ''.obs;
  static const messageMax = 150;

  final giftCards = <BasketOption>[].obs;
  final wraps = <BasketOption>[].obs;
  final addons = <BasketOption>[].obs;

  final _orderSubtotal = 0.obs;
  final _wrapPrice = 0.obs;
  final _addonsPrice = 0.obs;
  final _cardPrice = 0.obs;
  final _deliveryPrice = 0.obs;
  final _totalPrice = 0.obs;
  final _hasFreeDelivery = false.obs;

  int get orderSubtotal => _orderSubtotal.value;
  int get wrapPrice => _wrapPrice.value;
  int get addonsPrice => _addonsPrice.value;
  int get cardPrice => _cardPrice.value;
  int get deliveryPrice => _deliveryPrice.value;
  int get totalPrice => _totalPrice.value;
  bool get hasFreeDelivery => _hasFreeDelivery.value;

  final addonCategories = const [
    ('all', 'common_all'),
    ('candles', 'شموع'),
    ('chocolate', 'opt_chocolate'),
    ('party', 'للأحتفال'),
    ('balloons', 'بالونات'),
    ('lavender', 'fav_cat_lavender'),
  ];

  ApiClient get _api => Get.find<ApiClient>();

  @override
  void onInit() {
    super.onInit();
    loadCart();
    loadCatalogOptions();
  }

  bool _requireAuth() {
    if (!Get.find<AuthController>().isAuthenticated) {
      Get.toNamed('/login');
      return false;
    }
    return true;
  }

  BasketOption _mapOption(Map<String, dynamic> m) {
    final image = m['image'] as String? ?? '';
    return BasketOption(
      id: '${m['id']}',
      title: (m['title_ar'] ?? m['title'] ?? '') as String,
      price: (m['price'] as num?)?.toInt() ?? 0,
      imageAsset: ApiConfig.imageUrl(image) ??
          (image.isEmpty ? 'assets/images/basket/cart_item.jpg' : image),
      category: (m['category'] as String?) ?? 'all',
    );
  }

  void _applyCart(Map<String, dynamic> data) {
    final mappedItems = (data['items'] as List? ?? [])
        .whereType<Map>()
        .map((e) {
          final m = Map<String, dynamic>.from(e);
          final image = m['image'] as String? ?? '';
          final productId = (m['product_id'] as num?)?.toInt();
          return BasketItem(
            id: '${m['id']}',
            code: productId != null ? '#$productId' : '#${m['id']}',
            title: (m['title_ar'] ?? m['title'] ?? '') as String,
            subtitle: '',
            imageAsset: ApiConfig.imageUrl(image) ??
                (image.isEmpty
                    ? 'assets/images/basket/cart_item.jpg'
                    : image),
            unitPrice: (m['unit_price'] as num?)?.toInt() ?? 0,
            qty: (m['qty'] as num?)?.toInt() ?? 1,
            productId: productId,
          );
        })
        .toList();
    items.assignAll(mappedItems);

    final giftCard = data['gift_card'];
    if (giftCard is Map) {
      selectedCardId.value = '${giftCard['id']}';
    } else {
      selectedCardId.value = '';
    }

    final wrap = data['wrap'];
    if (wrap is Map) {
      selectedWrapId.value = '${wrap['id']}';
    } else {
      selectedWrapId.value = null;
    }

    final addonList = (data['addons'] as List? ?? [])
        .whereType<Map>()
        .map((e) => '${e['id']}')
        .toSet();
    selectedAddonIds
      ..clear()
      ..addAll(addonList);

    giftFrom.value = (data['gift_from'] as String?) ?? '';
    giftTo.value = (data['gift_to'] as String?) ?? '';
    giftMessage.value = (data['gift_message'] as String?) ?? '';

    final pricing = data['pricing'];
    if (pricing is Map) {
      _orderSubtotal.value = (pricing['subtotal'] as num?)?.toInt() ?? 0;
      _wrapPrice.value = (pricing['wrap_price'] as num?)?.toInt() ?? 0;
      _addonsPrice.value = (pricing['addons_price'] as num?)?.toInt() ?? 0;
      _cardPrice.value = (pricing['card_price'] as num?)?.toInt() ?? 0;
      _deliveryPrice.value = (pricing['delivery_price'] as num?)?.toInt() ?? 0;
      _totalPrice.value = (pricing['total'] as num?)?.toInt() ?? 0;
      _hasFreeDelivery.value = pricing['has_free_delivery'] as bool? ?? false;
    } else {
      _recalcLocal();
    }
  }

  void _recalcLocal() {
    _orderSubtotal.value = items.fold(0, (s, i) => s + i.lineTotal);
    final wrapId = selectedWrapId.value;
    _wrapPrice.value = wrapId == null
        ? 0
        : wraps.firstWhereOrNull((w) => w.id == wrapId)?.price ?? 0;
    _addonsPrice.value = selectedAddonIds.fold(0, (s, id) {
      final o = addons.firstWhereOrNull((a) => a.id == id);
      return s + (o?.price ?? 0);
    });
    final cardId = selectedCardId.value;
    _cardPrice.value = cardId.isEmpty
        ? 0
        : giftCards.firstWhereOrNull((c) => c.id == cardId)?.price ?? 0;
    _hasFreeDelivery.value = _orderSubtotal.value >= 100000;
    _deliveryPrice.value = _hasFreeDelivery.value ? 0 : 5000;
    _totalPrice.value = _orderSubtotal.value +
        _wrapPrice.value +
        _addonsPrice.value +
        _cardPrice.value +
        _deliveryPrice.value;
  }

  Future<void> loadCart() async {
    if (!_requireAuth()) return;
    isLoading.value = true;
    try {
      final data = await _api.getCart();
      _applyCart(data);
    } on ApiException catch (e) {
      Get.snackbar('common_app_name'.tr, e.message);
    } catch (_) {
      Get.snackbar('common_app_name'.tr, 'auth_error_generic'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCatalogOptions() async {
    try {
      final cards = await _api.getGiftCards();
      giftCards.assignAll(
        cards
            .whereType<Map>()
            .map((e) => _mapOption(Map<String, dynamic>.from(e))),
      );
      final wrapRows = await _api.getWraps();
      wraps.assignAll(
        wrapRows
            .whereType<Map>()
            .map((e) => _mapOption(Map<String, dynamic>.from(e))),
      );
      final addonRows = await _api.getAddons();
      addons.assignAll(
        addonRows
            .whereType<Map>()
            .map((e) => _mapOption(Map<String, dynamic>.from(e))),
      );
    } catch (_) {
      // keep empty option lists
    }
  }

  Future<void> addProductFromApi(int productId) async {
    if (!_requireAuth()) return;
    final data = await _api.addCartItem(productId: productId);
    _applyCart(data);
  }

  Future<void> persistOptions() async {
    if (!_requireAuth()) return;
    try {
      final data = await _api.updateCartOptions({
        'gift_card_id': int.tryParse(selectedCardId.value),
        'wrap_id': selectedWrapId.value == null
            ? null
            : int.tryParse(selectedWrapId.value!),
        'addon_ids': selectedAddonIds
            .map(int.tryParse)
            .whereType<int>()
            .toList(),
        'gift_from': giftFrom.value,
        'gift_to': giftTo.value,
        'gift_message': giftMessage.value,
      });
      _applyCart(data);
    } on ApiException catch (e) {
      Get.snackbar('common_app_name'.tr, e.message);
    }
  }

  String get wrapLabel {
    final id = selectedWrapId.value;
    if (id == null) return 'common_not_set'.tr;
    final wrap = wraps.firstWhereOrNull((w) => w.id == id);
    if (wrap == null) return 'common_not_set'.tr;
    return wrap.title.tr;
  }

  String money(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    return '${buf.toString()} ${'common_currency_iqd'.tr}';
  }

  void togglePriceDetails() => priceExpanded.toggle();

  Future<void> clearCart() async {
    if (!_requireAuth()) return;
    try {
      await _api.clearCart();
      items.clear();
      selectedCardId.value = '';
      selectedWrapId.value = null;
      selectedAddonIds.clear();
      giftFrom.value = '';
      giftTo.value = '';
      giftMessage.value = '';
      _recalcLocal();
    } on ApiException catch (e) {
      Get.snackbar('common_app_name'.tr, e.message);
    }
  }

  Future<void> incrementQty(String id) async {
    if (!_requireAuth()) return;
    final i = items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    final itemId = int.tryParse(id);
    if (itemId == null) return;
    final next = items[i].qty + 1;
    try {
      final data = await _api.updateCartItem(itemId: itemId, qty: next);
      _applyCart(data);
    } on ApiException catch (e) {
      Get.snackbar('common_app_name'.tr, e.message);
    }
  }

  Future<void> decrementQty(String id) async {
    if (!_requireAuth()) return;
    final i = items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    final itemId = int.tryParse(id);
    if (itemId == null) return;
    final next = items[i].qty - 1;
    try {
      if (next <= 0) {
        final data = await _api.deleteCartItem(itemId);
        _applyCart(data);
      } else {
        final data = await _api.updateCartItem(itemId: itemId, qty: next);
        _applyCart(data);
      }
    } on ApiException catch (e) {
      Get.snackbar('common_app_name'.tr, e.message);
    }
  }

  Future<void> selectCard(String id) async {
    selectedCardId.value = id;
    await persistOptions();
  }

  Future<void> selectWrap(String id) async {
    if (selectedWrapId.value == id) {
      selectedWrapId.value = null;
    } else {
      selectedWrapId.value = id;
    }
    await persistOptions();
  }

  Future<void> toggleAddon(String id) async {
    if (selectedAddonIds.contains(id)) {
      selectedAddonIds.remove(id);
    } else {
      selectedAddonIds.add(id);
    }
    await persistOptions();
  }

  void setAddonCategory(String id) => addonCategoryId.value = id;

  List<BasketOption> get filteredAddons {
    final cat = addonCategoryId.value;
    if (cat == 'all') return addons.toList();
    return addons.where((a) => a.category == cat).toList();
  }

  int get messageRemaining =>
      (messageMax - giftMessage.value.length).clamp(0, messageMax);

  void openGiftCard() => Get.toNamed('/basket/gift-card');
  void openWrapping() => Get.toNamed('/basket/wrapping');
  void openAddons() => Get.toNamed('/basket/addons');

  void completeOrder() => Get.toNamed('/order/user-info');
}
