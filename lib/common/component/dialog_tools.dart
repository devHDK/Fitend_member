import 'package:fitend_member/common/component/calendar.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/data/global_varialbles.dart';
import 'package:fitend_member/schedule/model/put_workout_schedule_date_model.dart';
import 'package:fitend_member/schedule/model/workout_schedule_model.dart';
import 'package:fitend_member/schedule/repository/workout_schedule_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
    required this.workoutScheduleId,
  });

  final DateTime scheduleDate;
  final int workoutScheduleId;

  @override
  ConsumerState<CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends ConsumerState<CalendarDialog> {
  DateTime? selectedDay;
  DateTime? focusedDay;
  DateTime? firstDay;
  DateTime? lastDay;
  Map<String, List<Workout>>? dateData = {};

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
    try {
      await ref.read(workoutScheduleRepositoryProvider).putworkoutScheduleDate(
            id: widget.workoutScheduleId,
            body: PutWorkoutScheduleModel(
              startDate: DateFormat('yyyy-MM-dd').format(selectedDay!),
              seq:
                  dateData!["${selectedDay!.month}-${selectedDay!.day}"] == null
                      ? 1
                      : dateData!["${selectedDay!.month}-${selectedDay!.day}"]!
                              .length +
                          1,
            ),
          );

      //이전 스케줄 인덱스
      final beforeChangeScheduleIndex =
          scheduleListGlobal.indexWhere((element) {
        return element.startDate == widget.scheduleDate;
      });

      print('beforeChangeScheduleIndex :  $beforeChangeScheduleIndex');

      //이전 워크아웃 인덱스
      final beforWorkoutIndex = scheduleListGlobal[beforeChangeScheduleIndex]
          .workouts!
          .indexWhere((element) =>
              element.workoutScheduleId == widget.workoutScheduleId);
      print('beforWorkoutIndex :  $beforWorkoutIndex');

      //변경할 날짜의 스케줄 인덱스
      final afterCahngeSchdedulIndex = scheduleListGlobal.indexWhere((element) {
        final localTime =
            DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(selectedDay!);
        return element.startDate == DateTime.parse(localTime);
      });

      print('afterCahngeSchdedulIndex :  $afterCahngeSchdedulIndex');

      //변경
      scheduleListGlobal[afterCahngeSchdedulIndex].workouts!.add(
          scheduleListGlobal[beforeChangeScheduleIndex]
              .workouts![beforWorkoutIndex]);

      //기존건 삭제
      scheduleListGlobal[beforeChangeScheduleIndex]
          .workouts!
          .removeAt(beforWorkoutIndex);
    } catch (e) {
      print(e);

      showDialog(
        context: context,
        builder: (context) => DialogTools.errorDialog(
          message: '오류가 발생하였습니다 다시 시도해주세요!',
          confirmText: '확인',
          confirmOnTap: () => context.pop(),
        ),
      );
    }
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

    Map<String, List<Workout>> dateMap = {
      for (var data in scheduleList)
        "${data.startDate.month}-${data.startDate.day}": data.workouts!
    };

    dateData = dateMap;

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
                    // if (dateMap["${selectedDay.month}-${selectedDay.day}"] !=
                    //     null) {
                    //   print(dateMap["${selectedDay.month}-${selectedDay.day}"]);
                    // }

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
                        if (selectedDay != null &&
                            selectedDay!.compareTo(widget.scheduleDate) != 0) {
                          changeScheduleDate();
                          context.pop({'changedDate': selectedDay});
                        } else {
                          print('오늘날짜 선택!');
                          showDialog(
                            context: context,
                            builder: (context) => DialogTools.errorDialog(
                              message: '오늘 이외의 날짜를 선택해주세요!',
                              confirmText: '확인',
                              confirmOnTap: () => context.pop(),
                            ),
                          );
                        }
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
