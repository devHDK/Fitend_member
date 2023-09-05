import 'package:dio/dio.dart';
import 'package:fitend_member/common/provider/hive_exercies_index_provider.dart';
import 'package:fitend_member/common/provider/hive_modified_exercise_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_record_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_x_more_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_feedback_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_result_provider.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/schedule/model/workout_feedback_record_model.dart';
import 'package:fitend_member/schedule/repository/workout_schedule_repository.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:fitend_member/workout/model/workout_record_simple_model.dart';
import 'package:fitend_member/workout/model/workout_result_model.dart';
import 'package:fitend_member/workout/provider/workout_result_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:collection/collection.dart';

final workoutProvider =
    StateNotifierProvider.family<WorkoutStateNotifier, WorkoutModelBase, int>(
        (ref, id) {
  final repository = ref.watch(workoutScheduleRepositoryProvider);
  final provider = ref.read(workoutResultProvider(id).notifier);
  final AsyncValue<Box> workoutRecordSimpleBox =
      ref.watch(hiveWorkoutRecordSimpleProvider);
  final AsyncValue<Box> workoutRecordForResultBox =
      ref.watch(hiveWorkoutRecordForResultProvider);
  final AsyncValue<Box> timerWorkoutBox = ref.watch(hiveTimerRecordProvider);
  final AsyncValue<Box> timerXMoreBox = ref.watch(hiveTimerXMoreRecordProvider);
  final AsyncValue<Box> modifiedExerciseBox =
      ref.watch(hiveModifiedExerciseProvider);
  final AsyncValue<Box> workoutFeedbackBox =
      ref.watch(hiveWorkoutFeedbackProvider);

  final AsyncValue<Box> exerciseIndexBox = ref.watch(hiveExerciseIndexProvider);
  final AsyncValue<Box> processingExerciseIndexBox =
      ref.watch(hiveExerciseIndexProvider);

  return WorkoutStateNotifier(
    workoutResultProvider: provider,
    repository: repository,
    id: id,
    workoutRecordSimpleBox: workoutRecordSimpleBox,
    workoutRecordForResultBox: workoutRecordForResultBox,
    timerWorkoutBox: timerWorkoutBox,
    timerXMoreBox: timerXMoreBox,
    modifiedExerciseBox: modifiedExerciseBox,
    exerciseIndexBox: exerciseIndexBox,
    workoutFeedbackBox: workoutFeedbackBox,
    processingExerciseIndexBox: processingExerciseIndexBox,
  );
});

class WorkoutStateNotifier extends StateNotifier<WorkoutModelBase> {
  final WorkoutScheduleRepository repository;
  final WorkoutRecordStateNotifier workoutResultProvider;
  final int id;
  final AsyncValue<Box> workoutRecordSimpleBox;
  final AsyncValue<Box> workoutRecordForResultBox;
  final AsyncValue<Box> timerWorkoutBox;
  final AsyncValue<Box> timerXMoreBox;
  final AsyncValue<Box> modifiedExerciseBox;
  final AsyncValue<Box> exerciseIndexBox;
  final AsyncValue<Box> workoutFeedbackBox;
  final AsyncValue<Box> processingExerciseIndexBox;

  WorkoutStateNotifier({
    required this.repository,
    required this.workoutResultProvider,
    required this.id,
    required this.workoutRecordSimpleBox,
    required this.workoutRecordForResultBox,
    required this.timerWorkoutBox,
    required this.timerXMoreBox,
    required this.modifiedExerciseBox,
    required this.exerciseIndexBox,
    required this.workoutFeedbackBox,
    required this.processingExerciseIndexBox,
  }) : super(WorkoutModelLoading()) {
    getWorkout(id: id);
  }

