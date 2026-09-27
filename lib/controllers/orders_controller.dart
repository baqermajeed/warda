import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/config/api_config.dart';
import '../core/errors/api_exception.dart';
import '../services/api_client.dart';
import 'auth_controller.dart';
import 'basket_controller.dart';

/// حالة الطلب في قائمة الطلبات.
enum OrderStatus {
  delivered,
  shipping,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.delivered:
        return 'order_status_delivered'.tr;
      case OrderStatus.shipping:
        return 'order_status_shipping'.tr;
      case OrderStatus.cancelled:
        return 'order_status_cancelled'.tr;
    }
  }

  Color get textColor {
    switch (this) {
      case OrderStatus.delivered:
        return const Color(0xFF0E8A61);
      case OrderStatus.shipping:
        return const Color(0xFFA98E0D);
      case OrderStatus.cancelled:
        return const Color(0xFFEB0101);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case OrderStatus.delivered:
        return const Color(0xFF0E8A61).withValues(alpha: 0.1);
      case OrderStatus.shipping:
        return const Color(0xFFE3C226).withValues(alpha: 0.26);
      case OrderStatus.cancelled:
        return const Color(0xFFEB0101).withValues(alpha: 0.1);
    }
  }
}

class OrderLineItem {
  const OrderLineItem({
    required this.title,
    required this.qty,
    required this.priceLabel,
    required this.imageAsset,
  });

  final String title;
  final int qty;
  final String priceLabel;
  final String imageAsset;
}

class OrderGiftCard {
  const OrderGiftCard({
    required this.imageAsset,
    required this.priceLabel,
  });

  final String imageAsset;
  final String priceLabel;
}

class OrderWrap {
  const OrderWrap({
    required this.title,
    required this.priceLabel,
    required this.imageAsset,
  });

  final String title;
  final String priceLabel;
  final String imageAsset;
}

class OrderRecipient {
  const OrderRecipient({
    required this.name,
    required this.phone,
    required this.governorate,
    required this.landmark,
  });

  final String name;
  final String phone;
  final String governorate;
  final String landmark;
}

class OrderPriceDetails {
  const OrderPriceDetails({
    required this.orderPrice,
    required this.deliveryLabel,
    required this.paymentMethod,
    required this.totalPrice,
  });

  final String orderPrice;
  final String deliveryLabel;
  final String paymentMethod;
  final String totalPrice;
}

/// نموذج طلب في سجل الطلبات.
class AppOrder {
  const AppOrder({
    required this.id,
    required this.code,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.productsCount,
    required this.totalLabel,
    required this.paymentMethod,
    required this.recipient,
    required this.items,
    required this.giftCards,
    required this.wrap,
    required this.priceDetails,
  });

  final String id;
  final String code;
  final String date;
  final String title;
  final String subtitle;
  final OrderStatus status;
  final int productsCount;
  final String totalLabel;
  final String paymentMethod;
  final OrderRecipient recipient;
  final List<OrderLineItem> items;
  final List<OrderGiftCard> giftCards;
  final OrderWrap wrap;
  final OrderPriceDetails priceDetails;
}

/// تحكم قائمة الطلبات وتفاصيل الطلب.
class OrdersController extends GetxController {
  final orders = <AppOrder>[].obs;
  final selectedOrderId = RxnString();
  final isLoading = false.obs;

  ApiClient get _api => Get.find<ApiClient>();

