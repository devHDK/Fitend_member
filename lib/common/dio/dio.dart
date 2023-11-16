import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/dio/dio_retry.dart';
import 'package:fitend_member/common/secure_storage/secure_storage.dart';
import 'package:fitend_member/flavors.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

final dioProvider = Provider(
  (ref) {
    final dio = Dio(
      BaseOptions(
        baseUrl: F.appFlavor == Flavor.local
            ? localIp
            : F.appFlavor == Flavor.development
                ? devIp
                : deployIp,
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 6),
        connectTimeout: const Duration(seconds: 6),
      ),
    );
    final storage = ref.watch(secureStorageProvider);

    dio.interceptors.addAll(
      [
        CustomInterceptor(
          storage: storage,
          ref: ref,
        ),
        PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            responseHeader: false,
            error: true,
            compact: true,
            maxWidth: 90)
      ],
    );

    return dio;
  },
);

bool _shouldRetry(DioException err) {
  return err.type == DioExceptionType.unknown &&
      err.error != null &&
      err.error is SocketException;
}

class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final Ref ref;

  CustomInterceptor({
    required this.ref,
    required this.storage,
  });
// //요청 보낼때
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // debugPrint('[REQ][${options.method}] ${options.uri}');
    if (options.headers['accessToken'] == 'true') {
      options.headers.remove('accessToken');

      final token = await storage.read(key: ACCESS_TOKEN_KEY);

      options.headers.addAll({
        'authorization': 'Bearer $token',
      });
    }

    return super.onRequest(options, handler);
  }

// 2)응답을 받을때
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // debugPrint(
    //     '[RES][${response.requestOptions.method}] ${response.requestOptions.uri}');

    return super.onResponse(response, handler);
  }

// 3)에러가 났을때
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      try {
        final dioRtry = ref.read(dioRetryProvider);

        final response = await dioRtry.fetch(err.requestOptions);

        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.reject(e);
      }
    }

    //401에러 (status code)
    //토큰을 재발급 받는 시도를 하고 토큰이 재발급 되면
    // 다시 새로운 토큰을 요청한다.
    // debugPrint(
    //     '[ERROR][${err.requestOptions.method}] ${err.requestOptions.uri} : ${err.response?.statusCode}');

    final oldAccessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    //refreshToken이 없으면
    if (refreshToken == null) {
      //에러를 던질때 handler.reject를 사용
      return handler.reject(err);
    }

    final isStatus401 = err.response?.statusCode == 401;
    final isPathRefresh = err.requestOptions.path == '/auth/refresh';

    if (isStatus401 && !isPathRefresh) {
      try {
        final dioRetry = ref.read(dioRetryProvider);

        final resp = await dioRetry.post(
          '/auth/refresh',
          data: {
            'accessToken': oldAccessToken,
            'refreshToken': refreshToken,
          },
        );

        final accessToken = resp.data['accessToken'];
        final options = err.requestOptions;
        options.headers.addAll(
          {
            'authorization': 'Bearer $accessToken',
          },
        );

        await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

        //요청 재전송
        final response = await dioRetry.fetch(options);

        //성공
        return handler.resolve(response);
      } on DioException catch (e) {
        //circular dependency error
        // A, B
        ref.read(getMeProvider.notifier).logout();

        return handler.reject(e);
      }
    }
    return handler.reject(err);
  }
}
