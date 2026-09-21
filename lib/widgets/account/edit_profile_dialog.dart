import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/account_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// دايلوج تعديل الملف الشخصي — متناسق مع شاشة الحساب.
class EditProfileDialog extends GetView<AccountController> {
  const EditProfileDialog({super.key});

  static const _iconBg = Color(0xFFEFE5DA);
  static const _softFill = Color(0xFFF8F3EE);
  static const _fieldBorder = Color(0x423A3F41);

  static Future<void> show() {
    return Get.dialog(
      const EditProfileDialog(),
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionCurve: Curves.easeOutCubic,
      transitionDuration: const Duration(milliseconds: 280),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      elevation: 0,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.only(bottom: bottomInset > 0 ? 8.h : 0),
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onboardingCta.withValues(alpha: 0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.snackbar(
                      'common_app_name'.tr,
                      'edit_profile_photo_soon'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                    );
                  },
                  child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 72.w,
                      height: 72.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _iconBg,
                            _softFill,
                            AppColors.authLogoCircle,
                          ],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/icons/account/avatar.svg',
                        width: 52.w,
                        height: 52.w,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 26.w,
                        height: 26.w,
                        decoration: BoxDecoration(
                          color: AppColors.onboardingCta,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 13.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'edit_profile_title'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onboardingCta,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'edit_profile_subtitle'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onboardingText.withValues(alpha: 0.55),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16.h),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'edit_profile_name'.tr,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingText,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                _DialogField(
                  controller: controller.nameController,
                  hint: 'edit_profile_name_hint'.tr,
                  iconAsset: 'assets/icons/auth/user.svg',
                  textInputAction: TextInputAction.next,
                  onChanged: (v) => controller.pendingName.value = v,
                ),
                SizedBox(height: 12.h),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'edit_profile_phone'.tr,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingText,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                _DialogField(
                  controller: controller.phoneController,
                  hint: 'edit_profile_phone_hint'.tr,
                  iconAsset: 'assets/icons/auth/phone.svg',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
                  ],
                  onChanged: (v) => controller.pendingPhone.value = v,
                ),
                SizedBox(height: 16.h),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 46.h,
                          child: TextButton(
                            onPressed: Get.back,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.onboardingCta,
                              backgroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: Text(
                              'common_cancel'.tr,
                              style: TextStyle(
                                fontFamily: kFontFamily,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 46.h,
                          child: ElevatedButton(
                            onPressed: controller.confirmEditProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.onboardingCta,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: Text(
                              'edit_profile_save'.tr,
                              style: TextStyle(
                                fontFamily: kFontFamily,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.controller,
    required this.hint,
    required this.iconAsset,
    required this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final String iconAsset;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters,
        style: TextStyle(
          fontFamily: kFontFamily,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.onboardingText,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.authMuted.withValues(alpha: 0.58),
          ),
          filled: true,
          fillColor: EditProfileDialog._softFill,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 12.h,
          ),
          prefixIcon: Padding(
            padding: EdgeInsetsDirectional.only(start: 12.w, end: 6.w),
            child: SvgPicture.asset(
              iconAsset,
              width: 20.w,
              height: 20.w,
            ),
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40.w,
            minHeight: 20.w,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: const BorderSide(color: EditProfileDialog._fieldBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: const BorderSide(color: EditProfileDialog._fieldBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: const BorderSide(color: AppColors.onboardingCta),
          ),
        ),
      ),
    );
  }
}
