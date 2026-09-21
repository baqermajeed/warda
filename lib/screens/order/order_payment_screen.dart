import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/order_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/order_app_header.dart';
import 'widgets/order_bottom_bar.dart';
import 'widgets/order_step_badge.dart';

/// الخطوة 2 — طرق الدفع وملخص الطلب.
class OrderPaymentScreen extends GetView<OrderController> {
  const OrderPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final basket = controller.basket;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            OrderAppHeader(
              stepBadge: const OrderStepBadge(
                label: '2 / 2',
                color: AppColors.successGreen,
                progress: 1,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 24.h),
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'order_choose_payment'.tr,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3D3E46),
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 23.h),
                  Obx(() {
                    final selected = controller.paymentMethod.value;
                    // ترتيب Figma LTR: ماستر كارد يسار، عند الاستلام يمين.
                    return Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          Expanded(
                            child: _PaymentCard(
                              label: 'order_mastercard'.tr,
                              imageAsset:
                                  'assets/images/order/mastercard.png',
                              imageWidth: 58.w,
                              imageHeight: 63.h,
                              selected: selected == 'card',
                              onTap: () =>
                                  controller.selectPayment('card'),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _PaymentCard(
                              label: 'order_cod'.tr,
                              imageAsset: 'assets/images/order/cod.png',
                              imageWidth: 50.5.w,
                              imageHeight: 50.5.w,
                              selected: selected == 'cod',
                              onTap: () =>
                                  controller.selectPayment('cod'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 23.h),
                  Text(
                    'order_info'.tr,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingText,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 23.h),
                  Obx(() {
                    final order = basket.money(basket.orderSubtotal);
                    final wrap = basket.money(basket.wrapPrice);
                    final addons = basket.money(basket.addonsPrice);
                    final delivery = basket.money(basket.deliveryPrice);
                    final total = basket.money(basket.totalPrice);
                    return _OrderSummaryCard(
                      orderPrice: order,
                      wrapPrice: wrap,
                      addonsPrice: addons,
                      deliveryPrice: delivery,
                      totalPrice: total,
                    );
                  }),
                ],
              ),
            ),
            OrderBottomBar(
              primaryLabel: 'order_confirm'.tr,
              secondaryLabel: 'order_cancel'.tr,
              onPrimary: controller.confirmOrder,
              onSecondary: controller.cancelOrder,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.label,
    required this.imageAsset,
    required this.imageWidth,
    required this.imageHeight,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String imageAsset;
  final double imageWidth;
  final double imageHeight;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(20.r),
          border: selected
              ? Border.all(color: AppColors.onboardingCta)
              : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.authLink.withValues(alpha: 0.45),
                    blurRadius: 3.4,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imageAsset,
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.contain,
              cacheWidth: 200,
            ),
            SizedBox(height: selected ? 10.h : 3.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3D3E46),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.orderPrice,
    required this.wrapPrice,
    required this.addonsPrice,
    required this.deliveryPrice,
    required this.totalPrice,
  });

  final String orderPrice;
  final String wrapPrice;
  final String addonsPrice;
  final String deliveryPrice;
  final String totalPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.authLink.withValues(alpha: 0.45),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          _PriceRow(label: 'basket_order_price'.tr, value: orderPrice),
          SizedBox(height: 11.h),
          _PriceRow(label: 'basket_wrap_price'.tr, value: wrapPrice),
          SizedBox(height: 11.h),
          _PriceRow(label: 'basket_addons_price'.tr, value: addonsPrice),
          SizedBox(height: 18.h),
          Divider(height: 1, color: Colors.black.withValues(alpha: 0.08)),
          SizedBox(height: 18.h),
          _PriceRow(label: 'basket_delivery_price'.tr, value: deliveryPrice),
          SizedBox(height: 18.h),
          Divider(height: 1, color: Colors.black.withValues(alpha: 0.08)),
          SizedBox(height: 18.h),
          Row(
            children: [
              Text(
                totalPrice,
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.successGreen,
                  height: 1.5,
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
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
            fontWeight: FontWeight.w400,
            color: AppColors.onboardingText,
            height: 1.5,
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
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
