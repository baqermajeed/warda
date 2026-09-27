import 'package:get/get.dart';

import '../core/errors/api_exception.dart';
import '../models/privacy_section.dart';
import '../services/api_client.dart';

/// تحكم شاشة سياسة الخصوصية.
class PrivacyController extends GetxController {
  final expandedId = RxnString();
  final sections = <PrivacySection>[].obs;
  final isLoading = false.obs;

  ApiClient get _api => Get.find<ApiClient>();

  bool get _isAr => (Get.locale?.languageCode ?? 'ar') == 'ar';

  @override
  void onInit() {
    super.onInit();
    loadPrivacy();
  }

  Future<void> loadPrivacy() async {
    isLoading.value = true;
    try {
      final data = await _api.getPrivacy();
      final isAr = _isAr;
      final mapped = (data['items'] as List? ?? []).whereType<Map>().map((e) {
        final m = Map<String, dynamic>.from(e);
        return PrivacySection(
          id: '${m['id']}',
          titleKey: isAr
              ? (m['title_ar'] as String? ?? '')
              : (m['title_en'] as String? ?? m['title_ar'] as String? ?? ''),
          bodyKey: isAr
              ? (m['body_ar'] as String? ?? '')
              : (m['body_en'] as String? ?? m['body_ar'] as String? ?? ''),
        );
      }).toList();
      sections.assignAll(mapped);
    } on ApiException catch (e) {
      Get.snackbar('common_app_name'.tr, e.message);
    } catch (_) {
      // keep empty
    } finally {
      isLoading.value = false;
    }
  }

  void toggle(String id) {
    if (expandedId.value == id) {
      expandedId.value = null;
    } else {
      expandedId.value = id;
    }
  }

  bool isExpanded(String id) => expandedId.value == id;

  void openSupport() => Get.toNamed('/support');
}
