import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/schedule/model/workout_schedule_model.dart';
import 'package:fitend_member/schedule/repository/workout_schedule_repository.dart';
import 'package:fitend_member/workout/view/workout_feedback_screen.dart';
import 'package:fitend_member/workout/view/workout_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ScheduleCard extends ConsumerStatefulWidget {
  final DateTime? date;
  final String? title;
  final String? subTitle;
  final String? time;
  final bool? isComplete;
  final bool? isRecord;
  final String? type;
  final bool selected;
  final bool? isDateVisible;
  final int? workoutScheduleId;
  final Function? onNotifyParent;
  final List<Exercise>? exercises;

  const ScheduleCard({
    super.key,
    this.date,
    this.title,
    this.subTitle,
    this.time,
    this.isComplete,
    this.isRecord,
    this.type,
    required this.selected,
    this.isDateVisible = true,
    this.workoutScheduleId,
    this.onNotifyParent,
    this.exercises,
  });

  factory ScheduleCard.fromModel({
    DateTime? date,
    required Workout model,
    bool? isDateVisible,
    VoidCallback? onNotifyParent,
    List<Exercise>? exercises,
  }) {
    return ScheduleCard(
      date: date,
      title: model.title,
      subTitle: model.subTitle,
      isComplete: model.isComplete,
      isRecord: model.isRecord,
      type: '',
      selected: model.selected!,
      isDateVisible: isDateVisible,
      workoutScheduleId: model.workoutScheduleId,
      onNotifyParent: onNotifyParent ?? onNotifyParent,
      exercises: exercises ?? exercises,
    );
  }

  @override
  ConsumerState<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends ConsumerState<ScheduleCard> {
  DateTime today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.selected ? 175 : 130,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.transparent,
        image: widget.selected
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
                      color: (widget.selected &&
                                  widget.isDateVisible! &&
                                  widget.date != null) ||
                              (widget.date != null &&
                                  widget.date!.compareTo(today) == 0 &&
                                  widget.isDateVisible == true)
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
                        if (widget.date != null)
                          Text(
                            weekday[widget.date!.weekday - 1],
                            style: TextStyle(
                              color: widget.isDateVisible!
                                  ? Colors.white
                                  : Colors.transparent,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        const SizedBox(
                          height: 5,
                        ),
                        if (widget.date != null)
                          Text(
                            widget.date!.day.toString(),
                            style: TextStyle(
                              color: widget.isDateVisible!
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
                        widget.title != null ? widget.title! : '',
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
                        widget.subTitle != null ? widget.subTitle! : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                ),
                if (widget.isComplete == null)
                  const SizedBox(
                    width: 24,
                  )
                else if (!widget.isComplete! &&
                    !widget.selected &&
                    widget.date!.isAfter(today)) //오늘, 오늘 이후 스케줄이 미완료
                  Image.asset('asset/img/round_checked.png')
                else if (!widget.isComplete! &&
                    !widget.selected &&
                    widget.date!.isBefore(today)) // 어제 스케줄이 미완료
                  Image.asset('asset/img/round_fail.png')
                else if (widget.isComplete! && !widget.selected)
                  Image.asset('asset/img/round_success.png') // 스케줄이 완료 일때
              ],
            ),
            if (widget.selected)
              Column(
                children: [
                  const SizedBox(
                    height: 23,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (widget.isRecord! && !widget.isComplete!)
                                ? Colors.white
                                : POINT_COLOR,
                      ),
                      onPressed: widget.workoutScheduleId == null
                          ? null
                          : (widget.isRecord! && !widget.isComplete!)
                              ? () async {
                                  await ref
                                      .read(workoutScheduleRepositoryProvider)
                                      .getWorkout(id: widget.workoutScheduleId!)
                                      .then((value) {
                                    GoRouter.of(context).goNamed(
                                        WorkoutFeedbackScreen.routeName,
                                        pathParameters: {
                                          'workoutScheduleId': widget
                                              .workoutScheduleId
                                              .toString(),
                                        },
                                        extra: value.exercises,
                                        queryParameters: {
                                          'startDate': value.startDate
                                        });
                                  });
                                }
                              : () async {
                                  var dateChanged = await context.pushNamed(
                                      WorkoutListScreen.routeName,
                                      pathParameters: {
                                        'workoutScheduleId': widget
                                            .workoutScheduleId!
                                            .toString(),
                                      });

                                  if (dateChanged == true &&
                                      widget.onNotifyParent != null) {
                                    widget.onNotifyParent!();
                                  }
                                },
                      child: Text(
                        (widget.isRecord! && !widget.isComplete!)
                            ? '운동 평가하기 📝'
                            : '운동확인 하기🔍',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: (widget.isRecord! && !widget.isComplete!)
                                ? POINT_COLOR
                                : Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            if (!widget.selected)
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
