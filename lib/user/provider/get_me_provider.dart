import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/global/global_varialbles.dart';
import 'package:fitend_member/common/secure_storage/secure_storage.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/common/utils/update_checker.dart';
import 'package:fitend_member/ticket/model/ticket_model.dart';
import 'package:fitend_member/user/model/get_next_week_survey_model.dart';
import 'package:fitend_member/user/model/post_change_password.dart';
import 'package:fitend_member/user/model/post_confirm_password.dart';
import 'package:fitend_member/user/model/post_next_week_survey_model.dart';
import 'package:fitend_member/user/model/put_fcm_token.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/repository/auth_repository.dart';
import 'package:fitend_member/user/repository/get_me_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

final getMeProvider =
    StateNotifierProvider<GetMeStateNotifier, UserModelBase?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final getMeRepository = ref.watch(getMeRepositoryProvider);
  final storage = ref.watch(secureStorageProvider);

  return GetMeStateNotifier(
    authRepository: authRepository,
    repository: getMeRepository,
    storage: storage,
  );
});

Future<Map<String, dynamic>> getStoreVersionInfo() async {
  final packageInfo = await PackageInfo.fromPlatform();
  final version = packageInfo.version;
  final storeVersion = await checkUpdatable(version);

  return storeVersion;

  // return Future.value(storeVersion);
}

Future<Map<String, dynamic>?> checkStoreVersion() async {
  final storeVersion = await getStoreVersionInfo();
  return storeVersion;
}

class GetMeStateNotifier extends StateNotifier<UserModelBase?> {
  final AuthRepository authRepository;
  final GetMeRepository repository;
  final FlutterSecureStorage storage;

  GetMeStateNotifier({
    required this.authRepository,
    required this.repository,
    required this.storage,
  }) : super(UserModelLoading()) {
    Future.delayed(
      Duration.zero,
      () => getMe(),
    );
    // getMe();
  }

  Future<void> getMe() async {
    try {
      checkStoreVersion().then((storeVersion) async {
        debugPrint('$storeVersion');
        if (storeVersion != null) {
          bool isNeedStoreUpdate = storeVersion['needUpdate'];
          if (isNeedStoreUpdate) {
            //sotre 연결
            state =
                UserModelError(error: 'store version error', statusCode: 444);
          } else {
            final refreshToken =
                await storage.read(key: StringConstants.refreshToken);
            final accessToken =
                await storage.read(key: StringConstants.accessToken);

            if (refreshToken == null || accessToken == null) {
              state = null;
              return;
            }

            final response = await repository.getMe();
            // await FirebaseMessaging.instance
            //     .subscribeToTopic('user_${response.user.id}');

            final diviceId = await _getDeviceInfo();
            final token = await FirebaseMessaging.instance.getToken();

            debugPrint('diviceId : $diviceId');
            debugPrint('fcm token : $token');

            await repository.putFCMToken(
                putFcmToken: PutFcmToken(
              deviceId: diviceId,
              token: token!,
              platform: Platform.isIOS ? 'ios' : 'android',
            ));

            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final nextWeekMonday = today.add(Duration(days: 8 - today.weekday));

            late bool isNextWorkout;

            if (DataUtils.isBetweenFriday2PMAndSundayMidnight()) {
              final ret = await repository.getNextWeekSurvey(
                  model: GetNextWeekSurveyModel(mondayDate: nextWeekMonday));

              isNextWorkout = ret.data;
            } else {
              isNextWorkout = true;
            }

            state = response.copyWith(
                user: response.user.copyWith(
              isWorkoutSurvey: isNextWorkout,
            ));
          }
        }
      });
    } on DioException catch (e) {
      if (e.type == DioExceptionType.unknown) {
        state = UserModelError(error: 'connection error', statusCode: 504);
      }

      if (e.response != null && e.response!.statusCode == 500) {
        state = null;

        await logout();

        state = UserModelError(error: 'token error', statusCode: 500);
      }
    }
  }

