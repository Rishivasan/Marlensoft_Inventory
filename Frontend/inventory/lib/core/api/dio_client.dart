import 'package:dio/dio.dart';

class DioClient {
  static Dio getDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: "http://localhost:5069",
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        sendTimeout: const Duration(seconds: 8),
        headers: {
          "Content-Type": "application/json",
          // Disable caching to ensure fresh data
          "Cache-Control": "no-cache, no-store, must-revalidate",
          "Pragma": "no-cache",
          "Expires": "0",
        },      ),
    );

    // Add interceptor for better logging (only in debug mode)
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false, // Reduce logging for better performance
        responseBody: false,
        error: true,
        logPrint: (obj) => print('[DIO] $obj'),
      ),
    );

    return dio;
  }
}

