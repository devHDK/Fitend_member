import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fitend_member/common/provider/hive_schedule_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_feedback_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/schedule/model/workout_feedback_record_model.dart';
import 'package:fitend_member/schedule/model/workout_schedule_model.dart';
import 'package:fitend_member/schedule/model/workout_schedule_pagenate_params.dart';
import 'package:fitend_member/schedule/repository/workout_schedule_repository.dart';
import 'package:fitend_member/workout/model/get_workout_records_params.dart';
import 'package:fitend_member/workout/model/schedule_record_model.dart';
import 'package:fitend_member/workout/model/workout_record_simple_model.dart';
import 'package:fitend_member/workout/model/workout_result_model.dart';
import 'package:fitend_member/workout/repository/workout_records_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

final workoutResultProvider = StateNotifierProvider.family
    .autoDispose<WorkoutRecordStateNotifier, WorkoutResultModelBase?, int>(
        (ref, id) {
  final workoutRecordsRepository = ref.watch(workoutRecordsRepositoryProvider);
  final workoutscheduleRepository =
      ref.watch(workoutScheduleRepositoryProvider);
  final AsyncValue<Box> workoutFeedbackBox =
      ref.watch(hiveWorkoutFeedbackProvider);
  final AsyncValue<Box> workoutRecordSimpleBox =
      ref.watch(hiveWorkoutRecordSimpleProvider);
  final AsyncValue<Box> scheduleRecordBox = ref.watch(hiveScheduleRecordBox);
  final AsyncValue<Box> totalTimeBox = ref.watch(hiveProcessTotalTimeBox);

  return WorkoutRecordStateNotifier(
    resultRepository: workoutRecordsRepository,
    scheduleRepository: workoutscheduleRepository,
    id: id,
    workoutFeedbackBox: workoutFeedbackBox,
    workoutRecordSimpleBox: workoutRecordSimpleBox,
    scheduleRecordBox: scheduleRecordBox,
    totalTimeBox: totalTimeBox,
  );
});

class WorkoutRecordStateNotifier
    extends StateNotifier<WorkoutResultModelBase?> {
  final WorkoutRecordsRepository resultRepository;
  final WorkoutScheduleRepository scheduleRepository;
  final AsyncValue<Box> workoutRecordSimpleBox;
  final AsyncValue<Box> workoutFeedbackBox;
  final AsyncValue<Box> scheduleRecordBox;
  final AsyncValue<Box> totalTimeBox;
  final int id;

  WorkoutRecordStateNotifier({
    required this.resultRepository,
    required this.scheduleRepository,
    required this.id,
    required this.workoutRecordSimpleBox,
    required this.workoutFeedbackBox,
    required this.scheduleRecordBox,
    required this.totalTimeBox,
  }) : super(null);

  Future<void> getWorkoutResults({
    required int workoutScheduleId,
    List<Exercise>? exercises,
  }) async {
    try {
      final isLoading = state is WorkoutResultModelLoading;

      if (isLoading) return;

      state = WorkoutResultModelLoading();

      String startDate = '';
      WorkoutResultModel resultModel;

      if (exercises == null || exercises.isEmpty) {
        final response = await resultRepository.getWorkoutResults(
          params: GetWorkoutRecordsParams(
            workoutScheduleId: workoutScheduleId,
          ),
        );

        startDate = response.startDate;
        saveDataFromServer(response);

        resultModel = response;
      } else {
        bool hasLocal = true;

        WorkoutFeedbackRecordModel? savedFeedBack;
        ScheduleRecordsModel? savedScheduleRecord;
        List<WorkoutRecordSimple> savedWorkoutRecords = [];
        int? totalTime;

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

        totalTimeBox.whenData((value) {
          totalTime = value.get(id);
        });

        scheduleRecordBox.whenData((value) {
          savedScheduleRecord = value.get(id);

          if (savedScheduleRecord == null && totalTime == null) {
            hasLocal = false;
          }

          if (savedScheduleRecord == null && totalTime != null) {
            value.put(id, totalTime);
          }
        });

        debugPrint('hasLocal result : $hasLocal');
        debugPrint('result : $savedFeedBack');
        debugPrint('result  : $savedWorkoutRecords');
        debugPrint('result  : $savedScheduleRecord');

        if (!hasLocal) {
          final response = await resultRepository.getWorkoutResults(
            params: GetWorkoutRecordsParams(
              workoutScheduleId: workoutScheduleId,
            ),
          );

          startDate = response.startDate;
          saveDataFromServer(response);

          resultModel = response;
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

          startDate = DateFormat('yyyy-MM-dd').format(savedFeedBack!.startDate);

          resultModel = WorkoutResultModel(
            startDate: startDate,
            strengthIndex: savedFeedBack!.strengthIndex!,
            contents: savedFeedBack!.contents,
            issueIndexes: savedFeedBack!.issueIndexes,
            workoutRecords: workoutResults,
            scheduleRecords: savedScheduleRecord ??
                ScheduleRecordsModel(
                  workoutScheduleId: id,
                  workoutDuration: totalTime,
                ),
            // lastSchedules: [],
          );
        }
      }

      final lastMondayDate = DataUtils.getLastMondayDate(startDate);

      final scheduleResp = await scheduleRepository.getWorkoutSchedule(
          params: SchedulePagenateParams(
        startDate: lastMondayDate,
        interval: 13,
      ));

      List<WorkoutData> tempScheduleList = List.generate(
        14,
        (index) => WorkoutData(
          startDate: lastMondayDate.add(Duration(days: index)),
          workouts: [],
        ),
      );

      int index = 0;

      if (scheduleResp.data != null && scheduleResp.data!.isNotEmpty) {
        for (var tempSchedule in tempScheduleList) {
          if (index >= scheduleResp.data!.length) {
            break;
          }

          if (tempSchedule.startDate.year ==
                  scheduleResp.data![index].startDate.year &&
              tempSchedule.startDate.month ==
                  scheduleResp.data![index].startDate.month &&
              tempSchedule.startDate.day ==
                  scheduleResp.data![index].startDate.day) {
            tempSchedule.workouts!.addAll(scheduleResp.data![index].workouts!);

            index++;
          }
        }
      }

      state = resultModel.copyWith(
        lastSchedules: tempScheduleList,
      );
    } catch (e) {
      if (e is DioException) {
        debugPrint('getWorkoutResultsError : ${e.response!.statusCode}');
        state = WorkoutResultModelError(
            message: 'dioException : ${e.error} ${e.message}');
      } else {
        debugPrint(e.toString());
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

    workoutFeedbackBox.whenData((value) => value.put(
        id,
        WorkoutFeedbackRecordModel(
          startDate: DateTime.parse(model.startDate),
          strengthIndex: model.strengthIndex,
          issueIndexes: model.issueIndexes,
          contents: model.contents,
        )));

    scheduleRecordBox.whenData((value) => value.put(id, model.scheduleRecords));
  }
}
