import 'package:fitend_member/common/provider/shared_preference_provider.dart';
import 'package:fitend_member/common/utils/shared_pref_utils.dart';
import 'package:fitend_member/notifications/model/notificatiion_main_state_model.dart';
import 'package:fitend_member/notifications/model/notification_confirm_model.dart';
import 'package:fitend_member/notifications/model/notification_model.dart';
import 'package:fitend_member/notifications/repository/notifications_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationHomeProvider = StateNotifierProvider<
    NotificationHomeStateNotifier, NotificationMainModelBase>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  final sharedPref = ref.watch(sharedPrefsProvider);

  return NotificationHomeStateNotifier(
    repository: repository,
    sharedPref: sharedPref,
  );
});

class NotificationHomeStateNotifier
    extends StateNotifier<NotificationMainModelBase> {
  final NotificationsRepository repository;
  final Future<SharedPreferences> sharedPref;

  NotificationHomeStateNotifier({
    required this.repository,
    required this.sharedPref,
  }) : super(NotificationMainModelLoading()) {
    init();
  }

  Future<void> init() async {
    try {
      final pref = await sharedPref;

      final response = await repository.getNotificationsConfirm();
      final threadBadgeCount = SharedPrefUtils.getThreadBadgeCount(pref);

      state = NotificationMainModel(
          isConfirmed: response.isConfirm, threadBadgeCount: threadBadgeCount);
    } catch (e) {
      state = NotificationMainModelError(message: '데이터를 불러오지 못했습니다.');
    }
  }

  void updateBageCount(int count) async {
    if (state is NotificationMainModel) {
      final pstate = state as NotificationMainModel;

      pstate.threadBadgeCount = count;

      state = pstate.copyWith();
    }
  }

  void addBageCount(int count) {
    if (state is NotificationMainModel) {
      final pstate = state as NotificationMainModel;

      pstate.threadBadgeCount += count;

      state = pstate.copyWith();
    }
  }

  void updateIsConfirm(bool isConfirm) {
    if (state is NotificationMainModel) {
      final pstate = state as NotificationMainModel;

      pstate.isConfirmed = isConfirm;

      state = pstate.copyWith();
    }
  }
}
