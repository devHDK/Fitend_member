import 'package:dio/dio.dart' hide Headers;
import 'package:fitend_member/common/dio/dio.dart';
import 'package:fitend_member/user/model/bool_model.dart';
import 'package:fitend_member/user/model/post_change_password.dart';
import 'package:fitend_member/user/model/post_confirm_password.dart';
import 'package:fitend_member/user/model/post_email_exist_model.dart';
import 'package:fitend_member/user/model/post_next_week_survey_model.dart';
import 'package:fitend_member/user/model/post_user_register_model.dart';
import 'package:fitend_member/user/model/put_fcm_token.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

part 'get_me_repository.g.dart';

final getMeRepositoryProvider = Provider<GetMeRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return GetMeRepository(dio);
});

@RestApi()
abstract class GetMeRepository {
  factory GetMeRepository(Dio dio) = _GetMeRepository;

  @GET('/users/getMe')
  @Headers({
    'accessToken': 'true',
  })
  Future<UserModel> getMe();

  @GET('/users/nextWorkout')
  @Headers({
    'accessToken': 'true',
  })
  Future<BoolModel> getNextWeekSurvey({
    @Queries() required NextWeekSurveyModel model,
  });

  @POST('/users/password/confirm')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> confirmPassword({
    @Body() required PostConfirmPassword password,
  });

  @POST('/users/exist')
  Future<void> postEmailExist({
    @Body() required PostEmailExistModel model,
  });

  @POST('/users/nextWorkout')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> postNextWeekSurvey({
    @Body() required NextWeekSurveyModel model,
  });

  @POST('/users/register')
  Future<void> userRegister({
    @Body() required PostUserRegisterModel model,
  });

  @PUT('/users/fcmToken')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> putFCMToken({
    @Body() required PutFcmToken putFcmToken,
  });

  @PUT('/users/password')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> changePassword({
    @Body() required PostChangePassword password,
  });
}
