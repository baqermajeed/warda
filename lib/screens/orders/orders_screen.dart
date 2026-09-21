import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/orders_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// شاشة قائمة الطلبات.
class OrdersScreen extends GetView<OrdersController> {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 0),
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
                    'orders_title'.tr,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingText,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 23.h),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 24.h),
                itemCount: controller.orders.length,
                separatorBuilder: (_, _) => SizedBox(height: 16.h),
                itemBuilder: (_, i) {
                  final order = controller.orders[i];
                  return _OrderCard(
                    order: order,
                    onDetails: () => controller.openDetails(order),
                    onReorder: () => controller.reorder(order),
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

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.onDetails,
    required this.onReorder,
  });

  final AppOrder order;
  final VoidCallback onDetails;
  final VoidCallback onReorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 23.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.onboardingCta.withValues(alpha: 0.16),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                order.date,
                                style: TextStyle(
                                  fontFamily: kFontFamily,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF555553)
                                      .withValues(alpha: 0.58),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: Container(
                                  width: 3.5.w,
                                  height: 3.5.w,
                                  decoration: const BoxDecoration(
                                    color: Color(0x94555553),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Text(
                                order.code,
                                style: TextStyle(
                                  fontFamily: kFontFamily,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF555553)
                                      .withValues(alpha: 0.58),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 9.h),
                          Text(
                            order.title.tr,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onboardingText,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            order.subtitle.tr,
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.authLink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      width: 77.w,
                      height: 36.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: order.status.backgroundColor,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Text(
                        order.status.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: order.status.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 23.h),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          value: order.paymentMethod.tr,
                          label: 'orders_payment_method'.tr,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _StatBox(
                          value: order.totalLabel,
                          label: 'orders_total'.tr,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _StatBox(
                          value: 'common_product_count'.trParams({'count': '${order.productsCount}'}),
                          label: 'orders_products'.tr,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 19.h),
          Divider(
            height: 1,
            indent: 18.w,
            endIndent: 18.w,
            color: Colors.black.withValues(alpha: 0.06),
          ),
          SizedBox(height: 19.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.onboardingCta.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(23.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 123,
                      child: InkWell(
                        onTap: onReorder,
                        borderRadius: BorderRadius.circular(23.r),
                        child: Center(
                          child: Text(
                            'orders_reorder'.tr,
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onboardingText,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 189,
                      child: Material(
                        color: AppColors.onboardingCta,
                        borderRadius: BorderRadius.circular(23.r),
                        child: InkWell(
                          onTap: onDetails,
                          borderRadius: BorderRadius.circular(23.r),
                          child: Center(
                            child: Text(
                              'orders_view_details'.tr,
                              style: TextStyle(
                                fontFamily: kFontFamily,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55.h,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.onboardingCta.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
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
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.onboardingText.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
