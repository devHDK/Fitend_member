import 'package:fitend_member/common/component/hexagon_container.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/workout/component/setinfo_text_field.dart';
import 'package:fitend_member/workout/model/workout_process_model.dart';
import 'package:flutter/material.dart';

class SetInfoBoxForWeightReps extends StatefulWidget {
  const SetInfoBoxForWeightReps({
    super.key,
    required this.model,
    required this.setInfoIndex,
    required this.initialWeight,
    required this.initialReps,
  });

  final WorkoutProcessModel model;
  final int setInfoIndex;
  final double initialWeight;
  final int initialReps;

  @override
  State<SetInfoBoxForWeightReps> createState() =>
      _SetInfoBoxForWeightRepsState();
}

class _SetInfoBoxForWeightRepsState extends State<SetInfoBoxForWeightReps> {
  final repsController = TextEditingController();
  final weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    repsController.addListener(repsControllerListener);
    weightController.addListener(weightControllerListener);

    repsController.text = widget.initialReps.toString();
    weightController.text = widget.initialWeight.toString();
  }

  void repsControllerListener() {
    try {
      if (repsController.text.isNotEmpty &&
          int.parse(repsController.text) > 99) {
        repsController.text = 99.toString();
      }

      if (weightController.text.isEmpty || repsController.text.isEmpty) {}

      if (double.parse(weightController.text) < 0.1 ||
          int.parse(repsController.text) < 1) {}

      setState(() {});
    } catch (e) {
      setState(() {});
    }
  }

  void weightControllerListener() {
    try {
      if (weightController.text.isNotEmpty &&
          double.parse(weightController.text) > 999.0) {
        weightController.text = (999.0).toString();
      }

      if (weightController.text.isEmpty || repsController.text.isEmpty) {}

      if (double.parse(weightController.text) < 0.1 ||
          int.parse(repsController.text) < 1) {}

      setState(() {});
    } catch (e) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    repsController.removeListener(repsControllerListener);
    weightController.removeListener(weightControllerListener);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 85,
          width: MediaQuery.of(context).size.width - 56,
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
                    labelColor: Colors.black,
                    color: widget.setInfoIndex == widget.model.exerciseIndex
                        ? Colors.white
                        : LIGHT_GRAY_COLOR,
                    lineColor: widget.setInfoIndex == widget.model.exerciseIndex
                        ? POINT_COLOR
                        : LIGHT_GRAY_COLOR,
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
                width: 20,
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 36,
                  ),
                  Container(
                    width: 260,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      border: Border.all(
                        color: widget.setInfoIndex == widget.model.exerciseIndex
                            ? POINT_COLOR
                            : Colors.white,
                        width: 3,
                      ),
                      color: Colors.white,
                    ),
                    child: SizedBox(
                      width: 255,
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
                              controller: weightController,
                              textInputType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              allowedDigits: r'^-?\d*\.?\d?',
                            ),
                          ),
                          Text(
                            'kg',
                            style: s1SubTitle.copyWith(),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            '/',
                            style: s1SubTitle.copyWith(),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: SetInfoTextField(
                              controller: repsController,
                              textInputType:
                                  const TextInputType.numberWithOptions(),
                            ),
                          ),
                          Text(
                            '회',
                            style: s1SubTitle.copyWith(),
                          ),
                          const SizedBox(
                            width: 10,
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
