import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/faq_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/faq_item.dart';

/// شاشة الأسئلة الشائعة.
class FaqScreen extends GetView<FaqController> {
  const FaqScreen({super.key});

  static const _iconBg = Color(0xFFEFE5DA);
  static const _softFill = Color(0xFFF8F3EE);
  static const _muted = Color(0xFF555553);

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
                      colorFilter: const ColorFilter.mode(
                        AppColors.onboardingText,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'account_faq'.tr,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onboardingText,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 28.h),
                children: [
                  const _HeroBanner(),
                  SizedBox(height: 22.h),
                  ...controller.categories.map((category) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: _FaqSection(category: category),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 18.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFF8EEEA),
            Color(0xFFEFE5DA),
            Color(0xFFF5EAEA),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.onboardingCta.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'faq_banner_title'.tr,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onboardingCta,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'faq_banner_subtitle'.tr,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onboardingText.withValues(alpha: 0.72),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(16.r),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/icons/account/faq.svg',
              width: 26.w,
              height: 26.w,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection({required this.category});

  final FaqCategory category;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          category.titleKey.tr,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.onboardingText.withValues(alpha: 0.56),
            height: 1.5,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: [
              for (var i = 0; i < category.items.length; i++) ...[
                _FaqTile(item: category.items[i]),
                if (i < category.items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FaqTile extends GetView<FaqController> {
  const _FaqTile({required this.item});

  final FaqItem item;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = controller.isExpanded(item.id);
      return InkWell(
        onTap: () => controller.toggle(item.id),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: [
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 24.sp,
                        color: expanded
                            ? AppColors.onboardingCta
                            : FaqScreen._muted.withValues(alpha: 0.55),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        item.questionKey.tr,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onboardingText,
                          height: 1.45,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: expanded
                            ? AppColors.onboardingCta.withValues(alpha: 0.1)
                            : FaqScreen._iconBg,
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.help_outline_rounded,
                        size: 18.sp,
                        color: AppColors.onboardingCta,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Padding(
                  padding: EdgeInsets.fromLTRB(8.w, 10.h, 46.w, 2.h),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: FaqScreen._softFill,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      item.answerKey.tr,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: FaqScreen._muted.withValues(alpha: 0.85),
                        height: 1.55,
                      ),
                    ),
                  ),
                ),
                crossFadeState: expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 220),
                sizeCurve: Curves.easeOutCubic,
              ),
            ],
          ),
        ),
      );
    });
  }
}
