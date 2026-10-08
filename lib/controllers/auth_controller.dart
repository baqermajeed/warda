import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/token_storage.dart';

/// تحكم حالة المصادقة العامة.
class AuthController extends GetxController {
  AuthController({
    required TokenStorage tokenStorage,
    ApiClient? apiClient,
  })  : _tokenStorage = tokenStorage,
        _apiClient = apiClient;

  final TokenStorage _tokenStorage;
  ApiClient? _apiClient;

  final Rxn<User> user = Rxn<User>();
  final RxBool isLoading = true.obs;

  bool get isAuthenticated => user.value != null;

  bool _loginScheduled = false;

  /// يتحقق من الجلسة. إن لم توجد يوجّه إلى `/login` بعد انتهاء البناء الحالي.
  bool requireAuth() {
    if (isAuthenticated) return true;
    if (_loginScheduled) return false;
    _loginScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loginScheduled = false;
      if (isAuthenticated) return;
      if (Get.currentRoute == '/login') return;
      Get.toNamed('/login');
    });
    return false;
  }

  ApiClient get api {
    _apiClient ??= Get.find<ApiClient>();
    return _apiClient!;
  }

  Future<void> loadStoredAuth() async {
    isLoading.value = true;
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        user.value = null;
        return;
      }
      try {
        user.value = await api.me();
      } catch (_) {
        // Token may be stale; interceptor tries refresh. If still failing, clear.
        final still = await _tokenStorage.getAccessToken();
        if (still == null || still.isEmpty) {
          user.value = null;
        } else {
          user.value = User(id: 'local', name: 'auth_default_user'.tr);
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setSession({
    required String accessToken,
    required String refreshToken,
    required User loggedInUser,
  }) async {
    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
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
    try {
      final refresh = await _tokenStorage.getRefreshToken();
      await api.logout(refresh);
    } catch (_) {
      // ignore network errors on logout
    }
    await _tokenStorage.clearTokens();
    user.value = null;
    Get.offAllNamed('/login');
  }
}
