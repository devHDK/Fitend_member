import 'package:dio/dio.dart';
import 'package:fitend_member/common/dio/dio.dart';
import 'package:fitend_member/common/model/login_response.dart';
import 'package:fitend_member/common/model/token_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return AuthRepository(dio: dio);
});

class AuthRepository {
  final Dio dio;

  AuthRepository({
    required this.dio,
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
}
