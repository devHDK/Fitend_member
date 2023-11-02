import 'dart:async';

import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/provider/hive_modified_exercise_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/workout/component/workout_card.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:fitend_member/workout/model/workout_process_model.dart';
import 'package:fitend_member/workout/provider/workout_process_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class WorkoutChangeScreen extends ConsumerStatefulWidget {
  static String get routeName => 'workoutChange';
  final int exerciseIndex;
  final WorkoutModel workout;

  const WorkoutChangeScreen({
    super.key,
    required this.exerciseIndex,
    required this.workout,
  });

  @override
  ConsumerState<WorkoutChangeScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends ConsumerState<WorkoutChangeScreen> {
  late int selectedIndex;
  final ItemScrollController itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();

    selectedIndex = widget.exerciseIndex;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      int index = widget.exerciseIndex > 0
          ? widget.exerciseIndex - 1
          : widget.exerciseIndex;

      itemScrollController.jumpTo(index: index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Box> recordSimplebox =
        ref.watch(hiveWorkoutRecordSimpleProvider);
    final AsyncValue<Box> modifiedExerciseBox =
        ref.read(hiveModifiedExerciseProvider);

    final state =
        ref.watch(workoutProcessProvider(widget.workout.workoutScheduleId))
            as WorkoutProcessModel;

    var model = widget.workout;

    modifiedExerciseBox.whenData(
      (value) {
        for (var exercise in model.exercises) {
          if ((exercise.trackingFieldId == 3 ||
                  exercise.trackingFieldId == 4) &&
              exercise.setInfo.length == 1) {
            final record = value.get(exercise.workoutPlanId);
            if (record is Exercise && record.setInfo[0].seconds != null) {
              exercise.setInfo[0] = record.setInfo[0];
            }
          }
        }
      },
    );

    List<int> circuitGroupNumList = [];

    for (var exercise in model.exercises) {
      if (exercise.circuitGroupNum != null) {
        circuitGroupNumList.add(exercise.circuitGroupNum!);
      }
    }

    Map<int, int> groupCounts =
        circuitGroupNumList.fold({}, (Map<int, int> map, element) {
      if (!map.containsKey(element)) {
        map[element] = 1;
      } else if (map.containsKey(element)) {
        map[element] = map[element]! + 1;
      }
      return map;
    });

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 18),
          child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back)),
        ),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('asset/img/icon_red_dot.svg'),
            const SizedBox(
              width: 5,
            ),
            Text(
              DataUtils.getTimeStringHour(state.totalTime),
              style: h4Headline.copyWith(
                color: Colors.white,
                height: 1.1,
              ),
            ),
          ],
        ),
        actions: const [Padding(padding: EdgeInsets.symmetric(horizontal: 28))],
      ),
      body: ScrollablePositionedList.builder(
        itemCount: model.exercises.length,
        itemScrollController: itemScrollController,
        itemBuilder: (context, index) {
          final exerciseModel = model.exercises[index];
          int completeSetCount = 0;
          recordSimplebox.when(
            data: (data) {
              final record = data.get(exerciseModel.workoutPlanId);
              if (record != null) {
                completeSetCount = record.setInfo.length;
              } else {
                completeSetCount = 0;
              }
            },
            error: (error, stackTrace) => completeSetCount = 0,
            loading: () => debugPrint('loading...'),
          );

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Column(
              children: [
                if (exerciseModel.circuitGroupNum != null &&
                    exerciseModel.circuitSeq == 1)
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 58,
                          ),
                          SvgPicture.asset('asset/img/icon_turn_down.svg'),
                        ],
                      ),
                    ],
                  )
                else if (exerciseModel.circuitGroupNum != null)
                  Row(children: [
                    const SizedBox(
                      width: 58,
                    ),
                    SvgPicture.asset('asset/img/icon_turn_line.svg'),
                    const SizedBox(
                      width: 10,
                    ),
                    SvgPicture.asset('asset/img/icon_turn_line.svg'),
                  ]),
                WorkoutCard(
                  exercise: exerciseModel,
                  completeSetCount: completeSetCount,
                  exerciseIndex: widget.exerciseIndex == index
                      ? widget.exerciseIndex
                      : null,
                  isSelected: selectedIndex == index ? true : false,
                ),
                if (exerciseModel.circuitGroupNum != null &&
                    groupCounts[exerciseModel.circuitGroupNum!] ==
                        exerciseModel.circuitSeq!)
                  Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 58,
                          ),
                          SvgPicture.asset('asset/img/icon_turn_up.svg'),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                if (model.exercises.length - 1 == index)
                  const SizedBox(
                    height: 100,
                  )
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          width: 100.w,
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selectedIndex == widget.exerciseIndex
                ? POINT_COLOR.withOpacity(0.4)
                : POINT_COLOR,
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            onPressed: selectedIndex == widget.exerciseIndex
                ? () {}
                : () {
                    recordSimplebox.whenData(
                      (data) {
                        final record = data.get(widget
                            .workout.exercises[selectedIndex].workoutPlanId);

                        if (record != null &&
                            widget.workout.exercises[selectedIndex].setInfo
                                    .length <=
                                record.setInfo.length) {
                          DialogWidgets.errorDialog(
                            message: '이미 완료한 운동이에요 😗',
                            confirmText: '확인',
                            confirmOnTap: () {
                              context.pop('');
                            },
                          ).show(context);
                        } else {
                          context.pop(selectedIndex);
                        }
                      },
                    );
                  },
            child: Text(
              '선택한 운동으로 변경',
              style: h6Headline,
            ),
          ),
        ),
      ),
    );
  }
}
