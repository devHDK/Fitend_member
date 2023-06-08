import 'package:fitend_member/common/component/dialog_tools.dart';
import 'package:fitend_member/common/component/error_dialog.dart';
import 'package:fitend_member/common/component/workout_banner.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/provider/hive_timer_record_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_x_more_%20record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_edit_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_feedback_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/exercise/model/setInfo_model.dart';
import 'package:fitend_member/exercise/view/exercise_screen.dart';
import 'package:fitend_member/schedule/model/workout_feedback_record_model.dart';
import 'package:fitend_member/schedule/view/schedule_result_screen.dart';
import 'package:fitend_member/workout/component/workout_card.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:fitend_member/workout/model/workout_record_model.dart';
import 'package:fitend_member/workout/model/workout_result_model.dart';
import 'package:fitend_member/workout/provider/workout_provider.dart';
import 'package:fitend_member/workout/provider/workout_records_provider.dart';
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
  late AsyncValue<Box> timerXmoreBox;
  late AsyncValue<Box> timerXoneBox;
  bool isProcessing = false;
  bool isPoped = false;
  bool isWorkoutComplete = false;
  bool initial = true;
  bool hasLocal = false;

  @override
  void initState() {
    super.initState();

    ref.read(workoutProvider(widget.id).notifier).getWorkout(id: widget.id);

    Future.delayed(
        const Duration(
          milliseconds: 100,
        ), () {
      WidgetsBinding.instance.addPersistentFrameCallback(
        (timeStamp) {
          if (isWorkoutComplete && initial && !hasLocal) {
            ref
                .read(workoutRecordsProvider.notifier)
                .getWorkoutResults(workoutScheduleId: widget.id);

            initial = false;
          }
          if (isProcessing && !isPoped && !isWorkoutComplete) {
            _showConfirmDialog();
            isProcessing = false;
          }
        },
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    ref.read(workoutProvider(widget.id).notifier).getWorkout(id: widget.id);
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
                  workoutScheduleId: widget.id,
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

            timerXmoreBox.whenData((value) {
              for (var element in workoutModel.exercises) {
                if ((element.trackingFieldId == 3 ||
                        element.trackingFieldId == 4) &&
                    element.setInfo.length > 1) {
                  value.delete(element.workoutPlanId);
                }
              }
            });

            timerXoneBox.whenData((value) {
              for (var element in workoutModel.exercises) {
                if ((element.trackingFieldId == 3 ||
                        element.trackingFieldId == 4) &&
                    element.setInfo.length == 1) {
                  value.delete(element.workoutPlanId);
                }
              }
            });

            Navigator.of(context).pop();

            await Navigator.of(context)
                .push(MaterialPageRoute(
              builder: (context) => WorkoutScreen(
                exercises: workoutModel.exercises,
                date: DateTime.parse(workoutModel.startDate),
                workout: workoutModel,
                workoutScheduleId: widget.id,
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

    final AsyncValue<Box> workoutRecordBox =
        ref.watch(hiveWorkoutRecordProvider);
    final AsyncValue<Box> timerXoneRecordBox =
        ref.watch(hiveTimerRecordProvider);
    final AsyncValue<Box> timerXMoreRecordBox =
        ref.watch(hiveTimerXMoreRecordProvider);

    final AsyncValue<Box> workoutEditBox = ref.watch(hiveWorkoutEditProvider);
    final AsyncValue<Box> workoutFeedbackBox =
        ref.watch(hiveWorkoutFeedbackProvider);

    final pstate = ref.watch(workoutRecordsProvider);

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

    var model = state as WorkoutModel;

    workoutModel = model;
    workoutBox = workoutRecordBox;
    timerXoneBox = timerXoneRecordBox;
    timerXmoreBox = timerXMoreRecordBox;
    isWorkoutComplete = model.isWorkoutComplete;

    if (model.isWorkoutComplete) {
      workoutRecordBox.whenData(
        (value) {
          final record = value.get(model.exercises[0].workoutPlanId);

          if (record == null && pstate is WorkoutResultModel) {
            hasLocal = false;
            for (var i = 0; i < pstate.workoutRecords.length; i++) {
              value.put(
                pstate.workoutRecords[i].workoutPlanId,
                WorkoutRecordModel(
                  workoutPlanId: pstate.workoutRecords[i].workoutPlanId,
                  setInfo: pstate.workoutRecords[i].setInfo,
                ),
              );
            }
          }
        },
      );

      workoutFeedbackBox.whenData(
        (value) {
          final record = value.get(widget.id);
          if ((record == null || record.strengthIndex == null) &&
              pstate is WorkoutResultModel) {
            hasLocal = false;
            value.put(
              widget.id,
              WorkoutFeedbackRecordModel(
                startDate: DateTime.parse(pstate.startDate),
                strengthIndex: pstate.strengthIndex,
                issueIndexes: pstate.issueIndexes,
                contents: pstate.contents,
              ),
            );
          }
        },
      );

      workoutEditBox.whenData(
        (value) {
          final record = value.get(model.exercises[0].workoutPlanId);
          if (record == null && pstate is WorkoutResultModel) {
            hasLocal = false;
            for (var i = 0; i < pstate.workoutRecords.length; i++) {
              value.put(
                pstate.workoutRecords[i].workoutPlanId,
                WorkoutRecordResult(
                  exerciseName: pstate.workoutRecords[i].exerciseName,
                  targetMuscles: pstate.workoutRecords[i].targetMuscles,
                  trackingFieldId: pstate.workoutRecords[i].trackingFieldId,
                  workoutPlanId: pstate.workoutRecords[i].workoutPlanId,
                  setInfo: pstate.workoutRecords[i].setInfo,
                ),
              );
            }
          }
        },
      );

      timerXoneBox.whenData((value) {
        if (pstate is WorkoutResultModel) {
          for (var i = 0; i < pstate.workoutRecords.length; i++) {
            if (pstate.workoutRecords[i].setInfo.length == 1 &&
                (pstate.workoutRecords[i].trackingFieldId == 3 ||
                    pstate.workoutRecords[i].trackingFieldId == 4)) {
              final record = value.get(pstate.workoutRecords[i].workoutPlanId);
              if (record == null) {
                hasLocal = false;
                value.put(pstate.workoutRecords[i].workoutPlanId,
                    pstate.workoutRecords[i].setInfo[0]);
              }
            }
          }
        }
      });
      setState(() {});
    } else {
      workoutEditBox.whenData(
        // api로 받아온 데이터 hive로 저장
        (value) {
          for (int i = 0; i < model.exercises.length; i++) {
            final record = value.get(model.exercises[i].workoutPlanId);

            if (record != null && record is WorkoutRecordResult) {
              model.exercises[i] =
                  model.exercises[i].copyWith(setInfo: record.setInfo);
              hasLocal = true;
            }
          }
        },
      );

      workoutRecordBox.whenData(
        (value) async {
          for (var element in model.exercises) {
            final comfleteSet = await value.get(element.workoutPlanId);
            if (comfleteSet != null && comfleteSet.setInfo.length > 0) {
              isProcessing = true;
              hasLocal = true;
              break;
            }
          }
        },
      );
    }

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
          '${DateFormat('M월 dd일').format(DateTime.parse(model.startDate))} ${weekday[DateTime.parse(model.startDate).weekday]}요일',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Hero(
              tag: model.workoutScheduleId,
              child: WorkoutBanner(
                title: model.workoutTitle,
                subTitle: model.workoutSubTitle,
                exerciseCount: model.exercises.length,
                time: model.workoutTotalTime,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final exerciseModel = model.exercises[index];
                  int completeSetCount = 0;
                  workoutRecordBox.when(
                    data: (data) {
                      final record = data.get(exerciseModel.workoutPlanId);
                      if (record != null && record is WorkoutRecordModel) {
                        List<SetInfo> savedSetInfo = record.setInfo;
                        int unCompletecnt = 0;

                        for (SetInfo info in savedSetInfo) {
                          if (info.reps == null &&
                              info.seconds == null &&
                              info.weight == null) {
                            unCompletecnt += 1;
                          }
                        }
                        completeSetCount =
                            record.setInfo.length - unCompletecnt;
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
            onPressed: model.isWorkoutComplete
                ? () {
                    context.goNamed(
                      ScheduleResultScreen.routeName,
                      pathParameters: {
                        "workoutScheduleId": model.workoutScheduleId.toString(),
                      },
                      extra: model.exercises,
                    );
                  }
                : () async {
                    workoutEditBox.whenData(
                      (value) {
                        for (var e in state.exercises) {
                          final record = value.get(e.workoutPlanId);

                          if (record == null) {
                            value.put(
                              e.workoutPlanId,
                              WorkoutRecordResult(
                                exerciseName: e.name,
                                targetMuscles: [e.targetMuscles[0].name],
                                trackingFieldId: e.trackingFieldId,
                                workoutPlanId: e.workoutPlanId,
                                setInfo: e.setInfo,
                              ),
                            );
                          }
                        }
                      },
                    );

                    workoutFeedbackBox.whenData(
                      (value) {
                        final record = value.get(model.workoutScheduleId);
                        if (record == null) {
                          value.put(
                            model.workoutScheduleId,
                            WorkoutFeedbackRecordModel(
                              startDate: DateTime.parse(model.startDate),
                            ),
                          );
                        }
                      },
                    );

                    await Navigator.of(context)
                        .push(MaterialPageRoute(
                      builder: (context) => WorkoutScreen(
                        exercises: model.exercises,
                        date: DateTime.parse(model.startDate),
                        workout: model,
                        workoutScheduleId: widget.id,
                      ),
                    ))
                        .then((value) {
                      setState(() {
                        isPoped = true;
                      });
                    });
                  },
            child: Text(
              model.isWorkoutComplete ? '결과보기📝' : '운동 시작하기💪',
              style: const TextStyle(
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
