import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/workout/component/setinfo_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ndialog/ndialog.dart';

class RepsXWeightSetinfoDialog extends StatefulWidget {
  const RepsXWeightSetinfoDialog({
    super.key,
    required this.initialReps,
    required this.initialWeight,
  });

  final int initialReps;
  final double initialWeight;

  @override
  State<RepsXWeightSetinfoDialog> createState() =>
      _RepsXWeightSetinfoDialogState();
}

class _RepsXWeightSetinfoDialogState extends State<RepsXWeightSetinfoDialog> {
  bool buttonEnable = true;
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

  @override
  void dispose() {
    repsController.removeListener(repsControllerListener);
    weightController.removeListener(weightControllerListener);
    super.dispose();
  }

  void repsControllerListener() {
    try {
      if (repsController.text.isNotEmpty &&
          int.parse(repsController.text) > 99) {
        repsController.text = 99.toString();
      }

      buttonEnable = true;

      if (weightController.text.isEmpty || repsController.text.isEmpty) {
        buttonEnable = false;
      }

      if (double.parse(weightController.text) < 0.1 ||
          int.parse(repsController.text) < 1) {
        buttonEnable = false;
      }

      setState(() {});
    } catch (e) {
      setState(() {
        buttonEnable = false;
      });
    }
  }

  void weightControllerListener() {
    try {
      if (weightController.text.isNotEmpty &&
          double.parse(weightController.text) > 999.0) {
        weightController.text = (999.0).toString();
      }

      buttonEnable = true;

      if (weightController.text.isEmpty || repsController.text.isEmpty) {
        buttonEnable = false;
      }

      if (double.parse(weightController.text) < 0.1 ||
          int.parse(repsController.text) < 1) {
        buttonEnable = false;
      }

      setState(() {});
    } catch (e) {
      setState(() {
        buttonEnable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogBackground(
      blur: 0.2,
      dismissable: false,
      dialog: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 319,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '세트 수정',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SetInfoTextField(
                        controller: weightController,
                        textInputType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        allowedDigits: r'^-?\d*\.?\d?',
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    const Text(
                      'kg',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: GRAY_COLOR,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      width: 24,
                    ),
                    Expanded(
                      child: SetInfoTextField(
                        controller: repsController,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    const Text(
                      '회',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: GRAY_COLOR,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: buttonEnable
                      ? () => {
                            context.pop({
                              'weight': weightController.text,
                              'reps': repsController.text,
                            })
                          }
                      : null,
                  child: Container(
                    width: 279,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: buttonEnable
                          ? POINT_COLOR
                          : POINT_COLOR.withOpacity(0.3),
                    ),
                    child: const Center(
                      child: Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
