import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/workout/model/workout_record_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WorkoutCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Box> box = ref.watch(hiveWorkoutRecordProvider);

    List<Widget> countList = [];
    List<Widget> firstList = [];
    List<Widget> secondList = [];

    late WorkoutRecordModel workoutRecord;

    box.whenData((value) {
      final record = value.get(exercise.workoutPlanId);

      if (record != null && record.setInfo.length > 0) {
        workoutRecord = record;
      } else {
        workoutRecord = WorkoutRecordModel(workoutPlanId: 0, setInfo: []);
      }
    });

    List.generate(
      exercise.setInfo.length,
      (index) => exercise.setInfo.length != 1 ||
              (exercise.trackingFieldId != 3 && exercise.trackingFieldId != 4)
          ? countList.add(
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: index <= completeSetCount - 1
                          ? POINT_COLOR
                          : BODY_TEXT_COLOR,
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
                        value: workoutRecord.setInfo.isNotEmpty
                            ? (workoutRecord.setInfo[0].seconds! /
                                exercise.setInfo[0].seconds!)
                            : 0,
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

    if (exercise.setInfo.length > 5) {
      firstList = countList.sublist(0, 5);
      secondList = countList.sublist(5, exercise.setInfo.length);
    }

    return Container(
      padding: isSelected != null
          ? const EdgeInsets.symmetric(horizontal: 28)
          : null,
      width: MediaQuery.of(context).size.width,
      height: 157,
      decoration: BoxDecoration(
        color: BACKGROUND_COLOR,
        border: isSelected != null && isSelected!
            ? Border.all(
                color: POINT_COLOR,
                width: 1.0,
              )
            : null,
      ),
      child: Row(
        children: [
          _renderImage(
            exercise.videos[0].thumbnail,
            exercise.targetMuscles[0].image,
          ),
          const SizedBox(
            width: 23,
          ),
          Expanded(
            child: _RenderBody(
                exerciseIndex: exerciseIndex,
                exercise: exercise,
                countList: countList,
                firstList: firstList,
                secondList: secondList),
          ),
        ],
      ),
    );
  }

  Stack _renderImage(String thumnail, String muscle) {
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
              child: CustomNetworkImage(imageUrl: '$s3Url$muscle'),
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
            color: BODY_TEXT_COLOR,
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
