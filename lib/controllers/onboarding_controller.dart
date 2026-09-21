import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// منطق شاشات التعريف (Onboarding).
class OnboardingController extends GetxController {
  static const _seenKey = 'onboarding_seen';

  final pageController = PageController();
  final RxInt currentPage = 0.obs;
  final RxBool isChecking = true.obs;
  final RxBool hasSeenOnboarding = false.obs;

  static const pages = <OnboardingPageData>[
    OnboardingPageData(
      imageAsset: 'assets/images/onboarding/step_1.png',
      title: 'onboarding_1_title',
      description: 'onboarding_1_desc',
      buttonLabel: 'common_next',
    ),
    OnboardingPageData(
      imageAsset: 'assets/images/onboarding/step_2.png',
      title: 'onboarding_2_title',
      description: 'onboarding_2_desc',
      buttonLabel: 'common_next',
    ),
    OnboardingPageData(
      imageAsset: 'assets/images/onboarding/step_3.png',
      title: 'onboarding_3_title',
      description: 'onboarding_3_desc',
      buttonLabel: 'onboarding_start',
    ),
  ];

  bool get isLastPage => currentPage.value >= pages.length - 1;

  @override
  void onInit() {
    super.onInit();
    _loadSeenFlag();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  Future<void> _loadSeenFlag() async {
    final prefs = await SharedPreferences.getInstance();
    hasSeenOnboarding.value = prefs.getBool(_seenKey) ?? false;
    isChecking.value = false;
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void next() {
    if (isLastPage) {
      complete();
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void skip() => complete();

  Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey, true);
    hasSeenOnboarding.value = true;
    Get.offAllNamed('/login');
  }
}

/// بيانات صفحة واحدة داخل الـ onboarding.
class OnboardingPageData {
  const OnboardingPageData({
    required this.imageAsset,
    required this.title,
    required this.description,
    required this.buttonLabel,
  });

  final String imageAsset;
  final String title;
  final String description;
  final String buttonLabel;
}
