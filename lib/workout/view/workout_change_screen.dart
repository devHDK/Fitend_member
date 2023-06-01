import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/workout/component/workout_card.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

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
  @override
  Widget build(BuildContext context) {
    final AsyncValue<Box> box = ref.watch(hiveWorkoutRecordProvider);

    final model = widget.workout;

    print('exerciseIndex : ${widget.exerciseIndex}');

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
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            sliver: SliverList(
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

                  return GestureDetector(
                    onTap: () {
                      context.pop(index);
                    },
                    child: WorkoutCard(
                        exercise: exerciseModel,
                        completeSetCount: completeSetCount,
                        exerciseIndex: widget.exerciseIndex == index
                            ? widget.exerciseIndex
                            : null),
                  );
                },
                childCount: model.exercises.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
