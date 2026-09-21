import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// حقل إدخال بأسلوب شاشات المصادقة من Figma.
class AuthInputField extends StatelessWidget {
  const AuthInputField({
    super.key,
    required this.hint,
    required this.iconAsset,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.hasError = false,
    this.readOnly = false,
    this.onTap,
    this.leading,
    this.inputFormatters,
  });

  final String hint;
  final String iconAsset;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool hasError;
  final bool readOnly;
  final VoidCallback? onTap;
  /// يظهر في جهة النهاية (يسار في RTL) — مثل سهم القائمة.
  final Widget? leading;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        hasError ? AppColors.authErrorBorder : AppColors.authFieldBorder;

    return SizedBox(
      height: 58.h,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        readOnly: readOnly,
        onTap: onTap,
        inputFormatters: inputFormatters,
        style: TextStyle(
          fontFamily: kFontFamily,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.onboardingText,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.authMuted.withValues(alpha: 0.58),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 17.h,
          ),
          // في RTL يظهر على اليمين بجانب النص كما في التصميم.
          prefixIcon: Padding(
            padding: EdgeInsetsDirectional.only(start: 16.w, end: 8.w),
            child: SvgPicture.asset(
              iconAsset,
              width: 26.w,
              height: 26.w,
            ),
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 50.w,
            minHeight: 26.h,
          ),
          suffixIcon: leading == null
              ? null
              : Padding(
                  padding: EdgeInsetsDirectional.only(end: 12.w),
                  child: leading,
                ),
          suffixIconConstraints: leading == null
              ? null
              : BoxConstraints(minWidth: 40.w, minHeight: 32.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22.r),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22.r),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22.r),
            borderSide: BorderSide(
              color: hasError
                  ? AppColors.authErrorBorder
                  : AppColors.onboardingCta,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
