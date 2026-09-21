import 'package:get/get.dart';

import '../models/privacy_section.dart';

/// تحكم شاشة سياسة الخصوصية.
class PrivacyController extends GetxController {
  final expandedId = RxnString();

  final sections = const <PrivacySection>[
    PrivacySection(
      id: 'intro',
      titleKey: 'privacy_s_intro_title',
      bodyKey: 'privacy_s_intro_body',
    ),
    PrivacySection(
      id: 'collect',
      titleKey: 'privacy_s_collect_title',
      bodyKey: 'privacy_s_collect_body',
    ),
    PrivacySection(
      id: 'use',
      titleKey: 'privacy_s_use_title',
      bodyKey: 'privacy_s_use_body',
    ),
    PrivacySection(
      id: 'share',
      titleKey: 'privacy_s_share_title',
      bodyKey: 'privacy_s_share_body',
    ),
    PrivacySection(
      id: 'store',
      titleKey: 'privacy_s_store_title',
      bodyKey: 'privacy_s_store_body',
    ),
    PrivacySection(
      id: 'rights',
      titleKey: 'privacy_s_rights_title',
      bodyKey: 'privacy_s_rights_body',
    ),
    PrivacySection(
      id: 'contact',
      titleKey: 'privacy_s_contact_title',
      bodyKey: 'privacy_s_contact_body',
    ),
  ];

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
