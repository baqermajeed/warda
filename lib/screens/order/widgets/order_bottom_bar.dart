import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';

/// شريط أزرار أسفل شاشات إكمال الطلب — حسب Figma.
class OrderBottomBar extends StatelessWidget {
  const OrderBottomBar({
    super.key,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
    this.primaryColor = const Color(0xFF4D0F14),
    this.barTint,
  });

  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;
  final Color primaryColor;
  final Color? barTint;

  @override
  Widget build(BuildContext context) {
    final tint = barTint ?? primaryColor.withValues(alpha: 0.1);

    return Container(
      height: 97.h,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 19.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(23.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(23.r),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 222,
              child: _BarButton(
                label: primaryLabel,
                onTap: onPrimary,
                background: primaryColor,
                foreground: Colors.white,
                bold: true,
              ),
            ),
            Expanded(
              flex: 123,
              child: _BarButton(
                label: secondaryLabel,
                onTap: onSecondary,
                background: Colors.transparent,
                foreground: primaryColor,
                bold: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  const _BarButton({
    required this.label,
    required this.onTap,
    required this.background,
    required this.foreground,
    required this.bold,
  });

  final String label;
  final VoidCallback onTap;
  final Color background;
  final Color foreground;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(23.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23.r),
        child: SizedBox(
          height: 50.h,
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 16.sp,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
