import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/reminders_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// ورقة إضافة / تعديل مناسبة.
class AddReminderSheet extends GetView<RemindersController> {
  const AddReminderSheet({super.key});

  static const _iconBg = Color(0xFFEFE5DA);
  static const _softFill = Color(0xFFF8F3EE);
  static const _fieldBorder = Color(0x423A3F41);

  static Future<void> show() {
    return Get.bottomSheet(
      const AddReminderSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isEditing = controller.editingId.value != null;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: 0.9.sh),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10.h),
              Container(
                width: 42.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEditing ? 'rem_edit_title'.tr : 'rem_add_title'.tr,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onboardingCta,
                          height: 1.3,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: _softFill,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.close_rounded,
                          size: 18.sp,
                          color: AppColors.onboardingText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FieldLabel('rem_person_name'.tr),
                      SizedBox(height: 8.h),
                      _NameField(
                        initial: controller.personName.value,
                        onChanged: (v) => controller.personName.value = v,
                      ),
                      SizedBox(height: 18.h),
                      _FieldLabel('rem_occasion_type'.tr),
                      SizedBox(height: 10.h),
                      SizedBox(
                        height: 88.h,
                        child: Obx(() {
                          final selected = controller.selectedTypeId.value;
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: RemindersController.occasionTypes.length,
                            separatorBuilder: (_, _) => SizedBox(width: 10.w),
                            itemBuilder: (_, i) {
                              final type =
                                  RemindersController.occasionTypes[i];
                              final isSelected = type.id == selected;
                              return _TypeChip(
                                label: type.labelKey.tr,
                                iconAsset: type.iconAsset,
                                selected: isSelected,
                                onTap: () =>
                                    controller.selectedTypeId.value = type.id,
                              );
                            },
                          );
                        }),
                      ),
                      SizedBox(height: 18.h),
                      _FieldLabel('rem_date'.tr),
                      SizedBox(height: 8.h),
                      Obx(() {
                        final date = controller.selectedDate.value;
                        return InkWell(
                          onTap: () => controller.pickDate(context),
                          borderRadius: BorderRadius.circular(14.r),
                          child: Container(
                            height: 52.h,
                            padding: EdgeInsets.symmetric(horizontal: 14.w),
                            decoration: BoxDecoration(
                              color: _softFill,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(color: _fieldBorder),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18.sp,
                                  color: AppColors.onboardingCta,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    date == null
                                        ? 'rem_date_hint'.tr
                                        : controller.formatDate(date),
                                    style: TextStyle(
                                      fontFamily: kFontFamily,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: date == null
                                          ? AppColors.authMuted
                                              .withValues(alpha: 0.7)
                                          : AppColors.onboardingText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      SizedBox(height: 18.h),
                      _FieldLabel('rem_before'.tr),
                      SizedBox(height: 10.h),
                      Obx(() {
                        final selected = controller.remindDaysBefore.value;
                        return Row(
                          children: RemindersController.remindDayOptions
                              .map((days) {
                            final isSelected = days == selected;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: InkWell(
                                  onTap: () => controller
                                      .remindDaysBefore.value = days,
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Container(
                                    height: 44.h,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.onboardingCta
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.onboardingCta
                                            : _fieldBorder,
                                      ),
                                    ),
                                    child: Text(
                                      'rem_days_option'
                                          .trParams({'days': '$days'}),
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
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                      SizedBox(height: 18.h),
                      _FieldLabel('rem_note'.tr),
                      SizedBox(height: 8.h),
                      _NoteField(
                        initial: controller.note.value,
                        onChanged: (v) => controller.note.value = v,
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: controller.saveReminder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.onboardingCta,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            isEditing ? 'rem_update'.tr : 'rem_save'.tr,
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: kFontFamily,
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.onboardingText,
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.initial, required this.onChanged});

  final String initial;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initial,
      onChanged: onChanged,
      style: TextStyle(
        fontFamily: kFontFamily,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.onboardingText,
      ),
      decoration: InputDecoration(
        hintText: 'rem_person_hint'.tr,
        hintStyle: TextStyle(
          fontFamily: kFontFamily,
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.authMuted.withValues(alpha: 0.7),
        ),
        filled: true,
        fillColor: AddReminderSheet._softFill,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AddReminderSheet._fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AddReminderSheet._fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.onboardingCta),
        ),
      ),
    );
  }
}

class _NoteField extends StatelessWidget {
  const _NoteField({required this.initial, required this.onChanged});

  final String initial;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initial,
      onChanged: onChanged,
      maxLines: 2,
      style: TextStyle(
        fontFamily: kFontFamily,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.onboardingText,
      ),
      decoration: InputDecoration(
        hintText: 'rem_note_hint'.tr,
        hintStyle: TextStyle(
          fontFamily: kFontFamily,
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.authMuted.withValues(alpha: 0.7),
        ),
        filled: true,
        fillColor: AddReminderSheet._softFill,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AddReminderSheet._fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AddReminderSheet._fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.onboardingCta),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.iconAsset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 78.w,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.onboardingCta : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected
                ? AppColors.onboardingCta
                : AddReminderSheet._fieldBorder,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.18)
                    : AddReminderSheet._iconBg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                iconAsset,
                width: 18.w,
                height: 18.w,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.onboardingText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
