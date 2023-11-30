import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/workout/model/workout_result_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class ScheduleResultSetInfoScreen extends StatefulWidget {
  final List<WorkoutRecord> workoutRecords;

  const ScheduleResultSetInfoScreen({
    super.key,
    required this.workoutRecords,
  });

  @override
  State<ScheduleResultSetInfoScreen> createState() =>
      _ScheduleResultSetInfoScreenState();
}

class _ScheduleResultSetInfoScreenState
    extends State<ScheduleResultSetInfoScreen> {
  @override
  Widget build(BuildContext context) {
    for (var element in widget.workoutRecords) {
      print(element.toJson());
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Pallete.background,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Icon(Icons.arrow_back)),
          ),
        ),
        backgroundColor: Pallete.background,
        body: ListView.separated(
          itemCount: widget.workoutRecords.length,
          itemBuilder: (context, index) {
            return Text(
              widget.workoutRecords[index].exerciseName,
              style: h1Headline.copyWith(
                color: Colors.white,
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(
            height: 30,
          ),
        )
        // Center(
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Text(
        //         DataUtils.getTimeStringMinutes(999),
        //         style: h1Headline.copyWith(
        //           color: Colors.white,
        //         ),
        //       ),
        //       const Divider(
        //         color: Pallete.gray,
        //         thickness: 1,
        //       ),
        //       Text(
        //         DataUtils.getTimeStringHour(1200),
        //         style: h1Headline.copyWith(
        //           color: Colors.white,
        //         ),
        //       ),
        //       SvgPicture.asset(
        //         SVGConstants.history,
        //         width: 30,
        //         colorFilter:
        //             const ColorFilter.mode(Pallete.point, BlendMode.srcIn),
        //       )
        //     ],
        //   ),
        // ),
        );
  }
}
