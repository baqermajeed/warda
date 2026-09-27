import 'package:flutter/material.dart';

import '../../core/config/api_config.dart';

/// صورة تدعم الأصول المحلية وروابط الشبكة/مسارات الـ API.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.fallbackAsset = 'assets/images/home/product_1.png',
  });

  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final String fallbackAsset;

  bool get _isNetwork {
    final s = source.trim();
    return s.startsWith('http://') ||
        s.startsWith('https://') ||
        s.startsWith('/');
  }

  String get _resolved {
    final s = source.trim();
    if (s.startsWith('http://') || s.startsWith('https://')) return s;
    if (s.startsWith('/')) return ApiConfig.imageUrl(s) ?? s;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_isNetwork) {
      child = Image.network(
        _resolved,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => Image.asset(
          fallbackAsset,
          fit: fit,
          width: width,
          height: height,
        ),
      );
    } else {
      child = Image.asset(
        source.isEmpty ? fallbackAsset : source,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => ColoredBox(
          color: const Color(0xFFF3EEE6),
          child: SizedBox(width: width, height: height),
        ),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}
