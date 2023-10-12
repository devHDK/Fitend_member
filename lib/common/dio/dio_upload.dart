import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

final dioUploadProvider = Provider(
  (ref) {
    final dioUpload = Dio();

    dioUpload.interceptors.addAll(
      [
        RetryInterceptor(
          dio: dioUpload,
          logPrint: print,
        ),
        PrettyDioLogger(
          requestHeader: true,
          // requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 100,
        )
      ],
    );

    return dioUpload;
  },
);
