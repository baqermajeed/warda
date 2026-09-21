import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'order_step_badge.dart';

/// عنوان شاشات إكمال الطلب مع زر رجوع ومؤشر الخطوة.
class OrderAppHeader extends StatelessWidget {
  const OrderAppHeader({
    super.key,
    this.showBack = true,
    this.stepBadge,
  });

  final bool showBack;
  final OrderStepBadge? stepBadge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
      child: SizedBox(
        height: 40.h,
        child: Row(
          children: [
            if (showBack)
              GestureDetector(
                onTap: () => Get.back(),
                behavior: HitTestBehavior.opaque,
                child: SvgPicture.asset(
                  'assets/icons/home/caret.svg',
                  width: 23.w,
                  height: 23.w,
                ),
              )
            else
              SizedBox(width: 23.w),
            Expanded(
              child: Text(
                'order_complete_title'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onboardingText,
                  height: 1.5,
                ),
              ),
            ),
            if (stepBadge != null)
              stepBadge!
            else
              SizedBox(width: 40.w),
          ],
        ),
      ),
    );
  }
}
