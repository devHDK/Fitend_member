import 'package:dio/dio.dart';
import 'package:fitend_member/common/provider/hive_exercies_index_provider.dart';
import 'package:fitend_member/common/provider/hive_modified_exercise_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_record_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_x_more_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_feedback_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_result_provider.dart';
import 'package:fitend_member/schedule/repository/workout_schedule_repository.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:fitend_member/workout/model/workout_record_model.dart';
import 'package:fitend_member/workout/model/workout_result_model.dart';
import 'package:fitend_member/workout/provider/workout_records_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final workoutProvider =
    StateNotifierProvider.family<WorkoutStateNotifier, WorkoutModelBase, int>(
        (ref, id) {
  final repository = ref.watch(workoutScheduleRepositoryProvider);
  final provider = ref.read(workoutRecordsProvider(id).notifier);
  final AsyncValue<Box> workoutRecordBox = ref.read(hiveWorkoutRecordProvider);
  final AsyncValue<Box> workoutResultBox = ref.read(hiveWorkoutResultProvider);
  final AsyncValue<Box> timerWorkoutBox = ref.read(hiveTimerRecordProvider);
  final AsyncValue<Box> timerXMoreBox = ref.read(hiveTimerXMoreRecordProvider);
  final AsyncValue<Box> modifiedExerciseBox =
      ref.read(hiveModifiedExerciseProvider);
  final AsyncValue<Box> workoutFeedbackBox =
      ref.read(hiveWorkoutFeedbackProvider);
  final AsyncValue<Box> exerciseIndexBox = ref.read(hiveExerciseIndexProvider);

  return WorkoutStateNotifier(
    workoutRecordProvider: provider,
    repository: repository,
    id: id,
    workoutRecordBox: workoutRecordBox,
    workoutResultBox: workoutResultBox,
    timerWorkoutBox: timerWorkoutBox,
    timerXMoreBox: timerXMoreBox,
    modifiedExerciseBox: modifiedExerciseBox,
    exerciseIndexBox: exerciseIndexBox,
    workoutFeedbackBox: workoutFeedbackBox,
  );
});

class WorkoutStateNotifier extends StateNotifier<WorkoutModelBase> {
  final WorkoutScheduleRepository repository;
  final WorkoutRecordStateNotifier workoutRecordProvider;
  final int id;
  final AsyncValue<Box> workoutRecordBox;
  final AsyncValue<Box> workoutResultBox;
  final AsyncValue<Box> timerWorkoutBox;
  final AsyncValue<Box> timerXMoreBox;
  final AsyncValue<Box> modifiedExerciseBox;
  final AsyncValue<Box> exerciseIndexBox;
  final AsyncValue<Box> workoutFeedbackBox;

  WorkoutStateNotifier({
    required this.repository,
    required this.workoutRecordProvider,
    required this.id,
    required this.workoutRecordBox,
    required this.workoutResultBox,
    required this.timerWorkoutBox,
    required this.timerXMoreBox,
    required this.modifiedExerciseBox,
    required this.exerciseIndexBox,
    required this.workoutFeedbackBox,
  }) : super(WorkoutModelLoading()) {
    getWorkout(id: id);
  }

  Future<void> getWorkout({required int id}) async {
    try {
      final response = await repository.getWorkout(id: id);

      if (response.isWorkoutComplete) {
        response.hasLocal = true;

        workoutRecordBox.whenData(
          (value) {
            final record = value.get(response.exercises[0].workoutPlanId);
            if (record == null) {
              // result 기록 없음
              workoutRecordProvider.getWorkoutResults(workoutScheduleId: id);
              response.hasLocal = false;
            } else {
              workoutRecordBox.whenData((value) {
                for (int i = 0; i < response.exercises.length; i++) {}
              });
            }
          },
        );
      }

      state = response;
    } on DioException {
      state = WorkoutModelError(message: '데이터를 불러올수없습니다');
    }
  }

  void updateWorkoutStateDate({
    required String dateTime,
  }) {
    final pstate = state as WorkoutModel;

    state = pstate.copyWith(startDate: dateTime);
  }

  void updateWorkoutStateIsComplete() {
    if (state is WorkoutModelLoading) {
      return;
    }

    final pstate = state as WorkoutModel;

    state = pstate.copyWith(isWorkoutComplete: true);
  }
}
