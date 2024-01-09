import 'package:dio/dio.dart';
import 'package:fitend_member/common/dio/dio.dart';
import 'package:fitend_member/common/model/login_response.dart';
import 'package:fitend_member/common/model/token_response.dart';
import 'package:fitend_member/common/secure_storage/secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.read(secureStorageProvider);

  return AuthRepository(dio: dio, storage: storage);
});

class AuthRepository {
  final Dio dio;
  final FlutterSecureStorage storage;

  AuthRepository({
    required this.dio,
    required this.storage,
  });

  Future<LoginResponse> login({
    required String email,
    required String password,
    required String platform,
    required String token,
    required String deviceId,
  }) async {
    final response = await dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
        'platform': platform,
        'token': token,
        'deviceId': deviceId
      },
    );

    return LoginResponse.fromJson(response.data);
  }

  Future<void> logout({
    required String deviceId,
    required String platform,
  }) async {
    await dio.post(
      '/auth/logout',
      options: Options(
        headers: {
          'accessToken': 'true',
        },
      ),
      data: {
        'deviceId': deviceId,
        'platform': platform,
      },
    );
  }

  Future<TokenResponse> token() async {
    final response = await dio.post(
      '/auth/refresh',
      options: Options(
        headers: {
          'accessToken': 'true',
          'refreshToken': 'true',
        },
      ),
    );

    return TokenResponse.fromJson(response.data);
  }

  Future<void> passwordReset({
    required String phoneToken,
    required String phone,
    required String email,
    required String password,
  }) async {
    await dio.put(
      '/auth/reset',
      options: Options(),
      data: {
        'phoneToken': phoneToken,
        'phone': phone,
        'email': email,
        'password': password,
      },
    );
  }
}
