import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/schedule/model/workout_schedule_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LastScheduleBox extends StatefulWidget {
  final String startDate;
  final List<WorkoutData> workoutSchedules;

  const LastScheduleBox({
    super.key,
    required this.startDate,
    required this.workoutSchedules,
  });

  @override
  State<LastScheduleBox> createState() => _LastScheduleBoxState();
}

class _LastScheduleBoxState extends State<LastScheduleBox> {
  @override
  Widget build(BuildContext context) {
    final lastWeek = widget.workoutSchedules.sublist(0, 7);
    final thisWeek = widget.workoutSchedules.sublist(7, 14);

    print('lastWeek $lastWeek');
    print('thisWeek $thisWeek');

    return Container(
      width: 100.w,
      height: 225,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Pallete.darkGray,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _WeekComponet(
              week: lastWeek,
              widget: widget,
              title: '지난주',
            ),
            _WeekComponet(
              week: thisWeek,
              widget: widget,
              title: '이번주',
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekComponet extends StatelessWidget {
  const _WeekComponet({
    required this.week,
    required this.widget,
    required this.title,
  });

  final List<WorkoutData> week;
  final LastScheduleBox widget;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              title,
              style: s2SubTitle.copyWith(color: Pallete.lightGray),
            ),
            const Spacer(),
            Text(
              ' ${DateFormat('MM.dd').format(week.first.startDate)} -',
              style: s2SubTitle.copyWith(color: Pallete.lightGray),
            ),
            Text(
              ' ${DateFormat('MM.dd').format(week.last.startDate)}',
              style: s2SubTitle.copyWith(color: Pallete.lightGray),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: week
              .map(
                (workoutData) => _WorkoutDayComponent(
                  startTime: DateTime.parse(widget.startDate),
                  workoutData: workoutData,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _WorkoutDayComponent extends StatelessWidget {
  final DateTime startTime;
  final WorkoutData workoutData;

  const _WorkoutDayComponent({
    required this.workoutData,
    required this.startTime,
  });

  @override
  Widget build(BuildContext context) {
    bool isWorkoutDay = workoutData.workouts!.isNotEmpty;
    bool isToday = workoutData.startDate.isAtSameMomentAs(startTime);
    bool isAttend = false;
    if (workoutData.workouts != null) {
      for (var workout in workoutData.workouts!) {
        if (workout.isComplete) {
          isAttend = true;
          break;
        }
      }
    }
    return Column(
      children: [
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isAttend ? Pallete.point : Colors.transparent,
            border: Border.all(
              color: isWorkoutDay ? Pallete.point : Pallete.lightGray,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              DateFormat('d').format(workoutData.startDate),
              style: h6Headline.copyWith(
                color: isWorkoutDay ? Colors.white : Pallete.gray,
                height: 1,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          weekday[workoutData.startDate.weekday - 1],
          style: s3SubTitle.copyWith(
            color: isToday ? Colors.white : Pallete.gray,
          ),
        ),
      ],
    );
  }
}
