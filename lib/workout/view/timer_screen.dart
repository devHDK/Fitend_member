import 'dart:async';

import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/workout/model/workout_process_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({
    super.key,
    required this.model,
    required this.setInfoIndex,
    required this.secondsGoal,
    required this.secondsRecord,
  });

  final WorkoutProcessModel model;
  final int setInfoIndex;
  final int secondsGoal;
  final int secondsRecord;

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  late ValueNotifier<double> valueNotifier;
  late int totalSeconds;
  late Timer timer;
  bool isRunning = false;
  bool isReady = false;
  int count = 4;

  @override
  void initState() {
    super.initState();
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
      count = 4;
    });
  }

  void onResetPressed() {
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
        setState(() {
          isRunning = false;
        });
        timer.cancel();
      } else {
        setState(() {
          isReady = false;
          totalSeconds -= 1;
          valueNotifier.value = (widget.secondsGoal - totalSeconds).toDouble() /
              widget.secondsGoal.toDouble();
        });
      }
    }
  }

  @override
  void dispose() {
    valueNotifier.dispose();
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
            const SizedBox(
              height: 55,
            ),
            Text(
              '${widget.setInfoIndex + 1} SET',
              style: h2Headline,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              '${(widget.model.modifiedExercises[widget.model.exerciseIndex].setInfo[widget.setInfoIndex].seconds! / 60).floor()} 분 ${(widget.model.modifiedExercises[widget.model.exerciseIndex].setInfo[widget.setInfoIndex].seconds! % 60).toString().padLeft(2, '0')} 초',
              style: s1SubTitle.copyWith(
                color: GRAY_COLOR,
              ),
            ),
            const SizedBox(
              height: 100,
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
                              : '${(totalSeconds / 60).floor().toString().padLeft(2, '0')} : ${(totalSeconds % 60).toString().padLeft(2, '0')}',
                      style: h1Headline.copyWith(fontSize: 40),
                    ),
                  ),
                ),
                SimpleCircularProgressBar(
                  animationDuration: 1,
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
            const SizedBox(
              height: 100,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    TextButton(
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
                                  : 'play',
                      style: s2SubTitle,
                    ),
                  ],
                ),
                Column(
                  children: [
                    TextButton(
                      onPressed: () {
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
          ],
        ),
      ),
    );
  }
}
