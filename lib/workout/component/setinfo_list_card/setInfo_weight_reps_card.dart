import 'package:fitend_member/common/component/hexagon_container.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/workout/component/setinfo_text_field.dart';
import 'package:fitend_member/workout/model/workout_process_model.dart';
import 'package:fitend_member/workout/provider/workout_process_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SetInfoBoxForWeightReps extends ConsumerStatefulWidget {
  const SetInfoBoxForWeightReps({
    super.key,
    required this.model,
    required this.setInfoIndex,
    required this.initialWeight,
    required this.initialReps,
    required this.workoutScheduleId,
    required this.refresh,
  });

  final WorkoutProcessModel model;
  final int setInfoIndex;
  final double initialWeight;
  final int initialReps;
  final int workoutScheduleId;
  final Function refresh;

  @override
  ConsumerState<SetInfoBoxForWeightReps> createState() =>
      _SetInfoBoxForWeightRepsState();
}

class _SetInfoBoxForWeightRepsState
    extends ConsumerState<SetInfoBoxForWeightReps> {
  final repsController = TextEditingController();
  final weightController = TextEditingController();

  void repsControllerListener() {
    try {
      if (repsController.text.isNotEmpty &&
          int.parse(repsController.text) > 99) {
        repsController.text = 99.toString();
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  void weightControllerListener() {
    try {
      if (weightController.text.isNotEmpty &&
          double.parse(weightController.text) > 999.0) {
        weightController.text = (999.0).toString();
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  @override
  void initState() {
    super.initState();
    repsController.addListener(repsControllerListener);
    weightController.addListener(weightControllerListener);

    repsController.text = widget.initialReps.toString();
    weightController.text = widget.initialWeight.toString();
  }

  @override
  void dispose() {
    repsController.removeListener(repsControllerListener);
    weightController.removeListener(weightControllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNowSet = widget.setInfoIndex ==
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
                    color: LIGHT_GRAY_COLOR,
                  ),
                  HexagonContainer(
                    label: (widget.setInfoIndex + 1).toString(),
                    labelColor: isNowSet ? Colors.black : GRAY_COLOR,
                    color: isNowSet ? Colors.white : LIGHT_GRAY_COLOR,
                    lineColor: isNowSet ? POINT_COLOR : LIGHT_GRAY_COLOR,
                    size: 39,
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Container(
                    height: 4,
                    width: 1,
                    color: LIGHT_GRAY_COLOR,
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
                            ? POINT_COLOR
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
                          Expanded(
                            child: SetInfoTextField(
                              // initValue: widget.initialWeight.toString(),
                              textColor: isNowSet ? Colors.black : GRAY_COLOR,
                              controller: weightController,
                              onChanged: (value) {
                                if (double.parse(value) < 1) {
                                  value = 1.0.toString();
                                }

                                if (double.parse(value) > 999.0) {
                                  value = 999.0.toString();
                                  repsController.text = 999.0.toString();
                                }

                                if (value.isNotEmpty) {
                                  ref
                                      .read(workoutProcessProvider(
                                              widget.workoutScheduleId)
                                          .notifier)
                                      .modifiedWeight(double.parse(value),
                                          widget.setInfoIndex);
                                }
                              },
                              textInputType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              allowedDigits: r'^-?\d*\.?\d?',
                            ),
                          ),
                          Text(
                            'kg',
                            style: s1SubTitle.copyWith(
                              color: isNowSet ? Colors.black : GRAY_COLOR,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            '/',
                            style: s1SubTitle.copyWith(
                              color: isNowSet ? Colors.black : GRAY_COLOR,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: SetInfoTextField(
                              // initValue: widget.initialReps.toString(),
                              textColor: isNowSet ? Colors.black : GRAY_COLOR,
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
                            width: 20,
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
