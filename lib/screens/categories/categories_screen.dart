import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/categories_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// شاشة التصنيفات والفلاتر — حسب تصميم Figma.
class CategoriesScreen extends GetView<CategoriesController> {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: 8.h),
          Text(
            'categories_title'.tr,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.onboardingText,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 120.h),
              children: [
                _SearchField(onTap: controller.openSearch),
                SizedBox(height: 23.h),
                for (final filter in controller.filters) ...[
                  _FilterTile(filter: filter),
                  SizedBox(height: 13.h),
                ],
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  height: 55.h,
                  child: OutlinedButton(
                    onPressed: controller.showResults,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.onboardingText),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23.r),
                      ),
                    ),
                    child: Obx(
                      () => Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onboardingText,
                          ),
                          children: [
                            TextSpan(text: '${'categories_show_results'.tr} '),
                            TextSpan(
                              text: '( ${controller.resultsCount.value} )',
                              style: const TextStyle(
                                color: AppColors.authLink,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(23.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23.r),
        child: Container(
          height: 52.h,
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
                child: Text(
                  'search_hint'.tr,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onboardingText.withValues(alpha: 0.6),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              SvgPicture.asset(
                'assets/icons/categories/search.svg',
                width: 22.w,
                height: 22.w,
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

class _FilterTile extends StatelessWidget {
  const _FilterTile({required this.filter});

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
        width: double.infinity,
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
                          width: 23.w,
                          height: 23.w,
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
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (expanded && filter.options.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filter.options.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 9.w,
                    mainAxisSpacing: 9.h,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final option = filter.options[index];
                    final isSelected =
                        controller.selectedOptions[filter.id] == option.id;
                    return _OptionChip(
                      label: option.label.tr,
                      selected: isSelected,
                      onTap: () =>
                          controller.selectOption(filter.id, option.id),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
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
      borderRadius: BorderRadius.circular(21.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.onboardingCta.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(21.r),
          border: selected
              ? Border.all(color: AppColors.onboardingCta, width: 1)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/categories/person_option.svg',
              width: 28.w,
              height: 28.w,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 10.sp,
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
