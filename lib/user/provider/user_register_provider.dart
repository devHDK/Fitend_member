import 'package:fitend_member/common/provider/hive_post_user_register_record_provider.dart';
import 'package:fitend_member/user/model/post_user_register_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final userRegisterProvider = StateNotifierProvider.family<
    UserRegisterStateNotifier, PostUserRegisterModel, String>((ref, phone) {
  final AsyncValue<Box> userRegisterBox =
      ref.watch(hiveUserRegisterRecordProvider);

  return UserRegisterStateNotifier(
    phone: phone,
    userRegisterBox: userRegisterBox,
  );
});

class UserRegisterStateNotifier extends StateNotifier<PostUserRegisterModel> {
  final String phone;
  final AsyncValue<Box> userRegisterBox;

  UserRegisterStateNotifier({
    required this.phone,
    required this.userRegisterBox,
  }) : super(PostUserRegisterModel(phone: phone, step: 1)) {
    init();
  }

  void init() {
    userRegisterBox.whenData((value) {
      final record = value.get(phone);

      if (record != null && record is PostUserRegisterModel) {
        state = record;
      } else {
        state = PostUserRegisterModel(
          phone: phone,
          step: 1,
        );
      }
    });
  }

  void updateData({
    int? trainerId,
    String? nickname,
    String? password,
    String? email,
    String? phone,
    DateTime? birth,
    String? gender,
    int? height,
    int? weight,
    int? experience,
    int? purpose,
    List<int>? achievement,
    List<int>? obstacle,
    String? place,
    List<int>? preferDays,
    int? step,
  }) {
    final pstate = state;

    state = pstate.copyWith(
      trainerId: trainerId ?? trainerId,
      nickname: nickname ?? nickname,
      password: password ?? password,
      email: email ?? email,
      phone: phone ?? phone,
      birth: birth ?? birth,
      gender: gender ?? gender,
      height: height ?? height,
      weight: weight ?? weight,
      experience: experience ?? experience,
      purpose: purpose ?? purpose,
      achievement: achievement ?? achievement,
      obstacle: obstacle ?? obstacle,
      place: place ?? place,
      preferDays: preferDays ?? preferDays,
      step: step ?? step,
    );
  }
}
