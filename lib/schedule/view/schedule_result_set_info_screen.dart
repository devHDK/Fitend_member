import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:fitend_member/workout/model/workout_result_model.dart';
import 'package:fitend_member/workout/provider/workout_provider.dart';
import 'package:fitend_member/workout/view/workout_history_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ScheduleResultSetInfoScreen extends ConsumerStatefulWidget {
  final List<WorkoutRecord> workoutRecords;
  final String startDate;
  final int workoutScheduleId;

  const ScheduleResultSetInfoScreen({
    super.key,
    required this.workoutRecords,
    required this.startDate,
    required this.workoutScheduleId,
  });

  @override
  ConsumerState<ScheduleResultSetInfoScreen> createState() =>
      _ScheduleResultSetInfoScreenState();
}

class _ScheduleResultSetInfoScreenState
    extends ConsumerState<ScheduleResultSetInfoScreen> {
  @override
  Widget build(BuildContext context) {
    int completeCount = 0;
    final state = ref.watch(workoutProvider(widget.workoutScheduleId));

    if (state is WorkoutModelLoading) {
      return const Scaffold(
        backgroundColor: Pallete.background,
        body: Center(
          child: CircularProgressIndicator(
            color: Pallete.point,
          ),
        ),
      );
    }

    if (state is WorkoutModelError) {
      return Scaffold(
        backgroundColor: Pallete.background,
        body: DialogWidgets.errorDialog(
          message: state.message,
          confirmText: '확인',
          confirmOnTap: () => context.pop(),
        ),
      );
    }

    final workoutModel = state as WorkoutModel;

    for (var record in widget.workoutRecords) {
      for (var set in record.setInfo) {
        if (set.weight != null || set.reps != null || set.seconds != null) {
          completeCount++;
          break;
        }
      }
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
        title: Text(
          '${DateFormat('M월 d일').format(DateTime.parse(widget.startDate))} ${weekday[DateTime.parse(widget.startDate).weekday - 1]}요일',
          style: h4Headline,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Pallete.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '총 $completeCount개의 운동을 완료했어요 🏋🏼‍♂️',
                    style: h4Headline.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Divider(
                    color: Pallete.gray,
                    thickness: 1,
                  ),
                  const SizedBox(
                    height: 9,
                  )
                ],
              ),
            ),
            SliverList.separated(
              itemCount: widget.workoutRecords.length,
              itemBuilder: (context, index) {
                Set targetMuscles = {};
                for (var targetMuscle
                    in workoutModel.exercises[index].targetMuscles) {
                  if (targetMuscle.type == 'main') {
                    targetMuscles.add(targetMuscle.name);
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.workoutRecords[index].exerciseName,
                          style: h5Headline.copyWith(
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            FirebaseAnalytics.instance
                                .logEvent(name: 'history_screen_from_result');

                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => WorkoutHistoryScreen(
                                  workoutPlanId: widget
                                      .workoutRecords[index].workoutPlanId,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: SvgPicture.asset(SVGConstants.history)),
                        )
                      ],
                    ),
                    // const SizedBox(
                    //   height: 6,
                    // ),
                    Text(
                      targetMuscles.join(' ∙ '),
                      style: s2SubTitle.copyWith(color: Pallete.lightGray),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Container(
                      width: 100.w,
                      decoration: BoxDecoration(
                        color: Pallete.darkGray,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        child: Column(
                          children: [
                            ...widget.workoutRecords[index].setInfo.map((set) {
                              switch (widget
                                  .workoutRecords[index].trackingFieldId) {
                                case 1:
                                  return _setInfoCellWeightReps(set);
                                case 2:
                                  return _setInfoCellReps(set);
                                default:
                                  return _setInfoCellTimer(set);
                              }
                            })
                          ],
                        ),
                      ),
                    )
                  ],
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 30),
            )
          ],
        ),
      ),
    );
  }

  Padding _setInfoCellWeightReps(SetInfo set) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${set.index} Set',
            style: s2SubTitle.copyWith(
              color: Pallete.lightGray,
            ),
          ),
          Text(
            set.weight != null ? '${set.weight}kg' : '-',
            style: s2SubTitle.copyWith(
              color: Pallete.lightGray,
            ),
          ),
          Text(
            set.reps != null ? '${set.reps}회' : '-',
            style: s2SubTitle.copyWith(
              color: Pallete.lightGray,
            ),
          ),
          Text(
            set.reps != null && set.weight != null ? '✅' : '❌',
          ),
        ],
      ),
    );
  }

  Padding _setInfoCellReps(SetInfo set) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${set.index} Set',
            style: s2SubTitle.copyWith(
              color: Pallete.lightGray,
            ),
          ),
          Text(
            set.reps != null ? '${set.reps}회' : '-',
            style: s2SubTitle.copyWith(
              color: Pallete.lightGray,
            ),
          ),
          Text(
            set.reps != null ? '✅' : '❌',
          ),
        ],
      ),
    );
  }

  Padding _setInfoCellTimer(SetInfo set) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${set.index} Set',
            style: s2SubTitle.copyWith(
              color: Pallete.lightGray,
            ),
          ),
          Text(
            set.seconds != null
                ? DataUtils.getTimeStringHour(set.seconds!)
                : '-',
            style: s2SubTitle.copyWith(
              color: Pallete.lightGray,
            ),
          ),
          Text(
            set.seconds != null ? '✅' : '❌',
          ),
        ],
      ),
    );
  }
}
