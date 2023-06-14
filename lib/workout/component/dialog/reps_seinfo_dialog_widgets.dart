import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/workout/component/setinfo_text_field.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';

class RepsSetinfoDialog extends StatefulWidget {
  const RepsSetinfoDialog({
    super.key,
    required this.initialReps,
    required this.repsController,
    required this.confirmOnTap,
  });

  final int initialReps;
  final TextEditingController repsController;
  final GestureTapCallback confirmOnTap;

  @override
  State<RepsSetinfoDialog> createState() => _RepsSetinfoDialogState();
}

class _RepsSetinfoDialogState extends State<RepsSetinfoDialog> {
  @override
  void initState() {
    widget.repsController.addListener(repsControllerListener);

    super.initState();
  }

  @override
  void dispose() {
    widget.repsController.removeListener(repsControllerListener);

    super.dispose();
  }

  void repsControllerListener() {}
  void weightControllerListener() {}

  @override
  Widget build(BuildContext context) {
    widget.repsController.text = widget.initialReps.toString();

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
                        controller: widget.repsController,
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
