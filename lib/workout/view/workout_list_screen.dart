import 'package:fitend_member/common/component/dialog_tools.dart';
import 'package:fitend_member/common/component/error_dialog.dart';
import 'package:fitend_member/common/component/workout_banner.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/exercise/view/exercise_screen.dart';
import 'package:fitend_member/workout/component/workout_card.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:fitend_member/workout/provider/workout_provider.dart';
import 'package:fitend_member/workout/view/workout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class WorkoutListScreen extends ConsumerStatefulWidget {
  static String get routeName => 'workout';
  final int id;

  const WorkoutListScreen({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends ConsumerState<WorkoutListScreen> {
  late WorkoutModel workoutModel;
  late AsyncValue<Box> workoutBox;
  bool isProcessing = false;
  bool isPoped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPersistentFrameCallback(
      (timeStamp) {
        if (isProcessing && !isPoped) {
          _showConfirmDialog();
          isProcessing = false;
        }
      },
    );
  }

  Future<dynamic> _showConfirmDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return DialogTools.confirmDialog(
          message: '진행 중이던 운동이 있어요 🏃‍♂️\n이어서 진행할까요?',
          confirmText: '네, 이어서 할게요',
          cancelText: '아니요, 처음부터 할래요',
          confirmOnTap: () async {
            Navigator.of(context).pop();

            await Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => WorkoutScreen(
                  exercises: workoutModel.exercises,
                  date: DateTime.parse(workoutModel.startDate),
                  workout: workoutModel,
                ),
              ),
            )
                .then((value) {
              setState(() {
                isPoped = true;
              });
            });
          },
          cancelOnTap: () async {
            workoutBox.whenData(
              (value) {
                for (var element in workoutModel.exercises) {
                  value.delete(element.workoutPlanId);
                }
              },
            );

            Navigator.of(context).pop();

            await Navigator.of(context)
                .push(MaterialPageRoute(
              builder: (context) => WorkoutScreen(
                exercises: workoutModel.exercises,
                date: DateTime.parse(workoutModel.startDate),
                workout: workoutModel,
              ),
            ))
                .then((value) {
              setState(() {
                isPoped = true;
              });
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutProvider(widget.id));
    final AsyncValue<Box> box = ref.watch(hiveWorkoutRecordProvider);

    if (state is WorkoutModelLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: POINT_COLOR,
        ),
      );
    }

    if (state is WorkoutModelError) {
      return ErrorDialog(error: state.message);
    }

    final model = state as WorkoutModel;

    workoutModel = model;
    workoutBox = box;

    box.whenData(
      (value) {
        for (var element in model.exercises) {
          final comfleteSet = value.get(element.workoutPlanId);
          if (comfleteSet != null && comfleteSet.setInfo.length > 0) {
            isProcessing = true;
            break;
          }
        }
      },
    );

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back)),
        centerTitle: true,
        title: Text(
          '${DateFormat('MM월 dd일').format(DateTime.parse(model.startDate))} ${weekday[DateTime.parse(model.startDate).weekday]}요일',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: WorkoutBanner(
              title: model.workoutTitle,
              subTitle: model.workoutSubTitle,
              exerciseCount: model.exercises.length,
              time: model.workoutTotalTime,
            ),
          ),
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
                      GoRouter.of(context).goNamed(
                        ExerciseScreen.routeName,
                        pathParameters: {
                          'workoutScheduleId':
                              model.workoutScheduleId.toString()
                        },
                        extra: exerciseModel,
                      );
                    },
                    child: WorkoutCard(
                      exercise: exerciseModel,
                      completeSetCount: completeSetCount,
                    ),
                  );
                },
                childCount: model.exercises.length,
              ),
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
            style: ElevatedButton.styleFrom(backgroundColor: POINT_COLOR),
            onPressed: () async {
              final ret = await Navigator.of(context)
                  .push(MaterialPageRoute(
                builder: (context) => WorkoutScreen(
                  exercises: model.exercises,
                  date: DateTime.parse(model.startDate),
                  workout: model,
                ),
              ))
                  .then((value) {
                setState(() {
                  isPoped = true;
                });
              });
            },
            child: const Text('운동 시작하기💪'),
          ),
        ),
      ),
    );
  }
}
