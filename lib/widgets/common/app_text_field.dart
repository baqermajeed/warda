import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// حقل إدخال موحد.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: TextStyle(fontFamily: kFontFamily, fontSize: 15.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: kFontFamily,
          color: AppColors.textSecondary,
          fontSize: 14.sp,
        ),
      ),
    );
  }
}
