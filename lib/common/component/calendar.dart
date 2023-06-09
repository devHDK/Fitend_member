import 'package:fitend_member/common/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatelessWidget {
  const Calendar({
    super.key,
    this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    required this.scheduleDate,
  });
  final DateTime? selectedDay;
  final DateTime focusedDay;
  final DateTime scheduleDate;
  final OnDaySelected onDaySelected;

  @override
  Widget build(BuildContext context) {
    DateTime firstDay =
        scheduleDate.subtract(Duration(days: scheduleDate.weekday - 1));
    DateTime lastDay =
        scheduleDate.add(Duration(days: 7 - scheduleDate.weekday));

    return TableCalendar(
      focusedDay: focusedDay,
      firstDay: firstDay,
      lastDay: lastDay,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 19,
        ),
        leftChevronVisible: false,
        rightChevronVisible: false,
      ),
      calendarStyle: CalendarStyle(
          isTodayHighlighted: true,
          todayTextStyle: const TextStyle(
            color: Colors.black,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: POINT_COLOR,
            ),
            shape: BoxShape.circle,
          ),
          weekendTextStyle: const TextStyle(
            color: Colors.red,
          ),
          selectedDecoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: POINT_COLOR,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
          ),
          outsideDecoration: const BoxDecoration(
            shape: BoxShape.rectangle,
          )),
      onDaySelected: onDaySelected,
      selectedDayPredicate: (day) {
        if (selectedDay == null) {
          return false;
        }

        return day.year == selectedDay!.year &&
            day.month == selectedDay!.month &&
            day.day == selectedDay!.day;
      },
      availableGestures: AvailableGestures.all,
    );
  }
}
