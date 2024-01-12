import 'package:fitend_member/common/provider/hive_post_user_register_record_provider.dart';
import 'package:fitend_member/user/model/post_email_exist_model.dart';
import 'package:fitend_member/user/model/user_register_state_model.dart';
import 'package:fitend_member/user/repository/get_me_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final userRegisterProvider = StateNotifierProvider.family<
    UserRegisterStateNotifier, UserRegisterStateModel, String>((ref, phone) {
  final AsyncValue<Box> userRegisterBox =
      ref.watch(hiveUserRegisterRecordProvider);

  final getMeRepository = ref.read(getMeRepositoryProvider);

  return UserRegisterStateNotifier(
    phone: phone,
    userRegisterBox: userRegisterBox,
    getMeRepository: getMeRepository,
  );
});

class UserRegisterStateNotifier extends StateNotifier<UserRegisterStateModel> {
  final String phone;
  final AsyncValue<Box> userRegisterBox;
  final GetMeRepository getMeRepository;

  UserRegisterStateNotifier({
    required this.phone,
    required this.userRegisterBox,
    required this.getMeRepository,
  }) : super(UserRegisterStateModel(
          phone: phone,
          step: 1,
          progressStep: 1,
          achievement: [],
          obstacle: [],
          preferDays: [],
        )) {
    init();
  }

  void init() {
    state = UserRegisterStateModel(
      phone: phone,
      step: 1,
      progressStep: 1,
      achievement: [],
      obstacle: [],
      preferDays: [],
    );
  }

  void initFromLocalDB() {
    userRegisterBox.whenData((value) {
      final record = value.get(phone);

      if (record != null && record is UserRegisterStateModel) {
        state = record;
      } else {
        state = UserRegisterStateModel(
          phone: phone,
          step: 1,
          progressStep: 1,
          achievement: [],
          obstacle: [],
          preferDays: [],
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
    double? height,
    double? weight,
    int? experience,
    int? purpose,
    List<int>? achievement,
    List<int>? obstacle,
    String? place,
    List<int>? preferDays,
    int? step,
    int? progressStep,
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
      progressStep: progressStep ?? progressStep,
    );
  }

  Future<void> checkEmail(String email) async {
    try {
      await getMeRepository.postEmailExist(
          model: PostEmailExistModel(email: email));
    } catch (e) {
      rethrow;
    }
  }

  void saveState() {
    final pstate = state;

    userRegisterBox.whenData((value) {
      value.put(pstate.phone, pstate);

      debugPrint('saved user register state ===> ${pstate.toJson()}');
    });
  }
}
