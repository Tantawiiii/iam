import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../main.dart';
import '../constant/app_texts.dart';
import '../routing/app_routes.dart';
import 'api_constants.dart';
import '../services/storage_service.dart';

class DioClient {
  DioClient({required StorageService storageService})
    : _storageService = storageService {
    final initialLanguage = storageService.getLanguageCode() ?? 'ar';

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'lang': initialLanguage,
        },
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    _setupInterceptors();
  }

  late final Dio _dio;
  final StorageService _storageService;
  bool _isShowingUnauthorizedDialog = false;
  String? _cachedToken;

  /// Check if user is currently on home screen
  bool _isOnHomeScreen() {
    final context = navigatorKey.currentContext;
    if (context == null) return false;

    // Check if current route is home
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == AppRoutes.home) {
      return true;
    }

    return false;
  }

  /// Check if endpoint should show login dialog even for guests
  /// Returns false if user is on home screen (to avoid showing dialog in home)
  bool _shouldShowDialogForGuest(String path) {
    // Don't show dialog if user is on home screen
    if (_isOnHomeScreen()) {
      return false;
    }

    final guestDialogEndpoints = [
      ApiConstants.cart,
      ApiConstants.favorite,
      ApiConstants.createOrder,
    ];

    String normalizedPath = path.trim();
    if (normalizedPath.contains('?')) {
      normalizedPath = normalizedPath.split('?').first;
    }
    if (normalizedPath.endsWith('/') && normalizedPath.length > 1) {
      normalizedPath = normalizedPath.substring(0, normalizedPath.length - 1);
    }

    for (final endpoint in guestDialogEndpoints) {
      String normalizedEndpoint = endpoint;
      if (normalizedEndpoint.endsWith('/') && normalizedEndpoint.length > 1) {
        normalizedEndpoint = normalizedEndpoint.substring(
          0,
          normalizedEndpoint.length - 1,
        );
      }

      if (normalizedPath == normalizedEndpoint ||
          normalizedPath.startsWith('$normalizedEndpoint/') ||
          normalizedPath.startsWith('$normalizedEndpoint?')) {
        return true;
      }
    }

    return false;
  }

  bool _requiresAuth(String path) {
    final publicEndpoints = [
      ApiConstants.categories,
      ApiConstants.brands,
      ApiConstants.cards,
      ApiConstants.offers,
      ApiConstants.register,
      ApiConstants.login,
      ApiConstants.verifyOtp,
      ApiConstants.contactUs,
    ];

    String normalizedPath = path.trim();

    if (normalizedPath.contains('?')) {
      normalizedPath = normalizedPath.split('?').first;
    }

    if (normalizedPath.endsWith('/') && normalizedPath.length > 1) {
      normalizedPath = normalizedPath.substring(0, normalizedPath.length - 1);
    }

    if (normalizedPath.startsWith('http')) {
      try {
        final uri = Uri.parse(normalizedPath);
        normalizedPath = uri.path;

        if (normalizedPath.endsWith('/') && normalizedPath.length > 1) {
          normalizedPath = normalizedPath.substring(
            0,
            normalizedPath.length - 1,
          );
        }
      } catch (_) {}
    }

    // Check if path matches any public endpoint
    for (final endpoint in publicEndpoints) {
      String normalizedEndpoint = endpoint;
      if (normalizedEndpoint.endsWith('/') && normalizedEndpoint.length > 1) {
        normalizedEndpoint = normalizedEndpoint.substring(
          0,
          normalizedEndpoint.length - 1,
        );
      }

      if (normalizedPath == normalizedEndpoint ||
          normalizedPath.startsWith('$normalizedEndpoint/') ||
          normalizedPath.startsWith('$normalizedEndpoint?')) {
        debugPrint(
          'Public endpoint detected: $endpoint in path: $path (normalized: $normalizedPath)',
        );
        return false;
      }
    }

    debugPrint('Protected endpoint: $path (normalized: $normalizedPath)');
    return true;
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final languageCode = _storageService.getLanguageCode() ?? 'ar';
          options.headers['lang'] = languageCode;
          _dio.options.headers['lang'] = languageCode;

          final path = options.path;
          if (_requiresAuth(path)) {
            final token = _cachedToken ?? _storageService.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            } else {
              options.headers.remove('Authorization');
            }
          } else {
            options.headers.remove('Authorization');
          }

          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401 &&
              !_isShowingUnauthorizedDialog) {
            final path = error.requestOptions.path;

            debugPrint('401 Error on path: $path');

            // Exclude login/register/verifyOtp from global 401 handling to avoid loops/wrong UX
            // if a bad credential starts triggering "session expired".
            if (!path.contains(ApiConstants.login) &&
                !path.contains(ApiConstants.register) &&
                !path.contains(ApiConstants.verifyOtp)) {
              _handleUnauthorizedError();
            }
          }
          return handler.next(error);
        },
        onResponse: (response, handler) {
          if (response.statusCode == 401 && !_isShowingUnauthorizedDialog) {
            final path = response.requestOptions.path;

            debugPrint('401 Response on path: $path');

            if (!path.contains(ApiConstants.login) &&
                !path.contains(ApiConstants.register) &&
                !path.contains(ApiConstants.verifyOtp)) {
              _handleUnauthorizedError();
              return handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  response: response,
                  type: DioExceptionType.badResponse,
                  error: 'Unauthenticated',
                ),
              );
            }
          }
          return handler.next(response);
        },
      ),
    );

    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  void _handleUnauthorizedError() {
    if (_isShowingUnauthorizedDialog) return;
    _isShowingUnauthorizedDialog = true;
    clearAuthToken();
    _storageService.clearAuthData();

    final context = navigatorKey.currentContext;
    if (context != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentContext = navigatorKey.currentContext;
        if (currentContext != null) {
          _showUnauthorizedDialog(currentContext);
        }
      });
    }
  }

  void _showUnauthorizedDialog(BuildContext context) {
    if (!context.mounted) {
      _isShowingUnauthorizedDialog = false;
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppTexts.login),
        content: Text(AppTexts.unauthenticatedMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _isShowingUnauthorizedDialog = false;
            },
            child: Text(AppTexts.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _isShowingUnauthorizedDialog = false;
              // Navigate to login screen
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              }
            },
            child: Text(AppTexts.ok),
          ),
        ],
      ),
    ).then((_) {
      _isShowingUnauthorizedDialog = false;
    });
  }

  /// Get Dio instance
  Dio get dio => _dio;

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Set authentication token
  void setAuthToken(String token) {
    _cachedToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authentication token
  void clearAuthToken() {
    _cachedToken = null;
    _dio.options.headers.remove('Authorization');
  }

  /// Update base URL
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }
}
