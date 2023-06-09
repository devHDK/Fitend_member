import 'package:fitend_member/common/component/calendar.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ndialog/ndialog.dart';

class DialogTools {
  static DialogBackground confirmDialog({
    required String message,
    required String confirmText,
    required String cancelText,
    required GestureTapCallback confirmOnTap,
    required GestureTapCallback cancelOnTap,
  }) {
    return DialogBackground(
      blur: 0.2,
      dialog: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 319,
          height: 204,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: confirmOnTap,
                  child: Container(
                    width: 279,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: POINT_COLOR,
                    ),
                    child: Center(
                      child: Text(
                        confirmText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                GestureDetector(
                  onTap: cancelOnTap,
                  child: Container(
                    width: 279,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: POINT_COLOR),
                    ),
                    child: Center(
                      child: Text(
                        cancelText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: POINT_COLOR,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  static DialogBackground errorDialog({
    required String message,
    required String confirmText,
    required GestureTapCallback confirmOnTap,
  }) {
    return DialogBackground(
      blur: 0.3,
      dialog: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 319,
          height: 135,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: confirmOnTap,
                  child: Container(
                    width: 279,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: POINT_COLOR,
                    ),
                    child: Center(
                      child: Text(
                        confirmText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CalendarDialog extends ConsumerStatefulWidget {
  const CalendarDialog({
    super.key,
    required this.scheduleDate,
  });

  final DateTime scheduleDate;

  @override
  ConsumerState<CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends ConsumerState<CalendarDialog> {
  DateTime selectedDay = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  DateTime focusedDay = DateTime.now();

  void changeScheduleDate() async {
    try {} catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return DialogBackground(
      blur: 0.2,
      dialog: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 319,
          height: 430,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Calendar(
                  scheduleDate: widget.scheduleDate,
                  focusedDay: focusedDay,
                  selectedDay: selectedDay,
                  onDaySelected: (selectedDay, focusedDay) {
                    print(selectedDay);
                    print(focusedDay);

                    setState(() {
                      this.selectedDay = selectedDay;
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        changeScheduleDate();

                        context.pop();
                      },
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
