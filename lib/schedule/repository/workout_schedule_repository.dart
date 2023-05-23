import 'package:dio/dio.dart' hide Headers;
import 'package:fitend_member/common/dio/dio.dart';
import 'package:fitend_member/schedule/model/workout_schedule_model.dart';
import 'package:fitend_member/schedule/model/workout_schedule_pagenate_params.dart';
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
    @Queries() required WorkoutSchedulePagenateParams startDate,
  });
}
