import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/order_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/order_app_header.dart';
import 'widgets/order_bottom_bar.dart';

/// شاشة نجاح تثبيت الطلب.
class OrderSuccessScreen extends GetView<OrderController> {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const OrderAppHeader(showBack: false),
            Expanded(
              child: Center(
                child: Container(
                  width: 275.w,
                  height: 266.h,
                  padding: EdgeInsets.symmetric(
                    horizontal: 21.w,
                    vertical: 19.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(23.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/order/success.png',
                        width: 102.w,
                        height: 102.w,
                        fit: BoxFit.contain,
                        cacheWidth: 256,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'order_success_title'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.successGreen,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 23.h),
                      Text(
                        'order_success_body'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 12.7.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.successGreen,
                          height: 2.11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            OrderBottomBar(
              primaryLabel: 'order_view_orders'.tr,
              secondaryLabel: 'nav_home'.tr,
              primaryColor: AppColors.successGreen,
              onPrimary: controller.viewOrders,
              onSecondary: controller.goHome,
            ),
          ],
        ),
      ),
    );
  }
}
