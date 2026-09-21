import 'package:get/get.dart';

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
  });

  final String id;
  final String code;
  final String title;
  final String subtitle;
  final String imageAsset;
  final int unitPrice;
  int qty;

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
  final priceExpanded = false.obs;
  final selectedCardId = 'card_wedding'.obs;
  final selectedWrapId = RxnString('wrap_2');
  final selectedAddonIds = <String>{'a1', 'a2', 'a4'}.obs;
  final addonCategoryId = 'all'.obs;

  final giftFrom = ''.obs;
  final giftTo = ''.obs;
  final giftMessage = ''.obs;
  static const messageMax = 150;

  final giftCards = const [
    BasketOption(
      id: 'card_wedding',
      title: 'مبارك الزواج',
      price: 2000,
      imageAsset: 'assets/images/basket/card_1.jpg',
    ),
    BasketOption(
      id: 'card_grad',
      title: 'مبارك التخرج',
      price: 2000,
      imageAsset: 'assets/images/basket/card_3.jpg',
    ),
    BasketOption(
      id: 'card_bday',
      title: 'ميلاد سعيد',
      price: 2000,
      imageAsset: 'assets/images/basket/card_2.jpg',
    ),
    BasketOption(
      id: 'card_grad2',
      title: 'مبروك التخرج',
      price: 2000,
      imageAsset: 'assets/images/basket/card_3.jpg',
    ),
  ];

  final wraps = const [
    BasketOption(
      id: 'wrap_1',
      title: 'ورق كلاسيكي فاخر',
      price: 10000,
      imageAsset: 'assets/images/basket/wrap_1.jpg',
    ),
    BasketOption(
      id: 'wrap_2',
      title: 'ورق كلاسيكي فاخر',
      price: 10000,
      imageAsset: 'assets/images/basket/wrap_2.jpg',
    ),
    BasketOption(
      id: 'wrap_3',
      title: 'ورق كلاسيكي فاخر',
      price: 10000,
      imageAsset: 'assets/images/basket/wrap_3.jpg',
    ),
    BasketOption(
      id: 'wrap_4',
      title: 'ورق كلاسيكي فاخر',
      price: 10000,
      imageAsset: 'assets/images/basket/wrap_4.jpg',
    ),
    BasketOption(
      id: 'wrap_5',
      title: 'ورق كلاسيكي فاخر',
      price: 10000,
      imageAsset: 'assets/images/basket/wrap_1.jpg',
    ),
    BasketOption(
      id: 'wrap_6',
      title: 'ورق كلاسيكي فاخر',
      price: 10000,
      imageAsset: 'assets/images/basket/wrap_3.jpg',
    ),
  ];

  final addons = const [
    BasketOption(
      id: 'a1',
      title: 'شوكولاه فاخرة',
      price: 10000,
      imageAsset: 'assets/images/basket/addon_1.jpg',
      category: 'chocolate',
    ),
    BasketOption(
      id: 'a2',
      title: 'بالونات احتفال',
      price: 10000,
      imageAsset: 'assets/images/basket/addon_2.jpg',
      category: 'balloons',
    ),
    BasketOption(
      id: 'a3',
      title: 'شموع معطرة',
      price: 10000,
      imageAsset: 'assets/images/basket/addon_3.jpg',
      category: 'candles',
    ),
    BasketOption(
      id: 'a4',
      title: 'صندوق احتفال',
      price: 10000,
      imageAsset: 'assets/images/basket/addon_4.jpg',
      category: 'party',
    ),
    BasketOption(
      id: 'a5',
      title: 'لافندر مجفف',
      price: 10000,
      imageAsset: 'assets/images/basket/addon_1.jpg',
      category: 'lavender',
    ),
    BasketOption(
      id: 'a6',
      title: 'إضافة مميزة',
      price: 10000,
      imageAsset: 'assets/images/basket/addon_3.jpg',
      category: 'chocolate',
    ),
  ];

  final addonCategories = const [
    ('all', 'common_all'),
    ('candles', 'شموع'),
    ('chocolate', 'opt_chocolate'),
    ('party', 'للأحتفال'),
    ('balloons', 'بالونات'),
    ('lavender', 'fav_cat_lavender'),
  ];

  @override
  void onInit() {
    super.onInit();
    items.assignAll([
      BasketItem(
        id: 'b1',
        code: '#23iS26',
        title: 'mock_orchid_bouquet',
        subtitle: '26 وردة رائعة , نفاثة الرائحة العطرة',
        imageAsset: 'assets/images/basket/cart_item.jpg',
        unitPrice: 63000,
        qty: 2,
      ),
      BasketItem(
        id: 'b2',
        code: '#23iS26',
        title: 'mock_orchid_bouquet',
        subtitle: 'orders_custom_wrap',
        imageAsset: 'assets/images/basket/cart_item.jpg',
        unitPrice: 126000,
        qty: 1,
      ),
    ]);
  }

  int get orderSubtotal => items.fold(0, (s, i) => s + i.lineTotal);

  int get wrapPrice {
    final id = selectedWrapId.value;
    if (id == null) return 0;
    return wraps.firstWhere((w) => w.id == id, orElse: () => wraps.first).price;
  }

  int get addonsPrice => selectedAddonIds.fold(0, (s, id) {
        final o = addons.where((a) => a.id == id);
        return s + (o.isEmpty ? 0 : o.first.price);
      });

  int get cardPrice {
    final id = selectedCardId.value;
    final o = giftCards.where((c) => c.id == id);
    return o.isEmpty ? 0 : o.first.price;
  }

  int get deliveryPrice => orderSubtotal >= 100000 ? 0 : 5000;

  int get totalPrice =>
      orderSubtotal + wrapPrice + addonsPrice + cardPrice + deliveryPrice;

  bool get hasFreeDelivery => orderSubtotal >= 100000;

  String get wrapLabel {
    final id = selectedWrapId.value;
    if (id == null) return 'common_not_set'.tr;
    return wraps
        .firstWhere((w) => w.id == id, orElse: () => wraps.first)
        .title
        .tr;
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

  void clearCart() => items.clear();

  void incrementQty(String id) {
    final i = items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    items[i].qty++;
    items.refresh();
  }

  void decrementQty(String id) {
    final i = items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    if (items[i].qty <= 1) {
      items.removeAt(i);
    } else {
      items[i].qty--;
      items.refresh();
    }
  }

  void selectCard(String id) => selectedCardId.value = id;

  void selectWrap(String id) {
    if (selectedWrapId.value == id) {
      selectedWrapId.value = null;
    } else {
      selectedWrapId.value = id;
    }
  }

  void toggleAddon(String id) {
    if (selectedAddonIds.contains(id)) {
      selectedAddonIds.remove(id);
    } else {
      selectedAddonIds.add(id);
    }
  }

  void setAddonCategory(String id) => addonCategoryId.value = id;

  List<BasketOption> get filteredAddons {
    final cat = addonCategoryId.value;
    if (cat == 'all') return addons;
    return addons.where((a) => a.category == cat).toList();
  }

  int get messageRemaining =>
      (messageMax - giftMessage.value.length).clamp(0, messageMax);

  void openGiftCard() => Get.toNamed('/basket/gift-card');
  void openWrapping() => Get.toNamed('/basket/wrapping');
  void openAddons() => Get.toNamed('/basket/addons');

  void completeOrder() => Get.toNamed('/order/user-info');
}
