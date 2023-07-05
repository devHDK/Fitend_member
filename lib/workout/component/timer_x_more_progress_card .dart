import 'dart:async';

import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
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

  @override
  void initState() {
    super.initState();

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
                width:
                    ((size.width - 152) / widget.exercise.setInfo.length) - 1,
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
                width:
                    ((size.width - 152) / widget.exercise.setInfo.length) - 1,
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
                width:
                    ((size.width - 152) / widget.exercise.setInfo.length) - 1,
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

    return Column(
      children: [
        Text(
          (widget.exercise.setInfo[widget.setInfoIndex].seconds! / 60).floor() >
                      0 &&
                  (widget.exercise.setInfo[widget.setInfoIndex].seconds! % 60) >
                      0
              ? '${(widget.exercise.setInfo[widget.setInfoIndex].seconds! / 60).floor()}분 ${(widget.exercise.setInfo[widget.setInfoIndex].seconds! % 60).toString().padLeft(2, '0')}초'
              : (widget.exercise.setInfo[widget.setInfoIndex].seconds! / 60)
                              .floor() >
                          0 &&
                      (widget.exercise.setInfo[widget.setInfoIndex].seconds! %
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
              color: (totalSeconds ==
                              widget.exercise.setInfo[widget.setInfoIndex]
                                  .seconds! ||
                          totalSeconds < 0) &&
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
                                widget.exercise.setInfo[widget.setInfoIndex]
                                    .seconds!
                        ? SvgPicture.asset('asset/img/icon_replay_small.svg')
                        : totalSeconds == 0
                            ? SvgPicture.asset('asset/img/icon_reset_small.svg')
                            : SvgPicture.asset('asset/img/icon_play_small.svg'),
                const SizedBox(
                  width: 8,
                ),
                Center(
                  child: Text(
                    (totalSeconds ==
                                    widget.exercise.setInfo[widget.setInfoIndex]
                                        .seconds! ||
                                totalSeconds < 0) &&
                            !isRunning
                        ? '운동 시작'
                        : '${(totalSeconds / 60).floor().toString().padLeft(2, '0')} : ${(totalSeconds % 60).toString().padLeft(2, '0')} ',
                    style: s2SubTitle.copyWith(
                      color: (totalSeconds ==
                                      widget
                                          .exercise
                                          .setInfo[widget.setInfoIndex]
                                          .seconds! ||
                                  totalSeconds < 0) &&
                              !isRunning
                          ? Colors.white
                          : POINT_COLOR,
                      fontWeight: (totalSeconds ==
                                      widget
                                          .exercise
                                          .setInfo[widget.setInfoIndex]
                                          .seconds! ||
                                  totalSeconds < 0) &&
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
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            InkWell(
              onTap: () {
                widget.updateSeinfoTap();
              },
              child: SvgPicture.asset(
                'asset/img/icon_edit.svg',
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
                          message: '먼저 운동을 진행해주세요 🏋🏻',
                          confirmText: '확인',
                          confirmOnTap: () => context.pop(),
                        ),
                      );
                    }
                  : widget.proccessOnTap,
              child: SvgPicture.asset(
                'asset/img/icon_forward.svg',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
