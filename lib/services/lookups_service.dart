import 'package:get/get.dart';

import 'api_client.dart';

/// خيار (معرّف + مفتاح ترجمة/نص) قادم من `/lookups`.
class LookupOption {
  const LookupOption({required this.id, required this.label});

  final String id;
  final String label;
}

/// مجموعة فلتر (مثل «لمن الهدية») مع خياراتها.
class LookupFilter {
  const LookupFilter({
    required this.id,
    required this.title,
    required this.options,
  });

  final String id;
  final String title;
  final List<LookupOption> options;
}

/// بيانات مرجعية من `GET /lookups` (المحافظات، الفلاتر، رسوم التوصيل...).
/// تبقى القيم الافتراضية المحلية فعّالة إلى أن يصل رد الـ API أو إذا فشل.
class LookupsService extends GetxService {
  static LookupsService get to => Get.find<LookupsService>();

  final governorates = <String>[
    'gov_baghdad',
    'gov_basra',
    'gov_nineveh',
    'gov_erbil',
    'gov_najaf',
    'gov_karbala',
    'gov_babylon',
    'gov_anbar',
    'gov_diyala',
    'gov_dhi_qar',
    'gov_saladin',
    'gov_wasit',
    'gov_maysan',
    'gov_muthanna',
    'gov_qadisiyyah',
    'gov_duhok',
    'gov_sulaymaniyah',
    'gov_kirkuk',
  ].obs;

  /// `null` حتى يصل رد الـ API — كل شاشة تستخدم قائمتها الافتراضية.
  final filters = Rxn<List<LookupFilter>>();
  final favoriteCategories = Rxn<List<LookupOption>>();
  final addonCategories = Rxn<List<LookupOption>>();

  final deliveryFee = 5000.obs;
  final freeDeliveryThreshold = 100000.obs;

  bool _loaded = false;
  Future<void>? _pending;

  ApiClient get _api => Get.find<ApiClient>();

  Future<void> ensureLoaded() {
    if (_loaded) return Future.value();
    return _pending ??= _load().whenComplete(() => _pending = null);
  }

  Future<void> _load() async {
    try {
      final data = await _api.getLookups();
      final govs = (data['governorates'] as List? ?? []).whereType<String>();
      if (govs.isNotEmpty) governorates.assignAll(govs);

      final rawFilters = data['filters'];
      if (rawFilters is List && rawFilters.isNotEmpty) {
        filters.value = rawFilters.whereType<Map>().map((f) {
          return LookupFilter(
            id: '${f['id']}',
            title: '${f['title'] ?? f['id']}',
            options: _options(f['options']),
          );
        }).toList();
      }

      final fav = _options(data['favorite_categories']);
      if (fav.isNotEmpty) favoriteCategories.value = fav;
      final addons = _options(data['addon_categories']);
      if (addons.isNotEmpty) addonCategories.value = addons;

      deliveryFee.value =
          (data['delivery_fee'] as num?)?.toInt() ?? deliveryFee.value;
      freeDeliveryThreshold.value =
          (data['free_delivery_threshold'] as num?)?.toInt() ??
              freeDeliveryThreshold.value;
      _loaded = true;
    } catch (_) {
      // keep local defaults; a later call retries
    }
  }

  static List<LookupOption> _options(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(
          (o) => LookupOption(
            id: '${o['id']}',
            label: '${o['label'] ?? o['label_key'] ?? o['id']}',
          ),
        )
        .toList();
  }
}
