import 'package:dio/dio.dart' hide Headers;
import 'package:fitend_member/common/dio/dio.dart';
import 'package:fitend_member/workout/model/post_workout_record_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

part 'workout_records_repository.g.dart';

final workoutRecordsRepositoryProvider =
    Provider<WorkoutRecordsRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return WorkoutRecordsRepository(dio);
});

@RestApi()
abstract class WorkoutRecordsRepository {
  factory WorkoutRecordsRepository(Dio dio) = _WorkoutRecordsRepository;

  @POST('/workoutRecords')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> postWorkoutRecords({
    @Body() required PostWorkoutRecordModel body,
  });
}
