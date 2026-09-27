import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/privacy_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/privacy_section.dart';

/// شاشة سياسة الخصوصية.
class PrivacyScreen extends GetView<PrivacyController> {
  const PrivacyScreen({super.key});

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
                      'account_privacy'.tr,
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
                  SizedBox(height: 14.h),
                  Text(
                    'privacy_updated'.tr,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: _muted.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'privacy_sections'.tr,
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
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
                    child: Obx(() {
                      final sections = controller.sections;
                      return Column(
                        children: [
                          for (var i = 0; i < sections.length; i++) ...[
                            _PrivacyTile(section: sections[i]),
                            if (i < sections.length - 1)
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.black.withValues(alpha: 0.06),
                              ),
                          ],
                        ],
                      );
                    }),
                  ),
                  SizedBox(height: 22.h),
                  _ContactCard(onTap: controller.openSupport),
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
                  'privacy_banner_title'.tr,
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
                  'privacy_banner_subtitle'.tr,
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
            child: Icon(
              Icons.shield_outlined,
              size: 26.sp,
              color: AppColors.onboardingCta,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyTile extends GetView<PrivacyController> {
  const _PrivacyTile({required this.section});

  final PrivacySection section;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = controller.isExpanded(section.id);
      return InkWell(
        onTap: () => controller.toggle(section.id),
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
                            : PrivacyScreen._muted.withValues(alpha: 0.55),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        section.titleKey.tr,
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
                            : PrivacyScreen._iconBg,
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.article_outlined,
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
                      color: PrivacyScreen._softFill,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      section.bodyKey.tr,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: PrivacyScreen._muted.withValues(alpha: 0.85),
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

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/account/arrow.svg',
                width: 22.w,
                height: 22.w,
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'privacy_contact_title'.tr,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingText,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'privacy_contact_hint'.tr,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: PrivacyScreen._muted.withValues(alpha: 0.72),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: PrivacyScreen._iconBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons/account/chat.svg',
                  width: 20.w,
                  height: 20.w,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
