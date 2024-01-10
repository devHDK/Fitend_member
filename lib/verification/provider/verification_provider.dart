import 'package:dio/dio.dart';
import 'package:fitend_member/verification/model/post_verification_confirm_model.dart';

import 'package:fitend_member/verification/model/post_verification_model.dart';
import 'package:fitend_member/verification/model/verification_state_model.dart';
import 'package:fitend_member/verification/repository/verification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final verificationProvider = StateNotifierProvider.autoDispose<
    VerificationStateNotifier, VerificationStateModel>((ref) {
  final repository = ref.watch(verificationRepositoryProvider);

  return VerificationStateNotifier(repository: repository);
});

class VerificationStateNotifier extends StateNotifier<VerificationStateModel> {
  final VerificationRepository repository;

  VerificationStateNotifier({
    required this.repository,
  }) : super(
          VerificationStateModel(
            isMessageSended: false,
            isCodeSended: false,
          ),
        );

  Future<void> postVerificationMessage(
      {required PostVerificationModel reqModel}) async {
    try {
      final pstate = state;

      state = pstate.copyWith(
        isCodeSended: true,
      );

      final ret = await repository.postVerification(model: reqModel);

      state = pstate.copyWith(
        isMessageSended: true,
        codeToken: ret.codeToken,
        expireAt: ret.expireAt,
      );
    } catch (e) {
      if (e is DioException) {}
    }
  }

  Future<void> postVerificationConfirm(
      {required PostVerificationConfirmModel reqModel}) async {
    try {
      final pstate = state;

      state = pstate.copyWith(isCodeSended: true);

      await repository.postVerificationConfirm(model: reqModel);
    } catch (e) {
      if (e is DioException) {}
    }
  }

  void updateData({
    bool? isMessageSended,
    String? phoneNumber,
    String? codeToken,
    DateTime? expireAt,
    int? code,
  }) {
    final pstate = state;

    state = pstate.copyWith(
        isMessageSended: isMessageSended ?? isMessageSended,
        phoneNumber: phoneNumber ?? phoneNumber,
        codeToken: codeToken ?? codeToken,
        expireAt: expireAt ?? expireAt,
        code: code ?? code);

    print(state.toJson());
  }
}
