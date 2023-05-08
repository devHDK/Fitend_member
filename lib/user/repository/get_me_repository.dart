import 'package:dio/dio.dart' hide Headers;
import 'package:fitend_member/common/dio/dio.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

part 'get_me_repository.g.dart';

final getMeRepositoryProvider = Provider<UserMeRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return UserMeRepository(dio);
});

@RestApi()
abstract class UserMeRepository {
  factory UserMeRepository(Dio dio) = _UserMeRepository;

  @GET('/users/getMe')
  @Headers({
    'accessToken': 'true',
  })
  Future<UserModel> getMe();
}
