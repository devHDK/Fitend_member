import 'dart:async';

import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/provider/hive_timer_x_more_%20record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/setInfo_model.dart';
import 'package:fitend_member/workout/model/workout_record_model.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TimerXMoreProgressCard extends ConsumerStatefulWidget {
  final Exercise exercise;
  final int setInfoIndex;
  final TextEditingController minController;
  final TextEditingController secController;
  final GestureTapCallback updateSeinfoTap;
  final GestureTapCallback proccessOnTap;
  final GestureTapCallback resetSet;

  const TimerXMoreProgressCard({
    super.key,
    required this.exercise,
    required this.setInfoIndex,
    required this.updateSeinfoTap,
    required this.proccessOnTap,
    required this.resetSet,
    required this.minController,
    required this.secController,
  });

  @override
  ConsumerState<TimerXMoreProgressCard> createState() =>
      _WeightWrepsProgressCardState();
}

class _WeightWrepsProgressCardState
    extends ConsumerState<TimerXMoreProgressCard> {
  bool colorChanged = false;

  Timer? timer;
  late int totalSeconds = -1;
  bool initial = true;
  bool isRunning = false;
  int count = 0;

  late AsyncValue<Box> workoutBox;
  late AsyncValue<Box> timerXmoreBox;

  void minControllerListener() {}
  void secControllerListener() {}

  @override
  void initState() {
    super.initState();

    widget.minController.addListener(minControllerListener);
    widget.secController.addListener(secControllerListener);

    WidgetsBinding.instance.addPersistentFrameCallback(
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
          print('totalSeconds : $totalSeconds');

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
    if (timer!.isActive) {
      timer!.cancel();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TimerXMoreProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.setInfoIndex != widget.setInfoIndex) {
      if (timer!.isActive) {
        timer!.cancel();
        isRunning = false;
        count = 0;
      }

      setState(() {
        totalSeconds = widget.exercise.setInfo[widget.setInfoIndex].seconds!;
      });
      print('totalSeconds : $totalSeconds');
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
              isRunning = false;
              count = 11;
              totalSeconds = 0;
            });

            if (timer!.isActive) {
              timer!.cancel();
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
    timer!.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void onStopPressed() {
    // timer.cancel();

    timerXmoreBox.whenData(
      (value) {
        var record = value.get(widget.exercise.workoutPlanId);

        if (record is WorkoutRecordModel) {
          record.setInfo.removeLast();

          value.put(widget.exercise.workoutPlanId, record);
        }
      },
    );

    // workoutBox.whenData((value) {
    //   value.delete(widget.exercise.workoutPlanId);
    // });

    // widget.resetSet();

    setState(() {
      totalSeconds = widget.exercise.setInfo[widget.setInfoIndex].seconds!;
      count = 0;
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
            print('timerXmoreBox 처음 저장!');
            print(totalSeconds);
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
                width:
                    ((size.width - 152) / widget.exercise.setInfo.length) - 1,
                height: 4,
                color: colorChanged ? LIGHT_GRAY_COLOR : POINT_COLOR,
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
                width:
                    ((size.width - 152) / widget.exercise.setInfo.length) - 1,
                color: LIGHT_GRAY_COLOR,
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
                width:
                    ((size.width - 152) / widget.exercise.setInfo.length) - 1,
                height: 4,
                decoration: const BoxDecoration(
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

    return Column(
      children: [
        Text(
          '${(widget.exercise.setInfo[widget.setInfoIndex].seconds! / 60).floor()}분 ${widget.exercise.setInfo[widget.setInfoIndex].seconds! % 60}초',
          style: const TextStyle(
            color: GRAY_COLOR,
            fontSize: 16,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          widget.exercise.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
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
              color: totalSeconds ==
                          widget
                              .exercise.setInfo[widget.setInfoIndex].seconds! ||
                      totalSeconds < 0
                  ? POINT_COLOR
                  : Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                isRunning
                    ? Image.asset('asset/img/icon_pause_small.png')
                    : totalSeconds > 0 &&
                            totalSeconds <
                                widget.exercise.setInfo[widget.setInfoIndex]
                                    .seconds!
                        ? Image.asset('asset/img/icon_replay_small.png')
                        : totalSeconds == 0
                            ? Image.asset('asset/img/icon_reset_small.png')
                            : Image.asset('asset/img/icon_play_small.png'),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  totalSeconds ==
                              widget.exercise.setInfo[widget.setInfoIndex]
                                  .seconds! ||
                          totalSeconds < 0
                      ? '운동 시작'
                      : '${(totalSeconds / 60).floor().toString().padLeft(2, '0')} : ${(totalSeconds % 60).toString().padLeft(2, '0')} ',
                  style: TextStyle(
                    color: totalSeconds ==
                                widget.exercise.setInfo[widget.setInfoIndex]
                                    .seconds! ||
                            totalSeconds < 0
                        ? Colors.white
                        : POINT_COLOR,
                    fontSize: 14,
                    fontWeight: totalSeconds ==
                                widget.exercise.setInfo[widget.setInfoIndex]
                                    .seconds! ||
                            totalSeconds < 0
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            InkWell(
              onTap: isRunning
                  ? null
                  : () {
                      widget.updateSeinfoTap();
                    },
              child: Image.asset(
                'asset/img/icon_edit.png',
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: progressList,
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            InkWell(
              // 운동 진행
              onTap: count < 10
                  ? () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => DialogWidgets.errorDialog(
                          message: '먼저 운동을 진행해 주세요 🏋🏻',
                          confirmText: '확인',
                          confirmOnTap: () => context.pop(),
                        ),
                      );
                    }
                  : widget.proccessOnTap,
              child: Image.asset(
                'asset/img/icon_foward.png',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
