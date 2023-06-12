import 'dart:async';

import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  int index = 0;
  bool colorChanged = false;
  int count = 0;

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
                width:
                    ((size.width - 152) / widget.exercise.setInfo.length) - 1,
                height: 4,
                color: colorChanged ? LIGHT_GRAY_COLOR : POINT_COLOR,
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
                width:
                    ((size.width - 152) / widget.exercise.setInfo.length) - 1,
                color: LIGHT_GRAY_COLOR,
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
                decoration: const BoxDecoration(
                  color: POINT_COLOR,
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

    return Column(
      children: [
        Text(
          widget.exercise.trackingFieldId == 1
              ? '${widget.exercise.setInfo[index].weight}kg ∙ ${widget.exercise.setInfo[index].reps}회'
              : widget.exercise.trackingFieldId == 2
                  ? '${widget.exercise.setInfo[index].reps}회'
                  : '${(widget.exercise.setInfo[index].seconds! / 60).floor()}분 ${widget.exercise.setInfo[index].seconds! % 30}초',
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
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: POINT_COLOR),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${widget.setInfoIndex + 1}세트 진행중',
              style: const TextStyle(
                color: POINT_COLOR,
                fontSize: 14,
                fontWeight: FontWeight.w700,
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
              child: Image.asset(
                'asset/img/icon_edit.png',
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
                          message: '먼저 운동을 진행해 주세요 🏋🏻',
                          confirmText: '확인',
                          confirmOnTap: () => context.pop(),
                        ),
                      );
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
