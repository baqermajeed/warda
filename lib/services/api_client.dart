import 'package:dio/dio.dart';

import '../core/config/api_config.dart';
import '../core/errors/api_exception.dart';
import '../models/auth_result.dart';
import '../models/user.dart';
import 'token_storage.dart';

/// عميل HTTP أساسي مع حقن التوكن وتجديد الجلسة ومعالجة 401.
class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    void Function()? onSessionExpired,
  })  : _tokenStorage = tokenStorage,
        _onSessionExpired = onSessionExpired {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  final TokenStorage _tokenStorage;
  final void Function()? _onSessionExpired;
  late final Dio _dio;
  bool _refreshing = false;

  Dio get raw => _dio;

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;
    final isAuthPublic = path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh');
    if (!isAuthPublic) {
      final token = await _tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_refreshing) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        try {
          final req = err.requestOptions;
          final token = await _tokenStorage.getAccessToken();
          if (token != null) {
            req.headers['Authorization'] = 'Bearer $token';
          }
          final response = await _dio.fetch(req);
          handler.resolve(response);
          return;
        } catch (_) {}
      }
      await _tokenStorage.clearTokens();
      _onSessionExpired?.call();
    }
    handler.next(err);
  }

  Future<bool> _tryRefresh() async {
    final refresh = await _tokenStorage.getRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;
    _refreshing = true;
    try {
      final response = await Dio(BaseOptions(baseUrl: ApiConfig.baseUrl)).post(
        '${ApiConfig.authPrefix}/refresh',
        data: {'refresh_token': refresh},
      );
      final data = response.data as Map<String, dynamic>;
      final access = data['access_token'] as String?;
      final newRefresh = data['refresh_token'] as String?;
      if (access == null || newRefresh == null) return false;
      await _tokenStorage.saveTokens(
        accessToken: access,
        refreshToken: newRefresh,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      _refreshing = false;
    }
  }

  Future<AuthResult> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.authPrefix}/login',
        data: {'phone': phone, 'password': password},
      );
      return AuthResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<AuthResult> register({
    required String phone,
    required String password,
    required String name,
    required String governorate,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.authPrefix}/register',
        data: {
          'phone': phone,
          'password': password,
          'name': name,
          'governorate': governorate,
        },
      );
      return AuthResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<User> me() async {
    try {
      final response = await _dio.get('${ApiConfig.authPrefix}/me');
      return User.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<User> updateProfile(Map<String, dynamic> body) async {
    try {
      final response = await _dio.patch('${ApiConfig.authPrefix}/me', data: body);
      return User.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<void> logout(String? refreshToken) async {
    try {
      await _dio.post(
        '${ApiConfig.authPrefix}/logout',
        data: {'refresh_token': refreshToken},
      );
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _dio.delete('${ApiConfig.authPrefix}/me');
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> getHome() async {
    try {
      final response = await _dio.get('${ApiConfig.apiPrefix}/home');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> getProducts({
    String? q,
    String? person,
    String? occasion,
    String? giftType,
    String? budget,
    String? delivery,
    int? categoryId,
    String sort = 'newest',
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.apiPrefix}/products',
        queryParameters: {
          if (q != null && q.isNotEmpty) 'q': q,
          if (person != null) 'person': person,
          if (occasion != null) 'occasion': occasion,
          if (giftType != null) 'gift_type': giftType,
          if (budget != null) 'budget': budget,
          if (delivery != null) 'delivery': delivery,
          if (categoryId != null) 'category_id': categoryId,
          'sort': sort,
          'page': page,
          'page_size': pageSize,
        },
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> getProduct(int id) async {
    try {
      final response = await _dio.get('${ApiConfig.apiPrefix}/products/$id');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> getLookups() async {
    try {
      final response = await _dio.get('${ApiConfig.apiPrefix}/lookups');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> getFavorites({
    String? category,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.apiPrefix}/favorites',
        queryParameters: {
          if (category != null) 'category': category,
          'page': page,
        },
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<void> addFavorite(int productId) async {
    try {
      await _dio.put('${ApiConfig.apiPrefix}/favorites/$productId');
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<void> removeFavorite(int productId) async {
    try {
      await _dio.delete('${ApiConfig.apiPrefix}/favorites/$productId');
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await _dio.get('${ApiConfig.apiPrefix}/cart');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> addCartItem({
    required int productId,
    int qty = 1,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.apiPrefix}/cart/items',
        data: {'product_id': productId, 'qty': qty},
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> updateCartItem({
    required int itemId,
    required int qty,
  }) async {
    try {
      final response = await _dio.patch(
        '${ApiConfig.apiPrefix}/cart/items/$itemId',
        data: {'qty': qty},
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> deleteCartItem(int itemId) async {
    try {
      final response =
          await _dio.delete('${ApiConfig.apiPrefix}/cart/items/$itemId');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<void> clearCart() async {
    try {
      await _dio.delete('${ApiConfig.apiPrefix}/cart');
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> updateCartOptions(
    Map<String, dynamic> body,
  ) async {
    try {
      final response =
          await _dio.put('${ApiConfig.apiPrefix}/cart/options', data: body);
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<List<dynamic>> getGiftCards() async {
    try {
      final response = await _dio.get('${ApiConfig.apiPrefix}/gift-cards');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<List<dynamic>> getWraps() async {
    try {
      final response = await _dio.get('${ApiConfig.apiPrefix}/wraps');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<List<dynamic>> getAddons({String? category}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.apiPrefix}/addons',
        queryParameters: {
          if (category != null) 'category': category,
        },
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> body) async {
    try {
      final response =
          await _dio.post('${ApiConfig.apiPrefix}/orders', data: body);
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> getOrders({int page = 1}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.apiPrefix}/orders',
        queryParameters: {'page': page},
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> getOrder(int id) async {
    try {
      final response = await _dio.get('${ApiConfig.apiPrefix}/orders/$id');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<void> reorder(int id) async {
    try {
      await _dio.post('${ApiConfig.apiPrefix}/orders/$id/reorder');
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> specialGiftOptions() async {
    try {
      final response =
          await _dio.get('${ApiConfig.apiPrefix}/special-gift/options');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> specialGiftRecommend(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.apiPrefix}/special-gift/recommend',
        data: body,
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<List<dynamic>> getReminders() async {
    try {
      final response = await _dio.get('${ApiConfig.apiPrefix}/reminders');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> createReminder(Map<String, dynamic> body) async {
    try {
      final response =
          await _dio.post('${ApiConfig.apiPrefix}/reminders', data: body);
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> updateReminder(
    int id,
    Map<String, dynamic> body,
  ) async {
    try {
      final response =
          await _dio.put('${ApiConfig.apiPrefix}/reminders/$id', data: body);
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<void> deleteReminder(int id) async {
    try {
      await _dio.delete('${ApiConfig.apiPrefix}/reminders/$id');
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> getFaq() async {
    try {
      final response = await _dio.get('${ApiConfig.apiPrefix}/faq');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> getPrivacy() async {
    try {
      final response = await _dio.get('${ApiConfig.apiPrefix}/privacy');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> getSupportContact() async {
    try {
      final response = await _dio.get('${ApiConfig.apiPrefix}/support/contact');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<void> createSupportTicket(Map<String, dynamic> body) async {
    try {
      await _dio.post('${ApiConfig.apiPrefix}/support/tickets', data: body);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> getShare() async {
    try {
      final response = await _dio.get('${ApiConfig.apiPrefix}/app/share');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> getProductShare(int id) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.apiPrefix}/products/$id/share',
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> getNotifications({int page = 1}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.apiPrefix}/notifications',
        queryParameters: {'page': page},
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<int> getUnreadNotificationsCount() async {
    try {
      final response = await _dio.get(
        '${ApiConfig.apiPrefix}/notifications/unread-count',
      );
      return ((response.data as Map)['count'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<void> markNotificationRead(int id) async {
    try {
      await _dio.post('${ApiConfig.apiPrefix}/notifications/$id/read');
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await _dio.post('${ApiConfig.apiPrefix}/notifications/read-all');
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'تعذر الاتصال بالخادم. تأكد أن الـ API يعمل وأن العنوان صحيح.',
        code: 'NETWORK_ERROR',
        statusCode: e.response?.statusCode,
      );
    }
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return ApiException.fromResponse(data, e.response?.statusCode ?? 0);
    }
    return ApiException(
      message: e.message ?? 'Network error',
      statusCode: e.response?.statusCode,
    );
  }
}
