import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fitend_member/common/component/custom_clipper.dart';
import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/component/guide_video_player.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/exercise_video_model.dart';
import 'package:fitend_member/exercise/view/exercise_screen.dart';
import 'package:fitend_member/workout/component/setinfo_list_card/setInfo_reps_card.dart';
import 'package:fitend_member/workout/component/setinfo_list_card/setInfo_timer_card.dart';
import 'package:fitend_member/workout/component/setinfo_list_card/setInfo_weight_reps_card.dart';
import 'package:fitend_member/workout/component/timer_progress_card%20.dart';
import 'package:fitend_member/workout/component/weight_reps_progress_card.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:fitend_member/workout/model/workout_process_model.dart';
import 'package:fitend_member/workout/provider/workout_process_provider.dart';
import 'package:fitend_member/workout/provider/workout_provider.dart';
import 'package:fitend_member/workout/view/workout_change_screen.dart';
import 'package:fitend_member/workout/view/workout_feedback_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:collection/collection.dart';

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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool isSwipeUp = false;
  bool isTooltipVisible = false;
  int tooltipCount = 0;
  late Timer timer;
  late Timer totalTimeTimer;
  final panelController = PanelController();

  bool isBackground = false;
  DateTime resumedTime = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  DateTime pausedTime = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    initData();
  }

  initData() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        ref
            .read(workoutProcessProvider(widget.workoutScheduleId).notifier)
            .init(ref.read(workoutProvider(widget.workoutScheduleId).notifier));

        totalTimerStart();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (isBackground) {
          resumedTime = DateTime.now();

          int addSeconds = resumedTime.difference(pausedTime).inSeconds;

          ref
              .read(workoutProcessProvider(widget.workoutScheduleId).notifier)
              .addProcessTotalTime(addSeconds);

          isBackground = false;

          totalTimeTimer = Timer.periodic(
            const Duration(seconds: 1),
            onTickTotalTimer,
          );
        }

        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        pausedTime = DateTime.now();
        isBackground = true;
        totalTimeTimer.cancel();

        break;
      case AppLifecycleState.detached:
        // print("app in detached");
        break;
      case AppLifecycleState.hidden:
        break;
    }
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

  void totalTimerStart() {
    totalTimeTimer = Timer.periodic(
      const Duration(seconds: 1),
      onTickTotalTimer,
    );
  }

  void onTickTotalTimer(timer) {
    ref
        .read(workoutProcessProvider(widget.workoutScheduleId).notifier)
        .putProcessTotalTime();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = Size(100.w, 100.h);
    final state = ref.watch(workoutProcessProvider(widget.workoutScheduleId));

    if (state is WorkoutProcessModelLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: POINT_COLOR,
        ),
      );
    }

    if (state is! WorkoutProcessModel) {
      return const Scaffold();
    }

    final model = state;

    // print(model.toJson());

    return WillPopScope(
      onWillPop: () async {
        _pagePop();

        return Future.value(true);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: GRAY_COLOR,
        floatingActionButton: isSwipeUp
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () async {
                      await _onTapNext(context, model);
                    },
                    child: Container(
                      width: size.width - 56,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: POINT_COLOR,
                      ),
                      child: Center(
                        child: Text(
                          '다음 운동',
                          style: h2Headline.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButtonAnimator: null,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 18),
            child: IconButton(
              onPressed: () {
                if (mounted) {
                  _pagePop();
                }
              },
              icon: const Icon(Icons.arrow_back),
              color: Colors.black,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 18.0),
              child: IconButton.filled(
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) {
                        return DialogWidgets.confirmDialog(
                          message: '오늘의 운동을 종료할까요?\n종료 후에는 다시 진행할 수 없어요 🙉',
                          confirmText: '아니요, 계속 할게요',
                          cancelText: '네, 종료할게요',
                          confirmOnTap: () {
                            context.pop();
                          },
                          cancelOnTap: () async {
                            try {
                              await ref
                                  .read(workoutProcessProvider(
                                          widget.workoutScheduleId)
                                      .notifier)
                                  .quitWorkout()
                                  .then((value) {
                                context.pop(); // workout screen 닫기

                                GoRouter.of(context).pushNamed(
                                  WorkoutFeedbackScreen.routeName,
                                  pathParameters: {
                                    'workoutScheduleId':
                                        widget.workoutScheduleId.toString(),
                                  },
                                  extra: widget.exercises,
                                  queryParameters: {
                                    'startDate': DateFormat('yyyy-MM-dd')
                                        .format(widget.date),
                                  },
                                );
                              });
                            } on DioException catch (e) {
                              debugPrint('$e');
                              if (e.response!.statusCode == 409) {
                                context.pop(); // workout screen 닫기
                                GoRouter.of(context).pushNamed(
                                  WorkoutFeedbackScreen.routeName,
                                  pathParameters: {
                                    'workoutScheduleId':
                                        widget.workoutScheduleId.toString(),
                                  },
                                  extra: widget.exercises,
                                  queryParameters: {
                                    'startDate': DateFormat('yyyy-MM-dd')
                                        .format(widget.date),
                                  },
                                );
                              }
                            }

                            //완료!!!!!!!!!
                          },
                        );
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.close_sharp,
                    color: Colors.black,
                  )),
            ),
          ],
          title: Container(
            width: 80,
            height: 27,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.8),
            ),
            child: Center(
              child: Text(
                DataUtils.getTimeStringMinutes(model.totalTime),
                style: s1SubTitle.copyWith(
                  color: Colors.black,
                  fontSize: 20,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned(
              // left: 0.0,
              right: 100.w > 600 //테블릿이면
                  ? (100.w - (100.h) * 9 / 16) / 2
                  : 0,
              child: SizedBox(
                width: 100.w > 600 //테블릿이면
                    ? (100.h) * 9 / 16
                    : 100.w,
                height: 100.w > 600 ? 100.h : 100.w * 16 / 9,
                child: GuideVideoPlayer(
                  isGuide: false,
                  videos: [
                    ExerciseVideo(
                      url:
                          '$s3Url${widget.exercises[model.exerciseIndex].videos.first.url}',
                      index: widget
                          .exercises[model.exerciseIndex].videos.first.index,
                      thumbnail:
                          '$s3Url${widget.exercises[model.exerciseIndex].videos.first.thumbnail}',
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 200,
              right: 28,
              child: IconButton(
                iconSize: 36,
                onPressed: () {
                  onTooltipPressed();
                },
                icon: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: CustomNetworkImage(
                    imageUrl:
                        '$s3Url${widget.exercises[model.exerciseIndex].trainerProfileImage}',
                    width: 36,
                    height: 36,
                    boxFit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            if (isTooltipVisible)
              _ShowTip(
                size: size,
                widget: widget,
                exerciseIndex: model.exerciseIndex,
              ),
            SlidingUpPanel(
              key: ValueKey(widget.workoutScheduleId),
              minHeight: 195,
              maxHeight: size.height - (56 + kToolbarHeight),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              onPanelClosed: () => setState(() {
                isSwipeUp = false;
              }),
              onPanelOpened: () => setState(() {
                isSwipeUp = true;
              }),
              panel: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 12,
                            ),
                            child: Container(
                              width: 44,
                              height: 4,
                              decoration: BoxDecoration(
                                  color: LIGHT_GRAY_COLOR,
                                  borderRadius: BorderRadius.circular(2)),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (model.modifiedExercises[model.exerciseIndex]
                                    .trackingFieldId ==
                                1 ||
                            model.modifiedExercises[model.exerciseIndex]
                                    .trackingFieldId ==
                                2)
                          WeightWrepsProgressCard(
                            workoutScheduleId: widget.workoutScheduleId,
                            isSwipeUp: isSwipeUp,
                            exercise:
                                model.modifiedExercises[model.exerciseIndex],
                            setInfoIndex:
                                model.setInfoCompleteList[model.exerciseIndex],
                            listOnTap: () async {
                              await Navigator.of(context)
                                  .push(CupertinoPageRoute(
                                builder: (context) => WorkoutChangeScreen(
                                  exerciseIndex: model.exerciseIndex,
                                  workout: widget.workout,
                                ),
                              ))
                                  .then(
                                (value) {
                                  if (value != null) {
                                    ref
                                        .read(workoutProcessProvider(
                                                widget.workoutScheduleId)
                                            .notifier)
                                        .exerciseChange(value);
                                    // isTooltipVisible = false;
                                    // tooltipCount = 0;
                                    // onTooltipPressed();
                                    setState(() {});
                                  }
                                },
                              );
                            },
                            proccessOnTap: () async {
                              await _onTapNext(context, model);
                            },
                          )
                        // Timer
                        else if ((model.modifiedExercises[model.exerciseIndex]
                                    .trackingFieldId ==
                                3 ||
                            model.modifiedExercises[model.exerciseIndex]
                                    .trackingFieldId ==
                                4))
                          TimerProgressCard(
                            workoutScheduleId: widget.workoutScheduleId,
                            isSwipeUp: isSwipeUp,
                            exercise:
                                model.modifiedExercises[model.exerciseIndex],
                            setInfoIndex:
                                model.setInfoCompleteList[model.exerciseIndex],
                            listOnTap: () async {
                              await Navigator.of(context)
                                  .push(CupertinoPageRoute(
                                builder: (context) => WorkoutChangeScreen(
                                  exerciseIndex: model.exerciseIndex,
                                  workout: widget.workout,
                                ),
                              ))
                                  .then(
                                (value) {
                                  if (value != null) {
                                    ref
                                        .read(workoutProcessProvider(
                                                widget.workoutScheduleId)
                                            .notifier)
                                        .exerciseChange(value);
                                    // isTooltipVisible = false;
                                    // tooltipCount = 0;
                                    // onTooltipPressed();
                                    setState(() {});
                                  }
                                },
                              );
                            },
                            proccessOnTap: () async {
                              await _onTapNext(context, model);
                            },
                            resetSet: () {},
                            refresh: () {
                              setState(() {});
                            },
                          ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: LIGHT_GRAY_COLOR,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              '${model.modifiedExercises[model.exerciseIndex].setInfo.length} SET',
                              style:
                                  s1SubTitle.copyWith(color: LIGHT_GRAY_COLOR),
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: LIGHT_GRAY_COLOR,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height -
                        (56 +
                            kToolbarHeight +
                            195 +
                            5), // (appbar + toolbar + bottomSlide mini)
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        ...model.modifiedExercises[model.exerciseIndex].setInfo
                            .mapIndexed((index, element) {
                          if (model.modifiedExercises[model.exerciseIndex]
                                  .trackingFieldId ==
                              1) {
                            return SetInfoBoxForWeightReps(
                              key: ValueKey(
                                  '${model.modifiedExercises[model.exerciseIndex].workoutPlanId}_$index'),
                              workoutScheduleId: widget.workoutScheduleId,
                              initialReps: element.reps!,
                              initialWeight: element.weight!,
                              model: model,
                              setInfoIndex: index,
                              refresh: () {
                                setState(() {});
                              },
                            );
                          } else if (model
                                  .modifiedExercises[model.exerciseIndex]
                                  .trackingFieldId ==
                              2) {
                            return SetInfoBoxForReps(
                              key: ValueKey(
                                  '${model.modifiedExercises[model.exerciseIndex].workoutPlanId}_$index'),
                              workoutScheduleId: widget.workoutScheduleId,
                              initialReps: element.reps!,
                              model: model,
                              setInfoIndex: index,
                              refresh: () {
                                setState(() {});
                              },
                            );
                          } else {
                            return SetInfoBoxForTimer(
                              key: ValueKey(
                                  '${model.modifiedExercises[model.exerciseIndex].workoutPlanId}_$index'),
                              workoutScheduleId: widget.workoutScheduleId,
                              initialSeconds: element.seconds!,
                              model: model,
                              setInfoIndex: index,
                              refresh: () {
                                setState(() {});
                              },
                            );
                          }
                        }).toList(),
                        Container(
                          color: LIGHT_GRAY_COLOR.withOpacity(0.15),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                            ),
                            child: Column(
                              children: [
                                SvgPicture.asset('asset/img/icon_more.svg'),
                                InkWell(
                                  onTap: () async {
                                    Navigator.of(context)
                                        .push(CupertinoPageRoute(
                                      builder: (context) => WorkoutChangeScreen(
                                        exerciseIndex: model.exerciseIndex,
                                        workout: widget.workout,
                                      ),
                                    ))
                                        .then(
                                      (value) {
                                        if (value != null) {
                                          ref
                                              .read(workoutProcessProvider(
                                                      widget.workoutScheduleId)
                                                  .notifier)
                                              .exerciseChange(value);
                                          // isTooltipVisible = false;
                                          // tooltipCount = 0;
                                          // onTooltipPressed();
                                          setState(() {});
                                        }
                                      },
                                    );
                                  },
                                  child: SizedBox(
                                    height: 55,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        SvgPicture.asset(
                                            'asset/img/icon_list.svg'),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '운동 리스트',
                                          style: h5Headline.copyWith(
                                            height: 1,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(CupertinoPageRoute(
                                      builder: (context) => ExerciseScreen(
                                          exercise: widget
                                              .exercises[model.exerciseIndex]),
                                    ));
                                  },
                                  child: SizedBox(
                                    height: 55,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: SvgPicture.asset(
                                              'asset/img/icon_guide.svg'),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '운동 가이드',
                                          style: h5Headline.copyWith(
                                            height: 1,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 50,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _onTapNext(
      BuildContext context, WorkoutProcessModel model) async {
    await ref
        .read(workoutProcessProvider(widget.workoutScheduleId).notifier)
        .nextWorkout()
        .then((value) async {
      if (value != null) {
        if (value == -1) {
          await ref
              .read(workoutProcessProvider(widget.workoutScheduleId).notifier)
              .quitWorkout()
              .then((value) {
            context.pop(); // workout screen 닫기

            GoRouter.of(context).pushNamed(
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
        } else {
          if (value == model.maxExerciseIndex &&
              model.setInfoCompleteList[value] == model.maxSetInfoList[value]) {
            for (int i = 0; i <= model.maxExerciseIndex; i++) {
              if (model.setInfoCompleteList[i] != model.maxSetInfoList[i]) {
                _showUncompleteExerciseDialog(context, i);
                break;
              }
            }
          }
        }
      }
    });

    setState(() {});
  }

  Future<dynamic> _showUncompleteExerciseDialog(
      BuildContext context, int index) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return DialogWidgets.confirmDialog(
          dismissable: false,
          message: '완료하지 않은 운동이 있어요🤓\n 마저 진행할까요?',
          confirmText: '네, 마저할게요',
          cancelText: '아니요, 그만할래요',
          confirmOnTap: () {
            ref
                .read(workoutProcessProvider(widget.workoutScheduleId).notifier)
                .exerciseChange(index);

            context.pop();
          },
          cancelOnTap: () async {
            //완료!!!
            try {
              context.pop(); //dialog 닫기

              await ref
                  .read(
                      workoutProcessProvider(widget.workoutScheduleId).notifier)
                  .quitWorkout()
                  .then((value) {
                context.pop(); // workout screen 닫기

                GoRouter.of(context).pushNamed(
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
            } on DioException catch (e) {
              debugPrint('$e');
              if (e.response!.statusCode == 409) {
                context.pop(); // workout screen 닫기
                GoRouter.of(context).pushNamed(
                  WorkoutFeedbackScreen.routeName,
                  pathParameters: {
                    'workoutScheduleId': widget.workoutScheduleId.toString(),
                  },
                  extra: widget.exercises,
                  queryParameters: {
                    'startDate': DateFormat('yyyy-MM-dd').format(widget.date),
                  },
                );
              }
            }
          },
        );
      },
    );
  }

  void _pagePop() {
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
        if (mounted) {
          int count = 0;
          ref
              .read(workoutProcessProvider(widget.workoutScheduleId).notifier)
              .resetWorkoutProcess();

          Navigator.of(context).popUntil((_) => count++ >= 2);
        }
        setState(() {});
      },
    ).show(context);
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
      bottom: 250,
      right: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
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
          const MyClipPath(),
        ],
      ),
    );
  }
}
