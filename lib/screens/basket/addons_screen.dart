import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/basket_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// صفحة إضافات تناسب هديتك.
class AddonsScreen extends GetView<BasketController> {
  const AddonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: SvgPicture.asset(
                      'assets/icons/home/caret.svg',
                      width: 23.w,
                      height: 23.w,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    'basket_addons'.tr,
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
            SizedBox(height: 18.h),
            SizedBox(
              height: 45.h,
              child: Obx(() {
                final selected = controller.addonCategoryId.value;
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: controller.addonCategories.length,
                  separatorBuilder: (_, _) => SizedBox(width: 7.w),
                  itemBuilder: (context, index) {
                    final cat = controller.addonCategories[index];
                    final isSelected = cat.$1 == selected;
                    return InkWell(
                      onTap: () => controller.setAddonCategory(cat.$1),
                      borderRadius: BorderRadius.circular(14.5.r),
                      child: Container(
                        height: 45.h,
                        padding: EdgeInsets.symmetric(horizontal: 17.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.onboardingCta
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14.5.r),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: const Color(0xFF3A3F41)
                                      .withValues(alpha: 0.26),
                                ),
                        ),
                        child: Text(
                          cat.$2.tr,
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 14.sp,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.authMuted.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            SizedBox(height: 18.h),
            Expanded(
              child: Obx(() {
                final selectedIds = controller.selectedAddonIds.toSet();
                final list = controller.filteredAddons;
                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                  itemCount: list.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: 169 / 264,
                  ),
                  itemBuilder: (context, index) {
                    final addon = list[index];
                    final selected = selectedIds.contains(addon.id);
                    return _AddonCard(
                      option: addon,
                      selected: selected,
                      priceLabel: controller.money(addon.price),
                      onTap: () => controller.toggleAddon(addon.id),
                    );
                  },
                );
              }),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(23.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.13),
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Container(
                padding: EdgeInsetsDirectional.only(start: 4.w),
                decoration: BoxDecoration(
                  color: AppColors.onboardingCta.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(23.r),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Obx(
                        () => Text(
                          controller.money(controller.addonsPrice),
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onboardingText,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.onboardingCta,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23.r),
                            ),
                          ),
                          child: Text(
                            'addons_with_gift'.tr,
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddonCard extends StatelessWidget {
  const _AddonCard({
    required this.option,
    required this.selected,
    required this.priceLabel,
    required this.onTap,
  });

  final BasketOption option;
  final bool selected;
  final String priceLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.authLink.withValues(alpha: selected ? 0.54 : 0.45),
            blurRadius: selected ? 5 : 1.7,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.asset(
              option.imageAsset,
              fit: BoxFit.cover,
              cacheWidth: 400,
              cacheHeight: 400,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priceLabel,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onboardingText,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  option.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.authLink,
                  ),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  width: double.infinity,
                  height: 33.h,
                  child: OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: selected
                            ? AppColors.onboardingCta
                            : AppColors.onboardingSoft,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      selected ? 'addons_remove'.tr : 'addons_add'.tr,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 14.sp,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                        color: selected
                            ? AppColors.onboardingCta
                            : AppColors.authLink,
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
