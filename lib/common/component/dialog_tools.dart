import 'package:fitend_member/common/component/calendar.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/data/global_varialbles.dart';
import 'package:fitend_member/schedule/model/workout_schedule_model.dart';
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
  DateTime? selectedDay;
  DateTime? focusedDay;
  DateTime? firstDay;
  DateTime? lastDay;

  @override
  void initState() {
    super.initState();
    selectedDay = widget.scheduleDate;
    focusedDay = widget.scheduleDate;
    firstDay = widget.scheduleDate
        .subtract(Duration(days: widget.scheduleDate.weekday - 1));
    lastDay = lastDay = widget.scheduleDate
        .add(Duration(days: 7 - widget.scheduleDate.weekday));
  }

  void changeScheduleDate() async {
    try {} catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    List<WorkoutData> scheduleList = [];
    if (firstDay != null && lastDay != null) {
      scheduleList = scheduleListGlobal
          .where((element) =>
              element.startDate.compareTo(firstDay!) >= 0 &&
              element.startDate.compareTo(lastDay!) <= 0 &&
              element.workouts!.isNotEmpty)
          .toList();
    }

    Map<String, List<Workout>> map = {
      for (var data in scheduleList)
        "${data.startDate.month}-${data.startDate.day}": data.workouts!
    };

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
                  schedules: scheduleList,
                  scheduleDate: widget.scheduleDate,
                  focusedDay:
                      focusedDay != null ? focusedDay! : widget.scheduleDate,
                  selectedDay: selectedDay != null ? selectedDay! : null,
                  onDaySelected: (selectedDay, focusedDay) {
                    if (map["${selectedDay.month}-${selectedDay.day}"] !=
                        null) {
                      print(map["${selectedDay.month}-${selectedDay.day}"]);
                    }

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
