import 'package:dio/dio.dart';
import 'package:fitend_member/common/provider/hive_exercies_index_provider.dart';
import 'package:fitend_member/common/provider/hive_modified_exercise_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_record_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_x_more_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:fitend_member/workout/model/post_workout_record_model.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:fitend_member/workout/model/workout_process_model.dart';
import 'package:fitend_member/workout/model/workout_record_model.dart';
import 'package:fitend_member/workout/provider/workout_provider.dart';
import 'package:fitend_member/workout/repository/workout_records_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final workoutProcessProvider = StateNotifierProvider.family<
    WorkoutProcessStateNotifier, WorkoutProcessModel, int>((ref, id) {
  final repository = ref.watch(workoutRecordsRepositoryProvider);
  final provider = ref.read(workoutProvider(id).notifier);
  final AsyncValue<Box> workoutRecordBox = ref.read(hiveWorkoutRecordProvider);
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

class WorkoutProcessStateNotifier extends StateNotifier<WorkoutProcessModel> {
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
  }) : super(WorkoutProcessModel(
          exerciseIndex: 0,
          maxExerciseIndex: 0,
          setInfoCompleteList: [],
          maxSetInfoList: [],
          exercises: [],
          workoutFinished: false,
        )) {
    init(workoutProvider);
  }

  //init
  Future<void> init(WorkoutStateNotifier workoutProvider) async {
    List<Exercise> tempExercises = [];
    List<Exercise> modifiedExercises = [];
    final workoutProvierState = workoutProvider.state as WorkoutModel;

    tempExercises = workoutProvierState.exercises; // 서버에서 받은 운동 목록
    state.maxExerciseIndex = tempExercises.length; //
    state.exercises = tempExercises;

    modifiedExerciseBox.whenData((value) async {
      // 이전에 저장된 운동 받아옴
      for (int i = 0; i < state.exercises.length; i++) {
        final record = await value.get(state.exercises[i].workoutPlanId);
        if (record != null && record is Exercise) {
          modifiedExercises.add(
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

      state.exercises = modifiedExercises;
    });

    workoutRecordBox.whenData((value) async {
      // 완료된 운동 체크
      for (int i = 0; i <= state.maxExerciseIndex; i++) {
        final tempRecord = await value.get(state.exercises[i].workoutPlanId);

        if (tempRecord != null && tempRecord.setInfo.length > 0) {
          state.setInfoCompleteList.add(
              await value.get(state.exercises[i].workoutPlanId).setInfo.length);
        } else {
          state.setInfoCompleteList.add(0);
        }
      }
    });

    exerciseIndexBox.whenData((value) async {
      //마지막 수행 운동 체크
      final record = await value.get(id);
      if (record != null) {
        state.exerciseIndex = record;
      } else {
        state.exerciseIndex = 0;
      }
    });
  }

  // 다음 운동
  // return <= -1  => 모든 운동 완료,
  // return > -1 => exerciseIndex
  Future<int> nextStepForRegular() async {
    if (state.exerciseIndex <= state.maxExerciseIndex &&
        state.setInfoCompleteList[state.exerciseIndex] <
            state.maxSetInfoList[state.exerciseIndex]) {
      _saveCompleteSet(workoutRecordBox);
    }

    if (state.setInfoCompleteList[state.exerciseIndex] <
        state.maxSetInfoList[state.exerciseIndex]) {
      state.setInfoCompleteList[state.exerciseIndex] += 1;
    }

    //운동 변경
    if (state.setInfoCompleteList[state.exerciseIndex] ==
            state.maxSetInfoList[state.exerciseIndex] &&
        state.exerciseIndex < state.maxExerciseIndex) {
      //해당 Exercise의 max 세트수 보다 작고 exerciseIndex가 maxExcerciseIndex보다 작을때

      state.exerciseIndex += 1; // 운동 변경
      exerciseIndexBox.whenData(
        (value) async {
          await value.put(id, state.exerciseIndex);
        },
      );

      while (state.setInfoCompleteList[state.exerciseIndex] ==
              state.maxSetInfoList[state.exerciseIndex] &&
          state.exerciseIndex < state.maxExerciseIndex) {
        if (state.exerciseIndex == state.maxExerciseIndex) {
          break;
        }

        state.exerciseIndex += 1; // 완료된 세트라면 건너뛰기
        exerciseIndexBox.whenData(
          (value) {
            value.put(id, state.exerciseIndex);
          },
        );
      }
    }
    //끝났는지 체크!
    if (!state.workoutFinished) {
      return _checkLastExerciseRegular();
    } else {
      return -1;
    }
  }

  //완료 운동 저장
  void _saveCompleteSet(AsyncValue<Box<dynamic>> workoutRecordBox) {
    workoutRecordBox.whenData(
      (value) {
        final record =
            value.get(state.exercises[state.exerciseIndex].workoutPlanId);
        if (record != null && record.setInfo.length > 0) {
          //local DB에 데이터가 있을때
          value.put(
            state.exercises[state.exerciseIndex].workoutPlanId,
            WorkoutRecordModel(
              workoutPlanId: state.exercises[state.exerciseIndex].workoutPlanId,
              setInfo: [
                ...record.setInfo,
                state.exercises[state.exerciseIndex]
                    .setInfo[state.setInfoCompleteList[state.exerciseIndex]],
              ],
            ),
          );
        } else {
          //local DB에 데이터가 없을때
          value.put(
            state.exercises[state.exerciseIndex].workoutPlanId,
            WorkoutRecordModel(
              workoutPlanId: state.exercises[state.exerciseIndex].workoutPlanId,
              setInfo: [
                state.exercises[state.exerciseIndex]
                    .setInfo[state.setInfoCompleteList[state.exerciseIndex]],
              ],
            ),
          );
        }
      },
    );
  }

  //완료안된 운동이 있는지 체크
  int _checkLastExerciseRegular() {
    for (int i = 0; i <= state.maxExerciseIndex; i++) {
      if (state.setInfoCompleteList[i] != state.maxSetInfoList[i]) {
        return i;
      }
    }

    return -1;
  }

  //운동 변경
  void exerciseChange(int exerciseIndex) {
    state.exerciseIndex = exerciseIndex;
  }

  //운동 종료 상태 변경
  void workoutFinishedChange(bool workoutFinished) {
    state.workoutFinished = workoutFinished;
  }

  //운동 종료
  Future<void> quitWorkout() async {
    try {
      List<WorkoutRecordModel> tempRecordList = [];

      workoutRecordBox.whenData(
        (value) {
          for (int i = 0; i < state.exercises.length; i++) {
            final record = value.get(state.exercises[i].workoutPlanId);

            if (record != null && record is WorkoutRecordModel) {
              if (record.setInfo.length < state.maxSetInfoList[i]) {
                for (int j = 0;
                    j < state.maxSetInfoList[i] - state.setInfoCompleteList[i];
                    j++) {
                  record.setInfo.add(
                    SetInfo(index: record.setInfo.length + 1),
                  );
                }
              }
              value.put(state.exercises[i].workoutPlanId, record);
              tempRecordList.add(record);
            } else {
              var tempRecord = WorkoutRecordModel(
                workoutPlanId: state.exercises[i].workoutPlanId,
                setInfo: [],
              );
              for (int j = 0; j < state.maxSetInfoList[i]; j++) {
                tempRecord.setInfo.add(SetInfo(index: j + 1));
              }
              value.put(state.exercises[i].workoutPlanId, tempRecord);
              tempRecordList.add(tempRecord);
            }
          }
        },
      );

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

  // 다음 운동(슈퍼세트)
  // 세트 수정
  // 총 운동 시간 추가

  // 이전에 수행하지 않은 운동 이동

  // 다음 운동 체크
}
