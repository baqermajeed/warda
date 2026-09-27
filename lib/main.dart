import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'controllers/auth_controller.dart';
import 'controllers/locale_controller.dart';
import 'controllers/login_controller.dart';
import 'controllers/onboarding_controller.dart';
import 'controllers/signup_controller.dart';
import 'controllers/theme_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/translations/app_translations.dart';
import 'controllers/basket_controller.dart';
import 'controllers/categories_controller.dart';
import 'controllers/favorites_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/orders_controller.dart';
import 'controllers/product_details_controller.dart';
import 'controllers/reminders_controller.dart';
import 'controllers/faq_controller.dart';
import 'controllers/support_controller.dart';
import 'controllers/privacy_controller.dart';
import 'controllers/share_app_controller.dart';
import 'controllers/special_gift_controller.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/basket/addons_screen.dart';
import 'screens/basket/gift_card_customize_screen.dart';
import 'screens/basket/wrapping_screen.dart';
import 'screens/categories/filter_sort_screen.dart';
import 'screens/categories/search_results_screen.dart';
import 'screens/categories/search_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/order/order_payment_screen.dart';
import 'screens/order/order_success_screen.dart';
import 'screens/order/order_user_info_screen.dart';
import 'screens/orders/order_details_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/prodect-deteals/product_details_screen.dart';
import 'screens/reminders/reminders_screen.dart';
import 'screens/faq/faq_screen.dart';
import 'screens/support/support_screen.dart';
import 'screens/privacy/privacy_screen.dart';
import 'screens/share/share_app_screen.dart';
import 'screens/spicial-gift/special_gift_flow_screen.dart';
import 'screens/spicial-gift/special_gift_results_screen.dart';
import 'services/api_client.dart';
import 'services/token_storage.dart';
import 'widgets/common/loading/full_page_loading.dart';
import 'widgets/shell/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final tokenStorage = TokenStorage();
  Get.put(tokenStorage, permanent: true);
  final auth = Get.put(AuthController(tokenStorage: tokenStorage), permanent: true);
  Get.put(
    ApiClient(
      tokenStorage: tokenStorage,
      onSessionExpired: () {
        auth.user.value = null;
        Get.offAllNamed('/login');
      },
    ),
    permanent: true,
  );
  Get.put(ThemeController(), permanent: true);
  final localeController = Get.put(LocaleController(), permanent: true);
  await localeController.ensureLoaded();
  Get.put(OnboardingController(), permanent: true);

  Get.find<AuthController>().loadStoredAuth();

  runApp(const WardaApp());
}

