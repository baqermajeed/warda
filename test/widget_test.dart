import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:warda/controllers/auth_controller.dart';
import 'package:warda/controllers/onboarding_controller.dart';
import 'package:warda/controllers/theme_controller.dart';
import 'package:warda/main.dart';
import 'package:warda/services/token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    final tokenStorage = TokenStorage();
    Get.put(tokenStorage, permanent: true);
    Get.put(AuthController(tokenStorage: tokenStorage), permanent: true);
    Get.put(ThemeController(), permanent: true);
    Get.put(OnboardingController(), permanent: true);
    Get.find<AuthController>().isLoading.value = false;
    Get.find<OnboardingController>().isChecking.value = false;
    Get.find<OnboardingController>().hasSeenOnboarding.value = true;
  });

  tearDown(Get.reset);

  testWidgets('shows login screen for guest after onboarding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const WardaApp());
    await tester.pumpAndSettle();

    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('وردة'), findsWidgets);
  });
}
