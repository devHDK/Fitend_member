import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/schedule/model/workout_schedule_model.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatelessWidget {
  const Calendar({
    super.key,
    this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    required this.scheduleDate,
    required this.schedules,
  });
  final DateTime? selectedDay;
  final DateTime focusedDay;
  final DateTime scheduleDate;
  final OnDaySelected onDaySelected;
  final List<WorkoutData> schedules;

  @override
  Widget build(BuildContext context) {
    DateTime firstDay =
        scheduleDate.subtract(Duration(days: scheduleDate.weekday - 1));
    DateTime lastDay =
        scheduleDate.add(Duration(days: 7 - scheduleDate.weekday));
    Map<String, List<Workout>> map = {
      for (var data in schedules)
        "${data.startDate.month}-${data.startDate.day}": data.workouts!
    };

    return TableCalendar(
      startingDayOfWeek: StartingDayOfWeek.monday,
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
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (map["${day.month}-${day.day}"] != null) {
            return Positioned(
              bottom: 1,
              child: Row(
                  children: map["${day.month}-${day.day}"]!.map(
                (e) {
                  return Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                  );
                },
              ).toList()),
            );
          }
          return null;
        },
        headerTitleBuilder: (context, day) {
          return Center(
            child: Text(
              '${scheduleDate.year} ${scheduleDate.month}월',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        },
      ),
    );
  }
}
