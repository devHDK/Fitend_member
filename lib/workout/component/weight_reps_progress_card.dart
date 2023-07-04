import 'dart:async';

import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class WeightWrepsProgressCard extends ConsumerStatefulWidget {
  final Exercise exercise;
  final int setInfoIndex;
  final GestureTapCallback updateSeinfoTap;
  final GestureTapCallback proccessOnTap;

  const WeightWrepsProgressCard({
    super.key,
    required this.exercise,
    required this.setInfoIndex,
    required this.proccessOnTap,
    required this.updateSeinfoTap,
  });

  @override
  ConsumerState<WeightWrepsProgressCard> createState() =>
      _WeightWrepsProgressCardState();
}

class _WeightWrepsProgressCardState
    extends ConsumerState<WeightWrepsProgressCard> {
  // int index = 0;
  bool colorChanged = false;
  int count = 0;
  int length = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(
      const Duration(milliseconds: 1000),
      (timer) {
        setState(() {
          colorChanged = !colorChanged;
          count += 1;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                  color: POINT_COLOR,
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

    if (widget.setInfoIndex > widget.exercise.setInfo.length - 1) {
      length = widget.setInfoIndex - 1;
    } else {
      length = widget.setInfoIndex;
    }

    return Column(
      children: [
        Text(
          widget.exercise.trackingFieldId == 1
              ? '${widget.exercise.setInfo[length].weight}kg ∙ ${widget.exercise.setInfo[length].reps}회'
              : widget.exercise.trackingFieldId == 2
                  ? '${widget.exercise.setInfo[length].reps}회'
                  : '${(widget.exercise.setInfo[length].seconds! / 60).floor()}분 ${widget.exercise.setInfo[length].seconds! % 60}초',
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
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: POINT_COLOR),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Text(
              '${length + 1}세트 진행중',
              style: h6Headline.copyWith(
                color: POINT_COLOR,
                height: 1.2,
              ),
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
              onTap: count > 10
                  ? () {
                      setState(() {
                        count = 0;
                      });
                      widget.proccessOnTap();
                    }
                  : () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => DialogWidgets.errorDialog(
                          message: '먼저 운동을 진행해주세요 🏋🏻',
                          confirmText: '확인',
                          confirmOnTap: () => context.pop(),
                        ),
                      );
                    },
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
