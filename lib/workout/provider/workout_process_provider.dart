import 'package:dio/dio.dart';
import 'package:fitend_member/common/provider/hive_exercies_index_provider.dart';
import 'package:fitend_member/common/provider/hive_modified_exercise_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_record_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_x_more_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/common/utils/hive_box_utils.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:fitend_member/workout/model/post_workout_record_model.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:fitend_member/workout/model/workout_process_model.dart';
import 'package:fitend_member/workout/model/workout_record_simple_model.dart';
import 'package:fitend_member/workout/provider/workout_provider.dart';
import 'package:fitend_member/workout/repository/workout_records_repository.dart';
import 'package:fitend_member/workout/view/workout_list_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final workoutProcessProvider = StateNotifierProvider.family<
    WorkoutProcessStateNotifier, WorkoutProcessModelBase?, int>((ref, id) {
  final repository = ref.watch(workoutRecordsRepositoryProvider);
  final provider = ref.read(workoutProvider(id).notifier);
  final AsyncValue<Box> workoutRecordBox =
      ref.read(hiveWorkoutRecordSimpleProvider);
  final AsyncValue<Box> timerWorkoutBox = ref.read(hiveTimerRecordProvider);
  final AsyncValue<Box> timerXMoreBox = ref.read(hiveTimerXMoreRecordProvider);
  final AsyncValue<Box> modifiedExerciseBox =
      ref.read(hiveModifiedExerciseProvider);
  final AsyncValue<Box> exerciseIndexBox = ref.read(hiveExerciseIndexProvider);

  return WorkoutProcessStateNotifier(
    repository: repository,
    id: id,
    workoutProvider: provider,
    workoutRecordBox: workoutRecordBox,
    timerWorkoutBox: timerWorkoutBox,
    timerXMoreBox: timerXMoreBox,
    modifiedExerciseBox: modifiedExerciseBox,
    exerciseIndexBox: exerciseIndexBox,
  );
});

