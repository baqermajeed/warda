import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/reminders_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/occasion_reminder.dart';
import '../../widgets/reminders/add_reminder_sheet.dart';

/// شاشة تذكير بالمناسبات.
class RemindersScreen extends GetView<RemindersController> {
  const RemindersScreen({super.key});

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
                      'account_reminders'.tr,
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
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = controller.upcoming;
                return ListView(
                  padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 24.h),
                  children: [
                    const _HeroBanner(),
                    SizedBox(height: 22.h),
                    if (items.isEmpty)
                      const _EmptyState()
                    else ...[
                      Text(
                        'rem_upcoming'.tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onboardingText.withValues(alpha: 0.56),
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ...items.map(
                        (item) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _ReminderCard(reminder: item),
                        ),
                      ),
                    ],
                  ],
                );
              }),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 18.h),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () {
                    controller.resetForm();
                    AddReminderSheet.show();
                  },
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
                      Icon(Icons.add_rounded, size: 22.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'rem_add'.tr,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
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
                  'rem_banner_title'.tr,
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
                  'rem_banner_subtitle'.tr,
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
              'assets/icons/account/reminder.svg',
              width: 26.w,
              height: 26.w,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: RemindersScreen._iconBg,
              borderRadius: BorderRadius.circular(22.r),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/icons/account/reminder.svg',
              width: 32.w,
              height: 32.w,
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            'rem_empty_title'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.onboardingText,
              height: 1.4,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'rem_empty_subtitle'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: RemindersScreen._muted.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends GetView<RemindersController> {
  const _ReminderCard({required this.reminder});

  final OccasionReminder reminder;

  @override
  Widget build(BuildContext context) {
    final days = controller.daysUntil(reminder.date);
    final isSoon = days <= 7;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: RemindersScreen._iconBg,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  controller.typeIcon(reminder.typeId),
                  width: 24.w,
                  height: 24.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.personName,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onboardingText,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${controller.typeLabel(reminder.typeId)} · ${controller.formatDate(reminder.date)}',
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: RemindersScreen._muted.withValues(alpha: 0.72),
                        height: 1.4,
                      ),
                    ),
                    if (reminder.note.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        reminder.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.authMuted.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSoon
                      ? AppColors.onboardingCta.withValues(alpha: 0.1)
                      : RemindersScreen._softFill,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  controller.daysUntilLabel(reminder.date),
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: isSoon
                        ? AppColors.onboardingCta
                        : AppColors.onboardingText.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.black.withValues(alpha: 0.06),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _MiniAction(
                icon: Icons.edit_outlined,
                label: 'rem_edit'.tr,
                onTap: () {
                  controller.resetForm(reminder: reminder);
                  AddReminderSheet.show();
                },
              ),
              SizedBox(width: 8.w),
              _MiniAction(
                icon: Icons.delete_outline_rounded,
                label: 'common_delete'.tr,
                color: const Color(0xFFEB0101),
                onTap: () => controller.deleteReminder(reminder.id),
              ),
              const Spacer(),
              Text(
                'rem_notify'.tr,
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onboardingText.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(width: 8.w),
              _NotifyToggle(
                value: reminder.notifyEnabled,
                onChanged: (v) => controller.toggleNotify(reminder.id, v),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.onboardingCta,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15.sp, color: color),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifyToggle extends StatelessWidget {
  const _NotifyToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 33.w,
        height: 16.h,
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          color: value ? AppColors.onboardingCta : const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: value ? Alignment.centerLeft : Alignment.centerRight,
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
  }
}
