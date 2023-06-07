import 'dart:async';

import 'package:fitend_member/workout/model/get_workout_records_params.dart';
import 'package:fitend_member/workout/model/workout_result_model.dart';
import 'package:fitend_member/workout/repository/workout_records_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workoutRecordsProvider =
    StateNotifierProvider<WorkoutRecordStateNotifier, WorkoutResultModelBase?>(
        (ref) {
  final workoutRecordsRepository = ref.watch(workoutRecordsRepositoryProvider);

  return WorkoutRecordStateNotifier(repository: workoutRecordsRepository);
});

class WorkoutRecordStateNotifier
    extends StateNotifier<WorkoutResultModelBase?> {
  final WorkoutRecordsRepository repository;

  WorkoutRecordStateNotifier({
    required this.repository,
  }) : super(null);

  Future<void> getWorkoutResults({
    required int workoutScheduleId,
  }) async {
    try {
      final isLoading = state is WorkoutResultModelLoading;
      if (isLoading) return;

      state = WorkoutResultModelLoading();

      final response = await repository.getWorkoutResults(
        params: GetWorkoutRecordsParams(
          workoutScheduleId: workoutScheduleId,
        ),
      );

      state = response;
    } catch (e) {
      state = WorkoutResultModelError(
        message: '데이터를 불러올수없습니다',
      );
    }
  }
}
