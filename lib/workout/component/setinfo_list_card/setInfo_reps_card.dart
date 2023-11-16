import 'package:fitend_member/common/component/hexagon_container.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/workout/component/setinfo_text_field.dart';
import 'package:fitend_member/workout/model/workout_process_model.dart';
import 'package:fitend_member/workout/provider/workout_process_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SetInfoBoxForReps extends ConsumerStatefulWidget {
  const SetInfoBoxForReps({
    super.key,
    required this.model,
    required this.setInfoIndex,
    required this.initialReps,
    required this.workoutScheduleId,
    required this.refresh,
  });

  final WorkoutProcessModel model;
  final int setInfoIndex;
  final int initialReps;
  final int workoutScheduleId;
  final Function refresh;

  @override
  ConsumerState<SetInfoBoxForReps> createState() => _SetInfoBoxForRepsState();
}

class _SetInfoBoxForRepsState extends ConsumerState<SetInfoBoxForReps> {
  final repsController = TextEditingController();

  void repsControllerListener() {
    try {
      if (repsController.text.isNotEmpty &&
          int.parse(repsController.text) > 99) {
        repsController.text = 99.toString();
      }

      widget.refresh();
    } catch (e) {
      debugPrint('$e');
    }
  }

  @override
  void initState() {
    super.initState();
    repsController.addListener(repsControllerListener);

    repsController.text = widget.initialReps.toString();
  }

  @override
  void dispose() {
    repsController.removeListener(repsControllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNowSet = widget.setInfoIndex ==
        widget.model.setInfoCompleteList[widget.model.exerciseIndex];

    final isDone = widget.setInfoIndex <
        widget.model.setInfoCompleteList[widget.model.exerciseIndex];

    return Column(
      children: [
        SizedBox(
          height: 85,
          width: 100.w - 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    height: 40,
                    width: 1,
                    color: Pallete.lightGray,
                  ),
                  HexagonContainer(
                    label: (widget.setInfoIndex + 1).toString(),
                    iconFile: isDone ? SVGConstants.checkSetInfo : null,
                    labelColor: isNowSet ? Colors.black : Pallete.gray,
                    color: isNowSet
                        ? Colors.white
                        : isDone
                            ? Pallete.point
                            : Pallete.lightGray,
                    lineColor:
                        isNowSet || isDone ? Pallete.point : Pallete.lightGray,
                    size: 39,
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Container(
                    height: 4,
                    width: 1,
                    color: Pallete.lightGray,
                  ),
                ],
              ),
              const SizedBox(
                width: 15,
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 35,
                  ),
                  Container(
                    width: 100.w - 110,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      border: Border.all(
                        color: widget.setInfoIndex ==
                                widget.model.setInfoCompleteList[
                                    widget.model.exerciseIndex]
                            ? Pallete.point
                            : Colors.white,
                        width: 3,
                      ),
                      color: Colors.white,
                    ),
                    child: SizedBox(
                      width: 100.w - 110,
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: SetInfoTextField(
                              // initValue: widget.initialReps.toString(),
                              textColor: isNowSet ? Colors.black : Pallete.gray,
                              controller: repsController,
                              onChanged: (value) {
                                if (int.parse(value) < 1) {
                                  value = 1.toString();
                                }

                                if (int.parse(value) > 99) {
                                  value = 99.toString();
                                  repsController.text = 99.toString();
                                }

                                if (value.isNotEmpty) {
                                  ref
                                      .read(workoutProcessProvider(
                                              widget.workoutScheduleId)
                                          .notifier)
                                      .modifiedReps(int.parse(value),
                                          widget.setInfoIndex);
                                }
                              },
                              textInputType:
                                  const TextInputType.numberWithOptions(),
                            ),
                          ),
                          Text(
                            '회',
                            style: s1SubTitle.copyWith(),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        if (widget.setInfoIndex ==
            widget.model.exercises[widget.model.exerciseIndex].setInfo.length -
                1)
          Container(
            height: 100,
          )
      ],
    );
  }
}
