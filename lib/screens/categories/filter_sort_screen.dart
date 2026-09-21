import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/categories_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// شاشة ترتيب وفلترة النتائج.
class FilterSortScreen extends GetView<CategoriesController> {
  const FilterSortScreen({super.key});

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
                    child: Text(
                      'filter_title'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onboardingText,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: controller.clearAllFilters,
                    child: Text(
                      'common_clear'.tr,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.authLink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                children: [
                  Text(
                    'filter_sort_by'.tr,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingText,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Obx(
                    () => Column(
                      children: [
                        for (final option in _sortOptions) ...[
                          _SortTile(
                            label: option.$1,
                            selected: controller.sortBy.value == option.$2,
                            onTap: () => controller.setSort(option.$2),
                          ),
                          SizedBox(height: 10.h),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'filter_filters'.tr,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingText,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  for (final filter in controller.filters) ...[
                    _FilterExpandTile(filter: filter),
                    SizedBox(height: 12.h),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
              child: SizedBox(
                width: double.infinity,
                height: 55.h,
                child: ElevatedButton(
                  onPressed: controller.applyFiltersFromSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.onboardingCta,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(23.r),
                    ),
                  ),
                  child: Obx(
                    () => Text(
                      'filter_show_results'.trParams({'count': '${controller.resultsCount.value}'}),
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _sortOptions = <(String, ResultsSort)>[
  ('sort_newest', ResultsSort.newest),
  ('sort_popular', ResultsSort.popular),
  ('sort_price_asc', ResultsSort.priceAsc),
  ('sort_price_desc', ResultsSort.priceDesc),
];

class _SortTile extends StatelessWidget {
  const _SortTile({
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
      borderRadius: BorderRadius.circular(23.r),
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23.r),
          border: Border.all(
            color: selected
                ? AppColors.onboardingCta
                : AppColors.authLink.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20.sp,
              color: selected ? AppColors.onboardingCta : AppColors.authLink,
            ),
            const Spacer(),
            Text(
              label.tr,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 13.sp,
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

class _FilterExpandTile extends StatelessWidget {
  const _FilterExpandTile({required this.filter});

  final CategoryFilter filter;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoriesController>();
    return Obx(() {
      final expanded = controller.expandedFilterId.value == filter.id;
      final selected = controller.selectedLabel(filter);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
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
        child: Column(
          children: [
            InkWell(
              onTap: () => controller.toggleFilter(filter.id),
              borderRadius: BorderRadius.circular(23.r),
              child: SizedBox(
                height: 48.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Row(
                    children: [
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: SvgPicture.asset(
                          'assets/icons/categories/caret.svg',
                          width: 22.w,
                          height: 22.w,
                        ),
                      ),
                      const Spacer(),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onboardingText,
                          ),
                          children: [
                            TextSpan(text: filter.title.tr),
                            if (selected != null)
                              TextSpan(
                                text: ' ( ${selected.tr} )',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.authLink,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (expanded && filter.options.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  alignment: WrapAlignment.end,
                  children: [
                    for (final option in filter.options)
                      _OptionPill(
                        label: option.label.tr,
                        selected:
                            controller.selectedOptions[filter.id] == option.id,
                        onTap: () =>
                            controller.selectOption(filter.id, option.id),
                      ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _OptionPill extends StatelessWidget {
  const _OptionPill({
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
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.onboardingCta
              : AppColors.onboardingCta.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.onboardingText,
          ),
        ),
      ),
    );
  }
}
