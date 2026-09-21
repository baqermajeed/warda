import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/support_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// شاشة خدمة العملاء.
class SupportScreen extends GetView<SupportController> {
  const SupportScreen({super.key});

  static const _iconBg = Color(0xFFEFE5DA);
  static const _softFill = Color(0xFFF8F3EE);
  static const _muted = Color(0xFF555553);
  static const _fieldBorder = Color(0x423A3F41);

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
                      'account_support'.tr,
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
                  _SectionTitle('support_channels'.tr),
                  SizedBox(height: 12.h),
                  _SettingsCard(
                    children: [
                      _ContactRow(
                        title: 'support_phone'.tr,
                        subtitle: SupportController.phone,
                        icon: Icons.phone_outlined,
                        onTap: controller.contactPhone,
                      ),
                      const _Divider(),
                      _ContactRow(
                        title: 'support_whatsapp'.tr,
                        subtitle: SupportController.whatsapp,
                        icon: Icons.chat_bubble_outline_rounded,
                        onTap: controller.contactWhatsApp,
                      ),
                      const _Divider(),
                      _ContactRow(
                        title: 'support_email'.tr,
                        subtitle: SupportController.email,
                        icon: Icons.mail_outline_rounded,
                        onTap: controller.contactEmail,
                      ),
                    ],
                  ),
                  SizedBox(height: 22.h),
                  _SectionTitle('support_hours'.tr),
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
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
                    child: Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: _iconBg,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.access_time_rounded,
                            size: 20.sp,
                            color: AppColors.onboardingCta,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            SupportController.hours.tr,
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onboardingText,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 22.h),
                  _SectionTitle('support_send_message'.tr),
                  SizedBox(height: 12.h),
                  const _MessageCard(),
                  SizedBox(height: 22.h),
                  _SectionTitle('support_quick_help'.tr),
                  SizedBox(height: 12.h),
                  _SettingsCard(
                    children: [
                      _ContactRow(
                        title: 'account_faq'.tr,
                        subtitle: 'support_faq_hint'.tr,
                        iconAsset: 'assets/icons/account/faq.svg',
                        onTap: controller.openFaq,
                      ),
                    ],
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
                  'support_banner_title'.tr,
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
                  'support_banner_subtitle'.tr,
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
              'assets/icons/account/chat.svg',
              width: 26.w,
              height: 26.w,
            ),
          ),
        ],
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

class _ContactRow extends StatelessWidget {
  const _ContactRow({
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
              Column(
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
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: SupportScreen._muted.withValues(alpha: 0.72),
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
                  color: SupportScreen._iconBg,
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

class _MessageCard extends GetView<SupportController> {
  const _MessageCard();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'support_subject'.tr,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.onboardingText,
            ),
          ),
          SizedBox(height: 10.h),
          Obx(() {
            final selected = controller.subjectId.value;
            return Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: SupportController.subjects.map((s) {
                final isSelected = s.id == selected;
                return InkWell(
                  onTap: () => controller.selectSubject(s.id),
                  borderRadius: BorderRadius.circular(12.r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 9.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.onboardingCta
                          : SupportScreen._softFill,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.onboardingCta
                            : SupportScreen._fieldBorder,
                      ),
                    ),
                    child: Text(
                      s.labelKey.tr,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : AppColors.onboardingText,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
          SizedBox(height: 16.h),
          Text(
            'support_message'.tr,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.onboardingText,
            ),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller.messageController,
            onChanged: (v) => controller.message.value = v,
            maxLines: 4,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.onboardingText,
            ),
            decoration: InputDecoration(
              hintText: 'support_message_hint'.tr,
              hintStyle: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.authMuted.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: SupportScreen._softFill,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 14.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(
                  color: SupportScreen._fieldBorder,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(
                  color: SupportScreen._fieldBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: AppColors.onboardingCta),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Obx(() {
            final loading = controller.isSending.value;
            return SizedBox(
              height: 52.h,
              child: ElevatedButton(
                onPressed: loading ? null : controller.submitMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.onboardingCta,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.onboardingCta.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: loading
                    ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'support_send'.tr,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
