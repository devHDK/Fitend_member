import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/component/workout_banner.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/common/provider/shared_preference_provider.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/common/utils/shared_pref_utils.dart';
import 'package:fitend_member/exercise/view/exercise_screen.dart';
import 'package:fitend_member/schedule/view/schedule_result_screen.dart';
import 'package:fitend_member/thread/model/common/thread_trainer_model.dart';
import 'package:fitend_member/thread/model/common/thread_user_model.dart';
import 'package:fitend_member/thread/provider/thread_create_provider.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:fitend_member/user/provider/go_router.dart';
import 'package:fitend_member/workout/component/workout_card.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:fitend_member/workout/model/workout_record_simple_model.dart';
import 'package:fitend_member/workout/provider/workout_process_provider.dart';
import 'package:fitend_member/workout/provider/workout_provider.dart';
import 'package:fitend_member/workout/view/workout_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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

class _WorkoutListScreenState extends ConsumerState<WorkoutListScreen>
    with RouteAware, WidgetsBindingObserver {
  late WorkoutModel workoutModel;
  bool isPoped = false;
  bool initial = true;
  bool hasLocal = false;
  bool changedDate = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    Future.delayed(const Duration(milliseconds: 300), () {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          fetch();

          if (initial && mounted) {
            if ((workoutModel.isProcessing != null &&
                    workoutModel.isProcessing!) &&
                !isPoped &&
                !workoutModel.isRecord &&
                DateTime.now().isBefore(DateTime.parse(workoutModel.startDate)
                    .add(const Duration(days: 1, hours: 4))) &&
                DateTime.now()
                    .isAfter(DateTime.parse(workoutModel.startDate))) {
              _showConfirmDialog();
            }
            initial = false;
          }
        },
      );
    });
  }

  void fetch() async {
    if (ref.read(workoutProvider(widget.id)) is WorkoutModelError) {
      await ref
          .read(workoutProvider(widget.id).notifier)
          .getWorkout(id: widget.id);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref
        .read(routeObserverProvider)
        .subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (mounted) {
          await _checkIsNeedUpdateWorkoutDetail();
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void didPush() async {
    if (mounted) {
      await _checkIsNeedUpdateWorkoutDetail();
    }
  }

  Future<void> _checkIsNeedUpdateWorkoutDetail() async {
    final pref = await ref.read(sharedPrefsProvider);
    final needUpdateList = SharedPrefUtils.getNeedUpdateList(
        StringConstants.needWorkoutUpdateList, pref);

    if (needUpdateList.contains(widget.id.toString()) &&
        workoutModel.exercises.isNotEmpty) {
      ref.read(workoutProvider(widget.id).notifier).getWorkout(id: widget.id);
      needUpdateList.remove(widget.id.toString());

      SharedPrefUtils.updateNeedUpdateList(
          StringConstants.needWorkoutUpdateList, pref, needUpdateList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutProvider(widget.id));
    final AsyncValue<Box> workoutRecordbox =
        ref.watch(hiveWorkoutRecordSimpleProvider);
    // final pstate = ref.watch(StringConstants.workoutResultProvider(widget.id));

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
        body: DialogWidgets.oneButtonDialog(
          message: state.message,
          confirmText: '확인',
          confirmOnTap: () => context.pop(),
        ),
      );
    }

    final model = WorkoutModel.clone(model: state as WorkoutModel);
    workoutModel = WorkoutModel.clone(model: model);

    final userModel = ref.watch(getMeProvider) as UserModel;

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

    final isTodayWorkout = DateTime.now().isBefore(
            DateTime.parse(model.startDate)
                .add(const Duration(days: 1, hours: 4))) &&
        DateTime.now().isAfter(DateTime.parse(model.startDate));

    List<String> videoRecordList = [];

    for (var exercise in model.exercises) {
      if (exercise.isVideoRecord != null && exercise.isVideoRecord!) {
        videoRecordList.add(exercise.name);
      }
    }

    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 18),
          child: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        centerTitle: true,
        title: Text(
          '${DateFormat('M월 d일').format(DateTime.parse(model.startDate))} ${weekday[DateTime.parse(model.startDate).weekday - 1]}요일',
          style: h4Headline,
        ),
        actions: [
          if (!model.isWorkoutComplete &&
              DateTime.parse(model.startDate).compareTo(today) >= 0 &&
              !hasLocal)
            GestureDetector(
              onTap: () async {
                await showDialog(
                    context: context,
                    builder: (context) {
                      return CalendarDialog(
                        scheduleDate: DateTime.parse(model.startDate),
                        workoutScheduleId: widget.id,
                      );
                    }).then(
                  (changedDate) async {
                    if (changedDate == null) {
                      return;
                    }
                    if (changedDate['changedDate'] != null) {
                      final originDate = model.startDate;
                      final changeDate = changedDate['changedDate'] as DateTime;

                      String content =
                          '${model.workoutTitle}\n${DateFormat('M월 d일').format(DateTime.parse(originDate))} (${weekday[DateTime.parse(originDate).weekday - 1]}) → ${DateFormat('M월 d일').format(changeDate)} (${weekday[changeDate.weekday - 1]})';

                      //thread 생성
                      ref.read(threadCreateProvider.notifier).init();

                      ref
                          .read(threadCreateProvider.notifier)
                          .updateTitle('운동일정을 변경했어요');
                      ref
                          .read(threadCreateProvider.notifier)
                          .updateContent(content);

                      ref
                          .read(workoutProvider(widget.id).notifier)
                          .updateWorkoutStateDate(
                            dateTime:
                                DateFormat('yyyy-MM-dd').format(changeDate),
                          );

                      await ref
                          .read(threadCreateProvider.notifier)
                          .createThread(
                            user: ThreadUser(
                              id: userModel.user.id,
                              nickname: userModel.user.nickname,
                              gender: userModel.user.gender,
                            ),
                            trainer: ThreadTrainer(
                              id: userModel.user.activeTrainers.first.id,
                              nickname:
                                  userModel.user.activeTrainers.first.nickname,
                              profileImage: userModel
                                  .user.activeTrainers.first.profileImage,
                            ),
                          );

                      DialogWidgets.showToast(
                        content: '운동일정을 변경했어요 ✅',
                        gravity: ToastGravity.CENTER,
                      );
                    }
                  },
                );
              },
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: SvgPicture.asset(SVGConstants.daymove),
                  ),
                  const SizedBox(
                    width: 28,
                  )
                ],
              ),
            )
        ],
      ),
      body: RefreshIndicator(
        backgroundColor: Pallete.background,
        color: Pallete.point,
        semanticsLabel: '새로고침',
        onRefresh: () async {
          await ref
              .read(workoutProvider(widget.id).notifier)
              .getWorkout(id: widget.id);
        },
        child: CustomScrollView(
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
                  if (videoRecordList.isNotEmpty)
                    _videoRecordListRender(videoRecordList)
                ],
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                  horizontal: Platform.isIOS ? 7.w : (3.8).w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final exerciseModel = model.exercises[index];

                    int completeSetCount = 0;

                    workoutRecordbox.when(
                      data: (data) {
                        final record = data.get(exerciseModel.workoutPlanId);
                        if (record != null && record is WorkoutRecordSimple) {
                          completeSetCount = record.setInfo
                              .where((element) =>
                                  element.reps != null ||
                                  element.weight != null ||
                                  element.seconds != null)
                              .length;
                        } else {
                          completeSetCount = 0;
                        }
                      },
                      error: (error, stackTrace) => completeSetCount = 0,
                      loading: () => debugPrint('loading...'),
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
                                      width: 30,
                                    ),
                                    SvgPicture.asset(SVGConstants.turnDown),
                                  ],
                                ),
                              ],
                            )
                          else if (exerciseModel.circuitGroupNum != null)
                            Row(children: [
                              const SizedBox(
                                width: 30,
                              ),
                              SvgPicture.asset(SVGConstants.tunrLine),
                              const SizedBox(
                                width: 10,
                              ),
                              SvgPicture.asset(SVGConstants.tunrLine),
                            ]),
                          WorkoutCard(
                            exercise: exerciseModel,
                            completeSetCount: completeSetCount,
                            islastCircuit: exerciseModel.circuitGroupNum !=
                                    null &&
                                groupCounts[exerciseModel.circuitGroupNum!] ==
                                    exerciseModel.circuitSeq!,
                          ),
                          if (exerciseModel.circuitGroupNum != null &&
                              groupCounts[exerciseModel.circuitGroupNum!] ==
                                  exerciseModel.circuitSeq!)
                            Column(
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 30,
                                    ),
                                    SvgPicture.asset(SVGConstants.turnUp),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            )
                        ],
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
      ),
      floatingActionButton: !isTodayWorkout && !model.isWorkoutComplete
          ? null
          : TextButton(
              onPressed: model.isWorkoutComplete
                  ? () {
                      FirebaseAnalytics.instance
                          .logEvent(name: 'click_result_screen');

                      context.pushNamed(
                        ScheduleResultScreen.routeName,
                        pathParameters: {
                          'id': model.workoutScheduleId.toString(),
                        },
                        extra: model.exercises,
                      );
                    }
                  : isTodayWorkout
                      ? () async {
                          if (model.isProcessing != null &&
                              !model.isProcessing!) {
                            ref
                                .read(
                                    workoutProcessProvider(widget.id).notifier)
                                .resetWorkoutProcess();
                            ref
                                .read(workoutProvider(widget.id).notifier)
                                .workoutSaveForStart();
                          }

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
                            if (mounted) {
                              setState(() {
                                isPoped = true;
                                // ref
                                //     .read(workoutProcessProvider(widget.id)
                                //         .notifier)
                                //     .init(ref.read(
                                //         workoutProvider(widget.id).notifier));
                              });
                            }
                          });
                        }
                      : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(
                  height: 44,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: model.isWorkoutComplete || isTodayWorkout
                        ? Pallete.point
                        : Pallete.point.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      model.isWorkoutComplete
                          ? '결과보기 📝'
                          : isTodayWorkout
                              ? '운동 시작하기 💪'
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

  Padding _videoRecordListRender(List<String> videoRecordList) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        width: 100.w,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '운동영상을 녹화 후 스레드에 올려주세요 🤳',
                style: s2SubTitle.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 9),
              ...videoRecordList.map(
                (e) => Text(
                  '∙ $e',
                  style: s1SubTitle.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
              if (mounted) {
                setState(() {
                  isPoped = true;

                  // ref
                  //     .read(workoutProvider(widget.id).notifier)
                  //     .getWorkout(id: widget.id);
                });
              }
            });
          },
          cancelOnTap: () async {
            // ref.read(workoutProvider(widget.id).notifier).resetWorkoutProcess();
            ref
                .read(workoutProcessProvider(widget.id).notifier)
                .resetWorkoutProcess();
            ref.read(workoutProvider(widget.id).notifier).workoutSaveForStart();

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
              if (mounted) {
                setState(() {
                  isPoped = true;

                  // ref
                  //     .read(workoutProvider(widget.id).notifier)
                  //     .getWorkout(id: widget.id);
                });
              }
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
