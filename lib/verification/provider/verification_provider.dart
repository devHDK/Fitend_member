import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fitend_member/verification/model/post_verification_confirm_model.dart';
import 'package:fitend_member/verification/model/post_verification_confirm_response.dart';

import 'package:fitend_member/verification/model/post_verification_model.dart';
import 'package:fitend_member/verification/model/verification_state_model.dart';
import 'package:fitend_member/verification/repository/verification_repository.dart';
import 'package:flutter/cupertino.dart';
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

  void init() {
    state = VerificationStateModel(
      isCodeSended: false,
      isMessageSended: false,
      phoneNumber: null,
      code: null,
      codeToken: null,
      expireAt: null,
    );
  }

  Future<void> postVerificationMessage(
      {required PostVerificationModel reqModel}) async {
    try {
      final pstate = state;

      state = pstate.copyWith(
        isMessageSended: true,
      );

      final ret = await repository.postVerification(model: reqModel);

      state = pstate.copyWith(
        isMessageSended: true,
        codeToken: ret.codeToken,
        expireAt: ret.expireAt,
      );
    } catch (e) {
      if (e is DioException && e.response != null) {
        state =
            VerificationStateModel(isMessageSended: false, isCodeSended: false);

        rethrow;
      }
    }
  }

  Future<PostVerificationConfirmResponse?> postVerificationConfirm(
      {required PostVerificationConfirmModel reqModel}) async {
    try {
      final pstate = state;

      state = pstate.copyWith(isCodeSended: true);

      final ret = await repository.postVerificationConfirm(model: reqModel);

      return ret;
    } catch (e) {
      if (e is DioException && e.response != null) {
        debugPrint('$e');
        rethrow;
      }
    }

    return null;
  }

  void updateData({
    bool? isMessageSended,
    bool? isCodeSended,
    String? phoneNumber,
    String? codeToken,
    DateTime? expireAt,
    int? code,
  }) {
    final pstate = state;

    state = pstate.copyWith(
      isMessageSended: isMessageSended ?? isMessageSended,
      isCodeSended: isCodeSended ?? isCodeSended,
      phoneNumber: phoneNumber ?? phoneNumber,
      codeToken: codeToken ?? codeToken,
      expireAt: expireAt ?? expireAt,
      code: code ?? code,
    );
  }
}
