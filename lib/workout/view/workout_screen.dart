import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:fitend_member/common/component/custom_clipper.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/component/draggable_bottom_sheet.dart';
import 'package:fitend_member/common/component/workout_video_player.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/provider/hive_modified_exercise_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_record_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_x_more_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_result_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/exercise_video_model.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:fitend_member/exercise/view/exercise_screen.dart';
import 'package:fitend_member/workout/component/dialog/reps_seinfo_dialog_widgets.dart';
import 'package:fitend_member/workout/component/dialog/timer_seinfo_dialog_widgets.dart';
import 'package:fitend_member/workout/component/dialog/weight_reps_seinfo_dialog_widgets.dart';
import 'package:fitend_member/workout/component/timer_x_more_progress_card%20.dart';
import 'package:fitend_member/workout/component/timer_x_one_progress_card.dart';
import 'package:fitend_member/workout/component/weight_reps_progress_card.dart';
import 'package:fitend_member/workout/model/post_workout_record_model.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:fitend_member/workout/model/workout_record_model.dart';
import 'package:fitend_member/workout/repository/workout_records_repository.dart';
import 'package:fitend_member/workout/view/workout_change_screen.dart';
import 'package:fitend_member/workout/view/workout_feedback_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  final List<Exercise> exercises;
  final DateTime date;
  final WorkoutModel workout;
  final int workoutScheduleId;

  const WorkoutScreen({
    super.key,
    required this.exercises,
    required this.date,
    required this.workout,
    required this.workoutScheduleId,
  });

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  late AsyncValue<Box> workoutRecordBox;
  late AsyncValue<Box> workoutResultBox;
  late AsyncValue<Box> modifiedExerciseBox;
  bool isSwipeUp = false;
  bool initial = true;
  late int exerciseIndex = 0;
  List<int> setInfoCompleteList = [];
  List<int> maxSetInfoList = [];
  bool workoutFinish = false;
  bool isPoped = false;
  bool lastChecked = false;
  late int maxExcerciseIndex;
  bool isTooltipVisible = false;
  int tooltipCount = 0;
  late Timer timer;

  List<Exercise> modifiedExercises = [];

  @override
  void initState() {
    super.initState();

    _initData();
  }

  void _initData() {
    setInfoCompleteList = List.generate(widget.exercises.length, (index) => 0);
    maxSetInfoList = List.generate(widget.exercises.length,
        (index) => widget.exercises[index].setInfo.length);
    maxExcerciseIndex = widget.exercises.length - 1;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (initial) {
        workoutRecordBox.whenData(
          (value) async {
            for (int i = 0; i < maxExcerciseIndex; i++) {
              final tempRecord =
                  await value.get(widget.exercises[i].workoutPlanId);

              if (tempRecord != null && tempRecord.setInfo.length > 0) {
                setInfoCompleteList[i] = await value
                    .get(widget.exercises[i].workoutPlanId)
                    .setInfo
                    .length;
              } else {
                setInfoCompleteList[i] = 0;
              }
            }
          },
        );

        modifiedExerciseBox.whenData((value) async {
          for (int i = 0; i < widget.exercises.length; i++) {
            final record = await value.get(widget.exercises[i].workoutPlanId);

            if (record != null && record is Exercise) {
              modifiedExercises.add(record);
            }
          }
        });

        if (!isPoped) {
          for (int i = 0; i < widget.exercises.length; i++) {
            if (setInfoCompleteList[i] < maxSetInfoList[i]) {
              setState(() {
                exerciseIndex = i;
              });

              break;
            }
          }
        }

        onTooltipPressed();

        initial = false;
      }
    });
  }

  @override
  void dispose() {
    // modifiedExercises = [];

    if (timer.isActive) {
      timer.cancel();
    }

    super.dispose();
  }

  void onTooltipPressed() {
    if (isTooltipVisible) {
      timer.cancel();
      setState(() {
        isTooltipVisible = !isTooltipVisible;
        tooltipCount = 0;
      });
    } else {
      setState(() {
        isTooltipVisible = !isTooltipVisible;
        tooltipCount = 3;
      });
      timer = Timer.periodic(
        const Duration(seconds: 1),
        onTick,
      );
    }
  }

  void onTick(Timer timer) {
    if (tooltipCount == 0) {
      //0초가 됬을때 저장
      timer.cancel();
      setState(() {
        isTooltipVisible = false;
      });
    } else {
      setState(() {
        tooltipCount -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final AsyncValue<Box> workoutBox = ref.read(hiveWorkoutRecordProvider);
    final AsyncValue<Box> timerWorkoutBox = ref.read(hiveTimerRecordProvider);
    final AsyncValue<Box> timerXMoreBox =
        ref.read(hiveTimerXMoreRecordProvider);
    final AsyncValue<Box> modifiedBox = ref.read(hiveModifiedExerciseProvider);
    final recordRepository = ref.read(workoutRecordsRepositoryProvider);

    final AsyncValue<Box> workoutResult = ref.read(hiveWorkoutResultProvider);

    workoutRecordBox = workoutBox;
    workoutResultBox = workoutResult;
    modifiedExerciseBox = modifiedBox;

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 18),
          child: IconButton(
            // onPressed: () => GoRouter.of(context).pop('result'),
            onPressed: () {
              if (mounted) {
                DialogWidgets.confirmDialog(
                  message: '아직 운동이 끝나지 않았어요 😮\n저장 후 뒤로 갈까요?',
                  confirmText: '네, 저장할게요',
                  cancelText: '아니요, 리셋할래요',
                  confirmOnTap: () {
                    int count = 0;
                    if (mounted) {
                      Navigator.of(context).popUntil((_) => count++ >= 2);
                    }
                  },
                  cancelOnTap: () {
                    workoutBox.whenData(
                      (value) {
                        for (var element in widget.exercises) {
                          value.delete(element.workoutPlanId);
                        }
                      },
                    );

                    modifiedBox.whenData(
                      (value) async {
                        for (var element in widget.exercises) {
                          await value.delete(element.workoutPlanId);
                        }
                      },
                    );

                    timerWorkoutBox.whenData(
                      (value) {
                        for (var element in widget.exercises) {
                          if ((element.trackingFieldId == 3 ||
                                  element.trackingFieldId == 4) &&
                              element.setInfo.length == 1) {
                            value.delete(element.workoutPlanId);
                          }
                        }
                      },
                    );

                    timerXMoreBox.whenData(
                      (value) {
                        for (var element in widget.exercises) {
                          if ((element.trackingFieldId == 3 ||
                                  element.trackingFieldId == 4) &&
                              element.setInfo.length > 1) {
                            value.delete(element.workoutPlanId);
                          }
                        }
                      },
                    );

                    workoutResultBox.whenData(
                      (value) {
                        for (var element in widget.exercises) {
                          value.delete(element.workoutPlanId);
                        }
                      },
                    );
                    int count = 0;
                    if (mounted) {
                      Navigator.of(context).popUntil((_) => count++ >= 2);
                    }
                  },
                ).show(context);
              }
            },
            icon: const Icon(Icons.arrow_back),
            color: Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                onTooltipPressed();
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: BACKGROUND_COLOR,
                foregroundImage: CachedNetworkImageProvider(
                  '$s3Url${widget.exercises[exerciseIndex].trainerProfileImage}',
                ),
                onForegroundImageError: (exception, stackTrace) {
                  Image.asset('asset/launcher/fitend_logo.png');
                },
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            left: 0.0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 175,
              child: WorkoutVideoPlayer(
                video: ExerciseVideo(
                    url:
                        '$s3Url${widget.exercises[exerciseIndex].videos.first.url}',
                    index: widget.exercises[exerciseIndex].videos.first.index,
                    thumbnail:
                        '$s3Url${widget.exercises[exerciseIndex].videos.first.thumbnail}'),
              ),
            ),
          ),
          if (isTooltipVisible)
            _ShowTip(
              size: size,
              widget: widget,
              exerciseIndex: exerciseIndex,
            ),
          AnimatedPositioned(
            bottom: 0.0,
            curve: Curves.ease,
            duration: const Duration(milliseconds: 300),
            top: isSwipeUp ? size.height - 315 : size.height - 195,
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.velocity.pixelsPerSecond.direction < 0) {
                  setState(() {
                    isSwipeUp = true;
                  });
                } else {
                  setState(() {
                    isSwipeUp = false;
                  });
                }
              },
              child: CustomDraggableBottomSheet(
                isSwipeUp: isSwipeUp,
                content: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      if (modifiedExercises[exerciseIndex].trackingFieldId ==
                              1 ||
                          modifiedExercises[exerciseIndex].trackingFieldId == 2)
                        WeightWrepsProgressCard(
                          exercise: modifiedExercises[exerciseIndex],
                          setInfoIndex: setInfoCompleteList[exerciseIndex],
                          updateSeinfoTap: modifiedExercises[exerciseIndex]
                                      .trackingFieldId ==
                                  1
                              ? () {
                                  // weight X reps

                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        RepsXWeightSetinfoDialog(
                                      initialReps:
                                          modifiedExercises[exerciseIndex]
                                              .setInfo[setInfoCompleteList[
                                                  exerciseIndex]]
                                              .reps!,
                                      initialWeight:
                                          modifiedExercises[exerciseIndex]
                                              .setInfo[setInfoCompleteList[
                                                  exerciseIndex]]
                                              .weight!,
                                    ),
                                  ).then(
                                    (value) {
                                      if (mounted) {
                                        setState(() {
                                          modifiedExercises[exerciseIndex]
                                                      .setInfo[
                                                  setInfoCompleteList[
                                                      exerciseIndex]] =
                                              modifiedExercises[exerciseIndex]
                                                  .setInfo[setInfoCompleteList[
                                                      exerciseIndex]]
                                                  .copyWith(
                                                      reps: int.parse(
                                                          value['reps']),
                                                      weight: double.parse(
                                                          value['weight']));
                                        });

                                        modifiedBox.whenData(
                                          (value) async {
                                            await value.put(
                                                modifiedExercises[exerciseIndex]
                                                    .workoutPlanId,
                                                modifiedExercises[
                                                    exerciseIndex]);
                                          },
                                        );
                                      }
                                    },
                                  );
                                }
                              : () {
                                  // reps
                                  if (mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => RepsSetinfoDialog(
                                        initialReps:
                                            modifiedExercises[exerciseIndex]
                                                .setInfo[setInfoCompleteList[
                                                    exerciseIndex]]
                                                .reps!,
                                      ),
                                    ).then(
                                      (value) {
                                        if (mounted) {
                                          setState(() {
                                            modifiedExercises[exerciseIndex]
                                                        .setInfo[
                                                    setInfoCompleteList[
                                                        exerciseIndex]] =
                                                modifiedExercises[exerciseIndex]
                                                    .setInfo[
                                                        setInfoCompleteList[
                                                            exerciseIndex]]
                                                    .copyWith(
                                                      reps: int.parse(
                                                          value['reps']),
                                                    );
                                          });

                                          modifiedBox.whenData(
                                            (value) async {
                                              await value.put(
                                                  modifiedExercises[
                                                          exerciseIndex]
                                                      .workoutPlanId,
                                                  modifiedExercises[
                                                      exerciseIndex]);
                                            },
                                          );
                                        }
                                      },
                                    );
                                  }
                                },
                          proccessOnTap: () {
                            if (exerciseIndex <= maxExcerciseIndex &&
                                setInfoCompleteList[exerciseIndex] <
                                    maxSetInfoList[exerciseIndex]) {
                              _hiveDataControl(workoutBox);
                            }

                            if (setInfoCompleteList[exerciseIndex] <
                                maxSetInfoList[exerciseIndex]) {
                              setState(() {
                                setInfoCompleteList[exerciseIndex] += 1;
                              });
                            }

                            //운동 변경
                            if (setInfoCompleteList[exerciseIndex] ==
                                    maxSetInfoList[exerciseIndex] &&
                                exerciseIndex < maxExcerciseIndex) {
                              //해당 Exercise의 max 세트수 보다 작고 exerciseIndex가 maxExcerciseIndex보다 작을때
                              setState(() {
                                exerciseIndex += 1; // 운동 변경
                                isTooltipVisible = false;
                                tooltipCount = 0;
                                onTooltipPressed();
                              });

                              while (setInfoCompleteList[exerciseIndex] ==
                                      maxSetInfoList[exerciseIndex] &&
                                  exerciseIndex < maxExcerciseIndex) {
                                if (exerciseIndex == maxExcerciseIndex) {
                                  break;
                                }

                                setState(() {
                                  exerciseIndex += 1; // 완료된 세트라면 건너뛰기
                                });
                              }
                            }

                            if (!workoutFinish) {
                              _checkLastExercise(
                                recordRepository: recordRepository,
                                workoutBox: workoutBox,
                              ); //끝났는지 체크!
                            }
                          },
                        ),
                      // Timer X 1set
                      if ((modifiedExercises[exerciseIndex].trackingFieldId ==
                                  3 ||
                              modifiedExercises[exerciseIndex]
                                      .trackingFieldId ==
                                  4) &&
                          modifiedExercises[exerciseIndex].setInfo.length == 1)
                        TimerXOneProgressCard(
                          exercise: modifiedExercises[exerciseIndex],
                          setInfoIndex: setInfoCompleteList[exerciseIndex],
                          updateSeinfoTap: () {
                            if (mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => TimerSetinfoDialog(
                                  initialTime: modifiedExercises[exerciseIndex]
                                      .setInfo[
                                          setInfoCompleteList[exerciseIndex]]
                                      .seconds!,
                                ),
                              ).then((value) {
                                if (mounted) {
                                  setState(
                                    () {
                                      modifiedExercises[exerciseIndex].setInfo[
                                              setInfoCompleteList[
                                                  exerciseIndex]] =
                                          modifiedExercises[exerciseIndex]
                                              .setInfo[setInfoCompleteList[
                                                  exerciseIndex]]
                                              .copyWith(
                                                seconds: int.parse(
                                                          value['min'],
                                                        ) *
                                                        60 +
                                                    int.parse(value['sec']),
                                              );
                                    },
                                  );

                                  modifiedBox.whenData(
                                    (value) async {
                                      await value.put(
                                          modifiedExercises[exerciseIndex]
                                              .workoutPlanId,
                                          modifiedExercises[exerciseIndex]);
                                    },
                                  );
                                }
                              });
                            }
                          },
                          proccessOnTap: () {
                            timerWorkoutBox.whenData(
                              (value) {
                                final record = value.get(widget
                                    .exercises[exerciseIndex].workoutPlanId);
                                if (record is SetInfo) {
                                  workoutBox.whenData((_) {
                                    _.put(
                                      modifiedExercises[exerciseIndex]
                                          .workoutPlanId,
                                      WorkoutRecordModel(
                                        workoutPlanId:
                                            modifiedExercises[exerciseIndex]
                                                .workoutPlanId,
                                        setInfo: [record],
                                      ),
                                    );
                                  });

                                  setState(() {
                                    setInfoCompleteList[exerciseIndex] = 1;
                                  });

                                  if (setInfoCompleteList[exerciseIndex] ==
                                          maxSetInfoList[exerciseIndex] &&
                                      exerciseIndex < maxExcerciseIndex) {
                                    //해당 Exercise의 max 세트수 보다 작고 exerciseIndex가 maxExcerciseIndex보다 작을때
                                    setState(() {
                                      exerciseIndex += 1;
                                      isTooltipVisible = false;
                                      tooltipCount = 0;
                                      onTooltipPressed();
                                    });

                                    while (setInfoCompleteList[exerciseIndex] ==
                                            maxSetInfoList[exerciseIndex] &&
                                        exerciseIndex < maxExcerciseIndex) {
                                      if (exerciseIndex == maxExcerciseIndex) {
                                        break;
                                      }
                                      setState(() {
                                        exerciseIndex += 1; // 완료된 세트라면 건너뛰기
                                      });
                                    }
                                  }

                                  if (!workoutFinish) {
                                    _checkLastExercise(
                                      recordRepository: recordRepository,
                                      workoutBox: workoutBox,
                                    ); //끝났는지 체크!
                                  }
                                }
                              },
                            );
                          },
                        ),

                      // Timer X more
                      if ((modifiedExercises[exerciseIndex].trackingFieldId ==
                                  3 ||
                              modifiedExercises[exerciseIndex]
                                      .trackingFieldId ==
                                  4) &&
                          modifiedExercises[exerciseIndex].setInfo.length > 1)
                        TimerXMoreProgressCard(
                          exercise: modifiedExercises[exerciseIndex],
                          setInfoIndex: setInfoCompleteList[exerciseIndex],
                          updateSeinfoTap: () {
                            if (mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => TimerSetinfoDialog(
                                  initialTime: modifiedExercises[exerciseIndex]
                                      .setInfo[
                                          setInfoCompleteList[exerciseIndex]]
                                      .seconds!,
                                ),
                              ).then((value) {
                                if (mounted) {
                                  setState(
                                    () {
                                      modifiedExercises[exerciseIndex].setInfo[
                                              setInfoCompleteList[
                                                  exerciseIndex]] =
                                          modifiedExercises[exerciseIndex]
                                              .setInfo[setInfoCompleteList[
                                                  exerciseIndex]]
                                              .copyWith(
                                                seconds: int.parse(
                                                          value['min'],
                                                        ) *
                                                        60 +
                                                    int.parse(value['sec']),
                                              );
                                    },
                                  );

                                  modifiedBox.whenData(
                                    (value) async {
                                      await value.put(
                                          modifiedExercises[exerciseIndex]
                                              .workoutPlanId,
                                          modifiedExercises[exerciseIndex]);
                                    },
                                  );
                                }
                              });
                            }
                          },
                          proccessOnTap: () {
                            if (exerciseIndex <= maxExcerciseIndex &&
                                setInfoCompleteList[exerciseIndex] <
                                    maxSetInfoList[exerciseIndex]) {
                              timerXMoreBox.whenData(
                                (value) {
                                  final record = value.get(widget
                                      .exercises[exerciseIndex].workoutPlanId);

                                  if (record != null &&
                                      record.setInfo.length > 0) {
                                    workoutRecordBox.whenData(
                                      (_) {
                                        _.put(
                                          modifiedExercises[exerciseIndex]
                                              .workoutPlanId,
                                          record,
                                        );
                                      },
                                    );
                                  }
                                },
                              );
                            }

                            if (setInfoCompleteList[exerciseIndex] <
                                maxSetInfoList[exerciseIndex]) {
                              setState(() {
                                setInfoCompleteList[exerciseIndex] += 1;
                              });
                            }

                            //운동 변경
                            if (setInfoCompleteList[exerciseIndex] ==
                                    maxSetInfoList[exerciseIndex] &&
                                exerciseIndex < maxExcerciseIndex) {
                              //해당 Exercise의 max 세트수 보다 작고 exerciseIndex가 maxExcerciseIndex보다 작을때
                              setState(() {
                                exerciseIndex += 1;
                                isTooltipVisible = false;
                                tooltipCount = 0;
                                onTooltipPressed();
                                // 운동 변경
                              });

                              while (setInfoCompleteList[exerciseIndex] ==
                                      maxSetInfoList[exerciseIndex] &&
                                  exerciseIndex < maxExcerciseIndex) {
                                if (exerciseIndex == maxExcerciseIndex) {
                                  break;
                                }
                                setState(() {
                                  exerciseIndex += 1; // 완료된 세트라면 건너뛰기
                                });
                              }
                            }

                            if (!workoutFinish) {
                              _checkLastExercise(
                                recordRepository: recordRepository,
                                workoutBox: workoutBox,
                              ); //끝났는지 체크!
                            }
                          },
                          resetSet: () {
                            setState(() {
                              setInfoCompleteList[exerciseIndex] = 0;
                            });
                          },
                        ),
                      const SizedBox(
                        height: 18,
                      ),
                      if (isSwipeUp)
                        _bottomButtons(
                          workoutBox,
                          modifiedBox,
                          timerWorkoutBox,
                          timerXMoreBox,
                          recordRepository,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkLastExercise({
    required WorkoutRecordsRepository recordRepository,
    required AsyncValue<Box> workoutBox,
  }) async {
    if (exerciseIndex == maxExcerciseIndex &&
        setInfoCompleteList[exerciseIndex] == maxSetInfoList[exerciseIndex]) {
      // 리스트 끝의 운동을 다 했는지 확인!
      bool finish = true;
      for (int i = 0; i <= maxExcerciseIndex; i++) {
        if (setInfoCompleteList[i] != maxSetInfoList[i]) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return DialogWidgets.confirmDialog(
                message: '완료하지 않은 운동이 있어요🤓\n 마저 진행할까요?',
                confirmText: '네, 마저할게요',
                cancelText: '아니요, 그만할래요',
                confirmOnTap: () {
                  setState(() {
                    exerciseIndex = i;
                  });
                  context.pop();
                },
                cancelOnTap: () async {
                  //완료!!!
                  try {
                    if (mounted) {
                      context.pop();

                      List<WorkoutRecordModel> tempRecordList = [];

                      workoutBox.whenData(
                        (value) {
                          for (int i = 0; i < widget.exercises.length; i++) {
                            final record =
                                value.get(widget.exercises[i].workoutPlanId);

                            if (record != null &&
                                record is WorkoutRecordModel) {
                              if (record.setInfo.length < maxSetInfoList[i]) {
                                for (int j = 0;
                                    j <
                                        maxSetInfoList[i] -
                                            setInfoCompleteList[i];
                                    j++) {
                                  record.setInfo.add(
                                    SetInfo(index: record.setInfo.length + 1),
                                  );
                                }
                              }
                              value.put(
                                  widget.exercises[i].workoutPlanId, record);
                              tempRecordList.add(record);
                            } else {
                              var tempRecord = WorkoutRecordModel(
                                workoutPlanId:
                                    widget.exercises[i].workoutPlanId,
                                setInfo: [],
                              );
                              for (int j = 0; j < maxSetInfoList[i]; j++) {
                                tempRecord.setInfo.add(SetInfo(index: j + 1));
                              }
                              value.put(widget.exercises[i].workoutPlanId,
                                  tempRecord);
                              tempRecordList.add(tempRecord);
                            }
                          }
                        },
                      );

                      await recordRepository
                          .postWorkoutRecords(
                        body: PostWorkoutRecordModel(
                          records: tempRecordList,
                        ),
                      )
                          .then(
                        (value) {
                          GoRouter.of(context).pushNamed(
                            WorkoutFeedbackScreen.routeName,
                            pathParameters: {
                              'workoutScheduleId':
                                  widget.workoutScheduleId.toString(),
                            },
                            extra: widget.exercises,
                            queryParameters: {
                              'startDate':
                                  DateFormat('yyyy-MM-dd').format(widget.date),
                            },
                          );
                        },
                      );
                    }
                  } on DioError {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => DialogWidgets.errorDialog(
                        message: '다시 시도해주세요',
                        confirmText: '확인',
                        confirmOnTap: () {
                          context.pop();
                        },
                      ),
                    );
                  }
                },
              );
            },
          );
          finish = false;
          lastChecked = true;
          break;
        }
      }

      if (finish) {
        setState(() {
          workoutFinish = true;
        });
        try {
          List<WorkoutRecordModel> tempRecordList = [];

          workoutBox.whenData(
            (value) {
              for (int i = 0; i < widget.exercises.length; i++) {
                final record = value.get(widget.exercises[i].workoutPlanId);

                if (record != null && record is WorkoutRecordModel) {
                  if (record.setInfo.length < maxSetInfoList[i]) {
                    for (int j = 0;
                        j <= maxSetInfoList[i] - setInfoCompleteList[i];
                        j++) {
                      record.setInfo.add(
                        SetInfo(index: record.setInfo.length + 1),
                      );
                    }
                  }
                  value.put(widget.exercises[i].workoutPlanId, record);
                  tempRecordList.add(record);
                } else {
                  var tempRecord = WorkoutRecordModel(
                    workoutPlanId: widget.exercises[i].workoutPlanId,
                    setInfo: [],
                  );
                  for (int j = 0; j < maxSetInfoList[i]; j++) {
                    tempRecord.setInfo.add(SetInfo(index: j + 1));
                  }
                  value.put(widget.exercises[i].workoutPlanId, tempRecord);
                  tempRecordList.add(tempRecord);
                }
              }
            },
          );

          await recordRepository
              .postWorkoutRecords(
            body: PostWorkoutRecordModel(
              records: tempRecordList,
            ),
          )
              .then((value) {
            GoRouter.of(context).goNamed(
              WorkoutFeedbackScreen.routeName,
              pathParameters: {
                'workoutScheduleId': widget.workoutScheduleId.toString(),
              },
              extra: widget.exercises,
              queryParameters: {
                'startDate': DateFormat('yyyy-MM-dd').format(widget.date),
              },
            );
          });
        } on DioError {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => DialogWidgets.errorDialog(
              message: '다시 시도해주세요',
              confirmText: '확인',
              confirmOnTap: () {
                context.pop();
              },
            ),
          );
        }
      }
    }
  }

  void _hiveDataControl(AsyncValue<Box<dynamic>> box) {
    box.whenData(
      (value) {
        final record = value.get(widget.exercises[exerciseIndex].workoutPlanId);

        if (record != null && record.setInfo.length > 0) {
          //local DB에 데이터가 있을때
          value.put(
            modifiedExercises[exerciseIndex].workoutPlanId,
            WorkoutRecordModel(
              workoutPlanId: modifiedExercises[exerciseIndex].workoutPlanId,
              setInfo: [
                ...record.setInfo,
                modifiedExercises[exerciseIndex]
                    .setInfo[setInfoCompleteList[exerciseIndex]],
              ],
            ),
          );
        } else {
          //local DB에 데이터가 없을때
          value.put(
            modifiedExercises[exerciseIndex].workoutPlanId,
            WorkoutRecordModel(
              workoutPlanId: modifiedExercises[exerciseIndex].workoutPlanId,
              setInfo: [
                modifiedExercises[exerciseIndex]
                    .setInfo[setInfoCompleteList[exerciseIndex]],
              ],
            ),
          );
        }
      },
    );
  }

  Column _bottomButtons(
    AsyncValue<Box<dynamic>> workoutBox,
    AsyncValue<Box<dynamic>> modifiedBox,
    AsyncValue<Box<dynamic>> timerWorkoutBox,
    AsyncValue<Box<dynamic>> timerXMoreBox,
    WorkoutRecordsRepository recordRepository,
  ) {
    return Column(
      children: [
        const Divider(
          height: 1,
          color: GRAY_COLOR,
        ),
        const SizedBox(
          height: 27,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _IconButton(
              img: 'asset/img/icon_change.png',
              name: '운동 변경',
              onTap: () async {
                Navigator.of(context)
                    .push(CupertinoPageRoute(
                  builder: (context) => WorkoutChangeScreen(
                    exerciseIndex: exerciseIndex,
                    workout: widget.workout,
                  ),

                  // PageRouteBuilder(
                  //   transitionDuration: const Duration(milliseconds: 300),
                  //   pageBuilder: (context, animation, secondaryAnimation) =>
                  //       WorkoutChangeScreen(
                  //     exerciseIndex: exerciseIndex,
                  //     workout: widget.workout,
                  //   ),
                  //   transitionsBuilder:
                  //       (context, animation, secondaryAnimation, child) =>
                  //           SlideTransition(
                  //     position: animation.drive(
                  //       Tween(
                  //         begin: const Offset(1.0, 0),
                  //         end: Offset.zero,
                  //       ).chain(
                  //         CurveTween(curve: Curves.linearToEaseOut),
                  //       ),
                  //     ),
                  //     child: child,
                  //   ),
                  // ),
                ))
                    .then(
                  (value) {
                    setState(() {
                      if (value != null) {
                        exerciseIndex = value;
                        isTooltipVisible = false;
                        tooltipCount = 0;
                        onTooltipPressed();
                      }
                      isPoped = true;
                    });
                  },
                );
              },
            ),
            _IconButton(
              img: 'asset/img/icon_guide.png',
              name: '운동 가이드',
              onTap: () {
                // Navigator.of(context).push(
                //   PageRouteBuilder(
                //     transitionDuration: const Duration(milliseconds: 300),
                //     pageBuilder: (context, animation, secondaryAnimation) =>
                //         ExerciseScreen(
                //             exercise: widget.exercises[exerciseIndex]),
                //     transitionsBuilder:
                //         (context, animation, secondaryAnimation, child) =>
                //             SlideTransition(
                //       position: animation.drive(
                //         Tween(
                //           begin: const Offset(1.0, 0),
                //           end: Offset.zero,
                //         ).chain(
                //           CurveTween(curve: Curves.linearToEaseOut),
                //         ),
                //       ),
                //       child: child,
                //     ),
                //   ),
                // );
                Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) =>
                      ExerciseScreen(exercise: widget.exercises[exerciseIndex]),
                ));
              },
            ),
            _IconButton(
              img: 'asset/img/icon_record.png',
              name: '영상 녹화',
              textColor: LIGHT_GRAY_COLOR,
              onTap: () {
                DialogWidgets.errorDialog(
                  message: '곧 업데이트 예정이에요 🙏',
                  confirmText: '확인',
                  confirmOnTap: () => context.pop(),
                ).show(context);
              },
            ),
            _IconButton(
              img: 'asset/img/icon_stop.png',
              name: '운동 종료',
              onTap: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (_) {
                    return DialogWidgets.confirmDialog(
                      message: '오늘의 운동을 종료할까요?\n 종료 후에는 다시 진행할 수 없어요 🙉',
                      confirmText: '아니요, 계속할게요',
                      cancelText: '네, 종료할게요',
                      confirmOnTap: () {
                        context.pop();
                      },
                      cancelOnTap: () async {
                        context.pop();

                        try {
                          List<WorkoutRecordModel> tempRecordList = [];

                          workoutBox.whenData(
                            (value) {
                              for (int i = 0;
                                  i < widget.exercises.length;
                                  i++) {
                                var record = value
                                    .get(widget.exercises[i].workoutPlanId);

                                if (record != null &&
                                    record is WorkoutRecordModel) {
                                  if (record.setInfo.length <
                                      maxSetInfoList[i]) {
                                    for (int j = 0;
                                        j <
                                            maxSetInfoList[i] -
                                                setInfoCompleteList[i];
                                        j++) {
                                      record.setInfo.add(
                                        SetInfo(
                                            index: record.setInfo.length + 1),
                                      );
                                    }
                                  }

                                  value.put(widget.exercises[i].workoutPlanId,
                                      record);
                                  tempRecordList.add(record);
                                } else {
                                  var tempRecord = WorkoutRecordModel(
                                    workoutPlanId:
                                        widget.exercises[i].workoutPlanId,
                                    setInfo: [],
                                  );
                                  for (int j = 0; j < maxSetInfoList[i]; j++) {
                                    tempRecord.setInfo.add(SetInfo(
                                      index: j + 1,
                                    ));
                                  }
                                  value.put(widget.exercises[i].workoutPlanId,
                                      tempRecord);
                                  tempRecordList.add(tempRecord);
                                }
                              }
                            },
                          );

                          await recordRepository
                              .postWorkoutRecords(
                            body: PostWorkoutRecordModel(
                              records: tempRecordList,
                            ),
                          )
                              .then((value) {
                            GoRouter.of(context)
                                .goNamed(WorkoutFeedbackScreen.routeName,
                                    pathParameters: {
                                      'workoutScheduleId':
                                          widget.workoutScheduleId.toString(),
                                    },
                                    extra: widget.exercises,
                                    queryParameters: {
                                      'startDate': DateFormat('yyyy-MM-dd')
                                          .format(widget.date),
                                    });
                          });
                        } on DioError catch (e) {
                          if (e.response!.statusCode == 403) {
                            workoutBox.whenData(
                              (value) {
                                for (var element in widget.exercises) {
                                  value.delete(element.workoutPlanId);
                                }
                              },
                            );

                            modifiedBox.whenData(
                              (value) async {
                                for (var element in widget.exercises) {
                                  await value.delete(element.workoutPlanId);
                                }
                              },
                            );

                            timerWorkoutBox.whenData(
                              (value) {
                                for (var element in widget.exercises) {
                                  if ((element.trackingFieldId == 3 ||
                                          element.trackingFieldId == 4) &&
                                      element.setInfo.length == 1) {
                                    value.delete(element.workoutPlanId);
                                  }
                                }
                              },
                            );

                            timerXMoreBox.whenData(
                              (value) {
                                for (var element in widget.exercises) {
                                  if ((element.trackingFieldId == 3 ||
                                          element.trackingFieldId == 4) &&
                                      element.setInfo.length > 1) {
                                    value.delete(element.workoutPlanId);
                                  }
                                }
                              },
                            );

                            workoutResultBox.whenData(
                              (value) {
                                for (var element in widget.exercises) {
                                  value.delete(element.workoutPlanId);
                                }
                              },
                            );

                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => DialogWidgets.errorDialog(
                                message:
                                    '운동 정보가 변경되었습니다.😂\n 앱을 종료후 다시 실행해 주세요.',
                                confirmText: '확인',
                                confirmOnTap: () {
                                  context.pop();
                                },
                              ),
                            );
                          } else {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => DialogWidgets.errorDialog(
                                message: '다시 시도해주세요',
                                confirmText: '확인',
                                confirmOnTap: () {
                                  context.pop();
                                },
                              ),
                            );
                          }
                        }
                        //완료!!!!!!!!!
                      },
                    );
                  },
                );
              },
            ),
          ],
        )
      ],
    );
  }

  InkWell _IconButton({
    required String img,
    required String name,
    required GestureTapCallback onTap,
    Color textColor = GRAY_COLOR,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          SizedBox(
            height: 44,
            width: 44,
            child: Image.asset(img),
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            name,
            style: s2SubTitle.copyWith(
              color: textColor,
              height: 1,
            ),
          )
        ],
      ),
    );
  }
}

class _ShowTip extends StatelessWidget {
  const _ShowTip({
    required this.size,
    required this.widget,
    required this.exerciseIndex,
  });

  final Size size;
  final WorkoutScreen widget;
  final int exerciseIndex;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 28,
      top: MediaQuery.of(context).padding.top,
      right: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const MyClipPath(),
          Container(
            width: size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black.withOpacity(0.8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tip 📣',
                    style: h5Headline.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    widget.exercises[exerciseIndex].description,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
