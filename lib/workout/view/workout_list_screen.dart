import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/component/workout_banner.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/provider/hive_exercies_index_provider.dart';
import 'package:fitend_member/common/provider/hive_modified_exercise_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_record_provider.dart';
import 'package:fitend_member/common/provider/hive_timer_x_more_record_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_result_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_feedback_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/set_info_model.dart';
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
import 'package:flutter/cupertino.dart';
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
  late AsyncValue<Box> modifiedExercise;
  late AsyncValue<Box> workoutResult;
  late AsyncValue<Box> processingExerciseIndex;
  bool isProcessing = false;
  bool isPoped = false;
  bool isWorkoutComplete = false;
  bool isRecorded = false;
  bool initial = true;
  bool hasLocal = false;
  bool changedDate = false;

  final today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  void initState() {
    super.initState();

    // ref.read(workoutProvider(widget.id).notifier).getWorkout(id: widget.id);

    Future.delayed(
      const Duration(
        milliseconds: 300,
      ),
      () {
        WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) {
            if (initial) {
              if ((isWorkoutComplete || isRecorded) && !hasLocal) {
                ref
                    .read(workoutRecordsProvider(widget.id).notifier)
                    .getWorkoutResults(workoutScheduleId: widget.id);
              }

              if (isProcessing &&
                  !isPoped &&
                  !isRecorded &&
                  today.compareTo(DateTime.parse(workoutModel.startDate)) ==
                      0) {
                _showConfirmDialog();
                isProcessing = false;
              }
              initial = false;
            }
          },
        );
      },
    );
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  //   // ref.read(workoutProvider(widget.id).notifier).getWorkout(id: widget.id);
  // }

  // @override
  // void didUpdateWidget(covariant WorkoutListScreen oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  // }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutProvider(widget.id));
    final pstate = ref.watch(workoutRecordsProvider(widget.id));

    final AsyncValue<Box> workoutRecordBox =
        ref.read(hiveWorkoutRecordProvider);
    final AsyncValue<Box> timerXoneRecordBox =
        ref.read(hiveTimerRecordProvider);
    final AsyncValue<Box> timerXMoreRecordBox =
        ref.read(hiveTimerXMoreRecordProvider);

    final AsyncValue<Box> workoutResultBox =
        ref.read(hiveWorkoutResultProvider);
    final AsyncValue<Box> workoutFeedbackBox =
        ref.read(hiveWorkoutFeedbackProvider);
    final AsyncValue<Box> modifiedBox = ref.watch(hiveModifiedExerciseProvider);
    final AsyncValue<Box> processingExerciseIndexBox =
        ref.read(hiveExerciseIndexProvider);

    if (state is WorkoutModelLoading) {
      return const Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        body: Center(
          child: CircularProgressIndicator(
            color: POINT_COLOR,
          ),
        ),
      );
    }

    if (state is WorkoutModelError) {
      showDialog(
        context: context,
        builder: (context) => DialogWidgets.errorDialog(
          message: state.message,
          confirmText: '확인',
          confirmOnTap: () => context.pop(),
        ),
      );
    }

    final model = WorkoutModel.clone(model: state as WorkoutModel);
    workoutModel = WorkoutModel.clone(model: model);

    workoutBox = workoutRecordBox;
    timerXoneBox = timerXoneRecordBox;
    timerXmoreBox = timerXMoreRecordBox;
    modifiedExercise = modifiedBox;
    workoutResult = workoutResultBox;
    processingExerciseIndex = processingExerciseIndexBox;

    isWorkoutComplete = model.isWorkoutComplete;
    isRecorded = model.isRecord;

    if (model.isWorkoutComplete) {
      hasLocal = true;
      // 완료된 운동
      workoutRecordBox.whenData(
        (value) {
          final record = value.get(model.exercises[0].workoutPlanId);
          if (record == null && pstate is WorkoutResultModel) {
            for (var i = 0; i < pstate.workoutRecords.length; i++) {
              value.put(
                pstate.workoutRecords[i].workoutPlanId,
                WorkoutRecordModel(
                  workoutPlanId: pstate.workoutRecords[i].workoutPlanId,
                  setInfo: pstate.workoutRecords[i].setInfo,
                ),
              );
            }
            hasLocal = false;
          }
        },
      );

      workoutFeedbackBox.whenData(
        (value) {
          final record = value.get(widget.id);
          if (record == null && pstate is WorkoutResultModel) {
            value.put(
              widget.id,
              WorkoutFeedbackRecordModel(
                startDate: DateTime.parse(pstate.startDate),
                strengthIndex: pstate.strengthIndex,
                issueIndexes: pstate.issueIndexes,
                contents: pstate.contents,
              ),
            );
            hasLocal = false;
          }
        },
      );

      workoutResultBox.whenData(
        (value) {
          final record = value.get(model.exercises[0].workoutPlanId);
          if (record == null && pstate is WorkoutResultModel) {
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
            hasLocal = false;
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
                value.put(pstate.workoutRecords[i].workoutPlanId,
                    pstate.workoutRecords[i].setInfo[0]);
                hasLocal = false;
              }
            }
          }
        }
      });

      modifiedBox.whenData(
        (value) {
          for (var exercise in model.exercises) {
            if ((exercise.trackingFieldId == 3 ||
                    exercise.trackingFieldId == 4) &&
                exercise.setInfo.length == 1) {
              final record = value.get(exercise.workoutPlanId);
              if (record is Exercise && record.setInfo[0].seconds != null) {
                exercise.setInfo[0] = SetInfo(
                    index: record.setInfo[0].index,
                    seconds: record.setInfo[0].seconds);
              }
            }
          }
        },
      );
    } else {
      workoutResultBox.whenData(
        (value) {
          for (int i = 0; i < model.exercises.length; i++) {
            final record = value.get(model.exercises[i].workoutPlanId);

            if (record != null && record is WorkoutRecordResult) {
              model.exercises[i] =
                  model.exercises[i].copyWith(setInfo: record.setInfo);
            } else {
              hasLocal = false;
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
            } else {
              hasLocal = false;
            }
          }
        },
      );

      processingExerciseIndexBox.whenData((value) {
        final record = value.get(widget.id);
        if (record != null) {
          isProcessing = true;
        }
      });
    }

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 18),
          child: IconButton(
              onPressed: () => context.pop(true),
              icon: const Icon(Icons.arrow_back)),
        ),
        centerTitle: true,
        title: Text(
          '${DateFormat('M월 d일').format(DateTime.parse(model.startDate))} ${weekday[DateTime.parse(model.startDate).weekday - 1]}요일',
          style: h4Headline,
        ),
        // actions: [
        //   if (!model.isWorkoutComplete &&
        //       DateTime.parse(model.startDate).compareTo(today) >= 0 &&
        //       !hasLocal)
        //     GestureDetector(
        //       onTap: () async {
        //         await showDialog(
        //             context: context,
        //             builder: (context) {
        //               return CalendarDialog(
        //                 scheduleDate: DateTime.parse(model.startDate),
        //                 workoutScheduleId: widget.id,
        //               );
        //             }).then(
        //           (changedDate) {
        //             if (changedDate == null) {
        //               return;
        //             }
        //             if (changedDate['changedDate'] != null) {
        //               setState(
        //                 () {
        //                   ref
        //                       .read(workoutProvider(widget.id).notifier)
        //                       .updateWorkoutStateDate(
        //                         dateTime: DateFormat('yyyy-MM-dd').format(
        //                           DateTime.parse(
        //                             changedDate['changedDate'].toString(),
        //                           ),
        //                         ),
        //                       );

        //                   //스케줄 업데이트
        //                   ref
        //                       .read(workoutScheduleProvider(
        //                         DateTime.parse(
        //                           changedDate['changedDate'].toString(),
        //                         ),
        //                       ).notifier)
        //                       .updateScheduleFromBuffer();
        //                 },
        //               );

        //               workoutFeedbackBox.whenData(
        //                 (value) async {
        //                   final record = value.get(widget.id);
        //                   if (record != null &&
        //                       record is WorkoutFeedbackRecordModel) {
        //                     hasLocal = false;
        //                     await value.put(
        //                       widget.id,
        //                       record.copyWith(
        //                         startDate: DateTime.parse(
        //                           DateFormat('yyyy-MM-dd').format(
        //                             DateTime.parse(
        //                               changedDate['changedDate'].toString(),
        //                             ),
        //                           ),
        //                         ),
        //                       ),
        //                     );
        //                   }
        //                 },
        //               );
        //             }
        //           },
        //         );
        //       },
        //       child: Row(
        //         children: [
        //           SizedBox(
        //             width: 28,
        //             height: 28,
        //             child: Image.asset('asset/img/icon_daymove.png'),
        //           ),
        //           const SizedBox(
        //             width: 28,
        //           )
        //         ],
        //       ),
        //     )
        // ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                WorkoutBanner(
                  title: model.workoutTitle,
                  subTitle: model.workoutSubTitle,
                  exercises: model.exercises,
                  time: model.workoutTotalTime,
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
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
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) =>
                              ExerciseScreen(exercise: exerciseModel),
                        ),
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
      floatingActionButton: today.compareTo(DateTime.parse(model.startDate)) !=
                  0 &&
              !model.isWorkoutComplete
          ? null
          : TextButton(
              onPressed: model.isWorkoutComplete
                  ? () {
                      context.pushNamed(
                        ScheduleResultScreen.routeName,
                        pathParameters: {
                          'id': model.workoutScheduleId.toString(),
                        },
                        extra: model.exercises,
                      );
                    }
                  : today.compareTo(DateTime.parse(model.startDate)) == 0
                      ? () async {
                          workoutResultBox.whenData(
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

                          modifiedBox.whenData(
                            (value) {
                              for (int i = 0; i < model.exercises.length; i++) {
                                final exercise =
                                    value.get(model.exercises[i].workoutPlanId);
                                if (exercise == null) {
                                  //저장된게 없으면 저장
                                  value.put(
                                      workoutModel.exercises[i].workoutPlanId,
                                      workoutModel.exercises[i]);
                                }
                              }
                            },
                          );

                          await Navigator.of(context)
                              .push(
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 300),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      WorkoutScreen(
                                exercises: model.exercises,
                                date: DateTime.parse(model.startDate),
                                workout: model,
                                workoutScheduleId: widget.id,
                              ),
                              transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) =>
                                  SlideTransition(
                                position: animation.drive(
                                  Tween(
                                    begin: const Offset(1.0, 0),
                                    end: Offset.zero,
                                  ).chain(
                                    CurveTween(curve: Curves.linearToEaseOut),
                                  ),
                                ),
                                child: child,
                              ),
                            ),
                          )
                              .then((value) {
                            setState(() {
                              isPoped = true;
                              // ref
                              //     .read(workoutProvider(widget.id).notifier)
                              //     .getWorkout(id: widget.id);
                            });
                          });
                        }
                      : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(
                  height: 44,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: model.isWorkoutComplete ||
                            today.compareTo(DateTime.parse(model.startDate)) ==
                                0
                        ? POINT_COLOR
                        : POINT_COLOR.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      model.isWorkoutComplete
                          ? '결과보기📝'
                          : today.compareTo(DateTime.parse(model.startDate)) ==
                                  0
                              ? '운동 시작하기💪'
                              : '오늘의 운동만 수행할 수 있어요!',
                      style: h6Headline.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButtonAnimator: _NoAnimationFabAnimator(),
    );
  }

  Future<dynamic> _showConfirmDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return DialogWidgets.confirmDialog(
          message: '진행 중이던 운동이 있어요 🏃‍♂️\n이어서 진행할까요?',
          confirmText: '네, 이어서 할게요',
          cancelText: '아니요, 처음부터 할래요',
          confirmOnTap: () async {
            Navigator.of(context).pop();

            await Navigator.of(context)
                .push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    WorkoutScreen(
                  exercises: workoutModel.exercises,
                  date: DateTime.parse(workoutModel.startDate),
                  workout: workoutModel,
                  workoutScheduleId: widget.id,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        SlideTransition(
                  position: animation.drive(
                    Tween(
                      begin: const Offset(1.0, 0),
                      end: Offset.zero,
                    ).chain(
                      CurveTween(curve: Curves.linearToEaseOut),
                    ),
                  ),
                  child: child,
                ),
              ),
            )
                .then((value) {
              setState(() {
                isPoped = true;

                // ref
                //     .read(workoutProvider(widget.id).notifier)
                //     .getWorkout(id: widget.id);
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
            workoutResult.whenData(
              (value) {
                for (var element in workoutModel.exercises) {
                  value.delete(element.workoutPlanId);
                }
              },
            );
            processingExerciseIndex.whenData(
              (value) {
                value.delete(widget.id);
              },
            );

            modifiedExercise.whenData(
              (value) async {
                for (var element in workoutModel.exercises) {
                  //  await value.delete(element.workoutPlanId);
                  await value.put(element.workoutPlanId, element);
                }
              },
            );

            Navigator.of(context).pop();

            await Navigator.of(context)
                .push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    WorkoutScreen(
                  exercises: workoutModel.exercises,
                  date: DateTime.parse(workoutModel.startDate),
                  workout: workoutModel,
                  workoutScheduleId: widget.id,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        SlideTransition(
                  position: animation.drive(
                    Tween(
                      begin: const Offset(1.0, 0),
                      end: Offset.zero,
                    ).chain(
                      CurveTween(curve: Curves.linearToEaseOut),
                    ),
                  ),
                  child: child,
                ),
              ),
            )
                .then((value) {
              setState(() {
                isPoped = true;

                // ref
                //     .read(workoutProvider(widget.id).notifier)
                //     .getWorkout(id: widget.id);
              });
            });
          },
        );
      },
    );
  }
}

class _NoAnimationFabAnimator extends FloatingActionButtonAnimator {
  @override
  Offset getOffset(
      {required Offset begin, required Offset end, required double progress}) {
    return end;
  }

  @override
  Animation<double> getRotationAnimation({required Animation<double> parent}) {
    return const AlwaysStoppedAnimation<double>(0);
  }

  @override
  Animation<double> getScaleAnimation({required Animation<double> parent}) {
    return const AlwaysStoppedAnimation<double>(1.0);
  }
}
