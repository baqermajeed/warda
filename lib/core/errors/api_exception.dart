/// استثناء يُرمى عند فشل طلب الـ API.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.code,
    this.statusCode,
  });

  factory ApiException.fromResponse(Map<String, dynamic> body, int statusCode) {
    final error = body['error'];
    if (error is Map<String, dynamic>) {
      return ApiException(
        message: error['message'] as String? ?? 'Unknown error',
        code: error['code'] as String?,
        statusCode: statusCode,
      );
    }
    final detail = body['detail'];
    final detailMessage = detail is String
        ? detail
        : (detail is List && detail.isNotEmpty
            ? detail.first.toString()
            : null);
    return ApiException(
      message: detailMessage ??
          body['message'] as String? ??
          'Unknown error',
      code: body['code'] as String?,
      statusCode: statusCode,
    );
  }

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => 'ApiException($code, $statusCode): $message';
}
