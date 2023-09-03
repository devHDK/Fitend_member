import 'dart:async';

import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/muscle_group.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/provider/hive_timer_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TimerXOneProgressCard extends ConsumerStatefulWidget {
  final Exercise exercise;
  final int setInfoIndex;
  final bool isSwipeUp;
  final GestureTapCallback updateSeinfoTap;
  final GestureTapCallback proccessOnTap;

  const TimerXOneProgressCard({
    super.key,
    required this.exercise,
    required this.isSwipeUp,
    required this.proccessOnTap,
    required this.setInfoIndex,
    required this.updateSeinfoTap,
  });

  @override
  ConsumerState<TimerXOneProgressCard> createState() =>
      _TimerXOneProgressCardState();
}

class _TimerXOneProgressCardState extends ConsumerState<TimerXOneProgressCard>
    with WidgetsBindingObserver {
  late Timer timer;
  late int totalSeconds = -1;
  bool initial = true;
  bool isRunning = false;
  int count = 0;

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

  bool isBackground = false;

  late AsyncValue<Box> timerBox;
  late AsyncValue<Box> workoutBox;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (initial) {
        timerBox.whenData((value) async {
          final record = await value.get(widget.exercise.workoutPlanId);

          if (record != null && record is SetInfo && widget.setInfoIndex == 0) {
            setState(() {
              totalSeconds =
                  widget.exercise.setInfo[0].seconds! - record.seconds!;
            });
          } else {
            setState(() {
              totalSeconds = widget.exercise.setInfo[0].seconds!;
            });
          }
        });
        // print('totalSeconds : $totalSeconds');
        initial = false;
      }
    });
  }

  @override
  void dispose() {
    if (timer.isActive) {
      timer.cancel();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (isBackground) {
          resumedTime = DateTime.now();
          print(
              "time substraction  ${resumedTime.difference(pausedTime).inSeconds}");

          if (totalSeconds <= resumedTime.difference(pausedTime).inSeconds) {
            setState(() {
              totalSeconds = 0;
              timer.cancel();
              isRunning = false;
              isBackground = false;
            });

            timerBox.whenData((value) {
              value.put(
                widget.exercise.workoutPlanId,
                SetInfo(
                  index: 1,
                  seconds: widget.exercise.setInfo[0].seconds!,
                ),
              );
            });
          } else {
            setState(() {
              totalSeconds -= resumedTime.difference(pausedTime).inSeconds;
              isBackground = false;
            });

            onStartPressed();
          }

          if (count + resumedTime.difference(pausedTime).inSeconds >= 11) {
            count = 11;
          } else {
            count += resumedTime.difference(pausedTime).inSeconds;
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
        // print("app in detached");
        break;
    }
  }

  void onStartPressed() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      onTick,
    );
    setState(() {
      isRunning = true;
    });
  }

  void onPausePressed() {
    timer.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void onStopPressed() {
    // timer.cancel();

    timerBox.whenData(
      (value) {
        value.delete(widget.exercise.workoutPlanId);
      },
    );

    workoutBox.whenData((value) {
      value.delete(widget.exercise.workoutPlanId);
    });

    setState(() {
      count = 0;
      totalSeconds = widget.exercise.setInfo[0].seconds!;
    });
  }

  @override
  void didUpdateWidget(covariant TimerXOneProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    timerBox.whenData((value) {
      final record = value.get(widget.exercise.workoutPlanId);
      if (record != null && record is SetInfo && widget.setInfoIndex == 0) {
        if (record.seconds! < widget.exercise.setInfo[0].seconds!) {
          setState(() {
            totalSeconds =
                widget.exercise.setInfo[0].seconds! - record.seconds!;
          });
        } else if (record.seconds! >= widget.exercise.setInfo[0].seconds!) {
          setState(() {
            totalSeconds = 0;
            isRunning = false;
            count = 11;
          });

          timer.cancel();

          timerBox.whenData((value) {
            value.put(
              widget.exercise.workoutPlanId,
              SetInfo(
                index: 1,
                seconds: widget.exercise.setInfo[0].seconds!,
              ),
            );
          });
        }
      } else {
        setState(() {
          totalSeconds = widget.exercise.setInfo[0].seconds!;
        });
      }
    });
  }

  void onTick(Timer timer) {
    if (totalSeconds == 0) {
      //0초가 됬을때 저장
      setState(() {
        isRunning = false;
        count = 11;
      });
      timer.cancel();
    } else {
      setState(() {
        totalSeconds -= 1;
        count++;
      });
      timerBox.whenData((value) async {
        await value.put(
          widget.exercise.workoutPlanId,
          SetInfo(
              index: 1,
              seconds: widget.exercise.setInfo[0].seconds! - totalSeconds),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Box> workoutRecordBox =
        ref.watch(hiveWorkoutRecordProvider);
    final AsyncValue<Box> timerWorkoutBox = ref.watch(hiveTimerRecordProvider);

    timerBox = timerWorkoutBox;
    workoutBox = workoutRecordBox;

    Set targetMuscles = {};
    String muscleString = '';

    for (var targetMuscle in widget.exercise.targetMuscles) {
      if (targetMuscle.type == 'main') {
        targetMuscles.add(targetMuscle.muscleType);
      }
    }

    for (var muscle in targetMuscles) {
      muscleString += ' ${muscleGroup[muscle]!} ∙';
    }

    return Column(
      crossAxisAlignment: !widget.isSwipeUp
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (!widget.isSwipeUp)
          Column(
            children: [
              Text(
                (widget.exercise.setInfo[0].seconds! / 60).floor() > 0 &&
                        (widget.exercise.setInfo[0].seconds! % 60) > 0
                    ? '${(widget.exercise.setInfo[0].seconds! / 60).floor()}분 ${(widget.exercise.setInfo[0].seconds! % 60).toString().padLeft(2, '0')}초'
                    : (widget.exercise.setInfo[0].seconds! / 60).floor() > 0 &&
                            (widget.exercise.setInfo[0].seconds! % 60) == 0
                        ? '${(widget.exercise.setInfo[0].seconds! / 60).floor()}분'
                        : '${(widget.exercise.setInfo[0].seconds! % 60).toString().padLeft(2, '0')}초',
                style: s1SubTitle.copyWith(
                  color: GRAY_COLOR,
                  height: 1.2,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                widget.exercise.name,
                style: h3Headline.copyWith(
                  color: Colors.black,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: isRunning
                    ? () => onPausePressed()
                    : totalSeconds == 0
                        ? () => onStopPressed()
                        : () => onStartPressed(),
                child: Container(
                  width: 100,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(color: POINT_COLOR),
                    borderRadius: BorderRadius.circular(12),
                    color:
                        totalSeconds == widget.exercise.setInfo[0].seconds! &&
                                !isRunning
                            ? POINT_COLOR
                            : Colors.white,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      isRunning
                          ? SvgPicture.asset('asset/img/icon_pause_small.svg')
                          : totalSeconds > 0 &&
                                  totalSeconds <
                                      widget.exercise.setInfo[0].seconds!
                              ? SvgPicture.asset(
                                  'asset/img/icon_replay_small.svg')
                              : totalSeconds == 0
                                  ? SvgPicture.asset(
                                      'asset/img/icon_reset_small.svg')
                                  : SvgPicture.asset(
                                      'asset/img/icon_play_small.svg'),
                      const SizedBox(
                        width: 8,
                      ),
                      Center(
                        child: Text(
                          (totalSeconds ==
                                          widget.exercise.setInfo[0].seconds! ||
                                      totalSeconds < 0) &&
                                  !isRunning
                              ? '운동 시작'
                              : '${(totalSeconds / 60).floor().toString().padLeft(2, '0')} : ${(totalSeconds % 60).toString().padLeft(2, '0')} ',
                          style: s2SubTitle.copyWith(
                            color: totalSeconds ==
                                        widget.exercise.setInfo[0].seconds! &&
                                    !isRunning
                                ? Colors.white
                                : POINT_COLOR,
                            fontWeight: totalSeconds ==
                                        widget.exercise.setInfo[0].seconds! &&
                                    !isRunning
                                ? FontWeight.w700
                                : FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                muscleString.substring(0, muscleString.length - 1),
                style: s2SubTitle.copyWith(color: GRAY_COLOR),
              ),
              Text(
                widget.exercise.name,
                style: h1Headline,
              ),
            ],
          ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            if (!widget.isSwipeUp)
              InkWell(
                onTap: () {
                  widget.updateSeinfoTap();
                },
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'asset/img/icon_edit.svg',
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Row(mainAxisSize: MainAxisSize.max, children: [
                SizedBox(
                  width: !widget.isSwipeUp
                      ? MediaQuery.sizeOf(context).width - 152
                      : MediaQuery.sizeOf(context).width - 56,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: LinearProgressIndicator(
                        value: (widget.exercise.setInfo[0].seconds! -
                                totalSeconds) /
                            widget.exercise.setInfo[0].seconds!,
                        backgroundColor: LIGHT_GRAY_COLOR,
                        valueColor: const AlwaysStoppedAnimation(POINT_COLOR),
                      ),
                    ),
                  ),
                )
              ]),
            ),
            if (!widget.isSwipeUp)
              InkWell(
                // 운동 진행
                onTap: () {
                  if (timer.isActive) {
                    timer.cancel();
                    setState(() {
                      isRunning = false;
                    });
                  }

                  widget.proccessOnTap();
                },
                child: Row(
                  children: [
                    const SizedBox(
                      width: 12,
                    ),
                    SvgPicture.asset(
                      'asset/img/icon_forward.svg',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
