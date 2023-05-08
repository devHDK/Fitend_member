import 'package:dio/dio.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/secure_storage/secure_storage.dart';
import 'package:fitend_member/flavors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

final dioProvider = Provider(
  (ref) {
    final dio = Dio();
    final storage = ref.watch(seccureStorageProvider);

    dio.interceptors.add(CustomInterceptor(storage: storage, ref: ref));
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: print,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    );
    dio.options.baseUrl = F.appFlavor == Flavor.local
        ? localIp
        : F.appFlavor == Flavor.development
            ? devIp
            : deployIp;
    dio.options.receiveTimeout = const Duration(seconds: 3);

    return dio;
  },
);

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
    // print('[REQ][${options.method}] ${options.uri}');
    print(options);

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
    print(
        '[RES][${response.requestOptions.method}] ${response.requestOptions.uri}');

    return super.onResponse(response, handler);
  }

// 3)에러가 났을때
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    //401에러 (status code)
    //토큰을 재발급 받는 시도를 하고 토큰이 재발급 되면
    // 다시 새로운 토큰을 요청한다.
    print('[ERROR][${err.requestOptions.method}] ${err.requestOptions.uri}');

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
      final dio = Dio();
      try {
        final resp = await dio.post(
          'auth/refresh',
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
        final response = await dio.fetch(options);

        //성공
        return handler.resolve(response);
      } on DioError catch (e) {
        //circular dependency error
        // A, B
        // ref.read(authProvider.notifier).logout();

        return handler.reject(e);
      }
    }
    return handler.reject(err);
  }
}
