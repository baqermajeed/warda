import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/onboarding_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/app_spacing.dart';
import '../../widgets/common/loading/full_page_loading.dart';

/// شاشات التعريف — مطابقة لتصميم Figma Splash / Onboarding.
class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isChecking.value) {
        return const FullPageLoading();
      }

      return Scaffold(
        backgroundColor: AppColors.onboardingBg,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
                child: _OnboardingHeader(onSkip: controller.skip),
              ),
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  itemCount: OnboardingController.pages.length,
                  onPageChanged: controller.onPageChanged,
                  itemBuilder: (context, index) {
                    return _OnboardingHeroImage(
                      asset: OnboardingController.pages[index].imageAsset,
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 48.w),
                child: Column(
                  children: [
                    Obx(
                      () => _PageIndicator(
                        count: OnboardingController.pages.length,
                        activeIndex: controller.currentPage.value,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    Obx(() {
                      final page = OnboardingController
                          .pages[controller.currentPage.value];
                      return Column(
                        children: [
                          Text(
                            page.title.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 23.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onboardingText,
                              height: 1.5,
                            ),
                          ),
                          AppSpacing.verticalMd,
                          Text(
                            page.description.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onboardingText
                                  .withValues(alpha: 0.8),
                              height: 1.58,
                            ),
                          ),
                          SizedBox(height: 40.h),
                          _OnboardingCta(
                            label: page.buttonLabel.tr,
                            onPressed: controller.next,
                          ),
                        ],
                      );
                    }),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'common_app_name'.tr,
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 23.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.onboardingText,
              height: 1.5,
            ),
          ),
          Align(
            // في RTL يظهر «تخطي» يمين الشاشة كما في التصميم.
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.onboardingText,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'onboarding_skip'.tr,
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingHeroImage extends StatelessWidget {
  const _OnboardingHeroImage({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 282.w,
        height: 282.w,
        child: ClipOval(
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
            width: 282.w,
            height: 282.w,
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          width: isActive ? 23.w : 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.onboardingSoft
                : AppColors.onboardingSoft.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(8.r),
          ),
        );
      }),
    );
  }
}

class _OnboardingCta extends StatelessWidget {
  const _OnboardingCta({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.onboardingCta,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
