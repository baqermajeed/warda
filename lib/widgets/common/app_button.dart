import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'loading/shimmer_box.dart';

/// زر أساسي بتصميم موحد ومتجاوب.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryDark,
            side: const BorderSide(color: AppColors.primaryDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          child: loading
              ? ShimmerBox(
                  width: 80.w,
                  height: 20.h,
                  borderRadius: BorderRadius.circular(6.r),
                )
              : Text(
                  label,
                  style: TextStyle(fontFamily: kFontFamily, fontSize: 16.sp),
                ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.primaryLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: loading
            ? SizedBox(
                width: 22.w,
                height: 22.h,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                label,
                style: TextStyle(fontFamily: kFontFamily, fontSize: 16.sp),
              ),
      ),
    );
  }
}