  Future<void> getWorkout({required int id}) async {
    try {
      final response = await repository.getWorkout(id: id);

      if (response.isWorkoutComplete) {
        //운동이 완료 상태일때
        bool hasLocal = false;
        WorkoutResultModel tempResultModel = WorkoutResultModel(
          startDate: '',
          strengthIndex: 0,
          workoutRecords: [],
        );

        workoutFeedbackBox.whenData((value) {
          final record = value.get(id);

          if (record != null && record is WorkoutFeedbackRecordModel) {
            hasLocal = true;
            tempResultModel = tempResultModel.copyWith(
              startDate: record.startDate.toString(),
              strengthIndex: record.strengthIndex,
              issueIndexes: record.issueIndexes,
              contents: record.contents,
            );
          }
        });

        if (hasLocal) {
          List<WorkoutRecord> tempRecordList = [];
          workoutRecordForResultBox.whenData((value) {
            for (var exercise in response.exercises) {
              final record = value.get(exercise.workoutPlanId);
              if (record != null && record is WorkoutRecord) {
                tempRecordList.add(record);
              }
            }

            tempResultModel =
                tempResultModel.copyWith(workoutRecords: tempRecordList);
          });

          workoutResultProvider.state = tempResultModel;
        } else {
          //TODO:  getWorkoutResults 에서 local db 저장
          await workoutResultProvider.getWorkoutResults(workoutScheduleId: id);

          if (workoutResultProvider.state is WorkoutResultModel) {
            final workoutResultState =
                workoutResultProvider.state as WorkoutResultModel;

            List<WorkoutRecordSimple> tempRecordList = [];

            //기록에 저장
            workoutRecordSimpleBox.whenData((value) {
              workoutResultState.workoutRecords.mapIndexed((index, e) {
                value.put(
                    e.workoutPlanId,
                    WorkoutRecordSimple(
                        workoutPlanId: e.workoutPlanId, setInfo: e.setInfo));
                tempRecordList.add(WorkoutRecordSimple(
                    workoutPlanId: e.workoutPlanId, setInfo: e.setInfo));
              });
            });

            response.recordedExercises = tempRecordList; // 기록 목록 업데이트
          }
        }
      } else {
        processingExerciseIndexBox.whenData((value) {
          final record = value.get(id);

          if (record != null) {
            response.isProcessing = true;
          } else {
            response.isProcessing = false;
          }
        });

        if (response.isProcessing != null && response.isProcessing!) {
          //진행중이던 운동일경우
          List<WorkoutRecordSimple> tempRecordList = [];
          workoutRecordSimpleBox.whenData((value) {
            for (int i = 0; i < response.exercises.length; i++) {
              final record = value.get(response.exercises[i].workoutPlanId);
              if (record != null && record is WorkoutRecordSimple) {
                tempRecordList.add(record);
              }
            }

            response.recordedExercises = tempRecordList;
          });

          List<Exercise> tempModifiedExercises = [];
          modifiedExerciseBox.whenData((value) {
            for (int i = 0; i < response.exercises.length; i++) {
              final record = value.get(response.exercises[i].workoutPlanId);
              if (record != null && record is Exercise) {
                tempModifiedExercises.add(record);
              }
            }
            response.modifiedExercises = tempModifiedExercises;
          });
        }
      }

      state = response;
    } on DioException {
      state = WorkoutModelError(message: '데이터를 불러올수없습니다');
    }
  }

  //modifiedExecises 등등 저장
  void workoutSaveForStart() async {
    final pstate = state as WorkoutModel;

    modifiedExerciseBox.whenData((value) {
      for (int i = 0; i < pstate.exercises.length; i++) {
        final exercise = value.get(pstate.exercises[i].workoutPlanId);
        if (exercise == null) {
          //저장된게 없으면 저장
          value.put(pstate.exercises[i].workoutPlanId, pstate.exercises[i]);
        }
      }
    });

    workoutRecordForResultBox.whenData((value) {
      for (var e in pstate.exercises) {
        final record = value.get(e.workoutPlanId);
        if (record == null) {
          value.put(
            e.workoutPlanId,
            WorkoutRecord(
              exerciseName: e.name,
              targetMuscles: [e.targetMuscles[0].name],
              trackingFieldId: e.trackingFieldId,
              workoutPlanId: e.workoutPlanId,
              setInfo: e.setInfo,
            ),
          );
        }
      }
    });

    workoutFeedbackBox.whenData((value) {
      final record = value.get(pstate.workoutScheduleId);
      if (record == null) {
        value.put(
          pstate.workoutScheduleId,
          WorkoutFeedbackRecordModel(
            startDate: DateTime.parse(pstate.startDate),
          ),
        );
      }
    });
  }

  void modifiedBoxDuplicate() {
    final pstate = state as WorkoutModel;

    modifiedExerciseBox.whenData(
      (value) {
        for (var element in pstate.exercises) {
          value.put(element.workoutPlanId, element);
        }
      },
    );
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
