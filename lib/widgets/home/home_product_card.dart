import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../common/app_image.dart';

/// بطاقة منتج أفقية (أحدث / أشهر).
class HomeProductCard extends StatelessWidget {
  const HomeProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavoriteTap,
    this.onTap,
    this.width,
    this.imageHeight,
  });

  final HomeProduct product;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback? onTap;
  final double? width;
  final double? imageHeight;

  @override
  Widget build(BuildContext context) {
    final cardWidth = width ?? 146.5.w;
    final imgH = imageHeight ?? 126.h;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: imgH,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: AppImage(
                        source: product.imageAsset,
                        fit: BoxFit.cover,
                        width: cardWidth,
                        height: imgH,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: 10.w,
                    bottom: 10.h,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        width: 30.w,
                        height: 30.w,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          isFavorite
                              ? 'assets/icons/home/heart_filled.svg'
                              : 'assets/icons/home/heart.svg',
                          width: 16.w,
                          height: 16.w,
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    end: 8.w,
                    bottom: 10.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(9.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onboardingText,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          SvgPicture.asset(
                            'assets/icons/home/star.svg',
                            width: 11.w,
                            height: 11.w,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '${product.priceLabel} ${'common_currency_iqd'.tr}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.onboardingText,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              product.title.tr,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.authLink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