class WardaApp extends StatelessWidget {
  const WardaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => Obx(() {
        final theme = Get.find<ThemeController>();
        return GetMaterialApp(
          title: 'warda',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.themeMode,
          translations: AppTranslations(),
          locale: Get.locale ?? const Locale('ar'),
          fallbackLocale: const Locale('ar'),
          builder: (context, child) => Obx(() {
            final dir = Get.find<LocaleController>().textDirection;
            return Directionality(
              textDirection: dir,
              child: child!,
            );
          }),
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => const AuthWrapper()),
            GetPage(
              name: '/onboarding',
              page: () => const OnboardingScreen(),
            ),
            GetPage(
              name: '/login',
              page: () => const LoginScreen(),
              binding: BindingsBuilder(() {
                Get.lazyPut<LoginController>(
                  () => LoginController(),
                  fenix: true,
                );
              }),
            ),
            GetPage(
              name: '/signup',
              page: () => const SignupScreen(),
              binding: BindingsBuilder(() {
                Get.lazyPut<SignupController>(
                  () => SignupController(),
                  fenix: true,
                );
              }),
            ),
            GetPage(
              name: '/home',
              page: () => const MainShell(),
              binding: MainShellBinding(),
            ),
            GetPage(
              name: '/search',
              page: () => const SearchScreen(),
              binding: BindingsBuilder(() {
                if (!Get.isRegistered<CategoriesController>()) {
                  Get.lazyPut<CategoriesController>(
                    () => CategoriesController(),
                    fenix: true,
                  );
                }
              }),
            ),
            GetPage(
              name: '/search-results',
              page: () => const SearchResultsScreen(),
              binding: BindingsBuilder(() {
                if (!Get.isRegistered<CategoriesController>()) {
                  Get.lazyPut<CategoriesController>(
                    () => CategoriesController(),
                    fenix: true,
                  );
                }
              }),
            ),
            GetPage(
              name: '/filter-sort',
              page: () => const FilterSortScreen(),
              binding: BindingsBuilder(() {
                if (!Get.isRegistered<CategoriesController>()) {
                  Get.lazyPut<CategoriesController>(
                    () => CategoriesController(),
                    fenix: true,
                  );
                }
              }),
            ),
            GetPage(
              name: '/favorites',
              page: () => const FavoritesScreen(),
              binding: BindingsBuilder(() {
                Get.lazyPut<FavoritesController>(
                  () => FavoritesController(),
                  fenix: true,
                );
              }),
            ),
            GetPage(
              name: '/basket/gift-card',
              page: () => const GiftCardCustomizeScreen(),
              binding: BindingsBuilder(_ensureBasket),
            ),
            GetPage(
              name: '/basket/wrapping',
              page: () => const WrappingScreen(),
              binding: BindingsBuilder(_ensureBasket),
            ),
            GetPage(
              name: '/basket/addons',
              page: () => const AddonsScreen(),
              binding: BindingsBuilder(_ensureBasket),
            ),
            GetPage(
              name: '/order/user-info',
              page: () => const OrderUserInfoScreen(),
              binding: BindingsBuilder(_ensureOrder),
            ),
            GetPage(
              name: '/order/payment',
              page: () => const OrderPaymentScreen(),
              binding: BindingsBuilder(_ensureOrder),
            ),
            GetPage(
              name: '/order/success',
              page: () => const OrderSuccessScreen(),
              binding: BindingsBuilder(_ensureOrder),
            ),
            GetPage(
              name: '/product-details',
              page: () => const ProductDetailsScreen(),
              binding: BindingsBuilder(() {
                Get.delete<ProductDetailsController>(force: true);
                Get.put(ProductDetailsController());
              }),
            ),
            GetPage(
              name: '/special-gift',
              page: () => const SpecialGiftFlowScreen(),
              opaque: false,
              transition: Transition.fadeIn,
              binding: BindingsBuilder(() {
                if (!Get.isRegistered<SpecialGiftController>()) {
                  Get.lazyPut<SpecialGiftController>(
                    () => SpecialGiftController(),
                    fenix: true,
                  );
                }
              }),
            ),
            GetPage(
              name: '/special-gift/results',
              page: () => const SpecialGiftResultsScreen(),
              binding: BindingsBuilder(() {
                if (!Get.isRegistered<SpecialGiftController>()) {
                  Get.lazyPut<SpecialGiftController>(
                    () => SpecialGiftController(),
                    fenix: true,
                  );
                }
              }),
            ),
            GetPage(
              name: '/orders',
              page: () => const OrdersScreen(),
              binding: BindingsBuilder(_ensureOrders),
            ),
            GetPage(
              name: '/orders/details',
              page: () => const OrderDetailsScreen(),
              binding: BindingsBuilder(_ensureOrders),
            ),
            GetPage(
              name: '/reminders',
              page: () => const RemindersScreen(),
              binding: BindingsBuilder(() {
                Get.lazyPut<RemindersController>(
                  () => RemindersController(),
                  fenix: true,
                );
              }),
            ),
            GetPage(
              name: '/faq',
              page: () => const FaqScreen(),
              binding: BindingsBuilder(() {
                Get.lazyPut<FaqController>(
                  () => FaqController(),
                  fenix: true,
                );
              }),
            ),
            GetPage(
              name: '/support',
              page: () => const SupportScreen(),
              binding: BindingsBuilder(() {
                Get.lazyPut<SupportController>(
                  () => SupportController(),
                  fenix: true,
                );
              }),
            ),
            GetPage(
              name: '/privacy',
              page: () => const PrivacyScreen(),
              binding: BindingsBuilder(() {
                Get.lazyPut<PrivacyController>(
                  () => PrivacyController(),
                  fenix: true,
                );
              }),
            ),
            GetPage(
              name: '/share',
              page: () => const ShareAppScreen(),
              binding: BindingsBuilder(() {
                Get.lazyPut<ShareAppController>(
                  () => ShareAppController(),
                  fenix: true,
                );
              }),
            ),
          ],
        );
      }),
    );
  }
}

void _ensureBasket() {
  if (!Get.isRegistered<BasketController>()) {
    Get.lazyPut<BasketController>(() => BasketController(), fenix: true);
  }
}

void _ensureOrder() {
  _ensureBasket();
  if (!Get.isRegistered<OrderController>()) {
    Get.lazyPut<OrderController>(() => OrderController(), fenix: true);
  }
}

void _ensureOrders() {
  if (!Get.isRegistered<OrdersController>()) {
    Get.lazyPut<OrdersController>(() => OrdersController(), fenix: true);
  }
}

/// يحدد الصفحة الأولى حسب حالة المصادقة والتعريف.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  void _ensureShellBindings() {
    MainShellBinding().dependencies();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final onboarding = Get.find<OnboardingController>();

    return Obx(() {
      if (auth.isLoading.value || onboarding.isChecking.value) {
        return const FullPageLoading();
      }
      if (auth.isAuthenticated) {
        _ensureShellBindings();
        return const MainShell();
      }
      if (!onboarding.hasSeenOnboarding.value) {
        return const OnboardingScreen();
      }
      if (!Get.isRegistered<LoginController>()) {
        Get.put(LoginController());
      }
      return const LoginScreen();
    });
  }
}