  AppOrder? get selectedOrder {
    final id = selectedOrderId.value;
    if (orders.isEmpty) return null;
    if (id == null) return orders.first;
    return orders.firstWhereOrNull((o) => o.id == id) ?? orders.first;
  }

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is String) {
      selectedOrderId.value = arg;
    } else if (arg is AppOrder) {
      selectedOrderId.value = arg.id;
    }
    loadOrders();
  }

  bool _requireAuth() {
    if (!Get.find<AuthController>().isAuthenticated) {
      Get.toNamed('/login');
      return false;
    }
    return true;
  }

  OrderStatus _mapStatus(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'delivered':
      case 'completed':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.shipping;
    }
  }

  String _money(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    return '${buf.toString()} ${'common_currency_iqd'.tr}';
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      return '${dt.year}/$m/$d';
    } catch (_) {
      return iso.split('T').first.replaceAll('-', '/');
    }
  }

  String _image(String? path) {
    if (path == null || path.isEmpty) {
      return 'assets/images/orders/product.jpg';
    }
    return ApiConfig.imageUrl(path) ?? path;
  }

  AppOrder _mapOrder(Map<String, dynamic> json) {
    final items = (json['items'] as List? ?? []).whereType<Map>().map((e) {
      final m = Map<String, dynamic>.from(e);
      final line = (m['line_total'] as num?)?.toInt() ??
          ((m['unit_price'] as num?)?.toInt() ?? 0) *
              ((m['qty'] as num?)?.toInt() ?? 1);
      return OrderLineItem(
        title: (m['title_ar'] ?? m['title'] ?? '') as String,
        qty: (m['qty'] as num?)?.toInt() ?? 1,
        priceLabel: _money(line),
        imageAsset: _image(m['image'] as String?),
      );
    }).toList();

    final giftCard = json['gift_card'];
    final giftCards = <OrderGiftCard>[];
    if (giftCard is Map && giftCard.isNotEmpty) {
      final price = (giftCard['price'] as num?)?.toInt() ?? 0;
      giftCards.add(
        OrderGiftCard(
          imageAsset: _image(giftCard['image'] as String?),
          priceLabel: _money(price),
        ),
      );
    }

    final wrapJson = json['wrap'];
    OrderWrap wrap;
    if (wrapJson is Map && wrapJson.isNotEmpty) {
      final price = (wrapJson['price'] as num?)?.toInt() ?? 0;
      wrap = OrderWrap(
        title: (wrapJson['title_ar'] ?? wrapJson['title'] ?? '') as String,
        priceLabel: _money(price),
        imageAsset: _image(wrapJson['image'] as String?),
      );
    } else {
      wrap = const OrderWrap(
        title: '',
        priceLabel: '',
        imageAsset: 'assets/images/orders/wrap.jpg',
      );
    }

    final total = (json['total'] as num?)?.toInt() ?? 0;
    final subtotal = (json['subtotal'] as num?)?.toInt() ?? 0;
    final delivery = (json['delivery_price'] as num?)?.toInt() ?? 0;
    final payment = (json['payment_method'] as String?) ?? 'cod';
    final paymentLabel =
        payment == 'card' ? 'order_mastercard' : 'order_cod';

    final firstTitle = items.isNotEmpty ? items.first.title : '';

    return AppOrder(
      id: '${json['id']}',
      code: (json['code'] as String?) ?? '',
      date: _formatDate((json['created_at'] as String?) ?? ''),
      title: firstTitle,
      subtitle: 'orders_custom_wrap',
      status: _mapStatus(json['status'] as String?),
      productsCount: items.fold<int>(0, (s, i) => s + i.qty),
      totalLabel: _money(total).replaceAll(' ${'common_currency_iqd'.tr}', ''),
      paymentMethod: paymentLabel,
      recipient: OrderRecipient(
        name: (json['recipient_name'] as String?) ?? '',
        phone: (json['recipient_phone'] as String?) ?? '',
        governorate: (json['governorate'] as String?) ?? '',
        landmark: (json['landmark'] as String?) ?? '',
      ),
      items: items,
      giftCards: giftCards.isEmpty
          ? const [
              OrderGiftCard(
                imageAsset: 'assets/images/basket/card_1.jpg',
                priceLabel: '',
              ),
            ]
          : giftCards,
      wrap: wrap,
      priceDetails: OrderPriceDetails(
        orderPrice: _money(subtotal),
        deliveryLabel: delivery == 0 ? 'common_free' : _money(delivery),
        paymentMethod: paymentLabel,
        totalPrice: _money(total),
      ),
    );
  }

  Future<void> loadOrders() async {
    if (!_requireAuth()) return;
    isLoading.value = true;
    try {
      final data = await _api.getOrders();
      final mapped = (data['items'] as List? ?? [])
          .whereType<Map>()
          .map((e) => _mapOrder(Map<String, dynamic>.from(e)))
          .toList();
      orders.assignAll(mapped);
    } on ApiException catch (e) {
      Get.snackbar('common_app_name'.tr, e.message);
    } catch (_) {
      Get.snackbar('common_app_name'.tr, 'auth_error_generic'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOrderDetails(String id) async {
    if (!_requireAuth()) return;
    final orderId = int.tryParse(id);
    if (orderId == null) return;
    try {
      final data = await _api.getOrder(orderId);
      final mapped = _mapOrder(data);
      final index = orders.indexWhere((o) => o.id == mapped.id);
      if (index >= 0) {
        orders[index] = mapped;
      } else {
        orders.insert(0, mapped);
      }
      selectedOrderId.value = mapped.id;
    } on ApiException catch (e) {
      Get.snackbar('common_app_name'.tr, e.message);
    }
  }

  void openDetails(AppOrder order) {
    selectedOrderId.value = order.id;
    Get.toNamed('/orders/details', arguments: order.id);
    loadOrderDetails(order.id);
  }

  Future<void> reorder(AppOrder order) async {
    if (!_requireAuth()) return;
    final id = int.tryParse(order.id);
    if (id == null) return;
    try {
      await _api.reorder(id);
      if (!Get.isRegistered<BasketController>()) {
        Get.put(BasketController());
      } else {
        await Get.find<BasketController>().loadCart();
      }
      Get.snackbar(
        'common_app_name'.tr,
        'orders_reorder_snack'.trParams({'code': order.code}),
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.toNamed('/basket');
    } on ApiException catch (e) {
      Get.snackbar('common_app_name'.tr, e.message);
    }
  }
}
