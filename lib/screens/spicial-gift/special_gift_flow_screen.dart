import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/special_gift_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// يفتح مودال هدية مخصصة فوق الشاشة الحالية.
Future<void> openSpecialGiftFlow() async {
  if (!Get.isRegistered<SpecialGiftController>()) {
    Get.put(SpecialGiftController(), permanent: false);
  } else {
    Get.find<SpecialGiftController>().reset();
  }

  final context = Get.overlayContext;
  if (context == null) return;

  // دخول بأنيميشن لطيف — خروج فوري بدون أنيميشن
  await Navigator.of(context, rootNavigator: true).push<void>(
    _SpecialGiftDialogRoute(
      pageBuilder: (context, animation, secondaryAnimation) {
        return SpecialGiftFlowScreen(animation: animation);
      },
    ),
  );
}

/// Dialog route: دخول متحرك / خروج فوري (متوافق مع Flutter 3.24).
class _SpecialGiftDialogRoute<T> extends PopupRoute<T> {
  _SpecialGiftDialogRoute({required this.pageBuilder});

  final RoutePageBuilder pageBuilder;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'special-gift';

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 320);

  @override
  Duration get reverseTransitionDuration => Duration.zero;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return pageBuilder(context, animation, secondaryAnimation);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

/// تدفق هدية مخصصة — مودال فوق الصفحة (Figma 1:3006).
class SpecialGiftFlowScreen extends GetView<SpecialGiftController> {
  const SpecialGiftFlowScreen({
    super.key,
    this.animation = kAlwaysCompleteAnimation,
  });

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    // ارتفاع الناف بار (86) + SafeArea — تبقى واضحة بدون ضبابية
    final clearNavHeight = 86.h + bottomInset;
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // التضبيب ثابت بكامل قوته من أول إطار
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: clearNavHeight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Get.back(),
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    color: const Color(0x99333333),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, clearNavHeight + 8.h),
              child: FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.12),
                    end: Offset.zero,
                  ).animate(curved),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
                    alignment: Alignment.bottomCenter,
                    child: Obx(() {
                      final step = controller.currentStep.value;
                      final selectedId = controller.selectedOptionId;
                      return _SpecialGiftSheet(
                        step: step,
                        selectedId: selectedId,
                        title: controller.stepTitle,
                        stepLabel: controller.stepLabel,
                        stepColor: controller.stepColor,
                        buttonLabel: controller.primaryButtonLabel,
                        options: controller.currentOptions,
                        onSelect: controller.selectOption,
                        onNext: controller.next,
                        budgetFromChanged: (v) =>
                            controller.budgetFrom.value = v,
                        budgetToChanged: (v) => controller.budgetTo.value = v,
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialGiftSheet extends StatelessWidget {
  const _SpecialGiftSheet({
    required this.step,
    required this.selectedId,
    required this.title,
    required this.stepLabel,
    required this.stepColor,
    required this.buttonLabel,
    required this.options,
    required this.onSelect,
    required this.onNext,
    required this.budgetFromChanged,
    required this.budgetToChanged,
  });

  final int step;
  final String? selectedId;
  final String title;
  final String stepLabel;
  final Color stepColor;
  final String buttonLabel;
  final List<SpecialGiftOption> options;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;
  final ValueChanged<String> budgetFromChanged;
  final ValueChanged<String> budgetToChanged;

  @override
  Widget build(BuildContext context) {
    final isIntro = step == 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 354.w,
          padding: EdgeInsets.fromLTRB(
            24.w,
            isIntro ? 36.h : 28.h,
            24.w,
            20.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 0.7.sh),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isIntro)
                    const _IntroContent()
                  else ...[
                    Row(
                      children: [
                        _StepBadge(
                          label: stepLabel,
                          color: stepColor,
                          progress: step / 4,
                        ),
                        Expanded(
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onboardingCta,
                              height: 1.4,
                            ),
                          ),
                        ),
                        SizedBox(width: 40.w),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    if (step < 4)
                      _OptionsGrid(
                        options: options,
                        selectedId: selectedId,
                        onSelect: onSelect,
                      )
                    else
                      _BudgetFields(
                        onFromChanged: budgetFromChanged,
                        onToChanged: budgetToChanged,
                      ),
                  ],
                  SizedBox(height: isIntro ? 26.h : 20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.onboardingCta,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23.r),
                        ),
                      ),
                      child: Text(
                        buttonLabel,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        CustomPaint(
          size: Size(28.w, 12.h),
          painter: _SheetPointerPainter(),
        ),
      ],
    );
  }
}

/// صفحة المقدمة — Figma 1:3007 «كوّن هديتك»
class _IntroContent extends StatelessWidget {
  const _IntroContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/spicial-gift/intro_gift.png',
          width: 101.w,
          height: 101.w,
          fit: BoxFit.contain,
          cacheWidth: 220,
        ),
        SizedBox(height: 23.h),
        Text(
          'sg_title'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.onboardingCta,
            height: 1.4,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'sg_intro_body'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.onboardingCta,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({
    required this.label,
    required this.color,
    required this.progress,
  });

  final String label;
  final Color color;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 40.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 40.w,
            height: 40.w,
            child: CircularProgressIndicator(
              value: progress.clamp(0.05, 1),
              strokeWidth: 3,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionsGrid extends StatelessWidget {
  const _OptionsGrid({
    required this.options,
    required this.selectedId,
    required this.onSelect,
  });

  final List<SpecialGiftOption> options;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const crossCount = 3;
        final gap = 10.w;
        final itemW = (constraints.maxWidth - gap * (crossCount - 1)) / crossCount;

        return Wrap(
          spacing: gap,
          runSpacing: 14.h,
          children: options.map((option) {
            final width =
                option.span == 2 ? (itemW * 2 + gap) : itemW;
            return SizedBox(
              width: width,
              child: _OptionTile(
                option: option,
                selected: selectedId == option.id,
                onTap: () => onSelect(option.id),
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final SpecialGiftOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26.r),
        child: Container(
          height: 86.h,
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.onboardingCta.withValues(alpha: 0.16)
                : AppColors.onboardingCta.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(26.r),
            border: selected
                ? Border.all(color: AppColors.onboardingCta, width: 1.2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 34.w,
                height: 34.w,
                child: SvgPicture.asset(
                  option.iconAsset,
                  fit: BoxFit.contain,
                  placeholderBuilder: (_) => SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                option.label.tr,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onboardingText,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetFields extends StatelessWidget {
  const _BudgetFields({
    required this.onFromChanged,
    required this.onToChanged,
  });

  final ValueChanged<String> onFromChanged;
  final ValueChanged<String> onToChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BudgetRow(
          label: 'sg_budget_from'.tr,
          hint: 'sg_budget_min_hint'.tr,
          onChanged: onFromChanged,
        ),
        SizedBox(height: 14.h),
        _BudgetRow(
          label: 'sg_budget_to'.tr,
          hint: 'sg_budget_max_hint'.tr,
          onChanged: onToChanged,
        ),
      ],
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0x334D0F14)),
            ),
            child: Row(
              children: [
                Text(
                  'common_currency_iqd'.tr,
                  style: TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.authLink,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    onChanged: onChanged,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 14.sp,
                      color: AppColors.onboardingText,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 13.sp,
                        color: AppColors.authLink.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        SizedBox(
          width: 36.w,
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.onboardingCta,
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetPointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
