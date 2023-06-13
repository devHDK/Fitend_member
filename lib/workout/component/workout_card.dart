import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/provider/hive_modified_exercise_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_record_provider.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/setInfo_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WorkoutCard extends ConsumerStatefulWidget {
  final Exercise exercise;
  final int completeSetCount;
  final int? exerciseIndex;
  final bool? isSelected;

  const WorkoutCard({
    super.key,
    required this.exercise,
    required this.completeSetCount,
    this.exerciseIndex,
    this.isSelected,
  });

  @override
  ConsumerState<WorkoutCard> createState() => _WorkoutCardState();
}

class _WorkoutCardState extends ConsumerState<WorkoutCard> {
  @override
  Widget build(BuildContext context) {
    // final AsyncValue<Box> workoutRecordBox =
    //     ref.watch(hiveWorkoutRecordProvider);
    final AsyncValue<Box> timerRecordBox = ref.watch(hiveTimerRecordProvider);
    final AsyncValue<Box> modifiedExerciseBox =
        ref.watch(hiveModifiedExerciseProvider);

    List<Widget> countList = [];
    List<Widget> firstList = [];
    List<Widget> secondList = [];

    late SetInfo timerSetInfo = SetInfo(index: 1, seconds: 0);

    if ((widget.exercise.trackingFieldId == 3 ||
            widget.exercise.trackingFieldId == 4) &&
        widget.exercise.setInfo.length == 1) {
      timerRecordBox.whenData(
        (value) {
          final record = value.get(widget.exercise.workoutPlanId);
          if (record != null && record is SetInfo) {
            timerSetInfo = record;
          } else {
            timerSetInfo = SetInfo(index: 1, seconds: 0);
          }
        },
      );
    }

    List.generate(
      widget.exercise.setInfo.length,
      (index) => widget.exercise.setInfo.length != 1 ||
              (widget.exercise.trackingFieldId != 3 &&
                  widget.exercise.trackingFieldId != 4)
          ? countList.add(
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: index <= widget.completeSetCount - 1
                          ? POINT_COLOR
                          : LIGHT_GRAY_COLOR,
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
                  SizedBox(
                    width: 182,
                    height: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: timerSetInfo.seconds == null
                            ? (0 / widget.exercise.setInfo[0].seconds!)
                            : (timerSetInfo.seconds! /
                                widget.exercise.setInfo[0].seconds!),
                        backgroundColor: LIGHT_GRAY_COLOR,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(POINT_COLOR),
                      ),
                    ),
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
          ? const EdgeInsets.symmetric(horizontal: 28)
          : null,
      width: MediaQuery.of(context).size.width,
      height: 157,
      decoration: BoxDecoration(
        color: BACKGROUND_COLOR,
        border: widget.isSelected != null && widget.isSelected!
            ? Border.all(
                color: POINT_COLOR,
                width: 1.0,
              )
            : null,
      ),
      child: Row(
        children: [
          _renderImage(widget.exercise.videos[0].thumbnail,
              widget.exercise.targetMuscles[0].id),
          const SizedBox(
            width: 23,
          ),
          Expanded(
            child: _RenderBody(
                exerciseIndex: widget.exerciseIndex,
                exercise: widget.exercise,
                countList: countList,
                firstList: firstList,
                secondList: secondList),
          ),
        ],
      ),
    );
  }

  Stack _renderImage(String thumnail, int muscleId) {
    return Stack(
      children: [
        SizedBox(
          width: 72,
          height: 128,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CustomNetworkImage(
              imageUrl: '$s3Url$thumnail',
            ),
          ),
        ),
        Positioned(
          left: 42,
          top: 98,
          child: SizedBox(
            width: 35,
            height: 35,
            child: ClipRRect(
              child: CustomNetworkImage(
                  imageUrl: '$s3Url$muscleImageUrl$muscleId.png'),
            ),
          ),
        )
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

  const _RenderBody({
    required this.exercise,
    required this.countList,
    required this.firstList,
    required this.secondList,
    this.exerciseIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 52,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              exercise.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (exerciseIndex != null)
              Container(
                width: 64,
                height: 24,
                decoration: BoxDecoration(
                  color: POINT_COLOR,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  '진행중🏃',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
          ],
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          exercise.setInfo.length > 1
              ? '${exercise.setInfo.length} SET'
              : '${(exercise.setInfo[0].seconds! / 60).floor()} 분',
          style: const TextStyle(
            color: LIGHT_GRAY_COLOR,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        _RenderSetInfo(
            exercise: exercise,
            countList: countList,
            firstList: firstList,
            secondList: secondList)
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
