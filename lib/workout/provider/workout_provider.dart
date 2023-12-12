import 'package:dio/dio.dart';
import 'package:fitend_member/common/provider/hive_exercies_index_provider.dart';
import 'package:fitend_member/common/provider/hive_modified_exercise_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_record_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_x_more_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_feedback_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_result_provider.dart';
import 'package:fitend_member/common/utils/hive_box_utils.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:fitend_member/schedule/model/workout_feedback_record_model.dart';
import 'package:fitend_member/schedule/repository/workout_schedule_repository.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:fitend_member/workout/model/workout_record_simple_model.dart';
import 'package:fitend_member/workout/model/workout_result_model.dart';

import 'package:fitend_member/workout/provider/workout_result_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  final AsyncValue<Box> processTotalTimeBox =
      ref.watch(hiveProcessTotalTimeBox);

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
    processTotalTimeBox: processTotalTimeBox,
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
  final AsyncValue<Box> processTotalTimeBox;

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
    required this.processTotalTimeBox,
  }) : super(WorkoutModelLoading()) {
    getWorkout(id: id);
  }

  Future<void> getWorkout({required int id}) async {
    try {
      var response = await repository.getWorkout(id: id);

      if (response.isWorkoutComplete) {
        //운동이 완료 상태일때
        bool hasLocal = false;
        response.isProcessing = false;

        WorkoutResultModel tempResultModel = WorkoutResultModel(
          startDate: '',
          strengthIndex: 0,
          workoutRecords: [],
          lastSchedules: [],
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
        } else {
          await workoutResultProvider.getWorkoutResults(workoutScheduleId: id);

          if (workoutResultProvider.state is WorkoutResultModel) {
            final workoutResultState =
                workoutResultProvider.state as WorkoutResultModel;

            debugPrint('${workoutResultState.workoutRecords[0].setInfo[0]}');

            //기록에 저장
            List<WorkoutRecordSimple> tempRecordList = [];

            workoutRecordSimpleBox.whenData((value) {
              for (var workoutRecord in workoutResultState.workoutRecords) {
                // final record = value.get(workoutRecord.workoutPlanId);

                value.put(
                    workoutRecord.workoutPlanId,
                    WorkoutRecordSimple(
                        workoutPlanId: workoutRecord.workoutPlanId,
                        setInfo: workoutRecord.setInfo));
              }
            });

            workoutRecordSimpleBox.whenData((value) {
              for (int i = 0; i < response.exercises.length; i++) {
                final record = value.get(response.exercises[i].workoutPlanId);
                if (record != null && record is WorkoutRecordSimple) {
                  tempRecordList.add(record);
                }
              }
              response.recordedExercises = tempRecordList;
            }); // 기록 목록 업데이트
          }
        }
      }

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

      debugPrint(response.toString());

      state = response.copyWith(
        exercises: response.exercises.map((exercise) {
          return Exercise(
            workoutPlanId: exercise.workoutPlanId,
            name: exercise.name,
            description: exercise.description,
            trackingFieldId: exercise.trackingFieldId,
            trainerNickname: exercise.trainerNickname,
            trainerProfileImage: exercise.trainerProfileImage,
            targetMuscles: exercise.targetMuscles,
            videos: exercise.videos,
            circuitGroupNum: exercise.circuitGroupNum,
            circuitSeq: exercise.circuitSeq,
            setType: exercise.setType,
            setInfo: exercise.setInfo.map((e) {
              return SetInfo(
                index: e.index,
                reps: e.reps,
                seconds: e.seconds,
                weight: e.weight,
              );
            }).toList(),
          );
        }).toList(),
      );
    } on DioException {
      state = WorkoutModelError(message: '데이터를 불러올수없습니다');
    }
  }

  //modifiedExecises 등등 저장
  void workoutSaveForStart() async {
    final pstate = state as WorkoutModel;

    exerciseIndexBox.whenData((value) {
      value.put(id, 0);
    });

    modifiedExerciseBox.whenData((value) {
      for (int i = 0; i < pstate.exercises.length; i++) {
        final exercise = value.get(pstate.exercises[i].workoutPlanId);
        if (exercise == null) {
          final tempExercise = Exercise(
            workoutPlanId: pstate.exercises[i].workoutPlanId,
            name: pstate.exercises[i].name,
            description: pstate.exercises[i].description,
            trackingFieldId: pstate.exercises[i].trackingFieldId,
            trainerNickname: pstate.exercises[i].trainerNickname,
            trainerProfileImage: pstate.exercises[i].trainerProfileImage,
            targetMuscles: pstate.exercises[i].targetMuscles,
            videos: pstate.exercises[i].videos,
            circuitGroupNum: pstate.exercises[i].circuitGroupNum,
            circuitSeq: pstate.exercises[i].circuitSeq,
            setType: pstate.exercises[i].setType,
            setInfo: pstate.exercises[i].setInfo.map((e) {
              return SetInfo(
                index: e.index,
                reps: e.reps,
                seconds: e.seconds,
                weight: e.weight,
              );
            }).toList(),
          );
          //저장된게 없으면 저장
          value.put(pstate.exercises[i].workoutPlanId, tempExercise);
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

    timerXMoreBox.whenData((value) {
      for (int i = 0; i < pstate.exercises.length; i++) {
        if (pstate.exercises[i].trackingFieldId == 3 ||
            pstate.exercises[i].trackingFieldId == 4) {
          final record = value.get(pstate.exercises[i].workoutPlanId);
          //저장된게 없으면 저장
          if (record == null ||
              (record is WorkoutRecordSimple &&
                  record.setInfo.length !=
                      pstate.exercises[i].setInfo.length)) {
            final tempSetInfoList =
                List.generate(pstate.exercises[i].setInfo.length, (index) {
              return SetInfo(index: index + 1, seconds: 0);
            });

            value.put(
              pstate.exercises[i].workoutPlanId,
              WorkoutRecordSimple(
                workoutPlanId: pstate.exercises[i].workoutPlanId,
                setInfo: tempSetInfoList,
              ),
            );
          }
        }
      }
    });
  }

  void resetWorkoutProcess() {
    final pstate = state as WorkoutModel;

    BoxUtils.deleteBox(workoutRecordSimpleBox, pstate.exercises);
    BoxUtils.deleteBox(modifiedExerciseBox, pstate.exercises);
    BoxUtils.deleteTimerBox(timerWorkoutBox, pstate.exercises);
    BoxUtils.deleteTimerBox(timerXMoreBox, pstate.exercises);
    BoxUtils.deleteBox(workoutRecordForResultBox, pstate.exercises);

    exerciseIndexBox.whenData((value) {
      value.delete(
        id,
      );
    });

    processTotalTimeBox.whenData((value) {
      value.delete(
        id,
      );
    });
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
