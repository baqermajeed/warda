import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/special_gift_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// صفحة نتائج اقتراحات الهدية المخصصة — Figma 1:3223.
class SpecialGiftResultsScreen extends GetView<SpecialGiftController> {
  const SpecialGiftResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: SvgPicture.asset(
                      'assets/icons/spicial-gift/chevron.svg',
                      width: 23.w,
                      height: 23.w,
                      colorFilter: const ColorFilter.mode(
                        AppColors.onboardingText,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'sg_results_title'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onboardingText,
                      ),
                    ),
                  ),
                  SizedBox(width: 23.w),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 7.w,
                    runSpacing: 8.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'sg_filter_by'.tr,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onboardingText,
                        ),
                      ),
                      Obx(
                        () => _FilterChip(
                          label: controller.recipientLabel,
                          showCaret: true,
                        ),
                      ),
                      Obx(
                        () => _FilterChip(
                          label: controller.occasionLabel,
                          showCaret: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 7.w,
                    runSpacing: 8.h,
                    children: [
                      Obx(
                        () => _FilterChip(
                          label: controller.budgetChipLabel,
                          showClose: true,
                        ),
                      ),
                      _FilterChip(
                        label: 'sg_arrives_today'.tr,
                        showClose: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 13.7.w,
                  mainAxisSpacing: 13.7.h,
                  childAspectRatio: 170 / 217,
                ),
                itemCount: controller.suggestions.length,
                itemBuilder: (context, index) {
                  final item = controller.suggestions[index];
                  return _SuggestionCard(
                    item: item,
                    onFavorite: () => controller.toggleFavorite(item.id),
                    onTap: () => Get.toNamed('/product-details'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.showCaret = false,
    this.showClose = false,
  });

  final String label;
  final bool showCaret;
  final bool showClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.5.r),
        border: Border.all(color: AppColors.onboardingCta, width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showClose) ...[
            SvgPicture.asset(
              'assets/icons/spicial-gift/close.svg',
              width: 12.w,
              height: 12.w,
              colorFilter: const ColorFilter.mode(
                AppColors.onboardingCta,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 6.w),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.onboardingCta,
            ),
          ),
          if (showCaret) ...[
            SizedBox(width: 6.w),
            SvgPicture.asset(
              'assets/icons/spicial-gift/caret.svg',
              width: 16.w,
              height: 16.w,
              colorFilter: const ColorFilter.mode(
                AppColors.onboardingCta,
                BlendMode.srcIn,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.item,
    required this.onFavorite,
    required this.onTap,
  });

  final SpecialGiftSuggestion item;
  final VoidCallback onFavorite;
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
                  Image.asset(
                    item.imageAsset,
                    fit: BoxFit.cover,
                    cacheWidth: 400,
                    filterQuality: FilterQuality.low,
                    gaplessPlayback: true,
                  ),
                  PositionedDirectional(
                    start: 12.w,
                    bottom: 10.h,
                    child: GestureDetector(
                      onTap: onFavorite,
                      child: Container(
                        width: 34.w,
                        height: 34.w,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Obx(() {
                          final isFavorite =
                              Get.find<SpecialGiftController>()
                                  .favoriteIds
                                  .contains(item.id);
                          return SvgPicture.asset(
                            isFavorite
                                ? 'assets/icons/home/heart_filled.svg'
                                : 'assets/icons/home/heart.svg',
                            width: 18.w,
                            height: 18.w,
                          );
                        }),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    end: 10.w,
                    bottom: 12.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.rating,
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onboardingCta,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.star_rounded,
                            size: 14.sp,
                            color: AppColors.onboardingCta,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.price} ${'common_currency_iqd'.tr}',
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onboardingText,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item.title.tr,
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
