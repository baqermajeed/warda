import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/account_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// شاشة الحساب / الإعدادات — حسب Figma.
class AccountScreen extends GetView<AccountController> {
  const AccountScreen({super.key});

  static const _iconBg = Color(0xFFEFE5DA);
  static const _logoutColor = Color(0xFFFF724C);
  static const _deleteColor = Color(0xFFEB0101);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          SizedBox(height: 12.h),
          Text(
            'account_title'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.onboardingText,
              height: 1.5,
            ),
          ),
          SizedBox(height: 23.h),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 120.h),
              children: [
                _ProfileCard(controller: controller),
                SizedBox(height: 22.h),
                _SectionTitle('account_user_info'.tr),
                SizedBox(height: 16.h),
                _SettingsCard(
                  children: [
                    _NavRow(
                      title: 'account_language'.tr,
                      iconAsset: 'assets/icons/account/language.svg',
                      onTap: controller.openLanguage,
                    ),
                    const _Divider(),
                    _NavRow(
                      title: 'account_reminders'.tr,
                      iconAsset: 'assets/icons/account/reminder.svg',
                      onTap: controller.openReminders,
                    ),
                    const _Divider(),
                    _NavRow(
                      title: 'account_orders'.tr,
                      iconAsset: 'assets/icons/account/orders.svg',
                      onTap: controller.openOrders,
                    ),
                    const _Divider(),
                    _NotificationRow(controller: controller),
                  ],
                ),
                SizedBox(height: 22.h),
                _SectionTitle('account_about'.tr),
                SizedBox(height: 16.h),
                _SettingsCard(
                  children: [
                    _NavRow(
                      title: 'account_faq'.tr,
                      iconAsset: 'assets/icons/account/faq.svg',
                      onTap: controller.openFaq,
                    ),
                    const _Divider(),
                    _NavRow(
                      title: 'account_support'.tr,
                      iconAsset: 'assets/icons/account/chat.svg',
                      onTap: controller.openSupport,
                    ),
                    const _Divider(),
                    _NavRow(
                      title: 'account_privacy'.tr,
                      iconAsset: 'assets/icons/account/faq.svg',
                      onTap: controller.openPrivacy,
                    ),
                    const _Divider(),
                    _NavRow(
                      title: 'account_share'.tr,
                      iconAsset: 'assets/icons/account/share.svg',
                      arrowAsset: 'assets/icons/account/share_arrow.svg',
                      onTap: controller.shareApp,
                    ),
                  ],
                ),
                SizedBox(height: 22.h),
                _SectionTitle('account_your_account'.tr),
                SizedBox(height: 16.h),
                _SettingsCard(
                  children: [
                    _NavRow(
                      title: 'account_logout'.tr,
                      iconAsset: 'assets/icons/account/logout.svg',
                      arrowAsset: 'assets/icons/account/logout_arrow.svg',
                      titleColor: _logoutColor,
                      iconBackground: _deleteColor.withValues(alpha: 0.08),
                      onTap: controller.logout,
                    ),
                    const _Divider(),
                    _NavRow(
                      title: 'account_delete'.tr,
                      iconAsset: 'assets/icons/account/trash.svg',
                      arrowAsset: 'assets/icons/account/delete_arrow.svg',
                      titleColor: _deleteColor,
                      iconBackground: _deleteColor.withValues(alpha: 0.08),
                      onTap: controller.deleteAccount,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.controller});

  final AccountController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 23.w, vertical: 19.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6.6,
          ),
        ],
      ),
      child: Obx(() {
        // قراءة المستخدم لتحديث الاسم/الهاتف.
        final _ = Get.find<AuthController>().user.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/account/avatar.svg',
              width: 51.w,
              height: 51.w,
            ),
            SizedBox(height: 12.h),
            Text(
              controller.displayName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.onboardingCta,
                height: 1.5,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              controller.displayPhone,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.onboardingCta.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: OutlinedButton(
                onPressed: controller.editProfile,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.onboardingCta,
                  side: const BorderSide(color: AppColors.onboardingCta),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'account_edit_info'.tr,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
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
      textAlign: TextAlign.right,
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
      padding: EdgeInsets.symmetric(horizontal: 19.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6.6,
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
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.black.withValues(alpha: 0.06),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.title,
    required this.iconAsset,
    required this.onTap,
    this.arrowAsset = 'assets/icons/account/arrow.svg',
    this.titleColor = AppColors.onboardingText,
    this.iconBackground = AccountScreen._iconBg,
  });

  final String title;
  final String iconAsset;
  final String arrowAsset;
  final Color titleColor;
  final Color iconBackground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        height: 40.h,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              SvgPicture.asset(
                arrowAsset,
                width: 24.w,
                height: 24.w,
              ),
              const Spacer(),
              Text(
                title,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                  height: 1.5,
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  iconAsset,
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

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.controller});

  final AccountController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Obx(() {
              final on = controller.notificationsEnabled.value;
              return GestureDetector(
                onTap: () => controller.toggleNotifications(!on),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 33.w,
                  height: 16.h,
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: on
                        ? AppColors.onboardingCta
                        : const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment:
                      on ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFE5DA),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            Text(
              'account_notifications'.tr,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.onboardingText,
                height: 1.5,
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AccountScreen._iconBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/icons/account/bell.svg',
                width: 20.w,
                height: 20.w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
