import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/schedule/model/workout_schedule_model.dart';
import 'package:fitend_member/workout/view/workout_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScheduleCard extends StatelessWidget {
  final DateTime? date;
  final String? title;
  final String? subTitle;
  final String? time;
  final bool? isComplete;
  final String? type;
  final bool selected;
  final bool? isDateVisible;
  final int? workoutScheduleId;

  const ScheduleCard({
    super.key,
    this.date,
    this.title,
    this.subTitle,
    this.time,
    this.isComplete,
    this.type,
    required this.selected,
    this.isDateVisible = true,
    this.workoutScheduleId,
  });

  factory ScheduleCard.fromModel({
    DateTime? date,
    required Workout model,
    bool? isDateVisible,
  }) {
    return ScheduleCard(
      date: date,
      title: model.title,
      subTitle: model.subTitle,
      isComplete: model.isComplete,
      type: '',
      selected: model.selected!,
      isDateVisible: isDateVisible,
      workoutScheduleId: model.workoutScheduleId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: selected ? 175 : 130,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.transparent,
        image: selected
            ? const DecorationImage(
                image: AssetImage("asset/img/schedule_image_pt.png"),
                fit: BoxFit.fill,
                opacity: 0.3)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 35,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selected && isDateVisible! && date != null
                          ? Colors.white
                          : Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    // image: ,
                  ),
                  width: 39,
                  height: 58,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        if (date != null)
                          Text(
                            weekday[date!.weekday - 1],
                            style: TextStyle(
                              color: isDateVisible!
                                  ? Colors.white
                                  : Colors.transparent,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        const SizedBox(
                          height: 5,
                        ),
                        if (date != null)
                          Text(
                            date!.day.toString(),
                            style: TextStyle(
                              color: isDateVisible!
                                  ? Colors.white
                                  : Colors.transparent,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title != null ? title! : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        subTitle != null ? subTitle! : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                ),
                if (isComplete == null)
                  const SizedBox(
                    width: 24,
                  )
                else if (!isComplete! &&
                    !selected &&
                    date!.isAfter(
                      DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                      ),
                    )) //오늘, 오늘 이후 스케줄이 미완료
                  Image.asset('asset/img/round_checked.png')
                else if (!isComplete! &&
                    !selected &&
                    date!.isBefore(
                      DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                      ),
                    )) // 어제 스케줄이 미완료
                  Image.asset('asset/img/round_fail.png')
                else if (isComplete! && !selected)
                  Image.asset('asset/img/round_success.png') // 스케줄이 완료 일때
              ],
            ),
            if (selected)
              Column(
                children: [
                  const SizedBox(
                    height: 23,
                  ),
                  SizedBox(
                    width: 319,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: POINT_COLOR,
                      ),
                      onPressed: workoutScheduleId == null
                          ? null
                          : () {
                              context.goNamed(WorkoutScreen.routeName,
                                  pathParameters: {
                                    'workoutScheduleId':
                                        workoutScheduleId!.toString(),
                                  });
                            },
                      child: const Text(
                        '운동확인 하기🔍',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            if (!selected)
              const SizedBox(
                height: 35,
              ),
            const Divider(
              color: DARK_GRAY_COLOR,
              height: 1,
            ),
          ],
        ),
      ),
    );
  }
}
