import 'dart:async';

import 'package:fitend_member/common/component/dialog_tools.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/provider/hive_timer_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/setInfo_model.dart';
import 'package:fitend_member/workout/model/workout_record_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TimerXOneProgressCard extends ConsumerStatefulWidget {
  final Exercise exercise;
  final GestureTapCallback proccessOnTap;

  const TimerXOneProgressCard({
    super.key,
    required this.exercise,
    required this.proccessOnTap,
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

    WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
      if (initial) {
        timerBox.whenData((value) {
          final record = value.get(widget.exercise.workoutPlanId);

          if (record is SetInfo) {
            totalSeconds =
                widget.exercise.setInfo[0].seconds! - record.seconds!;
          } else if (record == null) {
            totalSeconds = widget.exercise.setInfo[0].seconds!;
          }

          print('record : $record');
          print('totalSeconds : $totalSeconds');
        });

        setState(() {});
        initial = false;
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
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

  void onTick(Timer timer) {
    if (totalSeconds == 0) {
      //0초가 됬을때 저장
      setState(() {
        isRunning = false;
        count = 11;
      });
      timer.cancel();

      workoutBox.whenData((value) {
        value.put(
          widget.exercise.workoutPlanId,
          WorkoutRecordModel(
            workoutPlanId: widget.exercise.workoutPlanId,
            setInfo: widget.exercise.setInfo,
          ),
        );
        print(value.get(widget.exercise.workoutPlanId).setInfo.length);
      });
    } else {
      setState(() {
        totalSeconds -= 1;
        count++;
      });
      timerBox.whenData((value) {
        value.put(
          widget.exercise.workoutPlanId,
          SetInfo(
              index: 1,
              seconds: widget.exercise.setInfo[0].seconds! - totalSeconds),
        );

        print(value.get(widget.exercise.workoutPlanId).seconds!);
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
          '${(widget.exercise.setInfo[0].seconds! / 60).floor()}분 ${widget.exercise.setInfo[0].seconds! % 30}초',
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
                Text(
                  totalSeconds == widget.exercise.setInfo[0].seconds! ||
                          totalSeconds < 0
                      ? '운동 시작'
                      : '${(totalSeconds / 60).floor().toString().padLeft(2, '0')} : ${(totalSeconds % 60).toString().padLeft(2, '0')} ',
                  style: TextStyle(
                    color: totalSeconds == widget.exercise.setInfo[0].seconds!
                        ? Colors.white
                        : POINT_COLOR,
                    fontSize: 14,
                    fontWeight:
                        totalSeconds == widget.exercise.setInfo[0].seconds!
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
              onTap: () {},
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
                  width: 231,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value:
                          (widget.exercise.setInfo[0].seconds! - totalSeconds) /
                              widget.exercise.setInfo[0].seconds!,
                      backgroundColor: GRAY_COLOR,
                      valueColor: const AlwaysStoppedAnimation(POINT_COLOR),
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
                        context: context,
                        builder: (context) => DialogTools.errorDialog(
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
