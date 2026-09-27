import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/favorites_controller.dart';
import '../../controllers/home_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/app_image.dart';

/// شاشة المفضلات — حسب تصميم Figma (warda / Favorites).
class FavoritesScreen extends GetView<FavoritesController> {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: SvgPicture.asset(
                      'assets/icons/home/caret.svg',
                      width: 23.w,
                      height: 23.w,
                      colorFilter: const ColorFilter.mode(
                        AppColors.onboardingText,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'favorites_title'.tr,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 26.h),
            SizedBox(
              height: 45.h,
              child: Obx(() {
                final selected = controller.selectedCategoryId.value;
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: controller.categories.length,
                  separatorBuilder: (_, _) => SizedBox(width: 7.w),
                  itemBuilder: (context, index) {
                    final cat = controller.categories[index];
                    final isSelected = cat.id == selected;
                    return _CategoryChip(
                      label: cat.label.tr,
                      selected: isSelected,
                      onTap: () => controller.selectCategory(cat.id),
                    );
                  },
                );
              }),
            ),
            SizedBox(height: 26.h),
            Expanded(
              child: Obx(() {
                final products = controller.filteredItems;
                if (products.isEmpty) {
                  return const _EmptyFavorites();
                }
                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14.w,
                    mainAxisSpacing: 14.h,
                    childAspectRatio: 170 / 217,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _FavoriteProductCard(
                      product: product,
                      onFavoriteTap: () =>
                          controller.removeFavorite(product.id),
                      onTap: () => Get.toNamed(
                        '/product-details',
                        arguments: product,
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.5.r),
      child: Container(
        height: 45.h,
        padding: EdgeInsets.symmetric(horizontal: 17.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.onboardingCta : Colors.white,
          borderRadius: BorderRadius.circular(14.5.r),
          border: selected
              ? null
              : Border.all(
                  color: const Color(0xFF3A3F41).withValues(alpha: 0.26),
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 14.sp,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected
                ? Colors.white
                : AppColors.authMuted.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }
}

class _FavoriteProductCard extends StatelessWidget {
  const _FavoriteProductCard({
    required this.product,
    required this.onFavoriteTap,
    required this.onTap,
  });

  final HomeProduct product;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.authLink.withValues(alpha: 0.45),
            blurRadius: 1.7,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppImage(
                  source: product.imageAsset,
                  fit: BoxFit.cover,
                ),
                PositionedDirectional(
                  start: 16.w,
                  bottom: 12.h,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: Container(
                      width: 35.w,
                      height: 35.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/icons/home/heart_filled.svg',
                        width: 21.w,
                        height: 21.w,
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  end: 10.w,
                  bottom: 14.h,
                  child: Container(
                    width: 52.w,
                    height: 22.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onboardingCta,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        SvgPicture.asset(
                          'assets/icons/home/star.svg',
                          width: 14.w,
                          height: 14.w,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${product.priceLabel} ${'common_currency_iqd'.tr}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
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
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.authLink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/home/heart.svg',
              width: 40.w,
              height: 40.w,
              colorFilter: const ColorFilter.mode(
                AppColors.authLink,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'favorites_empty'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.onboardingText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
