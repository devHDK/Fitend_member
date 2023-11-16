import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/muscle_group.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class WeightWrepsProgressCard extends ConsumerStatefulWidget {
  final int workoutScheduleId;
  final Exercise exercise;
  final int setInfoIndex;
  final bool isSwipeUp;
  final GestureTapCallback listOnTap;
  final GestureTapCallback proccessOnTap;

  const WeightWrepsProgressCard({
    super.key,
    required this.workoutScheduleId,
    required this.exercise,
    required this.setInfoIndex,
    required this.isSwipeUp,
    required this.proccessOnTap,
    required this.listOnTap,
  });

  @override
  ConsumerState<WeightWrepsProgressCard> createState() =>
      _WeightWrepsProgressCardState();
}

class _WeightWrepsProgressCardState
    extends ConsumerState<WeightWrepsProgressCard> {
  // int index = 0;

  int count = 0;
  int length = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = Size(100.w, 100.h);

    List<Widget> progressList = widget.exercise.setInfo.mapIndexed(
      (index, element) {
        if (index == widget.setInfoIndex &&
            widget.exercise.setInfo.length > 1) {
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
        } else if (index == widget.setInfoIndex &&
            widget.exercise.setInfo.length == 1) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Pallete.point,
                ),
                width: widget.isSwipeUp
                    ? ((size.width - 56) / widget.exercise.setInfo.length) - 1
                    : ((size.width - 152) / widget.exercise.setInfo.length) - 1,
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
                  color: Pallete.point,
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
      muscleString += ' ${muscleGroup[muscle]!} ∙';
    }

    if (widget.setInfoIndex > widget.exercise.setInfo.length - 1) {
      length = widget.setInfoIndex - 1;
    } else {
      length = widget.setInfoIndex;
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
                widget.exercise.trackingFieldId == 1
                    ? '${widget.exercise.setInfo[length].weight! % 1 == 0 ? widget.exercise.setInfo[length].weight!.toInt() : widget.exercise.setInfo[length].weight}kg ∙ ${widget.exercise.setInfo[length].reps}회'
                    : widget.exercise.trackingFieldId == 2
                        ? '${widget.exercise.setInfo[length].reps}회'
                        : '${(widget.exercise.setInfo[length].seconds! / 60).floor()}분 ${widget.exercise.setInfo[length].seconds! % 60}초',
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
                  AutoSizeText(
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
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Pallete.point),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: Text(
                    '${length + 1}세트 진행중',
                    style: h6Headline.copyWith(
                      color: Pallete.point,
                      height: 1.2,
                    ),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: progressList,
              ),
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
