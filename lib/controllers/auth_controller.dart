import 'package:get/get.dart';

import '../models/user.dart';
import '../services/token_storage.dart';

/// تحكم حالة المصادقة العامة.
class AuthController extends GetxController {
  AuthController({required TokenStorage tokenStorage})
      : _tokenStorage = tokenStorage;

  final TokenStorage _tokenStorage;

  final Rxn<User> user = Rxn<User>();
  final RxBool isLoading = true.obs;

  bool get isAuthenticated => user.value != null;

  Future<void> loadStoredAuth() async {
    isLoading.value = true;
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        user.value = null;
        return;
      }
      // يمكن لاحقاً جلب بيانات المستخدم من الـ API.
      user.value = User(id: 'local', name: 'auth_default_user'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setSession({
    required String accessToken,
    required User loggedInUser,
  }) async {
    await _tokenStorage.saveAccessToken(accessToken);
    user.value = loggedInUser;
  }

  /// تحديث بيانات الملف الشخصي محليًا (حتى يتوفر API).
  void updateProfile({required String name, required String phone}) {
    final current = user.value;
    if (current == null) {
      user.value = User(id: 'local', name: name, phone: phone);
      return;
    }
    user.value = current.copyWith(name: name, phone: phone);
  }

  Future<void> logout() async {
    await _tokenStorage.clearTokens();
    user.value = null;
    Get.offAllNamed('/login');
  }
}
