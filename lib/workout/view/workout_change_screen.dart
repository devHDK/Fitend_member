import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/workout/component/workout_card.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

  @override
  void initState() {
    super.initState();

    selectedIndex = widget.exerciseIndex;
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Box> box = ref.watch(hiveWorkoutRecordProvider);

    final model = widget.workout;

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back)),
        centerTitle: true,
        title: const Text(
          '운동리스트',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final exerciseModel = model.exercises[index];
                int completeSetCount = 0;
                box.when(
                  data: (data) {
                    final record = data.get(exerciseModel.workoutPlanId);
                    if (record != null) {
                      completeSetCount = record.setInfo.length;
                    } else {
                      completeSetCount = 0;
                    }
                  },
                  error: (error, stackTrace) => completeSetCount = 0,
                  loading: () => print('loading...'),
                );

                return InkWell(
                  onTap: () {
                    print(index);
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: WorkoutCard(
                    exercise: exerciseModel,
                    completeSetCount: completeSetCount,
                    exerciseIndex: widget.exerciseIndex == index
                        ? widget.exerciseIndex
                        : null,
                    isSelected: selectedIndex == index ? true : false,
                  ),
                );
              },
              childCount: model.exercises.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedIndex == widget.exerciseIndex
                  ? POINT_COLOR.withOpacity(0.4)
                  : POINT_COLOR,
            ),
            onPressed: selectedIndex == widget.exerciseIndex
                ? () {}
                : () {
                    box.whenData(
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
            child: const Text(
              '선택한 운동으로 변경',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
