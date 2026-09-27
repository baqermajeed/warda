import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/basket_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/app_image.dart';

/// صفحة تخصيص بطاقة الأهداء.
class GiftCardCustomizeScreen extends GetView<BasketController> {
  const GiftCardCustomizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          size: 18.sp,
                          color: AppColors.onboardingText,
                        ),
                      ),
                      Text(
                        'gift_card_title'.tr,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onboardingText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'gift_card_choose'.tr,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingText,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  SizedBox(
                    height: 186.h,
                    child: Obx(() {
                      final selectedId = controller.selectedCardId.value;
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.giftCards.length,
                        separatorBuilder: (_, _) => SizedBox(width: 12.w),
                        itemBuilder: (context, index) {
                          final card = controller.giftCards[index];
                          final selected = selectedId == card.id;
                          return _CardOption(
                            card: card,
                            selected: selected,
                            priceLabel: controller.money(card.price),
                            onTap: () => controller.selectCard(card.id),
                          );
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 22.h),
                  Text(
                    'gift_card_message'.tr,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingText,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          hint: 'gift_card_to_hint'.tr,
                          onChanged: (v) => controller.giftTo.value = v,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _Field(
                          hint: 'gift_card_from_hint'.tr,
                          onChanged: (v) => controller.giftFrom.value = v,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  _MessageField(controller: controller),
                  SizedBox(height: 10.h),
                  _ActionRow(
                    label: 'gift_card_try_suggested'.tr,
                    filled: false,
                    onTap: () {},
                  ),
                  SizedBox(height: 22.h),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onboardingText,
                      ),
                      children: [
                        TextSpan(text: '${'gift_card_add_signature'.tr} '),
                        TextSpan(
                          text: 'gift_card_optional'.tr,
                          style: const TextStyle(color: AppColors.authLink),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 14.h),
                  _ActionRow(
                    label: 'gift_card_tap_to_add'.tr,
                    filled: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            _BottomActions(
              onPreview: () {},
              onSave: () async {
                await controller.persistOptions();
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CardOption extends StatelessWidget {
  const _CardOption({
    required this.card,
    required this.selected,
    required this.priceLabel,
    required this.onTap,
  });

  final BasketOption card;
  final bool selected;
  final String priceLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
                  border: selected
                      ? Border.all(color: AppColors.onboardingCta, width: 1.6)
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
                  child: AppImage(
                    source: card.imageAsset,
                    fit: BoxFit.cover,
                    fallbackAsset: 'assets/images/basket/card_1.jpg',
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '$priceLabel | ${card.title}',
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.onboardingCta,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageField extends StatelessWidget {
  const _MessageField({required this.controller});

  final BasketController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Field(
          hint: 'gift_card_write_hint'.tr,
          maxLines: 5,
          minHeight: 121.h,
          onChanged: (v) => controller.giftMessage.value = v,
        ),
        SizedBox(height: 6.h),
        Obx(
          () => Text(
            'gift_card_chars_left'.trParams({'count': '${controller.messageRemaining}'}),
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 12.sp,
              color: AppColors.authMuted.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.hint,
    required this.onChanged,
    this.maxLines = 1,
    this.minHeight,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight ?? 44.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFF3A3F41).withValues(alpha: 0.23),
        ),
      ),
      child: TextField(
        maxLines: maxLines,
        maxLength: maxLines > 1 ? BasketController.messageMax : null,
        textAlign: TextAlign.right,
        onChanged: onChanged,
        style: TextStyle(
          fontFamily: kFontFamily,
          fontSize: 14.sp,
          color: AppColors.onboardingText,
        ),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          counterText: '',
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 14.sp,
            color: AppColors.authMuted.withValues(alpha: 0.46),
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: filled
              ? AppColors.onboardingCta.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          border: filled
              ? null
              : Border.all(
                  color: AppColors.onboardingCta.withValues(alpha: 0.44),
                ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.chevron_left,
              color: AppColors.onboardingCta,
              size: 22.sp,
            ),
            const Spacer(),
            Text(
              label,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.onboardingCta.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.onPreview, required this.onSave});

  final VoidCallback onPreview;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(23.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppColors.onboardingCta.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(23.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50.h,
                child: TextButton(
                  onPressed: onPreview,
                  child: Text(
                    'gift_card_preview'.tr,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onboardingCta,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 50.h,
                child: ElevatedButton(
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.onboardingCta,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(23.r),
                    ),
                  ),
                  child: Text(
                    'gift_card_save'.tr,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
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
