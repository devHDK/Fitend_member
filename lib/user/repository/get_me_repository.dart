import 'package:dio/dio.dart' hide Headers;
import 'package:fitend_member/common/dio/dio.dart';
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

  @POST('/users/password/confirm')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> confirmPassword({
    @Body() required String password,
  });

  @PUT('/users/password')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> changePassword({
    @Body() required String password,
    @Body() required String newPassword,
  });
}
