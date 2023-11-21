import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:fitend_member/workout/model/workout_process_model.dart';
import 'package:fitend_member/workout/provider/workout_process_provider.dart';
import 'package:fitend_member/workout/provider/workout_provider.dart';
import 'package:fitend_member/workout/view/workout_feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({
    super.key,
    required this.model,
    required this.setInfoIndex,
    required this.secondsGoal,
    required this.secondsRecord,
    required this.workoutScheduleId,
    required this.refresh,
  });

  final WorkoutProcessModel model;
  final int setInfoIndex;
  final int secondsGoal;
  final int secondsRecord;
  final int workoutScheduleId;
  final Function refresh;

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen>
    with WidgetsBindingObserver {
  late ValueNotifier<double> valueNotifier;
  late int totalSeconds;
  late Timer timer;
  bool isRunning = false;
  bool isReady = false;
  int count = 4;
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

    valueNotifier = ValueNotifier(
        (widget.secondsRecord.toDouble() / widget.secondsGoal.toDouble()));

    if (widget.secondsRecord < widget.secondsGoal) {
      totalSeconds = widget.secondsGoal - widget.secondsRecord;
    } else {
      totalSeconds = 0;
    }
  }

  void onStartPressed() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      onTick,
    );
    if (mounted) {
      setState(() {
        isReady = true;
        isRunning = true;
      });
    }
  }

  void onPausePressed() {
    timer.cancel();
    if (mounted) {
      setState(() {
        isRunning = false;
        // count = 4;
      });
    }
  }

  void onResetPressed() {
    ref
        .read(workoutProcessProvider(widget.workoutScheduleId).notifier)
        .resetTimer(widget.setInfoIndex);
    if (mounted) {
      setState(() {
        count = 4;
        totalSeconds = widget.secondsGoal;
        valueNotifier.value = 0.0;
      });
    }
  }

  void onStopPressed() {
    if (mounted) {
      setState(() {
        count = 4;
        timer.cancel();
        isRunning = false;
        isReady = false;
        valueNotifier.value =
            (widget.secondsGoal - totalSeconds) / widget.secondsGoal;
      });
    }
  }

  void onTick(Timer timer) {
    if (count > 0) {
      if (mounted) {
        setState(() {
          count--;
          // isReady = true;
          valueNotifier.value = (4 - count).toDouble() / 4.toDouble();
        });
      }
    } else {
      if (totalSeconds == 0) {
        //0초가 됬을때 저장
        timer.cancel();
        valueNotifier.value = (widget.secondsGoal - totalSeconds).toDouble() /
            widget.secondsGoal.toDouble();
        if (mounted) {
          setState(() {
            isRunning = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isReady = false;
            valueNotifier.value =
                (widget.secondsGoal - totalSeconds).toDouble() /
                    widget.secondsGoal.toDouble();
            totalSeconds -= 1;
          });
        }

        ref
            .read(workoutProcessProvider(widget.workoutScheduleId).notifier)
            .modifiedSecondsRecord(
                widget.secondsGoal - totalSeconds, widget.setInfoIndex);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (isBackground) {
          resumedTime = DateTime.now();

          if (totalSeconds <= resumedTime.difference(pausedTime).inSeconds) {
            if (mounted) {
              setState(() {
                totalSeconds = 0;
                timer.cancel();
                isRunning = false;
                isBackground = false;
                valueNotifier.value = 1;
              });
            }

            ref
                .read(workoutProcessProvider(widget.workoutScheduleId).notifier)
                .modifiedSecondsRecord(widget.secondsGoal, widget.setInfoIndex);
          } else {
            if (mounted) {
              setState(() {
                totalSeconds -= resumedTime.difference(pausedTime).inSeconds;
                isBackground = false;
                isRunning = true;

                timer = Timer.periodic(
                  const Duration(seconds: 1),
                  onTick,
                );
              });
            }
          }

          if (mounted) {
            setState(() {});
          }
        }

        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        if (isRunning) {
          pausedTime = DateTime.now();
          isBackground = true;

          timer.cancel();
          isRunning = false;
        }

        break;
      case AppLifecycleState.detached:
        // debugPrint("app in detached");
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void dispose() {
    valueNotifier.dispose();
    WidgetsBinding.instance.removeObserver(this);

    if (timer.isActive) {
      timer.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutProcessModel =
        ref.watch(workoutProcessProvider(widget.workoutScheduleId))
            as WorkoutProcessModel;

    if (workoutProcessModel.isQuitting) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Pallete.point,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          widget.model.exercises[widget.model.exerciseIndex].name,
          style: h4Headline.copyWith(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 7.h,
            ),
            Text(
              '${widget.setInfoIndex + 1} SET',
              style: h2Headline,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              DataUtils.getTimerStringMinuteSeconds(widget
                  .model
                  .modifiedExercises[widget.model.exerciseIndex]
                  .setInfo[widget.setInfoIndex]
                  .seconds!),
              style: s1SubTitle.copyWith(
                color: Pallete.gray,
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Stack(
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: Center(
                    child: Text(
                      count < 4 && count > 0 && isRunning && isReady
                          ? '$count'
                          : count == 0 && isRunning && isReady
                              ? 'Go!'
                              : DataUtils.getTimeStringMinutes(totalSeconds),
                      style: h1Headline.copyWith(fontSize: 40),
                    ),
                  ),
                ),
                SimpleCircularProgressBar(
                  animationDuration: 0,
                  size: 220,
                  backColor: Pallete.point.withOpacity(0.1),
                  backStrokeWidth: 20,
                  progressStrokeWidth: 20,
                  progressColors: [
                    Pallete.point,
                    Pallete.point.withOpacity(0.3)
                  ],
                  valueNotifier: valueNotifier,
                  maxValue: 1,
                ),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shadowColor: Colors.transparent),
                      onPressed: () => isReady
                          ? onStopPressed()
                          : isRunning
                              ? onPausePressed()
                              : totalSeconds == 0
                                  ? onResetPressed()
                                  : onStartPressed(),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Pallete.point.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: SvgPicture.asset(isReady
                              ? SVGConstants.stop
                              : isRunning
                                  ? SVGConstants.pause
                                  : totalSeconds == 0
                                      ? SVGConstants.reset
                                      : SVGConstants.play),
                        ),
                      ),
                    ),
                    Text(
                      isReady
                          ? 'Stop'
                          : isRunning
                              ? 'Pause'
                              : totalSeconds == 0
                                  ? 'Reset'
                                  : 'start',
                      style: s2SubTitle,
                    ),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shadowColor: Colors.transparent),
                      onPressed: () {
                        widget.refresh();
                        context.pop();
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Pallete.point.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: SvgPicture.asset(SVGConstants.exit),
                        ),
                      ),
                    ),
                    Text(
                      'Exit',
                      style: s2SubTitle,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 5.h,
            ),
            if (totalSeconds == 0 && !workoutProcessModel.isQuitting)
              TextButton(
                onPressed: workoutProcessModel.isQuitting
                    ? null
                    : () {
                        // context.pop();

                        ref
                            .read(
                                workoutProcessProvider(widget.workoutScheduleId)
                                    .notifier)
                            .nextWorkout()
                            .then(
                          (value) async {
                            if (value != null) {
                              if (value == -1) {
                                final workoutModel = ref.read(workoutProvider(
                                    widget.workoutScheduleId)) as WorkoutModel;

                                ref
                                    .read(workoutProcessProvider(
                                            workoutModel.workoutScheduleId)
                                        .notifier)
                                    .workoutIsQuttingChange(true);

                                if (mounted) {
                                  setState(() {});
                                }

                                await ref
                                    .read(workoutProcessProvider(
                                            workoutModel.workoutScheduleId)
                                        .notifier)
                                    .quitWorkout(
                                      title: workoutModel.workoutTitle,
                                      subTitle: workoutModel.workoutSubTitle,
                                      trainerId: workoutModel.trainerId,
                                    )
                                    .then((_) {
                                  final id = workoutModel.workoutScheduleId;
                                  final date = workoutModel.startDate;
                                  context.pop(); //timerScreen pop
                                  context.pop(); //workoutScreen pop

                                  GoRouter.of(context).pushNamed(
                                    WorkoutFeedbackScreen.routeName,
                                    pathParameters: {
                                      'workoutScheduleId': id.toString(),
                                    },
                                    extra: workoutModel.exercises,
                                    queryParameters: {
                                      'startDate': DateFormat('yyyy-MM-dd')
                                          .format(DateTime.parse(date)),
                                    },
                                  );
                                });
                              } else {
                                final workoutModel = ref.read(workoutProvider(
                                    widget.workoutScheduleId)) as WorkoutModel;

                                _showUncompleteExerciseDialog(
                                  context,
                                  value,
                                  workoutModel,
                                  workoutProcessModel.isQuitting,
                                );
                              }
                            } else {
                              context.pop(); //timerScreen pop
                            }
                          },
                        );
                      },
                child: workoutProcessModel.isQuitting
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          color: Pallete.point,
                        ),
                      )
                    : Text(
                        '다음 운동',
                        style: h5Headline.copyWith(
                          color: Pallete.point,
                        ),
                      ),
              )
          ],
        ),
      ),
    );
  }

  Future<dynamic> _showUncompleteExerciseDialog(
    BuildContext context,
    int index,
    WorkoutModel model,
    bool isQuitting,
  ) {
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
          cancelOnTap: isQuitting
              ? () {}
              : () async {
                  //완료!!!
                  try {
                    await ref
                        .read(workoutProcessProvider(widget.workoutScheduleId)
                            .notifier)
                        .quitWorkout(
                          title: model.workoutTitle,
                          subTitle: model.workoutSubTitle,
                          trainerId: model.trainerId,
                        )
                        .then((value) {
                      final id = widget.workoutScheduleId;
                      final date = model.startDate;

                      context.pop();
                      context.pop();

                      GoRouter.of(context).goNamed(
                        WorkoutFeedbackScreen.routeName,
                        pathParameters: {
                          'workoutScheduleId': id.toString(),
                        },
                        extra: model.exercises,
                        queryParameters: {
                          'startDate': DateFormat('yyyy-MM-dd')
                              .format(DateTime.parse(date)),
                        },
                      );
                    });
                  } on DioException catch (e) {
                    debugPrint('$e');
                  }
                },
        );
      },
    );
  }
}
