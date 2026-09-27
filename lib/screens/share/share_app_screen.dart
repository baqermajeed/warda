import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/share_app_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// شاشة مشاركة التطبيق.
class ShareAppScreen extends GetView<ShareAppController> {
  const ShareAppScreen({super.key});

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
                      'account_share'.tr,
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
                  const _AppPreviewCard(),
                  SizedBox(height: 22.h),
                  _SectionTitle('share_message_title'.tr),
                  SizedBox(height: 12.h),
                  const _MessagePreviewCard(),
                  SizedBox(height: 22.h),
                  _SectionTitle('share_ways'.tr),
                  SizedBox(height: 12.h),
                  _SettingsCard(
                    children: [
                      Obx(
                        () => _ShareRow(
                          title: 'share_copy_link'.tr,
                          subtitle: controller.appLink.value,
                          icon: Icons.link_rounded,
                          onTap: controller.copyLink,
                        ),
                      ),
                      const _Divider(),
                      _ShareRow(
                        title: 'share_copy_message'.tr,
                        subtitle: 'share_copy_message_hint'.tr,
                        icon: Icons.content_copy_rounded,
                        onTap: controller.copyMessage,
                      ),
                      const _Divider(),
                      _ShareRow(
                        title: 'share_whatsapp'.tr,
                        subtitle: 'share_whatsapp_sub'.tr,
                        icon: Icons.chat_bubble_outline_rounded,
                        onTap: controller.shareViaWhatsApp,
                      ),
                      const _Divider(),
                      _ShareRow(
                        title: 'share_sms'.tr,
                        subtitle: 'share_sms_sub'.tr,
                        icon: Icons.sms_outlined,
                        onTap: controller.shareViaSms,
                      ),
                      const _Divider(),
                      _ShareRow(
                        title: 'share_more'.tr,
                        subtitle: 'share_more_sub'.tr,
                        iconAsset: 'assets/icons/account/share.svg',
                        onTap: controller.shareMore,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 18.h),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: controller.copyMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.onboardingCta,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/account/share.svg',
                        width: 20.w,
                        height: 20.w,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'share_primary_cta'.tr,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
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
                  'share_banner_title'.tr,
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
                  'share_banner_subtitle'.tr,
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
              'assets/icons/account/share.svg',
              width: 26.w,
              height: 26.w,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppPreviewCard extends StatelessWidget {
  const _AppPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
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
      child: Row(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: ShareAppScreen._iconBg,
              borderRadius: BorderRadius.circular(18.r),
            ),
            alignment: Alignment.center,
            child: Text(
              'ورد',
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.onboardingCta,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'common_app_name'.tr,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onboardingText,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'share_app_tagline'.tr,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: ShareAppScreen._muted.withValues(alpha: 0.75),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessagePreviewCard extends GetView<ShareAppController> {
  const _MessagePreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: ShareAppScreen._softFill,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Text(
        controller.shareMessage,
        style: TextStyle(
          fontFamily: kFontFamily,
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.onboardingText.withValues(alpha: 0.85),
          height: 1.55,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: kFontFamily,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.onboardingText.withValues(alpha: 0.56),
        height: 1.5,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
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
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.black.withValues(alpha: 0.06),
      ),
    );
  }
}

class _ShareRow extends StatelessWidget {
  const _ShareRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.icon,
    this.iconAsset,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData? icon;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
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
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
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
                      subtitle,
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: ShareAppScreen._muted.withValues(alpha: 0.72),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: ShareAppScreen._iconBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: iconAsset != null
                    ? SvgPicture.asset(iconAsset!, width: 20.w, height: 20.w)
                    : Icon(
                        icon,
                        size: 20.sp,
                        color: AppColors.onboardingCta,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