  Future<UserModelBase> login({
    required String email,
    required String password,
    required String platform,
    required String token,
    required String deviceId,
  }) async {
    try {
      state = UserModelLoading();

      final resp = await authRepository.login(
        email: email,
        password: password,
        platform: platform,
        token: token,
        deviceId: deviceId,
      );

      await storage.write(
          key: StringConstants.refreshToken, value: resp.refreshToken);
      await storage.write(
          key: StringConstants.accessToken, value: resp.accessToken);

      final userResp = await repository.getMe();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final nextWeekMonday = today.add(Duration(days: 8 - today.weekday));

      late bool isNextWorkout;

      if (DataUtils.isBetweenFriday2PMAndSundayMidnight()) {
        final ret = await repository.getNextWeekSurvey(
            model: GetNextWeekSurveyModel(mondayDate: nextWeekMonday));

        isNextWorkout = ret.data;
      } else {
        isNextWorkout = true;
      }

      state = userResp.copyWith(
          user: userResp.user.copyWith(
        isWorkoutSurvey: isNextWorkout,
      ));

      return userResp;
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode != null) {
          if (e.response!.statusCode! == 404 ||
              e.response!.statusCode! == 400) {
            state = UserModelError(
              error: '해당 이메일로 가입된 계정이 없어요 😅',
              statusCode: e.response!.statusCode!,
            );
          } else if (e.response!.statusCode! == 409) {
            state = UserModelError(
              error: '이메일 또는 비밀번호가 맞지 않아요 😭',
              statusCode: e.response!.statusCode!,
            );
          } else if (e.response!.statusCode! == 403) {
            state = UserModelError(
              error: '이용 중인 수강권이 없어요 😰',
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
    // if (state is UserModel) {
    //   final pState = state as UserModel;
    //   int userId = pState.user.id;
    //   await FirebaseMessaging.instance.unsubscribeFromTopic('user_$userId');
    // }

    try {
      final deviceId = await _getDeviceInfo();

      await authRepository.logout(
        deviceId: deviceId,
        platform: Platform.isAndroid ? 'android' : 'ios',
      );
    } catch (e) {
      debugPrint('$e');
    }

    state = null;

    if (scheduleListGlobal.isNotEmpty) {
      scheduleListGlobal.removeRange(0, scheduleListGlobal.length - 1);
    }

    await Future.wait([
      storage.delete(key: StringConstants.refreshToken),
      storage.delete(key: StringConstants.accessToken),
    ]);
    state = null;
  }

  Future<void> confirmPassword({
    required PostConfirmPassword password,
  }) async {
    try {
      await repository.confirmPassword(password: password);
    } on DioException catch (e) {
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
      );
    }
  }

  Future<void> changePassword({
    required String password,
    required String newPassword,
  }) async {
    try {
      await repository.changePassword(
          password: PostChangePassword(
        password: password,
        newPassword: newPassword,
      ));
    } on DioException catch (e) {
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
      );
    }
  }

  Future<void> changePasswordReset({
    required String password,
    required String phoneToken,
    required String email,
    required String phone,
  }) async {
    try {
      await authRepository.passwordReset(
          password: password,
          phone: phone,
          phoneToken: phoneToken,
          email: email);
    } on DioException catch (e) {
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
      );
    }
  }

  Future<void> postNextWorkout({
    required DateTime mondayDate,
    List<DateTime>? selectedDates,
    required bool noSchedule,
  }) async {
    try {
      await repository.postNextWeekSurvey(
          model: PostNextWeekSurveyModel(
        mondayDate: mondayDate,
        selectedDates: selectedDates,
        noSchedule: noSchedule,
      ));
    } on DioException {
      rethrow;
    }
  }

  void changeIsNotification({
    required bool isNotification,
  }) {
    final pstate = state as UserModel;

    state = pstate.copyWith(
      user: pstate.user.copyWith(isNotification: isNotification),
    );
  }

  void updateActiveTickets({
    required List<TicketModel> activeTickets,
  }) {
    final pstate = state as UserModel;

    pstate.user.activeTickets = activeTickets;

    state = pstate.copyWith();
  }

  void updateIsWorkoutSurvey({
    required bool isWorkoutSurvey,
  }) {
    final pstate = state as UserModel;

    pstate.user.isWorkoutSurvey = isWorkoutSurvey;

    state = pstate.copyWith();
  }

  Future<String> _getDeviceInfo() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo? iosInfo;
      String? androidUuid;

      if (Platform.isAndroid) {
        final savedUuid = await storage.read(key: StringConstants.deviceId);

        androidUuid = savedUuid;

        debugPrint('deviceId : $androidUuid');
      } else if (Platform.isIOS) {
        iosInfo = await deviceInfo.iosInfo;
        debugPrint('deviceId : ${iosInfo.identifierForVendor!}');
      }

      return Platform.isAndroid ? androidUuid! : iosInfo!.identifierForVendor!;
    } catch (e) {
      debugPrint('_getDeviceInfo error ===> $e');
      await Future.wait([
        storage.delete(key: StringConstants.refreshToken),
        storage.delete(key: StringConstants.accessToken),
      ]);
      state = null;

      return '';
    }
  }
}
