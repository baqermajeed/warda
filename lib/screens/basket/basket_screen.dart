import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/basket_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// شاشة السلة — تبويب الشريط السفلي.
class BasketScreen extends GetView<BasketController> {
  const BasketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              children: [
                GestureDetector(
                  onTap: controller.clearCart,
                  child: Container(
                    width: 35.w,
                    height: 35.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEB0101).withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14.5.r),
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/icons/basket/trash.svg',
                      width: 16.w,
                      height: 16.w,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'basket_title'.tr,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onboardingText,
                  ),
                ),
                const Spacer(),
                SizedBox(width: 35.w),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: Obx(() {
              if (controller.items.isEmpty) {
                return Center(
                  child: Text(
                    'basket_empty'.tr,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 14.sp,
                      color: AppColors.authLink,
                    ),
                  ),
                );
              }
              return ListView(
                padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 120.h),
                children: [
                  if (controller.hasFreeDelivery) ...[
                    _FreeDeliveryBanner(),
                    SizedBox(height: 16.h),
                  ],
                  for (final item in controller.items) ...[
                    _BasketItemCard(item: item),
                    SizedBox(height: 16.h),
                  ],
                  SizedBox(height: 8.h),
                  _NavRow(
                    title: 'basket_gift_card'.tr,
                    subtitle: 'basket_customized'.tr,
                    onTap: controller.openGiftCard,
                  ),
                  SizedBox(height: 13.h),
                  _NavRow(
                    title: 'basket_wrapping'.tr,
                    subtitle: '( ${controller.wrapLabel} )',
                    onTap: controller.openWrapping,
                  ),
                  SizedBox(height: 13.h),
                  _NavRow(
                    title: 'basket_addons'.tr,
                    subtitle:
                        'basket_addons_selected'.trParams({'count': '${controller.selectedAddonIds.length}'}),
                    onTap: controller.openAddons,
                  ),
                  SizedBox(height: 13.h),
                  _PriceDetailsTile(controller: controller),
                  SizedBox(height: 23.h),
                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: ElevatedButton(
                      onPressed: controller.completeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.onboardingCta,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23.r),
                        ),
                      ),
                      child: Text(
                        'basket_checkout'.tr,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FreeDeliveryBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'basket_free_delivery_banner'.tr,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.successGreen,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          SvgPicture.asset(
            'assets/icons/basket/truck.svg',
            width: 26.w,
            height: 26.w,
          ),
        ],
      ),
    );
  }
}

class _BasketItemCard extends StatelessWidget {
  const _BasketItemCard({required this.item});

  final BasketItem item;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<BasketController>();
    return Container(
      height: 143.h,
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
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 8.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.code,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 12.sp,
                      color: const Color(0xFF555553).withValues(alpha: 0.58),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    item.title.tr,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.subtitle.tr,
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
                  const Spacer(),
                  Row(
                    children: [
                      _QtyButton(
                        asset: 'assets/icons/basket/qty_minus.svg',
                        onTap: () => c.decrementQty(item.id),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        '${item.qty}',
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onboardingText,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      _QtyButton(
                        asset: 'assets/icons/basket/qty_plus.svg',
                        onTap: () => c.incrementQty(item.id),
                      ),
                      const Spacer(),
                      Text(
                        c.money(item.lineTotal),
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadiusDirectional.only(
              topEnd: Radius.circular(23.r),
              bottomEnd: Radius.circular(23.r),
            ),
            child: Image.asset(
              item.imageAsset,
              width: 97.w,
              height: 143.h,
              fit: BoxFit.cover,
              cacheWidth: 200,
              cacheHeight: 300,
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.asset, required this.onTap});

  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(asset, width: 22.w, height: 22.w),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
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
          boxShadow: [
            BoxShadow(
              color: AppColors.authLink.withValues(alpha: 0.45),
              blurRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/home/caret.svg',
              width: 23.w,
              height: 23.w,
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
                  TextSpan(text: title),
                  TextSpan(
                    text: ' $subtitle',
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
    );
  }
}

class _PriceDetailsTile extends StatelessWidget {
  const _PriceDetailsTile({required this.controller});

  final BasketController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = controller.priceExpanded.value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: expanded ? 16.h : 0,
        ),
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
              onTap: controller.togglePriceDetails,
              child: SizedBox(
                height: expanded ? 28.h : 48.h,
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
                    if (expanded)
                      Text(
                        'basket_price_details'.tr,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onboardingText,
                        ),
                      )
                    else
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onboardingText,
                          ),
                          children: [
                            TextSpan(text: '${'basket_price_details'.tr} '),
                            TextSpan(
                              text:
                                  '( ${controller.money(controller.totalPrice)} )',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.successGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (expanded) ...[
              SizedBox(height: 14.h),
              _PriceRow(
                label: 'basket_order_price'.tr,
                value: controller.money(controller.orderSubtotal),
              ),
              SizedBox(height: 10.h),
              _PriceRow(
                label: 'basket_wrap_price'.tr,
                value: controller.money(controller.wrapPrice),
              ),
              SizedBox(height: 10.h),
              _PriceRow(
                label: 'basket_addons_price'.tr,
                value: controller.money(controller.addonsPrice),
              ),
              Divider(height: 28.h, color: AppColors.authLink.withValues(alpha: 0.3)),
              _PriceRow(
                label: 'basket_delivery_price'.tr,
                value: controller.deliveryPrice == 0
                    ? 'common_free'.tr
                    : controller.money(controller.deliveryPrice),
              ),
              Divider(height: 28.h, color: AppColors.authLink.withValues(alpha: 0.3)),
              Row(
                children: [
                  Text(
                    controller.money(controller.totalPrice),
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.successGreen,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'basket_total'.tr,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onboardingText,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 14.sp,
            color: AppColors.onboardingText,
          ),
        ),
        const Spacer(),
        Text(
          label,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.onboardingText,
          ),
        ),
      ],
    );
  }
}
