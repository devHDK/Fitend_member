import 'dart:async';

import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/provider/hive_timer_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TimerXOneProgressCard extends ConsumerStatefulWidget {
  final Exercise exercise;
  final int setInfoIndex;
  final GestureTapCallback updateSeinfoTap;
  final GestureTapCallback proccessOnTap;

  const TimerXOneProgressCard({
    super.key,
    required this.exercise,
    required this.proccessOnTap,
    required this.setInfoIndex,
    required this.updateSeinfoTap,
  });

  @override
  ConsumerState<TimerXOneProgressCard> createState() =>
      _TimerXOneProgressCardState();
}

class _TimerXOneProgressCardState extends ConsumerState<TimerXOneProgressCard> {
  late Timer timer;
  late int totalSeconds = -1;
  bool initial = true;
  bool isRunning = false;
  int count = 0;

  late AsyncValue<Box> timerBox;
  late AsyncValue<Box> workoutBox;

  @override
  void initState() {
    super.initState();

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
    super.dispose();
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

    return Column(
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
              color: totalSeconds == widget.exercise.setInfo[0].seconds!
                  ? POINT_COLOR
                  : Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                isRunning
                    ? Image.asset('asset/img/icon_pause_small.png')
                    : totalSeconds > 0 &&
                            totalSeconds < widget.exercise.setInfo[0].seconds!
                        ? Image.asset('asset/img/icon_replay_small.png')
                        : totalSeconds == 0
                            ? Image.asset('asset/img/icon_reset_small.png')
                            : Image.asset('asset/img/icon_play_small.png'),
                const SizedBox(
                  width: 8,
                ),
                Center(
                  child: Text(
                    totalSeconds == widget.exercise.setInfo[0].seconds! ||
                            totalSeconds < 0
                        ? '운동 시작'
                        : '${(totalSeconds / 60).floor().toString().padLeft(2, '0')} : ${(totalSeconds % 60).toString().padLeft(2, '0')} ',
                    style: s2SubTitle.copyWith(
                        color:
                            totalSeconds == widget.exercise.setInfo[0].seconds!
                                ? Colors.white
                                : POINT_COLOR,
                        fontWeight:
                            totalSeconds == widget.exercise.setInfo[0].seconds!
                                ? FontWeight.w700
                                : FontWeight.w400,
                        height: 1.2),
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
              onTap: () {
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
              child: Row(mainAxisSize: MainAxisSize.max, children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width - 152,
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
                  : () {
                      if (timer.isActive) {
                        timer.cancel();
                        setState(() {
                          isRunning = false;
                        });
                      }

                      widget.proccessOnTap();
                    },
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
