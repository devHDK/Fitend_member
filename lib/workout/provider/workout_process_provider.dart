import 'package:fitend_member/common/provider/hive_exercies_index_provider.dart';
import 'package:fitend_member/common/provider/hive_modified_exercise_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_record_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_x_more_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:fitend_member/schedule/repository/workout_schedule_repository.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:fitend_member/workout/model/workout_process_model.dart';
import 'package:fitend_member/workout/provider/workout_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final workoutProcessProvider = StateNotifierProvider.family<
    WorkoutProcessStateNotifier, WorkoutProcessModel, int>((ref, id) {
  final repository = ref.watch(workoutScheduleRepositoryProvider);
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
  final WorkoutScheduleRepository repository;
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
        )) {
    init(workoutProvider);
  }

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

  //다음 운동
  //다음 운동(슈퍼세트)
  //세트 수정
}
