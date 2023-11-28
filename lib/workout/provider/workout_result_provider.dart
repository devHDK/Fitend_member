import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fitend_member/common/provider/hive_schedule_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_feedback_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/schedule/model/workout_feedback_record_model.dart';
import 'package:fitend_member/schedule/repository/workout_schedule_repository.dart';
import 'package:fitend_member/workout/model/get_workout_records_params.dart';
import 'package:fitend_member/workout/model/schedule_record_model.dart';
import 'package:fitend_member/workout/model/workout_record_simple_model.dart';
import 'package:fitend_member/workout/model/workout_result_model.dart';
import 'package:fitend_member/workout/repository/workout_records_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final workoutResultProvider = StateNotifierProvider.family<
    WorkoutRecordStateNotifier, WorkoutResultModelBase?, int>((ref, id) {
  final workoutRecordsRepository = ref.watch(workoutRecordsRepositoryProvider);
  final workoutscheduleRepository =
      ref.watch(workoutScheduleRepositoryProvider);
  final AsyncValue<Box> workoutFeedbackBox =
      ref.watch(hiveWorkoutFeedbackProvider);
  final AsyncValue<Box> workoutRecordSimpleBox =
      ref.watch(hiveWorkoutRecordSimpleProvider);
  final AsyncValue<Box> scheduleRecordBox = ref.watch(hiveScheduleRecordBox);

  return WorkoutRecordStateNotifier(
    resultRepository: workoutRecordsRepository,
    scheduleRepository: workoutscheduleRepository,
    id: id,
    workoutFeedbackBox: workoutFeedbackBox,
    workoutRecordSimpleBox: workoutRecordSimpleBox,
    scheduleRecordBox: scheduleRecordBox,
  );
});

class WorkoutRecordStateNotifier
    extends StateNotifier<WorkoutResultModelBase?> {
  final WorkoutRecordsRepository resultRepository;
  final WorkoutScheduleRepository scheduleRepository;
  final AsyncValue<Box> workoutRecordSimpleBox;
  final AsyncValue<Box> workoutFeedbackBox;
  final AsyncValue<Box> scheduleRecordBox;
  final int id;

  WorkoutRecordStateNotifier({
    required this.resultRepository,
    required this.scheduleRepository,
    required this.id,
    required this.workoutRecordSimpleBox,
    required this.workoutFeedbackBox,
    required this.scheduleRecordBox,
  }) : super(null) {
    // getWorkoutResults(workoutScheduleId: id);
  }

  Future<void> getWorkoutResults({
    required int workoutScheduleId,
    List<Exercise>? exercises,
    String? startDate,
  }) async {
    try {
      final isLoading = state is WorkoutResultModelLoading;

      if (isLoading) return;

      state = WorkoutResultModelLoading();

      if (exercises == null || exercises.isEmpty || startDate == null) {
        final response = await resultRepository.getWorkoutResults(
          params: GetWorkoutRecordsParams(
            workoutScheduleId: workoutScheduleId,
          ),
        );

        state = response;
      } else {
        bool hasLocal = true;

        WorkoutFeedbackRecordModel? savedFeedBack;
        ScheduleRecordsModel? savedScheduleRecord;
        List<WorkoutRecordSimple> savedWorkoutRecords = [];

        workoutFeedbackBox.whenData(
          (value) {
            savedFeedBack = value.get(workoutScheduleId);

            if (savedFeedBack == null) {
              hasLocal = false;
            }
          },
        );

        workoutRecordSimpleBox.whenData(
          (value) {
            for (var i = 0; i < exercises.length; i++) {
              final record = value.get(exercises[i].workoutPlanId);
              if (record != null && record is WorkoutRecordSimple) {
                savedWorkoutRecords.add(record);
              } else {
                hasLocal = false;
              }
            }
          },
        );

        scheduleRecordBox.whenData((value) {
          savedScheduleRecord = value.get(id);
          if (savedScheduleRecord == null) {
            hasLocal = false;
          }
        });

        if (!hasLocal) {
          final response = await resultRepository.getWorkoutResults(
            params: GetWorkoutRecordsParams(
              workoutScheduleId: workoutScheduleId,
            ),
          );

          state = response;
        } else {
          List<WorkoutRecord> workoutResults = [];

          for (int i = 0; i < exercises.length; i++) {
            workoutResults.add(
              WorkoutRecord(
                exerciseName: exercises[i].name,
                targetMuscles:
                    exercises[i].targetMuscles.map((e) => e.name).toList(),
                trackingFieldId: exercises[i].trackingFieldId,
                workoutPlanId: exercises[i].workoutPlanId,
                setInfo: savedWorkoutRecords[i].setInfo,
              ),
            );
          }

          state = WorkoutResultModel(
            startDate: startDate,
            strengthIndex: savedFeedBack!.strengthIndex!,
            contents: savedFeedBack!.contents,
            issueIndexes: savedFeedBack!.issueIndexes,
            workoutRecords: workoutResults,
            scheduleRecords: savedScheduleRecord,
          );
        }
      }
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

  void saveDataFromServer(WorkoutResultModel model) {
    workoutRecordSimpleBox.whenData((value) {
      for (var workoutRecord in model.workoutRecords) {
        final record = value.get(workoutRecord.workoutPlanId);
        if (record == null) {
          value.put(
            workoutRecord.workoutPlanId,
            WorkoutRecordSimple(
                workoutPlanId: workoutRecord.workoutPlanId,
                setInfo: workoutRecord.setInfo),
          );
        }
      }
    });

    workoutFeedbackBox.whenData((value) => null);
  }
}
