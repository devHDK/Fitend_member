import 'dart:async';

import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/muscle_group.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/provider/hive_timer_record_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_x_more_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:fitend_member/workout/model/workout_process_model.dart';
import 'package:fitend_member/workout/model/workout_record_simple_model.dart';
import 'package:fitend_member/workout/provider/workout_process_provider.dart';
import 'package:fitend_member/workout/view/timer_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TimerXOneProgressCard extends ConsumerStatefulWidget {
  final int workoutScheduleId;
  final Exercise exercise;
  final int setInfoIndex;
  final bool isSwipeUp;
  final GestureTapCallback listOnTap;
  final GestureTapCallback proccessOnTap;
  final Function refresh;

  const TimerXOneProgressCard({
    super.key,
    required this.workoutScheduleId,
    required this.exercise,
    required this.isSwipeUp,
    required this.proccessOnTap,
    required this.setInfoIndex,
    required this.listOnTap,
    required this.refresh,
  });

  @override
  ConsumerState<TimerXOneProgressCard> createState() =>
      _TimerXOneProgressCardState();
}

class _TimerXOneProgressCardState extends ConsumerState<TimerXOneProgressCard>
    with WidgetsBindingObserver {
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Box> timerXMoreRecordBox =
        ref.watch(hiveTimerXMoreRecordProvider);
    final state = ref.read(workoutProcessProvider(widget.workoutScheduleId));

    final pstate = state as WorkoutProcessModel;

    final modifiedSetInfo = pstate
        .modifiedExercises[pstate.exerciseIndex].setInfo[widget.setInfoIndex];

    SetInfo recordSetInfo = SetInfo(index: widget.setInfoIndex + 1);

    timerXMoreRecordBox.whenData((value) {
      final record = value.get(widget.exercise.workoutPlanId);

      if (record is WorkoutRecordSimple) {
        recordSetInfo = record.setInfo[widget.setInfoIndex];
        print(recordSetInfo.seconds);
      }
    });

    final remainSeconds = modifiedSetInfo.seconds! - recordSetInfo.seconds!;

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
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.exercise.name,
                    style: h3Headline.copyWith(
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis,
                      height: 1.2,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  if (widget.exercise.setType != null)
                    SvgPicture.asset('asset/img/icon_repeat.svg')
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) => TimerScreen(
                      model: pstate,
                      setInfoIndex: widget.setInfoIndex,
                      secondsGoal: modifiedSetInfo.seconds!,
                      secondsRecord: recordSetInfo.seconds!,
                      workoutScheduleId: widget.workoutScheduleId,
                      refresh: widget.refresh,
                    ),
                    fullscreenDialog: true,
                  ));
                },
                child: Container(
                  width: 100,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(color: POINT_COLOR),
                    borderRadius: BorderRadius.circular(12),
                    color:
                        recordSetInfo.seconds == 0 ? POINT_COLOR : Colors.white,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Center(
                          child: SvgPicture.asset(
                            recordSetInfo.seconds == 0
                                ? 'asset/img/icon_timer_white.svg'
                                : 'asset/img/icon_timer_red.svg',
                            width: 18,
                            height: 18,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Center(
                        child: Text(
                          recordSetInfo.seconds == 0
                              ? '타이머'
                              : '${(remainSeconds / 60).floor().toString().padLeft(2, '0')} : ${(remainSeconds % 60).toString().padLeft(2, '0')} ',
                          style: s1SubTitle.copyWith(
                            color: recordSetInfo.seconds == 0
                                ? Colors.white
                                : POINT_COLOR,
                            fontWeight: recordSetInfo.seconds == 0
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
              const SizedBox(
                height: 5,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.exercise.name,
                    style: h1Headline.copyWith(height: 1.2),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  if (widget.exercise.setType != null)
                    SvgPicture.asset('asset/img/icon_repeat.svg')
                ],
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
                  widget.listOnTap();
                },
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: SvgPicture.asset(
                        'asset/img/icon_list.svg',
                      ),
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
                  width: !widget.isSwipeUp ? 100.w - 152 : 100.w - 56,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: LinearProgressIndicator(
                        value:
                            recordSetInfo.seconds! / modifiedSetInfo.seconds!,
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
