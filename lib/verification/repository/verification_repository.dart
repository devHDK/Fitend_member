import 'package:dio/dio.dart' hide Headers;
import 'package:fitend_member/common/dio/dio.dart';
import 'package:fitend_member/verification/model/post_verification_confirm_model.dart';
import 'package:fitend_member/verification/model/post_verification_confirm_response.dart';
import 'package:fitend_member/verification/model/post_verification_model.dart';
import 'package:fitend_member/verification/model/post_verification_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

part 'verification_repository.g.dart';

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return VerificationRepository(dio);
});

@RestApi()
abstract class VerificationRepository {
  factory VerificationRepository(Dio dio) = _VerificationRepository;

  @POST('/verifications')
  Future<PostVerificationResponse> postVerification({
    @Body() required PostVerificationModel model,
  });

  @POST('/verifications/confirm')
  Future<PostVerificationConfirmResponse> postVerificationConfirm({
    @Body() required PostVerificationConfirmModel model,
  });
}
