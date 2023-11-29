import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/schedule/model/workout_schedule_model.dart';
import 'package:flutter/widgets.dart';
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
      child: const Column(
        children: [
          Row(
            children: [],
          )
        ],
      ),
    );
  }
}
