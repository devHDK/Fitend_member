import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/workout/component/setinfo_text_field.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';

class TimerSetinfoDialog extends StatefulWidget {
  const TimerSetinfoDialog({
    super.key,
    required this.initialTime,
    required this.minController,
    required this.secController,
    required this.confirmOnTap,
  });

  final int initialTime;
  final TextEditingController minController;
  final TextEditingController secController;
  final GestureTapCallback confirmOnTap;

  @override
  State<TimerSetinfoDialog> createState() => _TimerSetinfoDialogState();
}

class _TimerSetinfoDialogState extends State<TimerSetinfoDialog> {
  @override
  void initState() {
    super.initState();
    widget.minController.addListener(minControllerListener);
    widget.secController.addListener(secControllerListener);
  }

  @override
  void dispose() {
    widget.minController.removeListener(minControllerListener);
    widget.secController.removeListener(secControllerListener);
    super.dispose();
  }

  void minControllerListener() {}
  void secControllerListener() {}

  @override
  Widget build(BuildContext context) {
    widget.minController.text = (widget.initialTime / 60).floor().toString();
    widget.secController.text = (widget.initialTime % 60).toString();

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
                        controller: widget.minController,
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
                        controller: widget.secController,
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
                  onTap: () => widget.confirmOnTap(),
                  child: Container(
                    width: 279,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: POINT_COLOR,
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
