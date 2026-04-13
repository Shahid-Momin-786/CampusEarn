import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api_config.dart';
import 'dart:io' show Platform;

class ApiClient {
  late Dio dio;
  final storage = const FlutterSecureStorage();

  ApiClient() {
    String baseUrl = ApiConfig.baseUrl;
    try {
      if (Platform.isAndroid) {
        baseUrl = 'http://10.0.2.2:8000/api';
      }
    } catch (e) {
      // Platform check fails on Web
    }

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await storage.read(key: 'access_token');
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          return handler.next(e);
        },
      ),
    );
  }
}
