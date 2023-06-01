import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:flutter/material.dart';

class WorkoutCard extends StatelessWidget {
  final Exercise exercise;
  final int completeSetCount;

  const WorkoutCard({
    super.key,
    required this.exercise,
    required this.completeSetCount,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> countList = [];
    List<Widget> firstList = [];
    List<Widget> secondList = [];

    List.generate(
      exercise.setInfo.length,
      (index) => exercise.setInfo.length != 1
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
                  Container(
                    width: 182,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: index <= completeSetCount - 1
                          ? POINT_COLOR
                          : BODY_TEXT_COLOR,
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
      width: MediaQuery.of(context).size.width,
      height: 157,
      decoration: const BoxDecoration(
        color: BACKGROUND_COLOR,
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
          _RenderBody(
              exercise: exercise,
              countList: countList,
              firstList: firstList,
              secondList: secondList)
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
  const _RenderBody({
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
        const SizedBox(
          height: 52,
        ),
        Text(
          exercise.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          '${exercise.setInfo.length} SET',
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
