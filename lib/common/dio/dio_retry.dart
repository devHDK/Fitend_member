import 'package:dio/dio.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/flavors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

final dioRetryProvider = Provider(
  (ref) {
    final dioRetry = Dio(
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

    dioRetry.interceptors.addAll(
      [
        RetryInterceptor(
          dio: dioRetry,
          logPrint: print,
          retries: 3,
          retryDelays: const [
            Duration(seconds: 5),
            Duration(seconds: 7),
            Duration(seconds: 10),
          ],
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

    return dioRetry;
  },
);
