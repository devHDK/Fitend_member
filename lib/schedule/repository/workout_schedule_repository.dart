import 'package:dio/dio.dart' hide Headers;
import 'package:fitend_member/common/dio/dio.dart';
import 'package:fitend_member/schedule/model/post_workout_record_feedback_model.dart';
import 'package:fitend_member/schedule/model/put_workout_schedule_date_model.dart';
import 'package:fitend_member/schedule/model/workout_schedule_model.dart';
import 'package:fitend_member/schedule/model/workout_schedule_pagenate_params.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

part 'workout_schedule_repository.g.dart';

final workoutScheduleRepositoryProvider =
    Provider<WorkoutScheduleRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return WorkoutScheduleRepository(dio);
});

@RestApi()
abstract class WorkoutScheduleRepository {
  factory WorkoutScheduleRepository(Dio dio) = _WorkoutScheduleRepository;

  @GET('/workoutSchedules')
  @Headers({
    'accessToken': 'true',
  })
  Future<WorkoutScheduleModel> getWorkoutSchedule({
    @Queries() required WorkoutSchedulePagenateParams params,
  });

  @GET('/workoutSchedules/{id}')
  @Headers({
    'accessToken': 'true',
  })
  Future<WorkoutModel> getWorkout({
    @Path('id') required int id,
  });

  @POST('/workoutSchedules/{id}/feedbacks')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> postWorkoutRecordsFeedback({
    @Path('id') required int id,
    @Body() required PostWorkoutRecordFeedbackModel body,
  });

  @PUT('/workoutSchedules/{id}')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> putworkoutScheduleDate({
    @Path('id') required int id,
    @Body() required PutWorkoutScheduleModel body,
  });
}
