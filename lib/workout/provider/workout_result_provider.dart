import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fitend_member/common/provider/hive_workout_feedback_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_result_provider.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/workout/model/get_workout_records_params.dart';
import 'package:fitend_member/workout/model/workout_result_model.dart';
import 'package:fitend_member/workout/repository/workout_records_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final workoutResultProvider = StateNotifierProvider.family<
    WorkoutRecordStateNotifier, WorkoutResultModelBase?, int>((ref, id) {
  final workoutRecordsRepository = ref.watch(workoutRecordsRepositoryProvider);
  final AsyncValue<Box> workoutFeedbackBox =
      ref.watch(hiveWorkoutFeedbackProvider);
  final AsyncValue<Box> workoutRecordSimpleBox =
      ref.watch(hiveWorkoutRecordSimpleProvider);

  return WorkoutRecordStateNotifier(
    repository: workoutRecordsRepository,
    id: id,
    workoutFeedbackBox: workoutFeedbackBox,
    workoutRecordSimpleBox: workoutRecordSimpleBox,
  );
});

class WorkoutRecordStateNotifier
    extends StateNotifier<WorkoutResultModelBase?> {
  final WorkoutRecordsRepository repository;
  final AsyncValue<Box> workoutRecordSimpleBox;
  final AsyncValue<Box> workoutFeedbackBox;
  final int id;

  WorkoutRecordStateNotifier({
    required this.repository,
    required this.id,
    required this.workoutRecordSimpleBox,
    required this.workoutFeedbackBox,
  }) : super(null) {
    // getWorkoutResults(workoutScheduleId: id);
  }

  Future<void> getWorkoutResults({
    required int workoutScheduleId,
    List<Exercise>? exercises,
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
      if (e is DioException) {
        debugPrint('getWorkoutResultsError : ${e.response!.statusCode}');
        state = WorkoutResultModelError(
            message: 'dioException : ${e.error} ${e.message}');
      } else {
        state = WorkoutResultModelError(
          message: '데이터를 불러올수없습니다',
        );
      }
    }
  }
}
