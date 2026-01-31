import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// API Result wrapper
class ApiResult<T> {
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResult.success(this.data)
      : error = null,
        statusCode = 200;

  ApiResult.error(this.error, {this.statusCode})
      : data = null;

  bool get isSuccess => error == null;
  bool get isError => error != null;
}

/// HTTP API Client for Supabase Edge Functions
class ApiClient {
  final String _baseUrl;
  String? _authToken;

  ApiClient({String? baseUrl}) : _baseUrl = baseUrl ?? ApiConfig.functionsUrl;

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  /// Default headers
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'apikey': ApiConfig.supabaseAnonKey,
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  /// GET request
  Future<ApiResult<Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Duration? timeout,
  }) async {
    try {
      var uri = Uri.parse('$_baseUrl$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http
          .get(uri, headers: _headers)
          .timeout(timeout ?? ApiConfig.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      return ApiResult.error(e.toString());
    }
  }

  /// POST request
  Future<ApiResult<Map<String, dynamic>>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');

      final response = await http
          .post(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout ?? ApiConfig.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      return ApiResult.error(e.toString());
    }
  }

  /// Handle HTTP response
  ApiResult<Map<String, dynamic>> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResult.success(data);
      } else {
        final errorMessage = data['error'] ?? data['message'] ?? 'Unknown error';
        return ApiResult.error(
          _getErrorMessage(response.statusCode, errorMessage),
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResult.error(
        'Failed to parse response: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage(int statusCode, String serverMessage) {
    switch (statusCode) {
      case 401:
        return 'Oturum süresi doldu. Lütfen tekrar giriş yapın.';
      case 402:
        return 'Yetersiz kredi. Lütfen kredi satın alın.';
      case 403:
        return 'Bu işlem için yetkiniz yok.';
      case 404:
        return 'İstenen kaynak bulunamadı.';
      case 409:
        return serverMessage; // Usually specific conflict message
      case 429:
        return 'Çok fazla istek gönderdiniz. Lütfen biraz bekleyin.';
      case 500:
        return 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.';
      default:
        return serverMessage;
    }
  }
}
