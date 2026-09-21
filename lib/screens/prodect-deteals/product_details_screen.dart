import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/product_details_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/home/home_product_card.dart';

/// شاشة تفاصيل المنتج — حسب Figma.
class ProductDetailsScreen extends GetView<ProductDetailsController> {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: ListView(
              padding: EdgeInsets.only(bottom: 110.h),
              children: [
                _HeroGallery(controller: controller),
                SizedBox(height: 26.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Text(
                        '${controller.priceLabel} ${'common_currency_iqd'.tr}',
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.successGreen,
                          height: 1.5,
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          controller.title.tr,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onboardingText,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  height: 43.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: controller.badges.length,
                    separatorBuilder: (_, _) => SizedBox(width: 10.w),
                    itemBuilder: (_, i) {
                      final badge = controller.badges[i];
                      return _FeatureChip(
                        label: badge.label.tr,
                        iconAsset: badge.iconAsset,
                      );
                    },
                  ),
                ),
                SizedBox(height: 26.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionTitle('product_description'.tr),
                      SizedBox(height: 12.h),
                      Text(
                        controller.description,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E2E2E).withValues(alpha: 0.6),
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      const Divider(height: 1),
                      SizedBox(height: 16.h),
                      _SectionTitle('product_dimensions'.tr),
                      SizedBox(height: 12.h),
                      Text(
                        '${'product_height'.trParams({'value': controller.heightLabel})}\n${'product_width'.trParams({'value': controller.widthLabel})}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E2E2E).withValues(alpha: 0.6),
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      const Divider(height: 1),
                      SizedBox(height: 16.h),
                      _SectionTitle('product_care'.tr),
                      SizedBox(height: 12.h),
                      ...List.generate(controller.careSteps.length, (i) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 4.h),
                          child: Text(
                            '${i + 1}. ${controller.careSteps[i]}',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2E2E2E)
                                  .withValues(alpha: 0.6),
                              height: 1.86,
                            ),
                          ),
                        );
                      }),
                      SizedBox(height: 16.h),
                      const Divider(height: 1),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: controller.viewMoreSimilar,
                            child: Opacity(
                              opacity: 0.6,
                              child: Row(
                                children: [
                                  Transform.rotate(
                                    angle: 1.5708,
                                    child: SvgPicture.asset(
                                      'assets/icons/product/caret.svg',
                                      width: 16.w,
                                      height: 16.w,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'common_show_more'.tr,
                                    style: TextStyle(
                                      fontFamily: kFontFamily,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onboardingText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'product_similar'.tr,
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onboardingText,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 23.h),
                    ],
                  ),
                ),
                SizedBox(
                  height: 186.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: controller.similar.length,
                    separatorBuilder: (_, _) => SizedBox(width: 14.w),
                    itemBuilder: (_, i) {
                      final product = controller.similar[i];
                      return GestureDetector(
                        onTap: () => controller.openSimilar(product),
                        child: HomeProductCard(
                          product: product,
                          isFavorite: false,
                          onFavoriteTap: () {},
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopBar(controller: controller),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomBar(controller: controller),
          ),
        ],
      ),
    );
  }
}

class _HeroGallery extends StatelessWidget {
  const _HeroGallery({required this.controller});

  final ProductDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 423.h,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: controller.pageController,
            itemCount: controller.images.length,
            onPageChanged: controller.onPageChanged,
            itemBuilder: (_, i) {
              return Image.asset(
                controller.images[i],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 423.h,
                cacheWidth: 900,
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 29.h,
            child: Obx(() {
              final index = controller.imageIndex.value;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(controller.images.length, (i) {
                  final active = i == index;
                  return Container(
                    width: 42.w,
                    height: 4.h,
                    margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: active ? 1 : 0.4),
                      borderRadius: BorderRadius.circular(23.r),
                    ),
                  );
                }),
              );
            }),
          ),
          Positioned(
            left: 20.w,
            bottom: 18.h,
            child: _GlassBadge(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 13.75.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onboardingCta,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  SvgPicture.asset(
                    'assets/icons/product/star.svg',
                    width: 18.w,
                    height: 18.w,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 18.w,
            bottom: 18.h,
            child: Obx(() {
              final i = controller.imageIndex.value + 1;
              final total = controller.images.length;
              return _GlassBadge(
                child: Text(
                  '$i/$total',
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 13.75.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onboardingCta,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _GlassBadge extends StatelessWidget {
  const _GlassBadge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 27.5.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: child,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller});

  final ProductDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              _CircleIconButton(
                onTap: () => Get.back(),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18.sp,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Text(
                  'product_details'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onboardingText,
                    height: 1.5,
                  ),
                ),
              ),
              Obx(() {
                final fav = controller.isFavorite.value;
                return _CircleIconButton(
                  onTap: controller.toggleFavorite,
                  child: SvgPicture.asset(
                    fav
                        ? 'assets/icons/product/heart_filled.svg'
                        : 'assets/icons/product/heart.svg',
                    width: 25.w,
                    height: 25.w,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 41.5.w,
        height: 41.5.w,
        decoration: BoxDecoration(
          color: AppColors.onboardingText.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(21.r),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label, required this.iconAsset});

  final String label;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 43.h,
      padding: EdgeInsets.symmetric(horizontal: 13.w),
      decoration: BoxDecoration(
        color: AppColors.onboardingCta.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.onboardingText,
            ),
          ),
          SizedBox(width: 8.w),
          SvgPicture.asset(iconAsset, width: 23.w, height: 23.w),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontFamily: kFontFamily,
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.onboardingText,
        height: 1.5,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller});

  final ProductDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 97.h,
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 19.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(23.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50.h,
                child: ElevatedButton(
                  onPressed: controller.addToBasket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.onboardingCta,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(23.r),
                    ),
                  ),
                  child: Text(
                    'product_add_to_cart'.tr,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: controller.shareProduct,
              child: Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: AppColors.onboardingText.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(25.r),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons/product/share.svg',
                  width: 26.w,
                  height: 26.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
