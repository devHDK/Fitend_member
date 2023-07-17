import 'package:dio/dio.dart' hide Headers;
import 'package:fitend_member/common/dio/dio.dart';
import 'package:fitend_member/notifications/model/notification_confirm_model.dart';
import 'package:fitend_member/notifications/model/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

part 'notifications_repository.g.dart';

final notificationRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return NotificationsRepository(dio);
});

@RestApi()
abstract class NotificationsRepository {
  factory NotificationsRepository(Dio dio) = _NotificationsRepository;

  @GET('/notifications')
  @Headers({
    'accessToken': 'true',
  })
  Future<NotificationModel> getNotifications({
    @Queries() required NotificationConfirmParams params,
  });

  @GET('/notifications/confirm')
  @Headers({
    'accessToken': 'true',
  })
  Future<NotificationConfirmResponse>
      getNotificationsConfirm(); // 안읽은 알림 있는지 확인

  @PUT('/notifications/confirm')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> putNotificationsConfirm();
}
