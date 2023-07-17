import 'package:fitend_member/notifications/model/notification_confirm_model.dart';
import 'package:fitend_member/notifications/model/notification_model.dart';
import 'package:fitend_member/notifications/repository/notifications_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationProvider =
    StateNotifierProvider<NotificationStateNotifier, NotificationModelBase>(
        (ref) {
  final repository = ref.watch(notificationRepositoryProvider);

  return NotificationStateNotifier(repository: repository);
});

class NotificationStateNotifier extends StateNotifier<NotificationModelBase> {
  final NotificationsRepository repository;

  NotificationStateNotifier({
    required this.repository,
  }) : super(NotificationModelLoading()) {
    paginate();
  }

  Future<void> paginate({
    int? start = 0,
    bool fetchMore = false,
    bool isRefetch = false,
  }) async {
    try {
      final isLoading = state is NotificationModelLoading;
      final isFetchMore = state is NotificationModelFetchingMore;

      if (fetchMore && (isLoading || isFetchMore)) {
        return;
      }

      if (fetchMore) {
        // 데이터를 추가로 가져오는 상황
        final pState = state as NotificationModel;

        state = NotificationModelFetchingMore(
          data: pState.data,
          total: pState.total,
        );
      }

      final response = await repository.getNotifications(
          params: NotificationConfirmParams(start: start!, perPage: 20));

      if (state is NotificationModelFetchingMore) {
        final pState = state as NotificationModel;

        state = pState.copyWith(
          data: <NotificationData>[
            ...pState.data,
            ...response.data,
          ],
        );
      } else {
        state = NotificationModel(data: response.data, total: response.total);
      }
    } catch (e) {
      state = NotificationModelError(message: '데이터를 불러오지 못했습니다.');
    }
  }
}
