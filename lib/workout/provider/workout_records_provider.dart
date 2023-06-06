import 'package:dio/dio.dart';
import 'package:fitend_member/workout/model/post_workout_record_model.dart';
import 'package:fitend_member/workout/repository/workout_records_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workoutRecordsProvider = StateNotifierProvider((ref) {
  final workoutRecordsRepository = ref.watch(workoutRecordsRepositoryProvider);

  return WorkoutRecordStateNotifier(repository: workoutRecordsRepository);
});

class WorkoutRecordStateNotifier extends StateNotifier {
  final WorkoutRecordsRepository repository;

  WorkoutRecordStateNotifier({
    required this.repository,
  }) : super(null);

  Future<void> postWorkoutRecords({
    required PostWorkoutRecordModel model,
  }) async {
    try {
      final resp = await repository.postWorkoutRecords(body: model);
    } on DioError {}
  }
}
