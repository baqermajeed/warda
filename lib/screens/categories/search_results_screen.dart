import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/categories_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/home/home_product_card.dart';

/// شاشة نتائج البحث والفلترة — شبكة منتجات + شرائح الفلاتر.
class SearchResultsScreen extends GetView<CategoriesController> {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: 18.sp,
                      color: AppColors.onboardingText,
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      () => Text(
                        controller.searchQuery.value.isEmpty
                            ? 'search_results_title'.tr
                            : controller.searchQuery.value,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onboardingText,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.openFilterSort,
                    icon: Icon(
                      Icons.tune_rounded,
                      size: 22.sp,
                      color: AppColors.onboardingText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _ResultsSearchField(
                onTap: controller.openSearch,
                query: controller.searchQuery,
              ),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              height: 36.h,
              child: Obx(() {
                final chips = controller.activeFilterChips;
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  children: [
                    _SortChip(
                      label: controller.sortLabel,
                      onTap: controller.openFilterSort,
                    ),
                    SizedBox(width: 8.w),
                    for (final chip in chips) ...[
                      _FilterChipPill(
                        label: chip.label,
                        onClear: () => controller.clearFilter(chip.filterId),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    if (chips.isNotEmpty)
                      _ClearAllChip(onTap: controller.clearAllFilters),
                  ],
                );
              }),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Obx(
                    () => Text(
                      'common_results_count'.trParams({'count': '${controller.resultsCount.value}'}),
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.authLink,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'search_results_label'.tr,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: Obx(() {
                final products = controller.results;
                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      'search_empty'.tr,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 14.sp,
                        color: AppColors.onboardingText.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }
                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14.w,
                    mainAxisSpacing: 16.h,
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
                        onFavoriteTap: () =>
                            controller.toggleFavorite(product.id),
                        onTap: () => Get.toNamed(
                          '/product-details',
                          arguments: product,
                        ),
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

class _ResultsSearchField extends StatelessWidget {
  const _ResultsSearchField({
    required this.onTap,
    required this.query,
  });

  final VoidCallback onTap;
  final RxString query;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(23.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23.r),
        child: Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(23.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.authLink.withValues(alpha: 0.45),
                blurRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Obx(
                  () => Text(
                    query.value.isEmpty ? 'search_hint'.tr : query.value,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: query.value.isEmpty
                          ? AppColors.onboardingText.withValues(alpha: 0.6)
                          : AppColors.onboardingText,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              SvgPicture.asset(
                'assets/icons/categories/search.svg',
                width: 20.w,
                height: 20.w,
                colorFilter: const ColorFilter.mode(
                  AppColors.onboardingText,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.onboardingCta,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.keyboard_arrow_down, size: 16.sp, color: Colors.white),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipPill extends StatelessWidget {
  const _FilterChipPill({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.onboardingCta.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.onboardingCta.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close, size: 14.sp, color: AppColors.onboardingCta),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.onboardingText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClearAllChip extends StatelessWidget {
  const _ClearAllChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Text(
          'common_clear_all'.tr,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.authLink,
          ),
        ),
      ),
    );
  }
}
