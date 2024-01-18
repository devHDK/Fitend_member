import 'package:dio/dio.dart' hide Headers;
import 'package:fitend_member/common/dio/dio.dart';
import 'package:fitend_member/meeting/model/meeting_schedule_model.dart';
import 'package:fitend_member/meeting/model/post_meeting_create_model.dart';
import 'package:fitend_member/schedule/model/workout_schedule_pagenate_params.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

part 'meeting_repository.g.dart';

final meetingRepositoryProvider = Provider<MeetingRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return MeetingRepository(dio);
});

@RestApi()
abstract class MeetingRepository {
  factory MeetingRepository(Dio dio) = _MeetingRepository;

  @GET('/meetings')
  @Headers({
    'accessToken': 'true',
  })
  Future<MeetingScheduleModel> getMeetings({
    @Queries() required SchedulePagenateParams params,
  });

  @POST('/meetings')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> meetingCreate({
    @Body() required PostMeetingCreateModel model,
  });
}
