import 'package:fitend_member/common/component/custom_clipper.dart';
import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/component/dialog_tools.dart';
import 'package:fitend_member/common/component/draggable_bottom_sheet.dart';
import 'package:fitend_member/common/component/workout_video_player.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/provider/hive_timer_record_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_x_more_%20record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/exercise_video_model.dart';
import 'package:fitend_member/exercise/model/setInfo_model.dart';
import 'package:fitend_member/exercise/view/exercise_screen.dart';
import 'package:fitend_member/workout/component/timer_x_more_progress_card%20.dart';
import 'package:fitend_member/workout/component/timer_x_one_progress_card.dart';
import 'package:fitend_member/workout/component/weight_reps_progress_card.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:fitend_member/workout/model/workout_record_model.dart';
import 'package:fitend_member/workout/view/workout_change_screen.dart';
import 'package:fitend_member/workout/view/workout_feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  bool isSwipeUp = false;
  bool initial = true;
  late int exerciseIndex = 0;
  List<int> setInfoCompleteList = [];
  List<int> maxSetInfoList = [];
  bool workoutFinish = false;
  bool isPoped = false;
  bool lastChecked = false;
  late int maxExcerciseIndex;
  bool isTooltipVisible = true;

  @override
  void initState() {
    super.initState();

    setInfoCompleteList = List.generate(widget.exercises.length, (index) => 0);
    maxSetInfoList = List.generate(widget.exercises.length, (index) {
      return widget.exercises[index].setInfo.length;
    });
    maxExcerciseIndex = widget.exercises.length - 1;

    WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
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
                print('setInfoCompleteList[$i] : ${setInfoCompleteList[i]}');
              } else {
                setInfoCompleteList[i] = 0;
              }
            }

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
          },
        );
        initial = false;
      }
    });

    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        isTooltipVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final AsyncValue<Box> workoutBox = ref.watch(hiveWorkoutRecordProvider);
    final AsyncValue<Box> timerWorkoutBox = ref.watch(hiveTimerRecordProvider);
    final AsyncValue<Box> timerXMoreBox =
        ref.watch(hiveTimerXMoreRecordProvider);

    workoutRecordBox = workoutBox;

    if (isTooltipVisible) {
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          isTooltipVisible = false;
        });
      });
    }

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          // onPressed: () => GoRouter.of(context).pop('result'),
          onPressed: () {
            DialogTools.confirmDialog(
              message: '아직 운동이 끝나지 않았어요 😮\n저장 후 뒤로 갈까요?',
              confirmText: '네, 저장할게요',
              cancelText: '아니요, 리셋할래요',
              confirmOnTap: () {
                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 2);
              },
              cancelOnTap: () {
                workoutBox.whenData(
                  (value) {
                    for (var element in widget.exercises) {
                      value.delete(element.workoutPlanId);
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

                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 2);
              },
            ).show(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isTooltipVisible = !isTooltipVisible;
                });

                if (isTooltipVisible) {
                  Future.delayed(const Duration(seconds: 5), () {
                    setState(() {
                      isTooltipVisible = false;
                    });
                  });
                }
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: POINT_COLOR,
                child: CustomNetworkImage(
                  imageUrl:
                      '$s3Url${widget.exercises[exerciseIndex].trainerProfileImage}',
                ),
              ),
            ),
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            left: 0.0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 690,
              child: WorkoutVideoPlayer(
                video: ExerciseVideo(
                  url:
                      'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
                  index: 1,
                  thumbnail:
                      'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg',
                ),
              ),
            ),
          ),
          if (isTooltipVisible)
            Positioned(
              left: 28,
              top: 110,
              right: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const MyClipPath(),
                  Container(
                    width: size.width,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black.withOpacity(0.8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tip 📣',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
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
            ),
          AnimatedPositioned(
            bottom: 0.0,
            curve: Curves.linear,
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
                      if (widget.exercises[exerciseIndex].trackingFieldId ==
                              1 ||
                          widget.exercises[exerciseIndex].trackingFieldId == 2)
                        WeightWrepsProgressCard(
                          exercise: widget.exercises[exerciseIndex],
                          setInfoIndex: setInfoCompleteList[exerciseIndex],
                          proccessOnTap: () {
                            if (exerciseIndex <= maxExcerciseIndex &&
                                setInfoCompleteList[exerciseIndex] <
                                    maxSetInfoList[exerciseIndex]) {
                              _hiveDataControl(workoutBox);
                            }

                            if (!workoutFinish) {
                              _checkLastExercise(); //끝났는지 체크!
                            }

                            if (setInfoCompleteList[exerciseIndex] <
                                maxSetInfoList[exerciseIndex]) {
                              setState(() {
                                setInfoCompleteList[exerciseIndex] += 1;
                                print(
                                    'setInfoCompleteIndex[$exerciseIndex] : ${setInfoCompleteList[exerciseIndex]}');
                              });
                            }

                            //운동 변경
                            if (setInfoCompleteList[exerciseIndex] ==
                                    maxSetInfoList[exerciseIndex] &&
                                exerciseIndex < maxExcerciseIndex) {
                              //해당 Exercise의 max 세트수 보다 작고 exerciseIndex가 maxExcerciseIndex보다 작을때
                              setState(() {
                                exerciseIndex += 1; // 운동 변경
                                isTooltipVisible = true;
                              });

                              while (setInfoCompleteList[exerciseIndex] ==
                                      maxSetInfoList[exerciseIndex] &&
                                  exerciseIndex < maxExcerciseIndex) {
                                setState(() {
                                  exerciseIndex += 1; // 완료된 세트라면 건너뛰기
                                });
                                if (exerciseIndex == maxExcerciseIndex) {
                                  break;
                                }
                              }
                            }

                            if (!workoutFinish) {
                              _checkLastExercise(); //끝났는지 체크!
                            }
                          },
                        ),
                      if ((widget.exercises[exerciseIndex].trackingFieldId ==
                                  3 ||
                              widget.exercises[exerciseIndex].trackingFieldId ==
                                  4) &&
                          widget.exercises[exerciseIndex].setInfo.length ==
                              1) // Timer X 1set
                        TimerXOneProgressCard(
                          exercise: widget.exercises[exerciseIndex],
                          setInfoIndex: setInfoCompleteList[exerciseIndex],
                          proccessOnTap: () {
                            timerWorkoutBox.whenData(
                              (value) {
                                final record = value.get(widget
                                    .exercises[exerciseIndex].workoutPlanId);
                                if (record is SetInfo) {
                                  workoutBox.whenData((_) {
                                    _.put(
                                      widget.exercises[exerciseIndex]
                                          .workoutPlanId,
                                      WorkoutRecordModel(
                                        workoutPlanId: widget
                                            .exercises[exerciseIndex]
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
                                      isTooltipVisible = true;
                                      // 운동 변경
                                    });

                                    while (setInfoCompleteList[exerciseIndex] ==
                                            maxSetInfoList[exerciseIndex] &&
                                        exerciseIndex < maxExcerciseIndex) {
                                      setState(() {
                                        exerciseIndex += 1; // 완료된 세트라면 건너뛰기
                                      });
                                      if (exerciseIndex == maxExcerciseIndex) {
                                        break;
                                      }
                                    }
                                  }

                                  if (!workoutFinish) {
                                    _checkLastExercise(); //끝났는지 체크!
                                  }
                                }
                              },
                            );
                          },
                        ),
                      if ((widget.exercises[exerciseIndex].trackingFieldId ==
                                  3 ||
                              widget.exercises[exerciseIndex].trackingFieldId ==
                                  4) &&
                          widget.exercises[exerciseIndex].setInfo.length >
                              1) // Timer X more than 1 set
                        TimerXMoreProgressCard(
                          exercise: widget.exercises[exerciseIndex],
                          setInfoIndex: setInfoCompleteList[exerciseIndex],
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
                                          widget.exercises[exerciseIndex]
                                              .workoutPlanId,
                                          record,
                                        );
                                      },
                                    );
                                  }
                                },
                              );
                            }

                            if (!workoutFinish) {
                              _checkLastExercise(); //끝났는지 체크!
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
                                isTooltipVisible = true;
                                // 운동 변경
                              });

                              while (setInfoCompleteList[exerciseIndex] ==
                                      maxSetInfoList[exerciseIndex] &&
                                  exerciseIndex < maxExcerciseIndex) {
                                setState(() {
                                  exerciseIndex += 1; // 완료된 세트라면 건너뛰기
                                });
                                if (exerciseIndex == maxExcerciseIndex) {
                                  break;
                                }
                              }
                            }

                            if (!workoutFinish) {
                              _checkLastExercise(); //끝났는지 체크!
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
                        _bottomButtons(context, workoutBox, timerXMoreBox),
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

  void _checkLastExercise() {
    if (exerciseIndex == maxExcerciseIndex &&
        setInfoCompleteList[exerciseIndex] == maxSetInfoList[exerciseIndex]) {
      // 리스트 끝의 운동을 다 했는지 확인!
      bool finish = true;
      for (int i = 0; i <= maxExcerciseIndex; i++) {
        if (setInfoCompleteList[i] != maxSetInfoList[i]) {
          print('setInfoCompleteIndex[$i] : ${setInfoCompleteList[i]}');
          print('maxSetInfoIndex[$i] : ${maxSetInfoList[i]}');
          showDialog(
            context: context,
            builder: (context) {
              return DialogTools.confirmDialog(
                message: '완료하지 않은 운동이 있어요🤓\n 마저 진행할까요?',
                confirmText: '네, 마저할게요',
                cancelText: '아니요, 그만할래요',
                confirmOnTap: () {
                  setState(() {
                    exerciseIndex = i;
                  });
                  context.pop();
                },
                cancelOnTap: () {
                  print('완료쓰!!');
                  context.pop();
                  context.goNamed(WorkoutFeedbackScreen.routeName);
                  //완료
                },
              );
            },
          );
          finish = false;
          lastChecked = true;
          print('finish : $finish');
          break;
        }
      }

      if (finish) {
        print('완료쓰!!');
        setState(() {
          workoutFinish = true;
        });
        //완료
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
            widget.exercises[exerciseIndex].workoutPlanId,
            WorkoutRecordModel(
              workoutPlanId: widget.exercises[exerciseIndex].workoutPlanId,
              setInfo: [
                ...record.setInfo,
                widget.exercises[exerciseIndex]
                    .setInfo[setInfoCompleteList[exerciseIndex]],
              ],
            ),
          );
        } else {
          //local DB에 데이터가 없을때
          value.put(
            widget.exercises[exerciseIndex].workoutPlanId,
            WorkoutRecordModel(
              workoutPlanId: widget.exercises[exerciseIndex].workoutPlanId,
              setInfo: [
                widget.exercises[exerciseIndex]
                    .setInfo[setInfoCompleteList[exerciseIndex]],
              ],
            ),
          );
        }
      },
    );
  }

  Column _bottomButtons(
    BuildContext context,
    AsyncValue<Box<dynamic>> box,
    AsyncValue<Box<dynamic>> box2,
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
                final ret = Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => WorkoutChangeScreen(
                      exerciseIndex: exerciseIndex,
                      workout: widget.workout,
                    ),
                  ),
                )
                    .then(
                  (value) {
                    setState(() {
                      exerciseIndex = value;
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
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      ExerciseScreen(exercise: widget.exercises[0]),
                ));
              },
            ),
            _IconButton(
              img: 'asset/img/icon_record.png',
              name: '영상 녹화',
              textColor: LIGHT_GRAY_COLOR,
              onTap: () {
                DialogTools.errorDialog(
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
                  context: context,
                  builder: (context) {
                    return DialogTools.confirmDialog(
                      message: '오늘의 운동을 종료할까요?\n 종료 후에는 다시 진행할 수 없어요 🙉',
                      confirmText: '아니요, 계속할게요',
                      cancelText: '네, 종료할게요',
                      confirmOnTap: () {
                        context.pop();
                      },
                      cancelOnTap: () {
                        context.pop();
                        context.goNamed(
                          WorkoutFeedbackScreen.routeName,
                          pathParameters: {
                            'workoutScheduleId':
                                widget.workoutScheduleId.toString(),
                          },
                        );
                        //완료
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
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          )
        ],
      ),
    );
  }
}
