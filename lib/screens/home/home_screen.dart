import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/app_spacing.dart';
import '../../widgets/home/home_product_card.dart';

/// الصفحة الرئيسية — حسب تصميم Figma.
class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _HomeBanner(controller: controller)),
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: Offset(0, -56.h),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          SizedBox(height: 56.h),
                          _CategoriesSection(controller: controller),
                          SizedBox(height: 26.h),
                          _ProductSection(
                            title: 'home_latest'.tr,
                            products: controller.latestGifts.toList(),
                            horizontal: true,
                          ),
                          _SectionDivider(),
                          _ProductSection(
                            title: 'home_popular'.tr,
                            products: controller.popularGifts.toList(),
                            horizontal: true,
                          ),
                          _SectionDivider(),
                          _ProductSection(
                            title: 'home_all_gifts'.tr,
                            products: controller.allGifts.toList(),
                            horizontal: false,
                          ),
                          SizedBox(height: 120.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _StickyHomeHeader(),
            ),
          ],
        );
      }),
    );
  }
}

class _HomeBanner extends StatelessWidget {
  const _HomeBanner({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 396.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/home/banner.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 396.h,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 98.h,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.onboardingText.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 31.w,
            bottom: 44.h,
            child: SizedBox(
              width: 83.w,
              height: 34.h,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.onboardingCta,
                  foregroundColor: const Color(0xFFEFE5DA),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(44.r),
                  ),
                ),
                child: Text(
                  'home_explore'.tr,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 18.h,
            child: Obx(() {
              final active = controller.bannerIndex.value;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final isActive = i == active;
                  return Container(
                    width: 42.w,
                    height: 4.h,
                    margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFE5DA)
                          .withValues(alpha: isActive ? 1 : 0.4),
                      borderRadius: BorderRadius.circular(23.r),
                    ),
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StickyHomeHeader extends StatelessWidget {
  const _StickyHomeHeader();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: ColoredBox(
          color: Colors.transparent,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
              child: Transform.translate(
                offset: Offset(0, -2.h),
                child: const _HomeHeader(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          _RoundIconButton(
            asset: 'assets/icons/home/heart.svg',
            onTap: () => Get.toNamed('/favorites'),
          ),
          SizedBox(width: 10.w),
          const _DeliveryLocationChip(),
          const Spacer(),
          SizedBox(
            width: 150.w,
            height: 34.h,
            child: OverflowBox(
              maxWidth: 150.w,
              maxHeight: 34.h,
              alignment: Alignment.centerRight,
              child: Image.asset(
                'assets/images/home/logo.png',
                width: 150.w,
                height: 34.h,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// شريحة موقع التوصيل — حسب Figma.
class _DeliveryLocationChip extends StatelessWidget {
  const _DeliveryLocationChip();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 86.w,
        height: 34.h,
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(19.r),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'التوصيل الى',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 9.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Obx(
                    () => Text(
                      controller.locationLabel.value.tr,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                SvgPicture.asset(
                  'assets/icons/home/delivery_caret.svg',
                  width: 8.w,
                  height: 5.h,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.asset,
    required this.onTap,
    this.showBadge = false,
  });

  final String asset;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 34.5.w,
            height: 34.5.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(asset, width: 21.w, height: 21.w),
          ),
          if (showBadge)
            PositionedDirectional(
              end: 6.w,
              top: 6.h,
              child: Container(
                width: 7.w,
                height: 7.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'home_choose_by'.tr,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.onboardingText,
          ),
        ),
        AppSpacing.verticalMd,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: controller.categories
              .map((c) => _CategoryItem(category: c))
              .toList(),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.category});

  final HomeCategory category;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58.w,
      child: Column(
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF5EAEA),
              shape: BoxShape.circle,
              image: category.imageAsset == null
                  ? null
                  : DecorationImage(
                      image: AssetImage(category.imageAsset!),
                      fit: BoxFit.cover,
                    ),
            ),
            alignment: Alignment.center,
            child: category.id == 'more'
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => Container(
                        width: 5.5.w,
                        height: 5.5.w,
                        margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                        decoration: const BoxDecoration(
                          color: AppColors.onboardingText,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  )
                : category.id == 'delivery'
                    ? null
                    : null,
          ),
          SizedBox(height: 6.h),
          Text(
            category.title.tr,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.onboardingText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductSection extends StatelessWidget {
  const _ProductSection({
    required this.title,
    required this.products,
    required this.horizontal,
  });

  final String title;
  final List<HomeProduct> products;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Column(
      children: [
        Row(
          children: [
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/home/caret.svg',
                    width: 16.w,
                    height: 16.w,
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
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.onboardingText,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        if (horizontal)
          SizedBox(
            height: 186.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (context, index) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final product = products[index];
                return Obx(
                  () => HomeProductCard(
                    product: product,
                    isFavorite: controller.isFavorite(product.id),
                    onFavoriteTap: () =>
                        controller.toggleFavorite(product.id),
                    onTap: () => Get.toNamed(
                      '/product-details',
                      arguments: product,
                    ),
                  ),
                );
              },
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14.w,
              mainAxisSpacing: 14.h,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return Obx(
                () => HomeProductCard(
                  product: product,
                  width: double.infinity,
                  imageHeight: 146.h,
                  isFavorite: controller.isFavorite(product.id),
                  onFavoriteTap: () => controller.toggleFavorite(product.id),
                  onTap: () => Get.toNamed(
                    '/product-details',
                    arguments: product,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppColors.onboardingText.withValues(alpha: 0.08),
      ),
    );
  }
}
