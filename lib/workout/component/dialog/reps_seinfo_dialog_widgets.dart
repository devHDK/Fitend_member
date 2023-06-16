import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/workout/component/setinfo_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ndialog/ndialog.dart';

class RepsSetinfoDialog extends StatefulWidget {
  const RepsSetinfoDialog({
    super.key,
    required this.initialReps,
  });

  final int initialReps;

  @override
  State<RepsSetinfoDialog> createState() => _RepsSetinfoDialogState();
}

class _RepsSetinfoDialogState extends State<RepsSetinfoDialog> {
  bool buttonEnable = true;
  final repsController = TextEditingController();

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

  void repsControllerListener() {
    try {
      if (repsController.text.isNotEmpty &&
          int.parse(repsController.text) > 99) {
        repsController.text = 99.toString();
      }

      buttonEnable = true;

      if (repsController.text.isEmpty) {
        buttonEnable = false;
      }

      if (int.parse(repsController.text) < 1) {
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
                      ? () {
                          context.pop({
                            'reps': repsController.text,
                          });
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
