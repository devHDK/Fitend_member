import 'package:dio/dio.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/provider/hive_exercies_index_provider.dart';
import 'package:fitend_member/common/provider/hive_modified_exercise_provider.dart';
import 'package:fitend_member/common/provider/hive_schedule_record_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_record_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_x_more_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_result_provider.dart';
import 'package:fitend_member/common/provider/shared_preference_provider.dart';
import 'package:fitend_member/common/utils/hive_box_utils.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:fitend_member/thread/model/common/thread_trainer_model.dart';
import 'package:fitend_member/thread/model/common/thread_user_model.dart';
import 'package:fitend_member/thread/model/common/thread_workout_info_model.dart';
import 'package:fitend_member/thread/model/threads/thread_model.dart';
import 'package:fitend_member/thread/provider/thread_provider.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:fitend_member/workout/model/post_workout_record_model.dart';
import 'package:fitend_member/workout/model/schedule_record_model.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:fitend_member/workout/model/workout_process_model.dart';
import 'package:fitend_member/workout/model/workout_record_simple_model.dart';
import 'package:fitend_member/workout/provider/workout_provider.dart';
import 'package:fitend_member/workout/repository/workout_records_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

final workoutProcessProvider = StateNotifierProvider.family<
    WorkoutProcessStateNotifier, WorkoutProcessModelBase?, int>((ref, id) {
  final repository = ref.watch(workoutRecordsRepositoryProvider);
  final provider = ref.read(workoutProvider(id).notifier);
  final tProvider = ref.read(threadProvider.notifier);
  final meProvider = ref.read(getMeProvider.notifier);
  final pref = ref.watch(sharedPrefsProvider);
  final AsyncValue<Box> workoutRecordSimpleBox =
      ref.watch(hiveWorkoutRecordSimpleProvider);
  final AsyncValue<Box> workoutRecordForResultBox =
      ref.watch(hiveWorkoutRecordForResultProvider);
  final AsyncValue<Box> timerWorkoutBox = ref.watch(hiveTimerRecordProvider);
  final AsyncValue<Box> timerXMoreBox = ref.watch(hiveTimerXMoreRecordProvider);
  final AsyncValue<Box> modifiedExerciseBox =
      ref.watch(hiveModifiedExerciseProvider);
  final AsyncValue<Box> exerciseIndexBox = ref.watch(hiveExerciseIndexProvider);
  final AsyncValue<Box> processTotalTimeBox =
      ref.watch(hiveProcessTotalTimeBox);
  final AsyncValue<Box> scheduleRecordBox = ref.watch(hiveScheduleRecordBox);

  return WorkoutProcessStateNotifier(
    repository: repository,
    id: id,
    workoutProvider: provider,
    threadProvider: tProvider,
    getMeProvider: meProvider,
    pref: pref,
    workoutRecordSimpleBox: workoutRecordSimpleBox,
    workoutRecordForResultBox: workoutRecordForResultBox,
    timerWorkoutBox: timerWorkoutBox,
    timerXMoreBox: timerXMoreBox,
    modifiedExerciseBox: modifiedExerciseBox,
    exerciseIndexBox: exerciseIndexBox,
    processTotalTimeBox: processTotalTimeBox,
    scheduleRecordBox: scheduleRecordBox,
  );
});

