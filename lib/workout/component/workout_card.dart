import 'dart:io';

import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/provider/hive_modified_exercise_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_x_more_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:fitend_member/workout/model/workout_record_simple_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class WorkoutCard extends ConsumerStatefulWidget {
  final Exercise exercise;
  final int completeSetCount;
  final int? exerciseIndex;
  final bool? isSelected;
  final bool? islastCircuit;

  const WorkoutCard({
    super.key,
    required this.exercise,
    required this.completeSetCount,
    this.exerciseIndex,
    this.isSelected,
    this.islastCircuit,
  });

  @override
  ConsumerState<WorkoutCard> createState() => _WorkoutCardState();
}

class _WorkoutCardState extends ConsumerState<WorkoutCard> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<Box> timerRecordBox =
        ref.watch(hiveTimerXMoreRecordProvider);
    final AsyncValue<Box> modifiedBox = ref.watch(hiveModifiedExerciseProvider);
    final AsyncValue<Box> recordSimpleBox =
        ref.watch(hiveWorkoutRecordSimpleProvider);

    List<Widget> countList = [];
    List<Widget> firstList = [];
    List<Widget> secondList = [];

    SetInfo timerSetInfo = SetInfo(index: 1, seconds: 0);
    SetInfo modifiedSetInfo = SetInfo(index: 1, seconds: 0);
    List<SetInfo> recordedSetInfoList = [];

    if ((widget.exercise.trackingFieldId == 3 ||
            widget.exercise.trackingFieldId == 4) &&
        widget.exercise.setInfo.length == 1) {
      timerRecordBox.whenData(
        (value) {
          final record = value.get(widget.exercise.workoutPlanId);
          if (record != null && record is WorkoutRecordSimple) {
            timerSetInfo = record.setInfo[0];
          } else {
            timerSetInfo = SetInfo(index: 1, seconds: 0);
          }
        },
      );

      modifiedBox.whenData((value) {
        if ((widget.exercise.trackingFieldId == 3 ||
                widget.exercise.trackingFieldId == 4) &&
            widget.exercise.setInfo.length == 1) {
          final record = value.get(widget.exercise.workoutPlanId);
          if (record is Exercise && record.setInfo[0].seconds != null) {
            modifiedSetInfo = SetInfo(
                index: record.setInfo[0].index,
                seconds: record.setInfo[0].seconds);
          } else {
            modifiedSetInfo = SetInfo(
              index: widget.exercise.setInfo[0].index,
              seconds: widget.exercise.setInfo[0].seconds,
            );
          }
        }
      });
    }

    recordSimpleBox.whenData((value) {
      final record = value.get(widget.exercise.workoutPlanId);
      if (record is WorkoutRecordSimple) {
        recordedSetInfoList = record.setInfo;
      }
    });

    List.generate(
      widget.exercise.setInfo.length,
      (index) => widget.exercise.setInfo.length != 1 ||
              (widget.exercise.trackingFieldId != 3 &&
                  widget.exercise.trackingFieldId != 4)
          ? countList.add(
              Row(
                children: [
                  Container(
                    width: 39,
                    height: 17,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: index <= widget.completeSetCount - 1
                          ? Pallete.point
                          : Pallete.lightGray,
                    ),
                    child: Center(
                      child: Text(
                        widget.exercise.trackingFieldId == 1
                            ? '${index <= widget.completeSetCount - 1 && recordedSetInfoList.isNotEmpty ? recordedSetInfoList[index].weight!.floor() : widget.exercise.setInfo[index].weight!.floor()} ∙ ${index <= widget.completeSetCount - 1 ? recordedSetInfoList[index].reps : widget.exercise.setInfo[index].reps}'
                            : widget.exercise.trackingFieldId == 2
                                ? index <= widget.completeSetCount - 1
                                    ? '${recordedSetInfoList[index].reps}'
                                    : '${widget.exercise.setInfo[index].reps}'
                                : '${index <= widget.completeSetCount - 1 ? (recordedSetInfoList[index].seconds! / 60).floor().toString().padLeft(2, '0') : (widget.exercise.setInfo[index].seconds! / 60).floor().toString().padLeft(2, '0')} : ${index <= widget.completeSetCount - 1 ? (recordedSetInfoList[index].seconds! % 60).toString().padLeft(2, '0') : (widget.exercise.setInfo[index].seconds! % 60).toString().padLeft(2, '0')}',
                        style: s1SubTitle.copyWith(
                          color: index <= widget.completeSetCount - 1
                              ? Colors.white
                              : Pallete.gray,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  )
                ],
              ),
            )
          : countList.add(
              Row(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        width: 223,
                        height: 17,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: timerSetInfo.seconds == null
                                ? 0.0
                                : (timerSetInfo.seconds! /
                                    (modifiedSetInfo.seconds == 0
                                        ? widget.exercise.setInfo[0].seconds!
                                        : modifiedSetInfo.seconds!)),
                            backgroundColor: Pallete.lightGray,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Pallete.point),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 92,
                        child: Text(
                          timerSetInfo.seconds == null
                              ? DataUtils.getTimeStringMinutes(0)
                              : DataUtils.getTimeStringMinutes(
                                  timerSetInfo.seconds!),
                          style: s2SubTitle.copyWith(
                            fontSize: 10,
                            color: index <= widget.completeSetCount - 1
                                ? Colors.white
                                : Pallete.gray,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
    );

    if (widget.exercise.setInfo.length > 5) {
      firstList = countList.sublist(0, 5);
      secondList = countList.sublist(5, widget.exercise.setInfo.length);
    }

    return Container(
      padding: widget.isSelected != null
          ? EdgeInsets.symmetric(horizontal: Platform.isIOS ? 7.w : (3.8).w)
          : null,
      width: 100.w,
      height: widget.exercise.circuitGroupNum != null ? 137 : 157,
      decoration: BoxDecoration(
        color: Pallete.background,
        border: Border.fromBorderSide(
          BorderSide(
            color: widget.isSelected != null && widget.isSelected!
                ? Pallete.point
                : Colors.transparent,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _renderImage(
                widget.exercise.videos[0].thumbnail,
                widget.exercise.targetMuscles[0].id,
                widget.exerciseIndex,
              ),
            ],
          ),
          const SizedBox(
            width: 23,
          ),
          Expanded(
            child: _RenderBody(
              exerciseIndex: widget.exerciseIndex,
              exercise: widget.exercise,
              countList: countList,
              firstList: firstList,
              secondList: secondList,
              modifiedSetInfo: modifiedSetInfo,
            ),
          ),
        ],
      ),
    );
  }

  Stack _renderImage(String thumnail, int muscleId, int? exerciseIndex) {
    return Stack(
      children: [
        SizedBox(
          width: 72,
          height: 128,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CustomNetworkImage(
              imageUrl: '${URLConstants.s3Url}$thumnail',
            ),
          ),
        ),
        if (exerciseIndex != null)
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: 72,
              height: 24,
              decoration: BoxDecoration(
                color: Pallete.point,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '진행중🏃',
                  style: s3SubTitle.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        // Positioned(
        //   left: 42,
        //   top: 98,
        //   child: SizedBox(
        //     width: 35,
        //     height: 35,
        //     child: ClipRRect(
        //       child: CustomNetworkImage(
        //           imageUrl: '${URLConstants.s3Url}${URLConstants.muscleImageUrl}$muscleId.png'),
        //     ),
        //   ),
        // )
      ],
    );
  }
}

class _RenderBody extends StatelessWidget {
  final Exercise exercise;
  final List<Widget> countList;
  final List<Widget> firstList;
  final List<Widget> secondList;
  final int? exerciseIndex;
  final SetInfo? modifiedSetInfo;

  const _RenderBody({
    required this.exercise,
    required this.countList,
    required this.firstList,
    required this.secondList,
    this.exerciseIndex,
    this.modifiedSetInfo,
  });

  @override
  Widget build(BuildContext context) {
    // debugPrint('Renderbody : ${exercise.setInfo[0].seconds}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              exercise.name,
              style: h4Headline.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          exercise.setInfo.length > 1 ||
                  exercise.trackingFieldId == 1 ||
                  exercise.trackingFieldId == 2
              ? '${exercise.setInfo.length} SET'
              : DataUtils.getTimerStringMinuteSeconds(
                  modifiedSetInfo!.seconds!),
          style: s2SubTitle.copyWith(
            color: Pallete.lightGray,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        _RenderSetInfo(
          exercise: exercise,
          countList: countList,
          firstList: firstList,
          secondList: secondList,
        )
      ],
    );
  }
}

class _RenderSetInfo extends StatelessWidget {
  const _RenderSetInfo({
    required this.exercise,
    required this.countList,
    required this.firstList,
    required this.secondList,
  });

  final Exercise exercise;
  final List<Widget> countList;
  final List<Widget> firstList;
  final List<Widget> secondList;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (exercise.setInfo.length <= 5)
          Row(
            children: countList.toList(),
          ),
        if (exercise.setInfo.length > 5)
          Row(
            children: firstList.toList(),
          ),
        const SizedBox(
          height: 8,
        ),
        if (exercise.setInfo.length > 5)
          Row(
            children: secondList.toList(),
          )
      ],
    );
  }
}
