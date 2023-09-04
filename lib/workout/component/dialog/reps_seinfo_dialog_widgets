import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
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
      dialog: SimpleDialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        children: [
          Container(
            width: 319,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '세트 수정',
                    style: h3Headline.copyWith(
                      height: 1,
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
                      Text(
                        '회',
                        style: s1SubTitle.copyWith(
                          color: GRAY_COLOR,
                          height: 1,
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
                      width: 300,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: buttonEnable
                            ? POINT_COLOR
                            : POINT_COLOR.withOpacity(0.3),
                      ),
                      child: Center(
                        child: Text(
                          '확인',
                          style: h6Headline.copyWith(
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
