import 'package:get/get.dart';

import '../core/errors/api_exception.dart';
import '../services/api_client.dart';
import '../utils/app_links.dart';
import 'auth_controller.dart';

/// إشعار واحد قادم من `GET /notifications`.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
    required this.createdAt,
    this.link,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] as num).toInt(),
      type: (json['type'] as String?) ?? 'general',
      titleAr: (json['title_ar'] as String?) ?? '',
      titleEn: (json['title_en'] as String?) ?? '',
      bodyAr: (json['body_ar'] as String?) ?? '',
      bodyEn: (json['body_en'] as String?) ?? '',
      link: json['link'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.tryParse('${json['created_at']}'),
    );
  }

  final int id;
  final String type;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  final String? link;
  final bool isRead;
  final DateTime? createdAt;

  bool get _isAr => (Get.locale?.languageCode ?? 'ar') == 'ar';
  String get title => _isAr || titleEn.isEmpty ? titleAr : titleEn;
  String get body => _isAr || bodyEn.isEmpty ? bodyAr : bodyEn;

  String get dateLabel {
    final dt = createdAt?.toLocal();
    if (dt == null) return '';
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '${dt.year}/$m/$d';
  }

  AppNotification markRead() => AppNotification(
        id: id,
        type: type,
        titleAr: titleAr,
        titleEn: titleEn,
        bodyAr: bodyAr,
        bodyEn: bodyEn,
        link: link,
        isRead: true,
        createdAt: createdAt,
      );
}

/// تحكم الإشعارات + عدّاد غير المقروء لجرس الصفحة الرئيسية.
class NotificationsController extends GetxController {
  final items = <AppNotification>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final RxnString errorMessage = RxnString();
  int _page = 1;
  int _total = 0;

  bool get hasMore => items.length < _total;

  ApiClient get _api => Get.find<ApiClient>();
  AuthController get _auth => Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    refreshUnreadCount();
    ever(_auth.user, (_) => refreshUnreadCount());
  }

  Future<void> refreshUnreadCount() async {
    if (!_auth.isAuthenticated) {
      unreadCount.value = 0;
      return;
    }
    try {
      unreadCount.value = await _api.getUnreadNotificationsCount();
    } catch (_) {
      // keep last value
    }
  }

  void open() {
    if (!_auth.isAuthenticated) {
      Get.toNamed('/login');
      return;
    }
    Get.toNamed('/notifications');
    load();
  }

  Future<void> load() async {
    if (!_auth.isAuthenticated) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final data = await _api.getNotifications();
      items.assignAll(_map(data['items']));
      _page = 1;
      _total = (data['total'] as num?)?.toInt() ?? items.length;
      await refreshUnreadCount();
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'auth_error_generic'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoading.value || isLoadingMore.value) return;
    isLoadingMore.value = true;
    try {
      final data = await _api.getNotifications(page: _page + 1);
      final mapped = _map(data['items']);
      final known = items.map((n) => n.id).toSet();
      items.addAll(mapped.where((n) => !known.contains(n.id)));
      _page += 1;
      _total = (data['total'] as num?)?.toInt() ?? _total;
      if (mapped.isEmpty) _total = items.length;
    } catch (_) {
      // retry on next scroll
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> openNotification(AppNotification n) async {
    if (!n.isRead) {
      final index = items.indexWhere((e) => e.id == n.id);
      if (index >= 0) items[index] = n.markRead();
      if (unreadCount.value > 0) unreadCount.value -= 1;
      try {
        await _api.markNotificationRead(n.id);
      } catch (_) {
        // the server state is refreshed on next load
      }
    }
    await openAppLink(n.link);
  }

  Future<void> markAllRead() async {
    if (unreadCount.value == 0 && items.every((n) => n.isRead)) return;
    try {
      await _api.markAllNotificationsRead();
      items.assignAll(items.map((n) => n.markRead()));
      unreadCount.value = 0;
    } on ApiException catch (e) {
      Get.snackbar('common_app_name'.tr, e.message);
    } catch (_) {
      Get.snackbar('common_app_name'.tr, 'auth_error_generic'.tr);
    }
  }

  static List<AppNotification> _map(dynamic raw) {
    return (raw as List? ?? [])
        .whereType<Map>()
        .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
