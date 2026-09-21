import 'package:dio/dio.dart';

import '../core/config/api_config.dart';
import '../core/errors/api_exception.dart';
import '../models/auth_result.dart';
import 'token_storage.dart';

/// عميل HTTP أساسي مع حقن التوكن ومعالجة 401.
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

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;
    final isAuthPublic =
        path.contains('/auth/register') || path.contains('/auth/login');
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
    if (err.response?.statusCode == 401) {
      await _tokenStorage.clearTokens();
      _onSessionExpired?.call();
    }
    handler.next(err);
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

  ApiException _toApiException(DioException e) {
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
