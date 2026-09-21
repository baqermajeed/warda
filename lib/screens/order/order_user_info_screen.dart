import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/order_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/auth/auth_input_field.dart';
import 'widgets/order_app_header.dart';
import 'widgets/order_bottom_bar.dart';
import 'widgets/order_step_badge.dart';

/// الخطوة 1 — معلومات المستلم.
class OrderUserInfoScreen extends GetView<OrderController> {
  const OrderUserInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            OrderAppHeader(
              stepBadge: OrderStepBadge(
                label: '1 / 2',
                color: const Color(0xFFE3C226),
                progress: 0.55,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 24.h),
                children: [
                  Text(
                    'order_recipient_info'.tr,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingText,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 23.h),
                  AuthInputField(
                    hint: 'order_name_hint'.tr,
                    iconAsset: 'assets/icons/order/user.svg',
                    controller: controller.nameController,
                    textInputAction: TextInputAction.next,
                    onChanged: controller.onNameChanged,
                  ),
                  SizedBox(height: 12.h),
                  AuthInputField(
                    hint: 'order_phone_hint'.tr,
                    iconAsset: 'assets/icons/order/mobile.svg',
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onChanged: controller.onPhoneChanged,
                  ),
                  SizedBox(height: 12.h),
                  Obx(() {
                    final unknown = controller.unknownAddress.value;
                    return Opacity(
                      opacity: unknown ? 0.45 : 1,
                      child: AuthInputField(
                        hint: 'order_gov_hint'.tr,
                        iconAsset: 'assets/icons/order/map_pin.svg',
                        controller: controller.governorateController,
                        readOnly: true,
                        onTap: unknown
                            ? null
                            : () => _pickGovernorate(context),
                        leading: SvgPicture.asset(
                          'assets/icons/order/caret_down.svg',
                          width: 32.w,
                          height: 32.w,
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 12.h),
                  Obx(() {
                    final unknown = controller.unknownAddress.value;
                    return Opacity(
                      opacity: unknown ? 0.45 : 1,
                      child: _LandmarkField(
                        enabled: !unknown,
                        controller: controller.landmarkController,
                        onChanged: controller.onLandmarkChanged,
                      ),
                    );
                  }),
                  SizedBox(height: 16.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Obx(() {
                      final checked = controller.unknownAddress.value;
                      return GestureDetector(
                        onTap: controller.toggleUnknownAddress,
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 25.w,
                              height: 25.w,
                              padding: EdgeInsets.fromLTRB(3.w, 4.h, 3.w, 2.h),
                              decoration: BoxDecoration(
                                color: checked
                                    ? AppColors.onboardingCta
                                    : const Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: SvgPicture.asset(
                                'assets/icons/order/check.svg',
                                width: 19.w,
                                height: 19.w,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'order_unknown_address'.tr,
                              style: TextStyle(
                                fontFamily: kFontFamily,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                                color: AppColors.onboardingText
                                    .withValues(alpha: checked ? 1 : 0.4),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            OrderBottomBar(
              primaryLabel: 'common_next'.tr,
              secondaryLabel: 'order_cancel'.tr,
              onPrimary: controller.goToPayment,
              onSecondary: controller.cancelOrder,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickGovernorate(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(23.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            itemCount: OrderController.governorates.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              color: AppColors.authFieldBorder,
            ),
            itemBuilder: (_, i) {
              final name = OrderController.governorates[i];
              return ListTile(
                title: Text(
                  name.tr,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onboardingText,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, name),
              );
            },
          ),
        );
      },
    );
    if (selected != null) controller.selectGovernorate(selected);
  }
}

class _LandmarkField extends StatelessWidget {
  const _LandmarkField({
    required this.enabled,
    required this.controller,
    required this.onChanged,
  });

  final bool enabled;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58.h,
      child: TextField(
        controller: controller,
        enabled: enabled,
        onChanged: onChanged,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontFamily: kFontFamily,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.onboardingText,
        ),
        decoration: InputDecoration(
          hintText: 'order_landmark_hint'.tr,
          hintStyle: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.authMuted.withValues(alpha: 0.58),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 19.w,
            vertical: 17.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22.r),
            borderSide: const BorderSide(color: AppColors.authFieldBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22.r),
            borderSide: const BorderSide(color: AppColors.authFieldBorder),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22.r),
            borderSide: const BorderSide(color: AppColors.authFieldBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22.r),
            borderSide: const BorderSide(
              color: AppColors.onboardingCta,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
