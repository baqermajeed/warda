import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/account_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// دايلوج اختيار اللغة — تصميم حضاري متناسق مع شاشة الحساب.
class LanguageDialog extends GetView<AccountController> {
  const LanguageDialog({super.key});

  static const _iconBg = Color(0xFFEFE5DA);
  static const _softFill = Color(0xFFF8F3EE);

  static Future<void> show() {
    return Get.dialog(
      const LanguageDialog(),
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionCurve: Curves.easeOutCubic,
      transitionDuration: const Duration(milliseconds: 280),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      elevation: 0,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.onboardingCta.withValues(alpha: 0.14),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _iconBg,
                    _softFill,
                    AppColors.authLogoCircle,
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: Image.asset(
                'assets/icons/account/arabic.png',
                width: 38.w,
                height: 38.w,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'lang_dialog_title'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.onboardingCta,
                height: 1.3,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'lang_dialog_subtitle'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.onboardingText.withValues(alpha: 0.55),
                height: 1.4,
              ),
            ),
            SizedBox(height: 16.h),
            Obx(() {
              final selected = controller.pendingLanguage.value;
              return Row(
                children: [
                  Expanded(
                    child: _LanguageOption(
                      title: 'lang_arabic'.tr,
                      subtitle: 'Arabic',
                      selected: selected == 'ar',
                      leading: Text(
                        'AR',
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onboardingCta,
                          height: 1,
                        ),
                      ),
                      onTap: () => controller.pendingLanguage.value = 'ar',
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _LanguageOption(
                      title: 'English',
                      subtitle: 'lang_english'.tr,
                      selected: selected == 'en',
                      leading: Text(
                        'EN',
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onboardingCta,
                          height: 1,
                        ),
                      ),
                      onTap: () => controller.pendingLanguage.value = 'en',
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: 16.h),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 46.h,
                      child: TextButton(
                        onPressed: Get.back,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.onboardingCta,
                          backgroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          'common_cancel'.tr,
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 46.h,
                      child: ElevatedButton(
                        onPressed: controller.confirmLanguage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.onboardingCta,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          'common_confirm'.tr,
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
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

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final Widget? leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.onboardingCta.withValues(alpha: 0.05)
                : LanguageDialog._softFill,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: selected
                  ? AppColors.onboardingCta
                  : Colors.black.withValues(alpha: 0.05),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: LanguageDialog._iconBg,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  alignment: Alignment.center,
                  child: leading,
                ),
                SizedBox(width: 8.w),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onboardingCta,
                        height: 1.25,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color:
                            AppColors.onboardingText.withValues(alpha: 0.45),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 18.w,
                height: 18.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? AppColors.onboardingCta
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? AppColors.onboardingCta
                        : AppColors.onboardingSoft,
                    width: 1.4,
                  ),
                ),
                alignment: Alignment.center,
                child: selected
                    ? Icon(
                        Icons.check_rounded,
                        size: 12.sp,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
