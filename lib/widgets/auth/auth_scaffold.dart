import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/app_spacing.dart';

/// هيكل مشترك لشاشات تسجيل الدخول / إنشاء الحساب.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.onNext,
    required this.footer,
    this.isLoading = false,
    this.errorMessage,
  });

  final String title;
  final String subtitle;
  final List<Widget> fields;
  final VoidCallback onNext;
  final Widget footer;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height -
                  MediaQuery.paddingOf(context).vertical,
            ),
            child: Column(
              children: [
                SizedBox(height: 8.h),
                Text(
                  'common_app_name'.tr,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onboardingText,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 48.h),
                Container(
                  width: 134.w,
                  height: 134.w,
                  decoration: const BoxDecoration(
                    color: AppColors.authLogoCircle,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(height: 31.h),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onboardingText,
                    height: 1.5,
                  ),
                ),
                AppSpacing.verticalSm,
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.authMuted,
                    height: 1.58,
                  ),
                ),
                SizedBox(height: 40.h),
                ...fields,
                if (errorMessage != null) ...[
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.authError,
                            height: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      SvgPicture.asset(
                        'assets/icons/auth/info.svg',
                        width: 14.w,
                        height: 14.w,
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 40.h),
                SizedBox(
                  width: double.infinity,
                  height: 55.h,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.onboardingCta,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.onboardingCta.withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23.r),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 22.w,
                            height: 22.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'common_next'.tr,
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 26.h),
                footer,
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// تذييل روابط المصادقة (إنشاء حساب / ضيف / تسجيل دخول).
class AuthFooterLinks extends StatelessWidget {
  const AuthFooterLinks({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onAction,
    required this.onGuest,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontFamily: kFontFamily,
      fontSize: 14.sp,
      fontWeight: FontWeight.w700,
      height: 1.5,
      color: AppColors.onboardingText,
    );
    final link = base.copyWith(
      color: AppColors.authLink,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.authLink,
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(prompt, style: base),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(actionLabel, style: link),
        ),
        Text(' ${'common_or'.tr} ', style: base),
        TextButton(
          onPressed: onGuest,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text('auth_continue_guest'.tr, style: link),
        ),
      ],
    );
  }
}
