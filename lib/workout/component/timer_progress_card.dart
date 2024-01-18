import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/muscle_group.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/provider/hive_timer_x_more_record_provider.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:fitend_member/workout/model/workout_process_model.dart';
import 'package:fitend_member/workout/model/workout_record_simple_model.dart';
import 'package:fitend_member/workout/provider/workout_process_provider.dart';
import 'package:fitend_member/workout/view/timer_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TimerProgressCard extends ConsumerStatefulWidget {
  final int workoutScheduleId;
  final Exercise exercise;
  final int setInfoIndex;
  final bool isSwipeUp;
  final GestureTapCallback listOnTap;
  final GestureTapCallback proccessOnTap;
  final GestureTapCallback resetSet;
  final Function refresh;

  const TimerProgressCard({
    super.key,
    required this.workoutScheduleId,
    required this.exercise,
    required this.setInfoIndex,
    required this.isSwipeUp,
    required this.listOnTap,
    required this.proccessOnTap,
    required this.resetSet,
    required this.refresh,
  });

  @override
  ConsumerState<TimerProgressCard> createState() => _TimerProgressCardState();
}

class _TimerProgressCardState extends ConsumerState<TimerProgressCard> {
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
    Size size = Size(100.w, 100.h);
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
      }
    });

    int remainSeconds = modifiedSetInfo.seconds! - recordSetInfo.seconds!;
    if (remainSeconds < 0) remainSeconds = 0;

    List<Widget> progressList = widget.exercise.setInfo.mapIndexed(
      (index, element) {
        if (index == widget.setInfoIndex) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  color: Pallete.point,
                ),
                width: widget.isSwipeUp
                    ? ((size.width - 56) / widget.exercise.setInfo.length) - 1
                    : ((size.width - 152) / widget.exercise.setInfo.length) - 1,
                height: 4,
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
                  color: Pallete.lightGray,
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
                  color: Pallete.point,
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
      muscleString += ' ${muscleMap[muscle]!} ∙';
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
                DataUtils.getTimerStringMinuteSeconds(
                    widget.exercise.setInfo[widget.setInfoIndex].seconds!),
                style: s1SubTitle.copyWith(
                  color: Pallete.gray,
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
                    SvgPicture.asset(SVGConstants.repeat)
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
                    border: Border.all(color: Pallete.point),
                    borderRadius: BorderRadius.circular(12),
                    color: recordSetInfo.seconds == 0
                        ? Pallete.point
                        : Colors.white,
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
                                ? SVGConstants.timerWhite
                                : SVGConstants.timerRed,
                            width: 18,
                            height: 18,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Text(
                        recordSetInfo.seconds == 0
                            ? '타이머'
                            : DataUtils.getTimeStringMinutes(remainSeconds),
                        textAlign: TextAlign.center,
                        style: s1SubTitle.copyWith(
                          color: recordSetInfo.seconds == 0
                              ? Colors.white
                              : Pallete.point,
                          height: 1.2,
                        ),
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
                style: s2SubTitle.copyWith(color: Pallete.gray),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AutoSizeText(
                    widget.exercise.name,
                    style: h1Headline.copyWith(height: 1.2),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  if (widget.exercise.setType != null)
                    SvgPicture.asset(SVGConstants.repeat)
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
                        SVGConstants.list,
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                  ],
                ),
              ),
            if (widget.exercise.setInfo.length > 1)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: progressList,
                ),
              )
            else
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
                          backgroundColor: Pallete.lightGray,
                          valueColor:
                              const AlwaysStoppedAnimation(Pallete.point),
                        ),
                      ),
                    ),
                  )
                ]),
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
                      SVGConstants.forward,
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
