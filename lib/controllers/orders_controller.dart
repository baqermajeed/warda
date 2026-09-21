import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  late final List<AppOrder> orders;
  final selectedOrderId = RxnString();

  AppOrder? get selectedOrder {
    final id = selectedOrderId.value;
    if (id == null) return orders.isEmpty ? null : orders.first;
    return orders.firstWhere((o) => o.id == id, orElse: () => orders.first);
  }

  @override
  void onInit() {
    super.onInit();
    orders = _demoOrders();
    final arg = Get.arguments;
    if (arg is String) {
      selectedOrderId.value = arg;
    } else if (arg is AppOrder) {
      selectedOrderId.value = arg.id;
    }
  }

  void openDetails(AppOrder order) {
    selectedOrderId.value = order.id;
    Get.toNamed('/orders/details', arguments: order.id);
  }

  void reorder(AppOrder order) {
    Get.snackbar(
      'common_app_name'.tr,
      'orders_reorder_snack'.trParams({'code': order.code}),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  List<AppOrder> _demoOrders() {
    const recipient = OrderRecipient(
      name: 'بهجة علي رضا',
      phone: '07700262326',
      governorate: 'الحلة - بابل',
      landmark: 'شارع الجمعية',
    );
    const wrap = OrderWrap(
      title: 'ورق كلاسيكي فاخر',
      priceLabel: '2,000 د.ع',
      imageAsset: 'assets/images/orders/wrap.jpg',
    );
    const gifts = [
      OrderGiftCard(
        imageAsset: 'assets/images/basket/card_1.jpg',
        priceLabel: '2,000 د.ع',
      ),
      OrderGiftCard(
        imageAsset: 'assets/images/basket/card_2.jpg',
        priceLabel: '2,000 د.ع',
      ),
    ];
    const item = OrderLineItem(
      title: 'mock_orchid_bouquet',
      qty: 2,
      priceLabel: '126,000 د.ع',
      imageAsset: 'assets/images/orders/product.jpg',
    );

    return [
      AppOrder(
        id: 'o1',
        code: '#23iS26',
        date: '2026/08/31',
        title: 'mock_orchid_bouquet',
        subtitle: 'orders_custom_wrap',
        status: OrderStatus.delivered,
        productsCount: 4,
        totalLabel: '26,000',
        paymentMethod: 'order_mastercard',
        recipient: recipient,
        items: const [item],
        giftCards: gifts,
        wrap: wrap,
        priceDetails: const OrderPriceDetails(
          orderPrice: '126,000 د.ع',
          deliveryLabel: 'common_free',
          paymentMethod: 'order_mastercard',
          totalPrice: '126,000 د.ع',
        ),
      ),
      AppOrder(
        id: 'o2',
        code: '#23iS26',
        date: '2026/08/31',
        title: 'كيك الفراولة',
        subtitle: 'orders_custom_wrap',
        status: OrderStatus.shipping,
        productsCount: 2,
        totalLabel: '26,000',
        paymentMethod: 'order_mastercard',
        recipient: recipient,
        items: const [
          OrderLineItem(
            title: 'كيك الفراولة',
            qty: 1,
            priceLabel: '26,000 د.ع',
            imageAsset: 'assets/images/orders/product.jpg',
          ),
        ],
        giftCards: gifts,
        wrap: wrap,
        priceDetails: const OrderPriceDetails(
          orderPrice: '26,000 د.ع',
          deliveryLabel: 'common_free',
          paymentMethod: 'order_mastercard',
          totalPrice: '26,000 د.ع',
        ),
      ),
      AppOrder(
        id: 'o3',
        code: '#23iS26',
        date: '2026/08/31',
        title: 'mock_orchid_bouquet',
        subtitle: 'orders_custom_wrap',
        status: OrderStatus.cancelled,
        productsCount: 2,
        totalLabel: '26,000',
        paymentMethod: 'order_cod',
        recipient: recipient,
        items: const [item],
        giftCards: gifts,
        wrap: wrap,
        priceDetails: const OrderPriceDetails(
          orderPrice: '26,000 د.ع',
          deliveryLabel: 'common_free',
          paymentMethod: 'order_cod',
          totalPrice: '26,000 د.ع',
        ),
      ),
    ];
  }
}
