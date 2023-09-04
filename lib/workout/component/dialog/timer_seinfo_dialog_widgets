import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/workout/component/setinfo_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ndialog/ndialog.dart';

class TimerSetinfoDialog extends StatefulWidget {
  const TimerSetinfoDialog({
    super.key,
    required this.initialTime,
  });

  final int initialTime;

  @override
  State<TimerSetinfoDialog> createState() => _TimerSetinfoDialogState();
}

class _TimerSetinfoDialogState extends State<TimerSetinfoDialog> {
  bool buttonEnable = true;
  final minController = TextEditingController();
  final secController = TextEditingController();

  @override
  void initState() {
    super.initState();
    minController.addListener(minControllerListener);
    secController.addListener(secControllerListener);

    minController.text = (widget.initialTime / 60).floor().toString();
    secController.text = (widget.initialTime % 60).toString();
  }

  @override
  void dispose() {
    minController.removeListener(minControllerListener);
    secController.removeListener(secControllerListener);
    super.dispose();
  }

  void minControllerListener() {
    try {
      if (minController.text.isNotEmpty && int.parse(minController.text) > 99) {
        minController.text = 99.toString();
      }

      buttonEnable = true;

      if (minController.text.isEmpty || secController.text.isEmpty) {
        buttonEnable = false;
      }

      if (int.parse(minController.text) < 1 &&
          int.parse(secController.text) < 1) {
        buttonEnable = false;
      }

      setState(() {});
    } catch (e) {
      setState(() {
        setState(() {
          buttonEnable = false;
        });
      });
    }
  }

  void secControllerListener() {
    try {
      if (secController.text.isNotEmpty && int.parse(secController.text) > 59) {
        secController.text = 59.toString();
      }

      buttonEnable = true;

      if (minController.text.isEmpty || secController.text.isEmpty) {
        buttonEnable = false;
      }

      if (int.parse(minController.text) < 1 &&
          int.parse(secController.text) < 1) {
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
                          controller: minController,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'min',
                        style: s1SubTitle.copyWith(
                          color: GRAY_COLOR,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        width: 24,
                      ),
                      Expanded(
                        child: SetInfoTextField(
                          controller: secController,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'sec',
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
                              'min': minController.text,
                              'sec': secController.text,
                            });
                          }
                        : null,
                    child: Container(
                      width: 300,
                      height: 46,
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
                            letterSpacing: 0,
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
