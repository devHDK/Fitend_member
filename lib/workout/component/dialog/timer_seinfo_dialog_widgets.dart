import 'package:fitend_member/common/const/colors.dart';
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
                        controller: minController,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    const Text(
                      'min',
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
                        controller: secController,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    const Text(
                      'sec',
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
                            'min': minController.text,
                            'sec': secController.text,
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
