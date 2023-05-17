import 'package:dio/dio.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/secure_storage/secure_storage.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/repository/auth_repository.dart';
import 'package:fitend_member/user/repository/get_me_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final userMeProvider =
    StateNotifierProvider<UserMeStateNotifier, UserModelBase?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final userMeRepository = ref.watch(getMeRepositoryProvider);
  final storage = ref.watch(seccureStorageProvider);

  return UserMeStateNotifier(
      authRepository: authRepository,
      repository: userMeRepository,
      storage: storage);
});

class UserMeStateNotifier extends StateNotifier<UserModelBase?> {
  final AuthRepository authRepository;
  final UserMeRepository repository;
  final FlutterSecureStorage storage;

  UserMeStateNotifier({
    required this.authRepository,
    required this.repository,
    required this.storage,
  }) : super(UserModelLoading()) {
    getMe();
  }

  getMe() async {
    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

    if (refreshToken == null || accessToken == null) {
      state = null;
      return;
    }

    try {
      final response = await repository.getMe();
      state = response;
    } on DioError catch (e) {
      if (e.type == DioErrorType.unknown) {
        print('!!!server connection error!!!');
        state = UserModelError(error: 'connection error', statusCode: 504);
      }
    }
  }

  Future<UserModelBase> login({
    required String email,
    required String password,
    required String platform,
    required String token,
  }) async {
    try {
      state = UserModelLoading();

      final resp = await authRepository.login(
        email: email,
        password: password,
        platform: platform,
        token: token,
      );

      await storage.write(key: REFRESH_TOKEN_KEY, value: resp.refreshToken);
      await storage.write(key: ACCESS_TOKEN_KEY, value: resp.accessToken);

      final userResp = await repository.getMe();

      state = userResp;

      return userResp;
    } on DioError catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode != null) {
          if (e.response!.statusCode! == 400) {
            state = UserModelError(
              error: '이메일을 입력해주세요',
              statusCode: e.response!.statusCode!,
            );
          } else if (e.response!.statusCode! == 404) {
            state = UserModelError(
              error: '이메일 또는 비밀번호가 맞지않아요',
              statusCode: e.response!.statusCode!,
            );
          } else {
            state = UserModelError(
              error: '알수없는 에러입니다.',
              statusCode: e.response!.statusCode!,
            );
          }
        }
      }

      return Future.value(state);
    }
  }

  Future<void> logout() async {
    state = null;

    await Future.wait([
      storage.delete(key: REFRESH_TOKEN_KEY),
      storage.delete(key: ACCESS_TOKEN_KEY),
    ]);
  }
}
