import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';

/// دايلوج تأكيد مشترك — مطابق لتصميم Figma (تسجيل خروج / حذف حساب).
class AccountActionDialog extends StatelessWidget {
  const AccountActionDialog({
    super.key,
    required this.accent,
    required this.iconAsset,
    required this.title,
    required this.message,
    required this.confirmLabel,
  });

  final Color accent;
  final String iconAsset;
  final String title;
  final String message;
  final String confirmLabel;

  static const _bg = Color(0xFFFFFEFC);
  static const _subtitle = Color(0xFF515459);
  static const _confirmText = Color(0xFFFBFAF8);

  static Future<bool?> showLogout() {
    return Get.dialog<bool>(
      AccountActionDialog(
        accent: const Color(0xFFFF724C),
        iconAsset: 'assets/icons/account/logout_dialog.svg',
        title: 'account_logout'.tr,
        message: 'account_logout_confirm'.tr,
        confirmLabel: 'account_logout'.tr,
      ),
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionCurve: Curves.easeOutCubic,
      transitionDuration: const Duration(milliseconds: 280),
    );
  }

  static Future<bool?> showDelete() {
    return Get.dialog<bool>(
      AccountActionDialog(
        accent: const Color(0xFFED373A),
        iconAsset: 'assets/icons/account/delete_dialog.svg',
        title: 'account_delete'.tr,
        message: 'account_delete_confirm'.tr,
        confirmLabel: 'account_delete'.tr,
      ),
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionCurve: Curves.easeOutCubic,
      transitionDuration: const Duration(milliseconds: 280),
    );
  }

  @override
  Widget build(BuildContext context) {
    // عرض البطاقة ≈ 340 من التصميم (padding + أزرار).
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 36.w),
      elevation: 0,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(26.w, 29.h, 26.w, 25.h),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(29.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 5.25,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 42.w,
              height: 42.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  SvgPicture.asset(
                    iconAsset,
                    width: 25.w,
                    height: 25.w,
                  ),
                ],
              ),
            ),
            SizedBox(height: 25.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: accent,
                height: 1.2,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: _subtitle.withValues(alpha: 0.8),
                height: 1.3,
              ),
            ),
            SizedBox(height: 25.h),
            // في التصميم: إلغاء يسار / تأكيد يمين (حتى مع RTL).
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44.h,
                      child: OutlinedButton(
                        onPressed: () => Get.back(result: false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accent,
                          side: BorderSide(color: accent, width: 0.825),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'common_cancel'.tr,
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 16.6.sp,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 19.w),
                  Expanded(
                    child: SizedBox(
                      height: 44.h,
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: _confirmText,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          confirmLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 16.6.sp,
                            fontWeight: FontWeight.w800,
                            height: 1,
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
      ),
    );
  }
}