class WorkoutProcessStateNotifier
    extends StateNotifier<WorkoutProcessModelBase?> {
  final WorkoutRecordsRepository repository;
  final int id;
  final WorkoutStateNotifier workoutProvider;
  final AsyncValue<Box> workoutRecordBox;
  final AsyncValue<Box> timerWorkoutBox;
  final AsyncValue<Box> timerXMoreBox;
  final AsyncValue<Box> modifiedExerciseBox;
  final AsyncValue<Box> exerciseIndexBox;

  WorkoutProcessStateNotifier({
    required this.repository,
    required this.id,
    required this.workoutProvider,
    required this.workoutRecordBox,
    required this.timerWorkoutBox,
    required this.timerXMoreBox,
    required this.modifiedExerciseBox,
    required this.exerciseIndexBox,
  }) : super(null) {
    // init(workoutProvider);
  }

  //init
  void init(WorkoutStateNotifier workoutProvider) {
    final isLoading = state is WorkoutProcessModelLoading;
    if (isLoading) return;

    state = WorkoutProcessModelLoading();

    WorkoutProcessModel tempState = WorkoutProcessModel(
        exerciseIndex: 0,
        maxExerciseIndex: 0,
        setInfoCompleteList: [],
        maxSetInfoList: [],
        exercises: [],
        modifiedExercises: [],
        workoutFinished: false);
    List<Exercise> tempExercises = [];
    final workoutProvierState = workoutProvider.state as WorkoutModel;

    tempExercises = workoutProvierState.exercises; // 서버에서 받은 운동 목록
    tempState.exercises = tempExercises;
    tempState.maxExerciseIndex = tempExercises.length - 1; //
    tempState.setInfoCompleteList =
        List.generate(tempState.exercises.length, (index) => 0);
    tempState.maxSetInfoList = List.generate(tempState.exercises.length,
        (index) => tempState.exercises[index].setInfo.length);

    modifiedExerciseBox.whenData((value) {
      // 이전에 저장된 운동 받아옴
      for (int i = 0; i < tempState.exercises.length; i++) {
        final record = value.get(tempState.exercises[i].workoutPlanId);
        if (record != null && record is Exercise) {
          tempState.modifiedExercises.add(
            Exercise(
              workoutPlanId: record.workoutPlanId,
              name: record.name,
              description: record.description,
              trackingFieldId: record.trackingFieldId,
              trainerNickname: record.trainerNickname,
              trainerProfileImage: record.trainerProfileImage,
              targetMuscles: record.targetMuscles,
              videos: record.videos,
              setInfo: record.setInfo.map((e) {
                return SetInfo(
                  index: e.index,
                  weight: e.weight,
                  reps: e.reps,
                  seconds: e.seconds,
                );
              }).toList(),
            ),
          );
        }
      }
    });

    workoutRecordBox.whenData((value) {
      // 완료된 운동 체크
      for (int i = 0; i <= tempState.maxExerciseIndex; i++) {
        final tempRecord = value.get(tempState.exercises[i].workoutPlanId);

        if (tempRecord != null && tempRecord.setInfo.length > 0) {
          final record =
              value.get(tempState.exercises[i].workoutPlanId).setInfo.length;
          tempState.setInfoCompleteList[i] = record;
        } else {
          tempState.setInfoCompleteList[i] = 0;
        }
      }
    });

    exerciseIndexBox.whenData((value) {
      //마지막 수행 운동 체크
      final record = value.get(id);
      if (record != null) {
        tempState.exerciseIndex = record;
      } else {
        tempState.exerciseIndex = 0;
      }
    });

    state = WorkoutProcessModel(
      exerciseIndex: tempState.exerciseIndex,
      maxExerciseIndex: tempState.maxExerciseIndex,
      setInfoCompleteList: tempState.setInfoCompleteList,
      maxSetInfoList: tempState.maxSetInfoList,
      exercises: tempState.exercises,
      modifiedExercises: tempState.modifiedExercises,
      workoutFinished: tempState.workoutFinished,
    );
  }

  // 다음 운동
  // return <= -1  => 모든 운동 완료,
  // return > -1 => exerciseIndex
  Future<int> nextStepForRegular() async {
    final pstate = state as WorkoutProcessModel;

    if (pstate.exerciseIndex <= pstate.maxExerciseIndex &&
        pstate.setInfoCompleteList[pstate.exerciseIndex] <
            pstate.maxSetInfoList[pstate.exerciseIndex]) {
      _saveCompleteSet(workoutRecordBox);
    }

    if (pstate.setInfoCompleteList[pstate.exerciseIndex] <
        pstate.maxSetInfoList[pstate.exerciseIndex]) {
      pstate.setInfoCompleteList[pstate.exerciseIndex] += 1;
    }

    //운동 변경
    if (pstate.setInfoCompleteList[pstate.exerciseIndex] ==
            pstate.maxSetInfoList[pstate.exerciseIndex] &&
        pstate.exerciseIndex < pstate.maxExerciseIndex) {
      //해당 Exercise의 max 세트수 보다 작고 exerciseIndex가 maxExcerciseIndex보다 작을때

      pstate.exerciseIndex += 1; // 운동 변경
      exerciseIndexBox.whenData(
        (value) {
          value.put(id, pstate.exerciseIndex);
        },
      );

      while (pstate.setInfoCompleteList[pstate.exerciseIndex] ==
              pstate.maxSetInfoList[pstate.exerciseIndex] &&
          pstate.exerciseIndex < pstate.maxExerciseIndex) {
        if (pstate.exerciseIndex == pstate.maxExerciseIndex) {
          break;
        }

        pstate.exerciseIndex += 1; // 완료된 세트라면 건너뛰기
        exerciseIndexBox.whenData(
          (value) {
            value.put(id, pstate.exerciseIndex);
          },
        );
      }
    }
    //끝났는지 체크!
    if (!pstate.workoutFinished) {
      state = pstate;
      return _checkLastExerciseRegular();
    } else {
      state = pstate;
      return -1;
    }
  }

  //완료 운동 저장
  void _saveCompleteSet(AsyncValue<Box<dynamic>> workoutRecordBox) {
    final pstate = state as WorkoutProcessModel;
    workoutRecordBox.whenData((value) {
      final record =
          value.get(pstate.exercises[pstate.exerciseIndex].workoutPlanId);
      if (record != null && record.setInfo.length > 0) {
        //local DB에 데이터가 있을때
        value.put(
          pstate.exercises[pstate.exerciseIndex].workoutPlanId,
          WorkoutRecordSimple(
            workoutPlanId: pstate.exercises[pstate.exerciseIndex].workoutPlanId,
            setInfo: [
              ...record.setInfo,
              pstate.exercises[pstate.exerciseIndex]
                  .setInfo[pstate.setInfoCompleteList[pstate.exerciseIndex]],
            ],
          ),
        );
      } else {
        //local DB에 데이터가 없을때
        value.put(
          pstate.exercises[pstate.exerciseIndex].workoutPlanId,
          WorkoutRecordSimple(
            workoutPlanId: pstate.exercises[pstate.exerciseIndex].workoutPlanId,
            setInfo: [
              pstate.exercises[pstate.exerciseIndex]
                  .setInfo[pstate.setInfoCompleteList[pstate.exerciseIndex]],
            ],
          ),
        );
      }
      state = pstate;
    });
  }

  //완료안된 운동이 있는지 체크후 수행하지 않은 운동인덱스 return
  int _checkLastExerciseRegular() {
    final pstate = state as WorkoutProcessModel;
    for (int i = 0; i <= pstate.maxExerciseIndex; i++) {
      if (pstate.setInfoCompleteList[i] != pstate.maxSetInfoList[i]) {
        return i;
      }
    }
    return -1;
  }

  //운동 변경
  void exerciseChange(int exerciseIndex) {
    final pstate = state as WorkoutProcessModel;
    pstate.exerciseIndex = exerciseIndex;
    state = pstate;
  }

  //운동 종료 상태 변경
  void workoutFinishedChange(bool workoutFinished) {
    final pstate = state as WorkoutProcessModel;
    pstate.workoutFinished = workoutFinished;
    state = pstate;
  }

  //운동 종료
  Future<void> quitWorkout() async {
    try {
      final pstate = state as WorkoutProcessModel;
      List<WorkoutRecordSimple> tempRecordList = [];

      workoutRecordBox.whenData(
        (value) {
          for (int i = 0; i < pstate.exercises.length; i++) {
            final record = value.get(pstate.exercises[i].workoutPlanId);

            if (record != null && record is WorkoutRecordSimple) {
              if (record.setInfo.length < pstate.maxSetInfoList[i]) {
                for (int j = 0;
                    j <
                        pstate.maxSetInfoList[i] -
                            pstate.setInfoCompleteList[i];
                    j++) {
                  record.setInfo.add(
                    SetInfo(index: record.setInfo.length + 1),
                  );
                }
              }
              value.put(pstate.exercises[i].workoutPlanId, record);
              tempRecordList.add(record);
            } else {
              var tempRecord = WorkoutRecordSimple(
                workoutPlanId: pstate.exercises[i].workoutPlanId,
                setInfo: [],
              );
              for (int j = 0; j < pstate.maxSetInfoList[i]; j++) {
                tempRecord.setInfo.add(SetInfo(index: j + 1));
              }
              value.put(pstate.exercises[i].workoutPlanId, tempRecord);
              tempRecordList.add(tempRecord);
            }
          }
        },
      );

      state = pstate;

      try {
        //운동 기록 서버로
        await repository.postWorkoutRecords(
            body: PostWorkoutRecordModel(
          records: tempRecordList,
        ));
      } on DioException catch (e) {
        throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
        );
      }
    } on Error catch (e) {
      print(e);
    }
  }

  void resetWorkoutProcess() {
    final pstate = state as WorkoutProcessModel;

    BoxUtils.deleteBox(workoutRecordBox, pstate.exercises);
    BoxUtils.deleteBox(modifiedExerciseBox, pstate.exercises);
    BoxUtils.deleteTimerBox(timerWorkoutBox, pstate.exercises);
    BoxUtils.deleteTimerBox(timerXMoreBox, pstate.exercises);
    // BoxUtils.deleteBox(workoutResultBox, widget.exercises);

    exerciseIndexBox.whenData(
      (value) {
        value.delete(
          id,
        );
      },
    );

    state = null;

    // init(workoutProvider);
  }

  // 다음 운동(슈퍼세트)

  // 세트 수정 (seconds, reps, weight)
  void modifiedWeight(double weight, int setInfoIndex) {
    final pstate = state as WorkoutProcessModel;

    pstate.modifiedExercises[pstate.exerciseIndex].setInfo[setInfoIndex]
        .weight = weight;

    print(pstate
        .modifiedExercises[pstate.exerciseIndex].setInfo[setInfoIndex].weight);

    //로컬 저장
    modifiedExerciseBox.whenData((value) {
      final record =
          value.get(pstate.exercises[pstate.exerciseIndex].workoutPlanId);

      if (record is Exercise) {
        record.setInfo[setInfoIndex].weight = weight;
        value.put(pstate.exercises[pstate.exerciseIndex].workoutPlanId, record);
      }
    });
    //완료된 세트의 경우 수정후 저장
    if (setInfoIndex < pstate.setInfoCompleteList[pstate.exerciseIndex]) {
      workoutRecordBox.whenData((value) {
        final record =
            value.get(pstate.exercises[pstate.exerciseIndex].workoutPlanId);
        if (record is WorkoutRecordSimple) {
          record.setInfo[setInfoIndex].weight = weight;
          value.put(
              pstate.exercises[pstate.exerciseIndex].workoutPlanId, record);
        }
      });
    }

    state = pstate;
  }

  void modifiedReps(int reps, int setInfoIndex) {
    final pstate = state as WorkoutProcessModel;

    pstate.modifiedExercises[pstate.exerciseIndex].setInfo[setInfoIndex].reps =
        reps;

    //로컬 저장
    modifiedExerciseBox.whenData((value) {
      final record =
          value.get(pstate.exercises[pstate.exerciseIndex].workoutPlanId);

      if (record is Exercise) {
        record.setInfo[setInfoIndex].reps = reps;
        value.put(pstate.exercises[pstate.exerciseIndex].workoutPlanId, record);
      }
    });
    //완료된 세트의 경우 수정후 저장
    if (setInfoIndex < pstate.setInfoCompleteList[pstate.exerciseIndex]) {
      workoutRecordBox.whenData((value) {
        final record =
            value.get(pstate.exercises[pstate.exerciseIndex].workoutPlanId);
        if (record is WorkoutRecordSimple) {
          print(record.setInfo[0].reps);
          record.setInfo[setInfoIndex].reps = reps;
          value.put(
              pstate.exercises[pstate.exerciseIndex].workoutPlanId, record);
        }
      });
    }

    state = pstate;
  }

  void modifiedSeconds(int seconds, int setInfoIndex) {
    final pstate = state as WorkoutProcessModel;

    pstate.modifiedExercises[pstate.exerciseIndex].setInfo[setInfoIndex]
        .seconds = seconds;

    print(pstate
        .modifiedExercises[pstate.exerciseIndex].setInfo[setInfoIndex].seconds);

    //로컬 저장
    modifiedExerciseBox.whenData((value) {
      final record =
          value.get(pstate.exercises[pstate.exerciseIndex].workoutPlanId);

      if (record is Exercise) {
        record.setInfo[setInfoIndex].reps = seconds;
        value.put(pstate.exercises[pstate.exerciseIndex].workoutPlanId, record);
      }
    });
    //완료된 세트의 경우 수정후 저장
    if (setInfoIndex < pstate.setInfoCompleteList[pstate.exerciseIndex]) {
      workoutRecordBox.whenData((value) {
        final record =
            value.get(pstate.exercises[pstate.exerciseIndex].workoutPlanId);
        if (record is WorkoutRecordSimple) {
          record.setInfo[setInfoIndex].reps = seconds;
          value.put(
              pstate.exercises[pstate.exerciseIndex].workoutPlanId, record);
        }
      });
    }

    state = pstate;
  }

  // 총 운동 시간 추가

  // 이전에 수행하지 않은 운동 이동
}
