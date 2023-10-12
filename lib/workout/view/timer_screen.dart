import 'dart:async';

import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/workout/model/workout_process_model.dart';
import 'package:fitend_member/workout/provider/workout_process_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
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
    setState(() {
      isReady = true;
      isRunning = true;
    });
  }

  void onPausePressed() {
    timer.cancel();
    setState(() {
      isRunning = false;
      // count = 4;
    });
  }

  void onResetPressed() {
    ref
        .read(workoutProcessProvider(widget.workoutScheduleId).notifier)
        .resetTimer(widget.setInfoIndex);

    setState(() {
      count = 4;
      totalSeconds = widget.secondsGoal;
      valueNotifier.value = 0.0;
    });
  }

  void onStopPressed() {
    setState(() {
      count = 4;
      timer.cancel();
      isRunning = false;
      isReady = false;
      valueNotifier.value =
          (widget.secondsGoal - totalSeconds) / widget.secondsGoal;
    });
  }

  void onTick(Timer timer) {
    if (count > 0) {
      setState(() {
        count--;
        // isReady = true;
        valueNotifier.value = (4 - count).toDouble() / 4.toDouble();
      });
    } else {
      if (totalSeconds == 0) {
        //0초가 됬을때 저장
        timer.cancel();
        valueNotifier.value = (widget.secondsGoal - totalSeconds).toDouble() /
            widget.secondsGoal.toDouble();
        setState(() {
          isRunning = false;
        });
      } else {
        setState(() {
          isReady = false;
          valueNotifier.value = (widget.secondsGoal - totalSeconds).toDouble() /
              widget.secondsGoal.toDouble();
          totalSeconds -= 1;
        });

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
            setState(() {
              totalSeconds = 0;
              timer.cancel();
              isRunning = false;
              isBackground = false;
              valueNotifier.value = 1;
            });

            ref
                .read(workoutProcessProvider(widget.workoutScheduleId).notifier)
                .modifiedSecondsRecord(widget.secondsGoal, widget.setInfoIndex);
          } else {
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

          setState(() {});
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
                color: GRAY_COLOR,
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
                  backColor: POINT_COLOR.withOpacity(0.1),
                  backStrokeWidth: 20,
                  progressStrokeWidth: 20,
                  progressColors: [POINT_COLOR, POINT_COLOR.withOpacity(0.3)],
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
                          color: POINT_COLOR.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: SvgPicture.asset(isReady
                              ? 'asset/img/icon_stop.svg'
                              : isRunning
                                  ? 'asset/img/icon_pause.svg'
                                  : totalSeconds == 0
                                      ? 'asset/img/icon_reset.svg'
                                      : 'asset/img/icon_play.svg'),
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
                          color: POINT_COLOR.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: SvgPicture.asset('asset/img/icon_exit.svg'),
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
            if (totalSeconds == 0)
              TextButton(
                onPressed: () {
                  context.pop();

                  ref
                      .read(workoutProcessProvider(widget.workoutScheduleId)
                          .notifier)
                      .nextWorkout();
                },
                child: Text(
                  '다음 운동',
                  style: h5Headline.copyWith(
                    color: POINT_COLOR,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
