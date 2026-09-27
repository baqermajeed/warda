import '../core/config/api_config.dart';
import '../controllers/home_controller.dart';

/// تحويل استجابة المنتج من الـ API إلى [HomeProduct].
HomeProduct mapHomeProduct(Map<String, dynamic> json) {
  final image = json['image'] as String? ?? '';
  final resolved = ApiConfig.imageUrl(image) ?? image;
  final ratingRaw = json['rating'];
  final rating = ratingRaw is num
      ? ratingRaw.toDouble()
      : double.tryParse('$ratingRaw') ?? 4.5;
  return HomeProduct(
    id: '${json['id']}',
    title: (json['title'] ?? json['title_ar'] ?? '') as String,
    priceLabel: (json['price_label'] ?? '${json['price'] ?? 0}') as String,
    imageAsset: resolved.isEmpty
        ? 'assets/images/home/product_1.png'
        : resolved,
    rating: rating,
    isFavorite: json['is_favorite'] as bool? ?? false,
  );
}

List<HomeProduct> mapHomeProductList(dynamic items) {
  if (items is! List) return const [];
  return items
      .whereType<Map>()
      .map((e) => mapHomeProduct(Map<String, dynamic>.from(e)))
      .toList();
}
