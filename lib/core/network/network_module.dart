import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:pulse_chat/core/network/api_config.dart';
import 'package:pulse_chat/core/network/auth_interceptor.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(AuthInterceptor());

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(/* requestHeader: true, */ responseHeader: true, requestBody: true),
      );
    }

    return dio;
  }
}
