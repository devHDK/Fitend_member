import 'package:dio/dio.dart';
import 'package:fitend_member/workout/model/post_workout_record_model.dart';
import 'package:retrofit/retrofit.dart';

part 'workout_records_repository.g.dart';

// final workoutRecordsRepository = Provider

@RestApi()
abstract class WorkoutRecordsRepository {
  factory WorkoutRecordsRepository(Dio dio) = _WorkoutRecordsRepository;

  Future<void> postWorkoutRecords(
      {@Body() required PostWorkoutRecordModel body});
}