class WorkoutProcessStateNotifier
    extends StateNotifier<WorkoutProcessModelBase?> {
  final WorkoutRecordsRepository repository;
  final int id;
  final WorkoutStateNotifier workoutProvider;
  final ThreadStateNotifier threadProvider;
  final GetMeStateNotifier getMeProvider;
  final Future<SharedPreferences> pref;
  final AsyncValue<Box> workoutRecordSimpleBox;
  final AsyncValue<Box> workoutRecordForResultBox;
  final AsyncValue<Box> timerWorkoutBox;
  final AsyncValue<Box> timerXMoreBox;
  final AsyncValue<Box> modifiedExerciseBox;
  final AsyncValue<Box> exerciseIndexBox;
  final AsyncValue<Box> processTotalTimeBox;
  final AsyncValue<Box> scheduleRecordBox;

  WorkoutProcessStateNotifier({
    required this.repository,
    required this.id,
    required this.workoutProvider,
    required this.threadProvider,
    required this.getMeProvider,
    required this.pref,
    required this.workoutRecordSimpleBox,
    required this.workoutRecordForResultBox,
    required this.timerWorkoutBox,
    required this.timerXMoreBox,
    required this.modifiedExerciseBox,
    required this.exerciseIndexBox,
    required this.processTotalTimeBox,
    required this.scheduleRecordBox,
  }) : super(null) {
    // init(workoutProvider);
  }

  //init
  void init(WorkoutStateNotifier workoutProvider) async {
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
      workoutFinished: false,
      groupCounts: {},
      totalTime: 0,
      isQuitting: false,
      isSwipeGuide: true,
      isWorkoutChangeGuide: true,
      isThreadGuide: true,
    );
    List<Exercise> tempExercises = [];
    final workoutProviderState = workoutProvider.state as WorkoutModel;

    tempExercises = workoutProviderState.exercises; // 서버에서 받은 운동 목록
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
              circuitGroupNum: record.circuitGroupNum,
              circuitSeq: record.circuitSeq,
              setType: record.setType,
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

    workoutRecordSimpleBox.whenData((value) {
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
        value.put(id, 0);
      }
    });

    List<int> circuitGroupNumList = [];

    for (var exercise in tempState.exercises) {
      if (exercise.circuitGroupNum != null) {
        circuitGroupNumList.add(exercise.circuitGroupNum!);
      }
    }

    tempState.groupCounts =
        circuitGroupNumList.fold({}, (Map<int, int> map, element) {
      if (!map.containsKey(element)) {
        map[element] = 1;
      } else if (map.containsKey(element)) {
        map[element] = map[element]! + 1;
      }
      return map;
    });

    processTotalTimeBox.whenData((value) {
      final record = value.get(id);
      if (record != null) {
        tempState.totalTime = record;
      }
    });

    final sharedPref = await pref;
    final isFirstRun = sharedPref.getBool(StringConstants.isFirstRunWorkout);

    workoutProvider.state = workoutProviderState.copyWith(isProcessing: true);

    state = WorkoutProcessModel(
      exerciseIndex: tempState.exerciseIndex,
      maxExerciseIndex: tempState.maxExerciseIndex,
      setInfoCompleteList: tempState.setInfoCompleteList,
      maxSetInfoList: tempState.maxSetInfoList,
      exercises: tempState.exercises,
      modifiedExercises: tempState.modifiedExercises,
      workoutFinished: tempState.workoutFinished,
      groupCounts: tempState.groupCounts,
      totalTime: tempState.totalTime,
      isQuitting: tempState.isQuitting,
      isSwipeGuide: isFirstRun == null || isFirstRun ? true : false,
      isThreadGuide: isFirstRun == null || isFirstRun ? true : false,
      isWorkoutChangeGuide: isFirstRun == null || isFirstRun ? true : false,
    );
  }

  // 다음 운동
  // return <= -1  => 모든 운동 완료,
  // return > -1 => exerciseIndex
  Future<int?> nextWorkout() async {
    final pstate = state as WorkoutProcessModel;

    if (pstate.exerciseIndex <= pstate.maxExerciseIndex &&
        pstate.setInfoCompleteList[pstate.exerciseIndex] <
            pstate.maxSetInfoList[pstate.exerciseIndex]) {
      _saveCompleteSet();
    }

    //setInfoCompleteList 업데이트 => 세트 +1
    if (pstate.setInfoCompleteList[pstate.exerciseIndex] <
        pstate.maxSetInfoList[pstate.exerciseIndex]) {
      pstate.setInfoCompleteList[pstate.exerciseIndex] += 1;
    }

    if (pstate.exercises[pstate.exerciseIndex].setType == 'superSet') {
      //슈퍼세트
      debugPrint('superSet 진행');
      if (pstate.exercises[pstate.exerciseIndex].circuitSeq ==
          pstate.groupCounts[
              pstate.exercises[pstate.exerciseIndex].circuitGroupNum]) {
        //슈퍼세트 마지막 운동
        debugPrint('superSet 마지막 운동');
        final index = getUnCompleteSuperSet(
            pstate.exercises[pstate.exerciseIndex].circuitGroupNum!);
        debugPrint('index $index');

        if (index != null) {
          debugPrint('미완료 super세트');
          pstate.exerciseIndex = index; //
        } else {
          updateExerciseIndexRegular();
        }
      } else {
        //superset 마지막 운동이 아닐경우
        handleNonLastSuperSetExercise();
      }
    } else {
      //레귤러
      updateExerciseIndexRegular();
    }

    exerciseIndexBox.whenData(
      (value) {
        value.put(id, pstate.exerciseIndex);
      },
    );

    if (!pstate.workoutFinished) {
      if (pstate.exerciseIndex == pstate.maxExerciseIndex &&
          pstate.setInfoCompleteList[pstate.exerciseIndex] ==
              pstate.maxSetInfoList[pstate.exerciseIndex]) {
        final ret =
            _checkLastExercise(); //마지막 exercise를 완료했을때 완료안된 세트를 반환 전부 완료됬으면 -1 반환
        return ret;
      }
    }

    state = pstate;
    return null;
  }

  void updateExerciseIndexRegular() {
    final pstate = state as WorkoutProcessModel;

    if (pstate.setInfoCompleteList[pstate.exerciseIndex] ==
            pstate.maxSetInfoList[pstate.exerciseIndex] &&
        pstate.exerciseIndex < pstate.maxExerciseIndex) {
      //해당 Exercise의 max 세트수 보다 작고 exerciseIndex가 maxExcerciseIndex보다 작을때

      pstate.exerciseIndex += 1; //운동 변경
      while (pstate.setInfoCompleteList[pstate.exerciseIndex] ==
              pstate.maxSetInfoList[pstate.exerciseIndex] &&
          pstate.exerciseIndex < pstate.maxExerciseIndex) {
        pstate.exerciseIndex += 1; // 완료된 세트라면 건너뛰기

        if (pstate.exerciseIndex == pstate.maxExerciseIndex) {
          break;
        }
      }
    }
  }

  void handleNonLastSuperSetExercise() {
    final pstate = state as WorkoutProcessModel;
    bool done = false;

    // 해당 운동 그룹 내에서 다음 순서의 운동을 찾는다.

    final seq = pstate.exercises[pstate.exerciseIndex].circuitSeq!;
    final groupNum = pstate.exercises[pstate.exerciseIndex].circuitGroupNum!;

    int groupFirstIndex = getExerciseIndexByGroupNumSeq(groupNum, 1);
    int index = getExerciseIndexByGroupNumSeq(groupNum, seq);
    debugPrint('superset index : $index');
    for (int i = index + 1;
        i < groupFirstIndex + pstate.groupCounts[groupNum]!;
        i++) {
      if (pstate.setInfoCompleteList[i] != pstate.maxSetInfoList[i]) {
        pstate.exerciseIndex = i;
        done = true;
        break;
      }
    }

    if (!done) {
      int? uncompleteIndex = getUnCompleteSuperSet(groupNum);

      if (uncompleteIndex != null) {
        pstate.exerciseIndex = uncompleteIndex;
      } else {
        updateExerciseIndexRegular();
      }
    }
  }

  //완료 운동 저장
  void _saveCompleteSet() {
    final pstate = state as WorkoutProcessModel;

    SetInfo timerSetInfo = SetInfo(index: 0);
    bool isTimerExercise =
        pstate.exercises[pstate.exerciseIndex].trackingFieldId == 3 ||
            pstate.exercises[pstate.exerciseIndex].trackingFieldId == 4;

    if (isTimerExercise) {
      timerXMoreBox.whenData((value) {
        final record =
            value.get(pstate.exercises[pstate.exerciseIndex].workoutPlanId);

        if (record != null && record is WorkoutRecordSimple) {
          timerSetInfo = SetInfo(
            index: pstate.setInfoCompleteList[pstate.exerciseIndex] + 1,
            seconds: record
                .setInfo[pstate.setInfoCompleteList[pstate.exerciseIndex]]
                .seconds,
          );
        } else {
          timerSetInfo = SetInfo(
            index: pstate.setInfoCompleteList[pstate.exerciseIndex] + 1,
            seconds: 0,
          );
        }
      });

      debugPrint('${timerSetInfo.toJson()}');
    }

    workoutRecordSimpleBox.whenData((value) {
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
              isTimerExercise
                  ? timerSetInfo
                  : pstate.modifiedExercises[pstate.exerciseIndex].setInfo[
                      pstate.setInfoCompleteList[pstate.exerciseIndex]],
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
              isTimerExercise
                  ? timerSetInfo
                  : pstate.modifiedExercises[pstate.exerciseIndex].setInfo[
                      pstate.setInfoCompleteList[pstate.exerciseIndex]],
            ],
          ),
        );
      }
      state = pstate;
    });
  }

  //완료안된 운동이 있는지 체크후 수행하지 않은 운동인덱스 return
  int _checkLastExercise() {
    final pstate = state as WorkoutProcessModel;
    for (int i = 0; i <= pstate.maxExerciseIndex; i++) {
      if (pstate.setInfoCompleteList[i] != pstate.maxSetInfoList[i]) {
        return i;
      }
    }
    return -1;
  }

  //미완료 슈퍼세트
  int? getUnCompleteSuperSet(int groupNum) {
    final pstate = state as WorkoutProcessModel;

    List<Exercise> superSetList = pstate.modifiedExercises
        .where((element) => element.circuitGroupNum == groupNum)
        .toList();

    for (var exercise in superSetList) {
      final index = getExerciseIndexByGroupNumSeq(
          exercise.circuitGroupNum!, exercise.circuitSeq!);
      if (pstate.setInfoCompleteList[index] < pstate.maxSetInfoList[index]) {
        return index;
      }
    }
    return null;
  }

  //운동 변경
  void exerciseChange(int exerciseIndex) {
    final pstate = state as WorkoutProcessModel;
    pstate.exerciseIndex = exerciseIndex;

    exerciseIndexBox.whenData((value) => value.put(id, exerciseIndex));

    state = pstate;
  }

  //운동 종료 상태 변경
  void workoutFinishedChange(bool workoutFinished) {
    final pstate = state as WorkoutProcessModel;
    pstate.workoutFinished = workoutFinished;
    state = pstate;
  }

  void workoutIsQuttingChange(bool isQuitting) {
    final pstate = state as WorkoutProcessModel;
    pstate.isQuitting = isQuitting;
    state = pstate;
  }

  //운동 종료
  Future<void> quitWorkout({
    required String title,
    required String subTitle,
    required int trainerId,
  }) async {
    try {
      var pstate = state as WorkoutProcessModel;

      if (pstate.isQuitting) {
        debugPrint('pstate.isQuitting ===> ${pstate.isQuitting} ===> return');
        return;
      }

      pstate.isQuitting = true;
      state = pstate;

      List<WorkoutRecordSimple> tempRecordList = [];

      final sharedPref = await pref;
      final isFirstRun = sharedPref.getBool(StringConstants.isFirstRunWorkout);
      if (isFirstRun != null && isFirstRun) {
        await sharedPref.setBool(StringConstants.isFirstRunWorkout, false);
      }

      workoutRecordSimpleBox.whenData(
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

      pstate.workoutFinished = true;

      if (workoutProvider.state is WorkoutModel) {
        final tempWorkoutState = workoutProvider.state as WorkoutModel;

        workoutProvider.state = tempWorkoutState.copyWith(
          isProcessing: false,
        );
      }
      state = pstate.copyWith();

      try {
        List<int> targetMuscles = [];
        int totalSetCount = 0;

        for (var exercise in pstate.exercises) {
          for (var targetMuscle in exercise.targetMuscles) {
            targetMuscles.add(targetMuscle.id);
          }

          totalSetCount += exercise.setInfo
              .where((element) =>
                  element.reps != null ||
                  element.seconds != null ||
                  element.weight != null)
              .toList()
              .length;
        }

        scheduleRecordBox.whenData((value) => value.put(
            id,
            ScheduleRecordsModel(
              workoutScheduleId: id,
              workoutDuration: pstate.totalTime,
            )));

        //운동 기록 서버로
        await repository
            .postWorkoutRecords(
          body: PostWorkoutRecordModel(
            records: tempRecordList,
            scheduleRecords: ScheduleRecordsModel(
              workoutScheduleId: id,
              workoutDuration: pstate.totalTime,
            ),
            workoutInfo: ThreadWorkoutInfo(
              workoutScheduleId: id,
              trainerId: trainerId,
              targetMuscleIds: targetMuscles.toSet().toList(),
              title: title,
              subTitle: subTitle,
              workoutDuration: pstate.totalTime,
              totalSet: totalSetCount,
            ),
          ),
        )
            .then((value) {
          if (value != null) {
            final userModel = getMeProvider.state as UserModel;

            threadProvider.addThread(
              ThreadModel(
                id: value.id,
                writerType: 'user',
                type: 'record',
                title: title,
                content: '오늘의 운동을 완료했어요!',
                gallery: [],
                workoutInfo: ThreadWorkoutInfo(
                  workoutScheduleId: id,
                  trainerId: trainerId,
                  targetMuscleIds: targetMuscles.toSet().toList(),
                  title: title,
                  subTitle: subTitle,
                  workoutDuration: pstate.totalTime,
                  totalSet: totalSetCount,
                ),
                user: ThreadUser(
                    id: userModel.user.id,
                    nickname: userModel.user.nickname,
                    gender: userModel.user.gender),
                trainer: ThreadTrainer(
                  id: userModel.user.activeTrainers.first.id,
                  nickname: userModel.user.activeTrainers.first.nickname,
                  profileImage:
                      userModel.user.activeTrainers.first.profileImage,
                ),
                emojis: [],
                createdAt: DateTime.now().toUtc().toIso8601String(),
              ),
            );
          }
        });
      } on DioException catch (e) {
        debugPrint('postWorkoutRecords error: $e');
        throw DioException(
          requestOptions: e.requestOptions,
          type: DioExceptionType.badResponse,
          error: DioException.badResponse(
            statusCode: 409,
            requestOptions: e.requestOptions,
            response: e.response!,
          ),
          response: e.response,
        );
      }
    } on Error catch (e) {
      debugPrint('$e');
    }
  }

  void resetWorkoutProcess() {
    if (state != null) {
      final pstate = state as WorkoutProcessModel;

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

      if (workoutProvider.state is WorkoutModel) {
        final tempWorkoutState = workoutProvider.state as WorkoutModel;

        workoutProvider.state = tempWorkoutState.copyWith(
          isProcessing: false,
        );
      }

      state = null;
    } else {
      if (workoutProvider.state is WorkoutModel) {
        final tempWorkoutState = workoutProvider.state as WorkoutModel;

        workoutProvider.state = tempWorkoutState.copyWith(
          isProcessing: false,
        );

        BoxUtils.deleteBox(workoutRecordSimpleBox, tempWorkoutState.exercises);
        BoxUtils.deleteBox(modifiedExerciseBox, tempWorkoutState.exercises);
        BoxUtils.deleteTimerBox(timerWorkoutBox, tempWorkoutState.exercises);
        BoxUtils.deleteTimerBox(timerXMoreBox, tempWorkoutState.exercises);
        BoxUtils.deleteBox(
            workoutRecordForResultBox, tempWorkoutState.exercises);

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
    }

    // init(workoutProvider);
  }

  // 다음 운동(슈퍼세트)

  // 세트 수정 (seconds, reps, weight)
  void modifiedWeight(double weight, int setInfoIndex) {
    final pstate = state as WorkoutProcessModel;

    pstate.modifiedExercises[pstate.exerciseIndex].setInfo[setInfoIndex]
        .weight = weight;

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
      workoutRecordSimpleBox.whenData((value) {
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
      workoutRecordSimpleBox.whenData((value) {
        final record =
            value.get(pstate.exercises[pstate.exerciseIndex].workoutPlanId);
        if (record is WorkoutRecordSimple) {
          record.setInfo[setInfoIndex].reps = reps;
          value.put(
              pstate.exercises[pstate.exerciseIndex].workoutPlanId, record);
        }
      });
    }

    state = pstate;
  }

  void modifiedSecondsTarget(int seconds, int setInfoIndex) {
    final pstate = state as WorkoutProcessModel;

    pstate.modifiedExercises[pstate.exerciseIndex].setInfo[setInfoIndex]
        .seconds = seconds;

    //로컬 저장
    modifiedExerciseBox.whenData((value) {
      final record =
          value.get(pstate.exercises[pstate.exerciseIndex].workoutPlanId);

      if (record is Exercise) {
        record.setInfo[setInfoIndex].seconds = seconds;
        value.put(pstate.exercises[pstate.exerciseIndex].workoutPlanId, record);
      }
    });

    state = pstate;
  }

  void modifiedSecondsRecord(int seconds, int setInfoIndex) {
    final pstate = state as WorkoutProcessModel;
    timerXMoreBox.whenData((value) {
      final record =
          value.get(pstate.exercises[pstate.exerciseIndex].workoutPlanId);

      if (record is WorkoutRecordSimple) {
        record.setInfo[setInfoIndex].seconds = seconds;

        value.put(pstate.exercises[pstate.exerciseIndex].workoutPlanId, record);
      }
    });

    //완료된 세트의 경우 수정후 저장
    if (setInfoIndex < pstate.setInfoCompleteList[pstate.exerciseIndex]) {
      workoutRecordSimpleBox.whenData((value) {
        final record =
            value.get(pstate.exercises[pstate.exerciseIndex].workoutPlanId);
        if (record is WorkoutRecordSimple) {
          record.setInfo[setInfoIndex].seconds = seconds;
          value.put(
              pstate.exercises[pstate.exerciseIndex].workoutPlanId, record);
        }
      });
    }
  }

  void resetTimer(int setInfoIndex) {
    final pstate = state as WorkoutProcessModel;

    timerXMoreBox.whenData((value) {
      final record =
          value.get(pstate.exercises[pstate.exerciseIndex].workoutPlanId);

      if (record is WorkoutRecordSimple) {
        record.setInfo[setInfoIndex].seconds = 0;

        value.put(pstate.exercises[pstate.exerciseIndex].workoutPlanId, record);
      }
    });
  }

  //배열에서  groupnum, seq로 index 찾기
  int getExerciseIndexByGroupNumSeq(int groupNum, int seq) {
    final pstate = state as WorkoutProcessModel;

    int exerciseIndex = pstate.exercises.indexWhere((exercise) =>
        exercise.circuitGroupNum == groupNum && exercise.circuitSeq == seq);

    return exerciseIndex;
  }

  // 총 운동 시간 ++
  void putProcessTotalTime() {
    final pstate = state as WorkoutProcessModel;
    pstate.totalTime += 1;
    processTotalTimeBox.whenData((value) => value.put(id, pstate.totalTime));

    state = pstate;
  }

  void addProcessTotalTime(int seconds) {
    final pstate = state as WorkoutProcessModel;
    pstate.totalTime += seconds;
    processTotalTimeBox.whenData((value) => value.put(id, pstate.totalTime));

    state = pstate;
  }

  void putIsGuide({
    bool? isSwipeGuide,
    bool? isWorkoutChangeGuide,
    bool? isThreadGuide,
  }) {
    final pstate = state as WorkoutProcessModel;

    if (isSwipeGuide != null) {
      pstate.isSwipeGuide = isSwipeGuide;
    }

    if (isWorkoutChangeGuide != null) {
      pstate.isWorkoutChangeGuide = isWorkoutChangeGuide;
    }

    if (isThreadGuide != null) {
      pstate.isThreadGuide = isThreadGuide;
    }

    state = pstate;
  }
}
