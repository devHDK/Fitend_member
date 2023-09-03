import 'dart:async';

import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/muscle_group.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/provider/hive_timer_x_more_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:fitend_member/workout/model/workout_record_model.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TimerXMoreProgressCard extends ConsumerStatefulWidget {
  final Exercise exercise;
  final int setInfoIndex;
  final bool isSwipeUp;
  final GestureTapCallback updateSeinfoTap;
  final GestureTapCallback proccessOnTap;
  final GestureTapCallback resetSet;

  const TimerXMoreProgressCard({
    super.key,
    required this.exercise,
    required this.setInfoIndex,
    required this.isSwipeUp,
    required this.updateSeinfoTap,
    required this.proccessOnTap,
    required this.resetSet,
  });

  @override
  ConsumerState<TimerXMoreProgressCard> createState() =>
      _WeightWrepsProgressCardState();
}

class _WeightWrepsProgressCardState
    extends ConsumerState<TimerXMoreProgressCard> with WidgetsBindingObserver {
  bool colorChanged = false;

  late Timer timer;
  late int totalSeconds = -1;
  bool initial = true;

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

  late AsyncValue<Box> workoutBox;
  late AsyncValue<Box> timerXmoreBox;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (initial) {
          timerXmoreBox.whenData((value) async {
            final record = await value.get(widget.exercise.workoutPlanId);

            if (record != null && record is WorkoutRecordModel) {
              if (record.setInfo.length > widget.setInfoIndex) {
                setState(() {
                  totalSeconds =
                      widget.exercise.setInfo[widget.setInfoIndex].seconds! -
                          record.setInfo[widget.setInfoIndex].seconds!;
                });
              } else {
                setState(() {
                  totalSeconds =
                      widget.exercise.setInfo[widget.setInfoIndex].seconds!;
                });
              }
            } else {
              setState(() {
                totalSeconds =
                    widget.exercise.setInfo[widget.setInfoIndex].seconds!;
              });
            }
          });
          // print('totalSeconds : $totalSeconds');

          initial = false;
        }
      },
    );

    Timer.periodic(
      const Duration(milliseconds: 1000),
      (timer) {
        setState(() {
          colorChanged = !colorChanged;
        });
      },
    );
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
          debugPrint(
              "time substraction ${resumedTime.difference(pausedTime).inSeconds}");

          if (totalSeconds <= resumedTime.difference(pausedTime).inSeconds) {
            setState(() {
              totalSeconds = 0;
              timer.cancel();
              // isRunning = false;
              isBackground = false;
            });

            timerXmoreBox.whenData(
              (value) {
                var record = value.get(widget.exercise.workoutPlanId);

                if (record is WorkoutRecordModel) {
                  record.setInfo.removeLast();
                  record.setInfo.add(
                    SetInfo(
                      index: record.setInfo.length + 1,
                      seconds: widget
                          .exercise.setInfo[record.setInfo.length].seconds,
                    ),
                  );

                  value.put(widget.exercise.workoutPlanId, record);
                }
              },
            );
          } else {
            setState(() {
              totalSeconds -= resumedTime.difference(pausedTime).inSeconds;
              isBackground = false;
            });
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
        // if (isRunning) {
        //   pausedTime = DateTime.now();
        //   isBackground = true;

        //   timer.cancel();
        //   isRunning = false;
        // }

        break;
      case AppLifecycleState.detached:
        // print("app in detached");
        break;
    }
  }

  @override
  void didUpdateWidget(covariant TimerXMoreProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.setInfoIndex != widget.setInfoIndex) {
      if (timer.isActive) {
        timer.cancel();
        // isRunning = false;
        count = 0;
      }

      setState(() {
        totalSeconds = widget.exercise.setInfo[widget.setInfoIndex].seconds!;
      });
      // print('totalSeconds : $totalSeconds');
    }

    timerXmoreBox.whenData((value) async {
      final record = await value.get(widget.exercise.workoutPlanId);

      if (record != null && record is WorkoutRecordModel) {
        if (record.setInfo.length > widget.setInfoIndex) {
          if (record.setInfo[widget.setInfoIndex].seconds! <
              widget.exercise.setInfo[widget.setInfoIndex].seconds!) {
            setState(() {
              totalSeconds =
                  widget.exercise.setInfo[widget.setInfoIndex].seconds! -
                      record.setInfo[widget.setInfoIndex].seconds!;
            });
          } else {
            setState(() {
              // isRunning = false;
              count = 11;
              totalSeconds = 0;
            });

            if (timer.isActive) {
              timer.cancel();
            }

            record.setInfo[widget.setInfoIndex] =
                record.setInfo[widget.setInfoIndex].copyWith(
              seconds: widget.exercise.setInfo[widget.setInfoIndex].seconds!,
            );
            value.put(
              widget.exercise.workoutPlanId,
              WorkoutRecordModel(
                workoutPlanId: widget.exercise.workoutPlanId,
                setInfo: [
                  ...record.setInfo,
                ],
              ),
            );
          }
        } else {
          setState(() {
            totalSeconds =
                widget.exercise.setInfo[widget.setInfoIndex].seconds!;
          });
        }
      } else {
        setState(() {
          totalSeconds = widget.exercise.setInfo[widget.setInfoIndex].seconds!;
        });
      }
    });
  }

  void onTick(Timer timer) {
    if (totalSeconds == 0) {
      //0초가 됬을때 저장
      setState(() {
        // isRunning = false;
        count = 11;
      });
      timer.cancel();
    } else {
      setState(() {
        totalSeconds -= 1;
        count++;
      });

      timerXmoreBox.whenData(
        (value) {
          final record = value.get(widget.exercise.workoutPlanId);

          if (record != null &&
              widget.setInfoIndex < record.setInfo.length &&
              record is WorkoutRecordModel) {
            record.setInfo[widget.setInfoIndex] =
                record.setInfo[widget.setInfoIndex].copyWith(
              seconds: widget.exercise.setInfo[widget.setInfoIndex].seconds! -
                  totalSeconds,
            );
            value.put(
              widget.exercise.workoutPlanId,
              WorkoutRecordModel(
                workoutPlanId: widget.exercise.workoutPlanId,
                setInfo: [
                  ...record.setInfo,
                ],
              ),
            );
          } else if (record != null &&
              record is WorkoutRecordModel &&
              widget.setInfoIndex == record.setInfo.length) {
            value.put(
              widget.exercise.workoutPlanId,
              WorkoutRecordModel(
                  workoutPlanId: widget.exercise.workoutPlanId,
                  setInfo: [
                    ...record.setInfo,
                    SetInfo(
                      index: record.setInfo.length + 1,
                      seconds: 1,
                    ),
                  ]),
            );
          } else {
            // print('timerXmoreBox 처음 저장!');
            // print(totalSeconds);
            value.put(
              widget.exercise.workoutPlanId,
              WorkoutRecordModel(
                workoutPlanId: widget.exercise.workoutPlanId,
                setInfo: [
                  SetInfo(
                    index: 1,
                    seconds:
                        widget.exercise.setInfo[widget.setInfoIndex].seconds! -
                            totalSeconds,
                  )
                ],
              ),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final AsyncValue<Box> workoutRecordBox =
        ref.watch(hiveWorkoutRecordProvider);
    final AsyncValue<Box> timerXMoreRecordBox =
        ref.watch(hiveTimerXMoreRecordProvider);

    workoutBox = workoutRecordBox;
    timerXmoreBox = timerXMoreRecordBox;

    List<Widget> progressList = widget.exercise.setInfo.mapIndexed(
      (index, element) {
        if (index == widget.setInfoIndex) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                decoration: BoxDecoration(
                  borderRadius: index == 0
                      ? const BorderRadius.only(
                          bottomLeft: Radius.circular(2),
                          topLeft: Radius.circular(2))
                      : index == widget.exercise.setInfo.length - 1
                          ? const BorderRadius.only(
                              bottomRight: Radius.circular(2),
                              topRight: Radius.circular(2),
                            )
                          : null,
                  color: colorChanged ? LIGHT_GRAY_COLOR : POINT_COLOR,
                ),
                width: widget.isSwipeUp
                    ? ((size.width - 56) / widget.exercise.setInfo.length) - 1
                    : ((size.width - 152) / widget.exercise.setInfo.length) - 1,
                height: 4,
                duration: const Duration(microseconds: 1000),
                curve: Curves.linear,
              ),
              const SizedBox(
                width: 1,
              )
            ],
          );
        } else if (index > widget.setInfoIndex) {
          return Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: index == 0
                      ? const BorderRadius.only(
                          bottomLeft: Radius.circular(2),
                          topLeft: Radius.circular(2))
                      : index == widget.exercise.setInfo.length - 1
                          ? const BorderRadius.only(
                              bottomRight: Radius.circular(2),
                              topRight: Radius.circular(2),
                            )
                          : null,
                  color: LIGHT_GRAY_COLOR,
                ),
                width: widget.isSwipeUp
                    ? ((size.width - 56) / widget.exercise.setInfo.length) - 1
                    : ((size.width - 152) / widget.exercise.setInfo.length) - 1,
                height: 4,
              ),
              const SizedBox(
                width: 1,
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Container(
                width: widget.isSwipeUp
                    ? ((size.width - 56) / widget.exercise.setInfo.length) - 1
                    : ((size.width - 152) / widget.exercise.setInfo.length) - 1,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: index == 0
                      ? const BorderRadius.only(
                          bottomLeft: Radius.circular(2),
                          topLeft: Radius.circular(2))
                      : index == widget.exercise.setInfo.length - 1
                          ? const BorderRadius.only(
                              bottomRight: Radius.circular(2),
                              topRight: Radius.circular(2),
                            )
                          : null,
                  color: POINT_COLOR,
                ),
              ),
              const SizedBox(
                width: 1,
              )
            ],
          );
        }
      },
    ).toList();

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
                (widget.exercise.setInfo[widget.setInfoIndex].seconds! / 60)
                                .floor() >
                            0 &&
                        (widget.exercise.setInfo[widget.setInfoIndex].seconds! %
                                60) >
                            0
                    ? '${(widget.exercise.setInfo[widget.setInfoIndex].seconds! / 60).floor()}분 ${(widget.exercise.setInfo[widget.setInfoIndex].seconds! % 60).toString().padLeft(2, '0')}초'
                    : (widget.exercise.setInfo[widget.setInfoIndex].seconds! /
                                        60)
                                    .floor() >
                                0 &&
                            (widget.exercise.setInfo[widget.setInfoIndex]
                                        .seconds! %
                                    60) ==
                                0
                        ? '${(widget.exercise.setInfo[widget.setInfoIndex].seconds! / 60).floor()}분'
                        : '${(widget.exercise.setInfo[widget.setInfoIndex].seconds! % 60).toString().padLeft(2, '0')}초',
                style: s1SubTitle.copyWith(
                  color: GRAY_COLOR,
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
              Container(
                width: 100,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(color: POINT_COLOR),
                  borderRadius: BorderRadius.circular(12),
                  color: POINT_COLOR,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 8,
                    ),
                    Center(
                      child: Text(
                        '타이머',
                        style: s1SubTitle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: progressList,
              ),
            ),
            if (!widget.isSwipeUp)
              InkWell(
                // 운동 진행
                onTap: widget.proccessOnTap,
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
