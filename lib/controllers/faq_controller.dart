import 'package:get/get.dart';

import '../core/errors/api_exception.dart';
import '../models/faq_item.dart';
import '../services/api_client.dart';

/// تحكم شاشة الأسئلة الشائعة.
class FaqController extends GetxController {
  /// معرّف السؤال المفتوح حاليًا (Accordion).
  final expandedId = RxnString();
  final categories = <FaqCategory>[].obs;
  final isLoading = false.obs;

  ApiClient get _api => Get.find<ApiClient>();

  bool get _isAr => (Get.locale?.languageCode ?? 'ar') == 'ar';

  @override
  void onInit() {
    super.onInit();
    loadFaq();
  }

  Future<void> loadFaq() async {
    isLoading.value = true;
    try {
      final data = await _api.getFaq();
      final isAr = _isAr;
      final mapped = (data['items'] as List? ?? []).whereType<Map>().map((c) {
        final cat = Map<String, dynamic>.from(c);
        final items = (cat['items'] as List? ?? []).whereType<Map>().map((i) {
          final item = Map<String, dynamic>.from(i);
          return FaqItem(
            id: '${item['id']}',
            questionKey: isAr
                ? (item['question_ar'] as String? ?? '')
                : (item['question_en'] as String? ??
                    item['question_ar'] as String? ??
                    ''),
            answerKey: isAr
                ? (item['answer_ar'] as String? ?? '')
                : (item['answer_en'] as String? ??
                    item['answer_ar'] as String? ??
                    ''),
          );
        }).toList();
        return FaqCategory(
          id: '${cat['id']}',
          titleKey: isAr
              ? (cat['title_ar'] as String? ?? '')
              : (cat['title_en'] as String? ??
                  cat['title_ar'] as String? ??
                  ''),
          items: items,
        );
      }).toList();
      categories.assignAll(mapped);
    } on ApiException catch (e) {
      Get.snackbar('common_app_name'.tr, e.message);
    } catch (_) {
      // keep empty / fallback silent
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
}
