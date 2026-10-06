import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/categories_controller.dart';
import '../controllers/orders_controller.dart';
import '../screens/spicial-gift/special_gift_flow_screen.dart';

/// يفتح رابطًا داخليًا قادمًا من الـ API (بانر، إشعار...).
///
/// الصيغ المدعومة:
/// - `/products/{id}` — تفاصيل منتج
/// - `/orders/{id}` — تفاصيل طلب
/// - `/categories/{id}` — نتائج تصنيف
/// - `/search?gift_type=flowers&delivery=same_day&q=...` — نتائج بفلاتر
/// - `/special-gift` — تدفق الهدية المخصصة
/// - أي مسار مسجل في التطبيق مثل `/reminders` أو `/favorites`
/// - رابط خارجي `https://...` — يُنسخ للحافظة
Future<void> openAppLink(String? link) async {
  if (link == null || link.trim().isEmpty) return;
  final uri = Uri.tryParse(link.trim());
  if (uri == null) return;

  if (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
    await Clipboard.setData(ClipboardData(text: link));
    Get.snackbar('common_app_name'.tr, 'share_copied_link'.tr);
    return;
  }

  final segments = uri.pathSegments;
  if (segments.isEmpty) return;
  final id = segments.length > 1 ? int.tryParse(segments[1]) : null;

  switch (segments.first) {
    case 'products':
      if (id != null) {
        Get.toNamed('/product-details', arguments: {'id': id});
      }
      return;
    case 'orders':
      if (id == null) {
        Get.toNamed('/orders');
        return;
      }
      if (!Get.isRegistered<OrdersController>()) {
        Get.put(OrdersController());
      }
      final orders = Get.find<OrdersController>();
      orders.selectedOrderId.value = '$id';
      orders.loadOrderDetails('$id');
      Get.toNamed('/orders/details', arguments: '$id');
      return;
    case 'categories':
      if (id != null) {
        await _categories().openSearchLink(
          Uri(path: '/search', queryParameters: {'category_id': '$id'}),
        );
      }
      return;
    case 'search':
      await _categories().openSearchLink(uri);
      return;
    case 'special-gift':
      await openSpecialGiftFlow();
      return;
    default:
      Get.toNamed(uri.path);
  }
}

CategoriesController _categories() {
  if (!Get.isRegistered<CategoriesController>()) {
    Get.lazyPut<CategoriesController>(
      () => CategoriesController(),
      fenix: true,
    );
  }
  return Get.find<CategoriesController>();
}
