import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/basket_controller.dart';
import '../../controllers/categories_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/main_shell_controller.dart';
import '../../controllers/notifications_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../screens/acount-setting/account_screen.dart';
import '../../screens/basket/basket_screen.dart';
import '../../screens/categories/categories_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../controllers/account_controller.dart';
import '../../controllers/locale_controller.dart';
import '../../screens/spicial-gift/special_gift_flow_screen.dart';

/// الهيكل الرئيسي: شريط سفلي بتصميم Figma + محتوى التبويب.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  int _bodyIndex(int navIndex) {
    switch (navIndex) {
      case 0:
        return 0; // الرئيسية
      case 1:
        return 1; // التصنيفات
      case 3:
        return 2; // السلة
      case 4:
        return 3; // الحساب
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<MainShellController>();

    return Obx(() {
      final navIndex = shell.currentIndex.value;
      // يعيد بناء التسميات عند تغيير اللغة.
      final _ = Get.find<LocaleController>().languageCode.value;
      return Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        body: IndexedStack(
          index: _bodyIndex(navIndex),
          children: const [
            HomeScreen(),
            CategoriesScreen(),
            BasketScreen(),
            AccountScreen(),
          ],
        ),
        bottomNavigationBar: _GiftsBottomNav(
          currentIndex: navIndex,
          onTap: (i) {
            if (i == 2) {
              openSpecialGiftFlow();
              return;
            }
            shell.changeTab(i);
          },
        ),
      );
    });
  }
}

/// شريط تنقل سفلي — مطابق لـ Figma node 1:7813 (393×94).
class _GiftsBottomNav extends StatelessWidget {
  const _GiftsBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// لون الأيقونات والنصوص في Figma: #4D0F14
  static const _navColor = AppColors.onboardingCta;

  /// الشفافية للعناصر غير النشطة في Figma: opacity 0.23
  static const _inactiveOpacity = 0.23;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.zero,
        child: SizedBox(
          height: 86.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 9.5.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: _NavItem(
                      label: 'nav_home'.tr,
                      outlineAsset: 'assets/icons/nav/house.svg',
                      filledAsset: 'assets/icons/nav/house_filled.svg',
                      selected: currentIndex == 0,
                      onTap: () => onTap(0),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _NavItem(
                      label: 'nav_categories'.tr,
                      outlineAsset: 'assets/icons/nav/category.svg',
                      filledAsset: 'assets/icons/nav/category.svg',
                      selected: currentIndex == 1,
                      onTap: () => onTap(1),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _CenterGiftButton(onTap: () => onTap(2)),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _NavItem(
                      label: 'nav_basket'.tr,
                      outlineAsset: 'assets/icons/nav/basket.svg',
                      filledAsset: 'assets/icons/nav/basket_filled.svg',
                      selected: currentIndex == 3,
                      onTap: () => onTap(3),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _NavItem(
                      label: 'nav_account'.tr,
                      outlineAsset: 'assets/icons/nav/user.svg',
                      filledAsset: 'assets/icons/nav/user.svg',
                      selected: currentIndex == 4,
                      onTap: () => onTap(4),
                    ),
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

class _CenterGiftButton extends StatelessWidget {
  const _CenterGiftButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Figma Ellipse 17: 49.482 — Fill radial #4D0F14 → #000000, radius 0
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 49.5.w,
        height: 49.5.w,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment.center,
            // Figma scale 54.24 / radius 24.74 ≈ يظهر الأسود عند الحافة فقط
            radius: 1.1,
            colors: [
              Color(0xFF4D0F14),
              Color(0xFF000000),
            ],
          ),
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          'assets/icons/nav/gift_icon.svg',
          width: 24.w,
          height: 22.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.outlineAsset,
    required this.filledAsset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String outlineAsset;
  final String filledAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Opacity(
        opacity: selected ? 1 : _GiftsBottomNav._inactiveOpacity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              selected ? filledAsset : outlineAsset,
              width: 30.45.w,
              height: 30.45.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 13.3.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: _GiftsBottomNav._navColor,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Binding لتسجيل Controllers الخاصة بالـ Shell.
class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MainShellController>()) {
      Get.lazyPut<MainShellController>(() => MainShellController(), fenix: true);
    }
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    }
    if (!Get.isRegistered<CategoriesController>()) {
      Get.lazyPut<CategoriesController>(
        () => CategoriesController(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<BasketController>()) {
      Get.lazyPut<BasketController>(() => BasketController(), fenix: true);
    }
    if (!Get.isRegistered<AccountController>()) {
      Get.lazyPut<AccountController>(() => AccountController(), fenix: true);
    }
    if (!Get.isRegistered<NotificationsController>()) {
      Get.lazyPut<NotificationsController>(
        () => NotificationsController(),
        fenix: true,
      );
    }
  }
}
