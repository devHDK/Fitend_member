import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fitend_member/common/component/custom_clipper.dart';
import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/component/guide_video_player.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/exercise_video_model.dart';
import 'package:fitend_member/exercise/view/exercise_screen.dart';
import 'package:fitend_member/thread/model/common/thread_trainer_model.dart';
import 'package:fitend_member/thread/model/common/thread_user_model.dart';
import 'package:fitend_member/thread/provider/thread_create_provider.dart';
import 'package:fitend_member/thread/view/thread_create_screen.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:fitend_member/workout/component/setinfo_list_card/set_info_reps_card.dart';
import 'package:fitend_member/workout/component/setinfo_list_card/set_info_timer_card.dart';
import 'package:fitend_member/workout/component/setinfo_list_card/set_info_weight_reps_card.dart';
import 'package:fitend_member/workout/component/timer_progress_card.dart';
import 'package:fitend_member/workout/component/weight_reps_progress_card.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:fitend_member/workout/model/workout_process_model.dart';
import 'package:fitend_member/workout/provider/workout_history_screen.dart';
import 'package:fitend_member/workout/provider/workout_process_provider.dart';
import 'package:fitend_member/workout/provider/workout_provider.dart';
import 'package:fitend_member/workout/view/workout_change_screen.dart';
import 'package:fitend_member/workout/view/workout_feedback_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  final List<Exercise> exercises;
  final DateTime date;
  final WorkoutModel workout;
  final int workoutScheduleId;

  const WorkoutScreen({
    super.key,
    required this.exercises,
    required this.date,
    required this.workout,
    required this.workoutScheduleId,
  });

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool isSwipeUp = false;
  bool isTooltipVisible = false;
  int tooltipCount = 0;
  int tooltipSeq = 0;
  late Timer timer;
  late Timer totalTimeTimer;
  final panelController = PanelController();

  bool isBackground = false;
  DateTime resumedTime = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  DateTime pausedTime = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    initData();
  }

  initData() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        ref
            .read(workoutProcessProvider(widget.workoutScheduleId).notifier)
            .init(ref.read(workoutProvider(widget.workoutScheduleId).notifier));

        totalTimerStart();

        isTooltipVisible = false;
        tooltipCount = 0;
        onTooltipPressed();
        tooltipSeq = 0;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    totalTimeTimer.cancel();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (isBackground) {
          resumedTime = DateTime.now();

          int addSeconds = resumedTime.difference(pausedTime).inSeconds;

          ref
              .read(workoutProcessProvider(widget.workoutScheduleId).notifier)
              .addProcessTotalTime(addSeconds);

          isBackground = false;

          totalTimeTimer = Timer.periodic(
            const Duration(seconds: 1),
            onTickTotalTimer,
          );
        }

        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        pausedTime = DateTime.now();
        isBackground = true;
        totalTimeTimer.cancel();

        break;
      case AppLifecycleState.detached:
        // debugPrint("app in detached");
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void onTooltipPressed() {
    if (tooltipSeq == 0) {
      timer = Timer.periodic(
        const Duration(seconds: 1),
        onTick,
      );
      tooltipSeq++;
    }

    if (mounted) {
      if (isTooltipVisible) {
        if (mounted) {
          setState(() {
            isTooltipVisible = !isTooltipVisible;
            tooltipCount = 0;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isTooltipVisible = !isTooltipVisible;
            tooltipCount = 8;
          });
        }
      }
    }
  }

  void onTick(Timer timer) {
    if (mounted) {
      if (tooltipCount == 0) {
        timer.cancel();
        if (mounted) {
          setState(() {
            isTooltipVisible = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            tooltipCount -= 1;
          });
        }
      }
    }
  }

  void totalTimerStart() {
    totalTimeTimer = Timer.periodic(
      const Duration(seconds: 1),
      onTickTotalTimer,
    );
  }

  void onTickTotalTimer(timer) {
    if (mounted) {
      ref
          .read(workoutProcessProvider(widget.workoutScheduleId).notifier)
          .putProcessTotalTime();

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = Size(100.w, 100.h);
    final state = ref.watch(workoutProcessProvider(widget.workoutScheduleId));
    final userState = ref.watch(getMeProvider);
    final workoutState = ref.watch(workoutProvider(widget.workoutScheduleId));
    final threadCreateState = ref.watch(threadCreateProvider);

    if (state is WorkoutProcessModelLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Pallete.point,
        ),
      );
    }

    if (state is! WorkoutProcessModel) {
      return const Scaffold();
    }

    final model = state;

    final userModel = userState as UserModel;
    final workoutModel = workoutState as WorkoutModel;

    return WillPopScope(
      onWillPop: () async {
        _pagePop();

        return Future.value(true);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Pallete.gray,
        floatingActionButton: isSwipeUp
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: threadCreateState.isUploading ||
                            threadCreateState.isLoading
                        ? null
                        : () {
                            Navigator.of(context).push(CupertinoDialogRoute(
                                builder: (context) {
                                  return ThreadCreateScreen(
                                    trainer: ThreadTrainer(
                                      id: userModel
                                          .user.activeTrainers.first.id,
                                      nickname: userModel
                                          .user.activeTrainers.first.nickname,
                                      profileImage: userModel.user
                                          .activeTrainers.first.profileImage,
                                    ),
                                    user: ThreadUser(
                                      id: userModel.user.id,
                                      nickname: userModel.user.nickname,
                                      gender: userModel.user.gender,
                                    ),
                                    title:
                                        '${workoutModel.exercises[model.exerciseIndex].name} ${model.setInfoCompleteList[model.exerciseIndex] + 1}SET',
                                  );
                                },
                                context: context));
                          },
                    child: Container(
                      width: 98,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Pallete.darkGray,
                      ),
                      child: Center(
                        child: threadCreateState.isUploading
                            ? LoadingAnimationWidget.dotsTriangle(
                                color: Colors.white,
                                size: 25,
                              )
                            : SvgPicture.asset(
                                SVGConstants.message,
                                width: 25,
                                height: 25,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 9,
                  ),
                  GestureDetector(
                    onTap: model.isQuitting
                        ? null
                        : () async {
                            FirebaseAnalytics.instance
                                .logEvent(name: 'click_large_next_button');

                            await _onTapNext(context, model);

                            isTooltipVisible = false;
                            tooltipCount = 0;
                            onTooltipPressed();
                            tooltipSeq = 0;
                            if (mounted) {
                              setState(() {});
                            }

                            if (isSwipeUp) {
                              final index = model.setInfoCompleteList[
                                          model.exerciseIndex] ==
                                      model.maxSetInfoList[model.exerciseIndex]
                                  ? model.setInfoCompleteList[
                                          model.exerciseIndex] -
                                      1
                                  : model
                                      .setInfoCompleteList[model.exerciseIndex];
                              if (model.setInfoCompleteList[
                                      model.exerciseIndex] >
                                  5) {
                                _movetoRecentSetInfo(index);
                              }
                            }
                          },
                    child: Container(
                      width: size.width - 56 - 107,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Pallete.point,
                      ),
                      child: Center(
                        child: model.isQuitting
                            ? const SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                '다음 운동',
                                style: h2Headline.copyWith(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButtonAnimator: null,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 18),
            child: IconButton(
              onPressed: () {
                if (mounted) {
                  _pagePop();
                }
              },
              icon: const Icon(Icons.arrow_back),
              color: Colors.black,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 18.0),
              child: IconButton.filled(
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) {
                        return DialogWidgets.confirmDialog(
                          message: '오늘의 운동을 종료할까요?\n종료 후에는 다시 진행할 수 없어요 🙉',
                          confirmText: '아니요, 계속 할게요',
                          cancelText: model.isQuitting ? '종료중...' : '네, 종료할게요',
                          confirmOnTap: () {
                            context.pop();
                          },
                          cancelOnTap: model.isQuitting
                              ? () {}
                              : () async {
                                  try {
                                    await ref
                                        .read(workoutProcessProvider(
                                                widget.workoutScheduleId)
                                            .notifier)
                                        .quitWorkout(
                                          title: widget.workout.workoutTitle,
                                          subTitle:
                                              widget.workout.workoutSubTitle,
                                          trainerId: widget.workout.trainerId,
                                        )
                                        .then((value) {
                                      final id = widget.workoutScheduleId;
                                      final date = widget.workout.startDate;

                                      context.pop();
                                      context.pop();

                                      GoRouter.of(context).pushNamed(
                                        WorkoutFeedbackScreen.routeName,
                                        pathParameters: {
                                          'workoutScheduleId': id.toString(),
                                        },
                                        extra: widget.exercises,
                                        queryParameters: {
                                          'startDate': DateFormat('yyyy-MM-dd')
                                              .format(DateTime.parse(date)),
                                        },
                                      );
                                    });
                                  } on DioException catch (e) {
                                    debugPrint('$e');
                                  }
                                },
                        );
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.close_sharp,
                    color: Colors.black,
                  )),
            ),
          ],
          title: Container(
            width: 80,
            height: 27,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.8),
            ),
            child: Center(
              child: Text(
                DataUtils.getTimeStringMinutes(model.totalTime),
                style: s1SubTitle.copyWith(
                  color: Pallete.darkGray,
                  fontSize: 18,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned(
              // left: 0.0,
              right: 100.w > 600 //테블릿이면
                  ? (100.w - (100.h) * 9 / 16) / 2
                  : 0,
              child: SizedBox(
                width: 100.w > 600 //테블릿이면
                    ? (100.h) * 9 / 16
                    : 100.w,
                height: 100.w > 600 ? 100.h : 100.w * 16 / 9,
                child: GuideVideoPlayer(
                  isGuide: false,
                  videos: [
                    ExerciseVideo(
                      url:
                          '${URLConstants.s3Url}${widget.exercises[model.exerciseIndex].videos.first.url}',
                      index: widget
                          .exercises[model.exerciseIndex].videos.first.index,
                      thumbnail:
                          '${URLConstants.s3Url}${widget.exercises[model.exerciseIndex].videos.first.thumbnail}',
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 200,
              right: 28,
              child: IconButton(
                iconSize: 36,
                onPressed: () {
                  onTooltipPressed();
                },
                icon: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: CustomNetworkImage(
                    imageUrl:
                        '${URLConstants.s3Url}${widget.exercises[model.exerciseIndex].trainerProfileImage}',
                    width: 36,
                    height: 36,
                    boxFit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            if (isTooltipVisible)
              _ShowTip(
                size: size,
                widget: widget,
                tooltipSeq: tooltipSeq,
                workoutScheduleId: widget.workoutScheduleId,
              ),
            SlidingUpPanel(
              key: ValueKey(widget.workoutScheduleId),
              minHeight: 195,
              maxHeight: size.height - (56 + kToolbarHeight),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              onPanelClosed: () {
                if (mounted) {
                  setState(() {
                    isSwipeUp = false;
                  });
                }
              },
              onPanelOpened: () {
                if (mounted) {
                  setState(() {
                    isSwipeUp = true;

                    final index =
                        model.setInfoCompleteList[model.exerciseIndex] ==
                                model.maxSetInfoList[model.exerciseIndex]
                            ? model.setInfoCompleteList[model.exerciseIndex] - 1
                            : model.setInfoCompleteList[model.exerciseIndex];

                    _movetoRecentSetInfo(index);
                  });
                }
              },
              panel: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 12,
                            ),
                            child: Container(
                              width: 44,
                              height: 4,
                              decoration: BoxDecoration(
                                  color: Pallete.lightGray,
                                  borderRadius: BorderRadius.circular(2)),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (model.modifiedExercises[model.exerciseIndex]
                                    .trackingFieldId ==
                                1 ||
                            model.modifiedExercises[model.exerciseIndex]
                                    .trackingFieldId ==
                                2)
                          WeightWrepsProgressCard(
                            workoutScheduleId: widget.workoutScheduleId,
                            isSwipeUp: isSwipeUp,
                            exercise:
                                model.modifiedExercises[model.exerciseIndex],
                            setInfoIndex:
                                model.setInfoCompleteList[model.exerciseIndex],
                            listOnTap: () async {
                              await Navigator.of(context)
                                  .push(CupertinoPageRoute(
                                builder: (context) => WorkoutChangeScreen(
                                  exerciseIndex: model.exerciseIndex,
                                  workout: widget.workout,
                                ),
                              ))
                                  .then(
                                (value) {
                                  if (value != null) {
                                    ref
                                        .read(workoutProcessProvider(
                                                widget.workoutScheduleId)
                                            .notifier)
                                        .exerciseChange(value);
                                    isTooltipVisible = false;
                                    tooltipCount = 0;
                                    onTooltipPressed();
                                    tooltipSeq = 0;

                                    if (mounted) {
                                      setState(() {});
                                    }

                                    if (isSwipeUp) {
                                      final index = model.setInfoCompleteList[
                                                  model.exerciseIndex] ==
                                              model.maxSetInfoList[
                                                  model.exerciseIndex]
                                          ? model.setInfoCompleteList[
                                                  model.exerciseIndex] -
                                              1
                                          : model.setInfoCompleteList[
                                              model.exerciseIndex];

                                      _movetoRecentSetInfo(index);
                                    }
                                  }
                                },
                              );
                            },
                            proccessOnTap: model.isQuitting
                                ? () {}
                                : () async {
                                    FirebaseAnalytics.instance.logEvent(
                                        name: 'click_small_next_button');

                                    await _onTapNext(context, model);

                                    isTooltipVisible = false;
                                    tooltipCount = 0;
                                    onTooltipPressed();
                                    tooltipSeq = 0;
                                    if (mounted) {
                                      setState(() {});
                                    }
                                    if (isSwipeUp) {
                                      final index = model.setInfoCompleteList[
                                                  model.exerciseIndex] ==
                                              model.maxSetInfoList[
                                                  model.exerciseIndex]
                                          ? model.setInfoCompleteList[
                                                  model.exerciseIndex] -
                                              1
                                          : model.setInfoCompleteList[
                                              model.exerciseIndex];

                                      if (model.setInfoCompleteList[
                                              model.exerciseIndex] >
                                          5) {
                                        _movetoRecentSetInfo(index);
                                      }
                                    }
                                  },
                          )
                        // Timer
                        else if ((model.modifiedExercises[model.exerciseIndex]
                                    .trackingFieldId ==
                                3 ||
                            model.modifiedExercises[model.exerciseIndex]
                                    .trackingFieldId ==
                                4))
                          TimerProgressCard(
                            workoutScheduleId: widget.workoutScheduleId,
                            isSwipeUp: isSwipeUp,
                            exercise:
                                model.modifiedExercises[model.exerciseIndex],
                            setInfoIndex: model.setInfoCompleteList[
                                        model.exerciseIndex] ==
                                    model.maxSetInfoList[model.exerciseIndex]
                                ? model.setInfoCompleteList[
                                        model.exerciseIndex] -
                                    1
                                : model
                                    .setInfoCompleteList[model.exerciseIndex],
                            listOnTap: () async {
                              await Navigator.of(context)
                                  .push(CupertinoPageRoute(
                                builder: (context) => WorkoutChangeScreen(
                                  exerciseIndex: model.exerciseIndex,
                                  workout: widget.workout,
                                ),
                              ))
                                  .then(
                                (value) {
                                  if (value != null) {
                                    ref
                                        .read(workoutProcessProvider(
                                                widget.workoutScheduleId)
                                            .notifier)
                                        .exerciseChange(value);
                                    isTooltipVisible = false;
                                    tooltipCount = 0;
                                    onTooltipPressed();
                                    tooltipSeq = 0;
                                    if (mounted) {
                                      setState(() {});
                                    }

                                    if (isSwipeUp) {
                                      final index = model.setInfoCompleteList[
                                                  model.exerciseIndex] ==
                                              model.maxSetInfoList[
                                                  model.exerciseIndex]
                                          ? model.setInfoCompleteList[
                                                  model.exerciseIndex] -
                                              1
                                          : model.setInfoCompleteList[
                                              model.exerciseIndex];

                                      _movetoRecentSetInfo(index);
                                    }
                                  }
                                },
                              );
                            },
                            proccessOnTap: model.isQuitting
                                ? () {}
                                : () async {
                                    FirebaseAnalytics.instance.logEvent(
                                        name: 'click_small_next_button');
                                    await _onTapNext(context, model);

                                    isTooltipVisible = false;
                                    tooltipCount = 0;
                                    onTooltipPressed();
                                    tooltipSeq = 0;
                                    if (mounted) {
                                      setState(() {});
                                    }
                                    if (isSwipeUp) {
                                      final index = model.setInfoCompleteList[
                                                  model.exerciseIndex] ==
                                              model.maxSetInfoList[
                                                  model.exerciseIndex]
                                          ? model.setInfoCompleteList[
                                                  model.exerciseIndex] -
                                              1
                                          : model.setInfoCompleteList[
                                              model.exerciseIndex];

                                      if (model.setInfoCompleteList[
                                              model.exerciseIndex] >
                                          5) {
                                        _movetoRecentSetInfo(index);
                                      }
                                    }
                                  },
                            resetSet: () {},
                            refresh: () {
                              if (mounted) {
                                setState(() {});
                              }
                            },
                          ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Pallete.lightGray,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              '${model.modifiedExercises[model.exerciseIndex].setInfo.length} SET',
                              style:
                                  s1SubTitle.copyWith(color: Pallete.lightGray),
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Pallete.lightGray,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height -
                        (56 +
                            kToolbarHeight +
                            195 +
                            5), // (appbar + toolbar + bottomSlide mini)
                    child: ScrollablePositionedList.builder(
                      padding: EdgeInsets.zero,
                      itemScrollController: itemScrollController,
                      itemPositionsListener: itemPositionsListener,
                      initialScrollIndex:
                          model.setInfoCompleteList[model.exerciseIndex] ==
                                  model.maxSetInfoList[model.exerciseIndex]
                              ? model.maxSetInfoList[model.exerciseIndex] - 1
                              : model.setInfoCompleteList[model.exerciseIndex],
                      itemCount: model.modifiedExercises[model.exerciseIndex]
                              .setInfo.length +
                          1,
                      itemBuilder: (context, index) {
                        if (index !=
                            model.modifiedExercises[model.exerciseIndex].setInfo
                                .length) {
                          final element = model
                              .modifiedExercises[model.exerciseIndex]
                              .setInfo[index];

                          if (model.modifiedExercises[model.exerciseIndex]
                                  .trackingFieldId ==
                              1) {
                            return SetInfoBoxForWeightReps(
                              key: ValueKey(
                                  '${model.modifiedExercises[model.exerciseIndex].workoutPlanId}_$index'),
                              workoutScheduleId: widget.workoutScheduleId,
                              initialReps: element.reps!,
                              initialWeight: element.weight!,
                              model: model,
                              setInfoIndex: index,
                              refresh: () {
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                            );
                          } else if (model
                                  .modifiedExercises[model.exerciseIndex]
                                  .trackingFieldId ==
                              2) {
                            return SetInfoBoxForReps(
                              key: ValueKey(
                                  '${model.modifiedExercises[model.exerciseIndex].workoutPlanId}_$index'),
                              workoutScheduleId: widget.workoutScheduleId,
                              initialReps: element.reps!,
                              model: model,
                              setInfoIndex: index,
                              refresh: () {
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                            );
                          } else if (model
                                      .modifiedExercises[model.exerciseIndex]
                                      .trackingFieldId ==
                                  3 ||
                              model.modifiedExercises[model.exerciseIndex]
                                      .trackingFieldId ==
                                  4) {
                            return SetInfoBoxForTimer(
                              key: ValueKey(
                                  '${model.modifiedExercises[model.exerciseIndex].workoutPlanId}_$index'),
                              workoutScheduleId: widget.workoutScheduleId,
                              initialSeconds: element.seconds!,
                              model: model,
                              setInfoIndex: index,
                              refresh: () {
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                            );
                          }
                        } else {
                          return Container(
                            color: Pallete.lightGray.withOpacity(0.15),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                              ),
                              child: Column(
                                children: [
                                  SvgPicture.asset(SVGConstants.message),
                                  InkWell(
                                    onTap: () async {
                                      Navigator.of(context)
                                          .push(CupertinoPageRoute(
                                        builder: (context) =>
                                            WorkoutChangeScreen(
                                          exerciseIndex: model.exerciseIndex,
                                          workout: widget.workout,
                                        ),
                                      ))
                                          .then(
                                        (value) {
                                          if (value != null) {
                                            ref
                                                .read(workoutProcessProvider(
                                                        widget
                                                            .workoutScheduleId)
                                                    .notifier)
                                                .exerciseChange(value);
                                            isTooltipVisible = false;
                                            tooltipCount = 0;
                                            onTooltipPressed();
                                            tooltipSeq = 0;
                                            if (mounted) {
                                              setState(() {});
                                            }

                                            if (isSwipeUp) {
                                              final index = model
                                                              .setInfoCompleteList[
                                                          model
                                                              .exerciseIndex] ==
                                                      model.maxSetInfoList[
                                                          model.exerciseIndex]
                                                  ? model.setInfoCompleteList[
                                                          model.exerciseIndex] -
                                                      1
                                                  : model.setInfoCompleteList[
                                                      model.exerciseIndex];

                                              itemScrollController.jumpTo(
                                                  index: index);
                                            }
                                          }
                                        },
                                      );
                                    },
                                    child: SizedBox(
                                      height: 55,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SvgPicture.asset(
                                            SVGConstants.list,
                                            width: 24,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            '운동 리스트',
                                            style: h5Headline.copyWith(
                                              height: 1,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(CupertinoPageRoute(
                                        builder: (context) => ExerciseScreen(
                                            exercise: widget.exercises[
                                                model.exerciseIndex]),
                                      ));
                                    },
                                    child: SizedBox(
                                      height: 55,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SvgPicture.asset(
                                            SVGConstants.guide,
                                            width: 24,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            '운동 가이드',
                                            style: h5Headline.copyWith(
                                              height: 1,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(CupertinoPageRoute(
                                        builder: (context) =>
                                            WorkoutHistoryScreen(
                                          workoutPlanId: widget
                                              .exercises[model.exerciseIndex]
                                              .workoutPlanId,
                                        ),
                                      ));
                                    },
                                    child: SizedBox(
                                      height: 55,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SvgPicture.asset(
                                            SVGConstants.history,
                                            colorFilter: const ColorFilter.mode(
                                              Colors.black,
                                              BlendMode.srcIn,
                                            ),
                                            width: 24,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            '운동 히스토리',
                                            style: h5Headline.copyWith(
                                              height: 1,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: ((11 -
                                                model.maxSetInfoList[
                                                    model.exerciseIndex]) *
                                            30)
                                        .toDouble(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _movetoRecentSetInfo(int index) {
    int tempIndex = index < 2 ? index : index - 2;

    itemScrollController.jumpTo(index: tempIndex);
  }

  Future<void> _onTapNext(
      BuildContext context, WorkoutProcessModel model) async {
    print('dialog - isQuitting ===> ${model.isQuitting}');

    await ref
        .read(workoutProcessProvider(widget.workoutScheduleId).notifier)
        .nextWorkout()
        .then((value) async {
      if (value != null) {
        if (value == -1) {
          await ref
              .read(workoutProcessProvider(widget.workoutScheduleId).notifier)
              .quitWorkout(
                title: widget.workout.workoutTitle,
                subTitle: widget.workout.workoutSubTitle,
                trainerId: widget.workout.trainerId,
              )
              .then((_) {
            final id = widget.workoutScheduleId;
            final date = widget.workout.startDate;
            context.pop();

            GoRouter.of(context).pushNamed(
              WorkoutFeedbackScreen.routeName,
              pathParameters: {
                'workoutScheduleId': id.toString(),
              },
              extra: widget.exercises,
              queryParameters: {
                'startDate':
                    DateFormat('yyyy-MM-dd').format(DateTime.parse(date)),
              },
            );
          });
        } else {
          _showUncompleteExerciseDialog(context, value, model.isQuitting);
        }
      }
    });
    if (mounted) {
      setState(() {});
    }
  }

  Future<dynamic> _showUncompleteExerciseDialog(
    BuildContext context,
    int index,
    bool isQuitting,
  ) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return DialogWidgets.confirmDialog(
          dismissable: false,
          message: '완료하지 않은 운동이 있어요🤓\n 마저 진행할까요?',
          confirmText: '네, 마저할게요',
          cancelText: isQuitting ? '종료중...' : '아니요, 그만할래요',
          confirmOnTap: () {
            ref
                .read(workoutProcessProvider(widget.workoutScheduleId).notifier)
                .exerciseChange(index);

            context.pop();
          },
          cancelOnTap: isQuitting
              ? () {}
              : () async {
                  //완료!!!
                  try {
                    await ref
                        .read(workoutProcessProvider(widget.workoutScheduleId)
                            .notifier)
                        .quitWorkout(
                          title: widget.workout.workoutTitle,
                          subTitle: widget.workout.workoutSubTitle,
                          trainerId: widget.workout.trainerId,
                        )
                        .then((value) {
                      final id = widget.workoutScheduleId;
                      final date = widget.workout.startDate;

                      context.pop();
                      context.pop();

                      GoRouter.of(context).replaceNamed(
                        WorkoutFeedbackScreen.routeName,
                        pathParameters: {
                          'workoutScheduleId': id.toString(),
                        },
                        extra: widget.exercises,
                        queryParameters: {
                          'startDate': DateFormat('yyyy-MM-dd')
                              .format(DateTime.parse(date)),
                        },
                      );
                    });
                  } on DioException catch (e) {
                    debugPrint('$e');
                  }
                },
        );
      },
    );
  }

  void _pagePop() {
    DialogWidgets.confirmDialog(
      message: '아직 운동이 끝나지 않았어요 😮\n저장 후 뒤로 갈까요?',
      confirmText: '네, 저장할게요',
      cancelText: '아니요, 리셋할래요',
      confirmOnTap: () {
        int count = 0;
        if (mounted) {
          Navigator.of(context).popUntil((_) => count++ >= 2);
        }
      },
      cancelOnTap: () {
        if (mounted) {
          int count = 0;
          ref
              .read(workoutProcessProvider(widget.workoutScheduleId).notifier)
              .resetWorkoutProcess();

          Navigator.of(context).popUntil((_) => count++ >= 2);
          setState(() {});
        }
      },
    ).show(context);
  }
}

class _ShowTip extends ConsumerStatefulWidget {
  const _ShowTip({
    required this.size,
    required this.widget,
    required this.workoutScheduleId,
    required this.tooltipSeq,
  });

  final Size size;
  final WorkoutScreen widget;
  final int workoutScheduleId;
  final int tooltipSeq;

  @override
  ConsumerState<_ShowTip> createState() => _ShowTipState();
}

class _ShowTipState extends ConsumerState<_ShowTip> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutProcessProvider(widget.workoutScheduleId));

    final model = state as WorkoutProcessModel;
    final index = model.setInfoCompleteList[model.exerciseIndex] ==
            model.maxSetInfoList[model.exerciseIndex]
        ? model.setInfoCompleteList[model.exerciseIndex] - 1
        : model.setInfoCompleteList[model.exerciseIndex];

    String setInfoString = '';
    final setInfo = model.modifiedExercises[model.exerciseIndex].setInfo[index];
    final setSeq = model.setInfoCompleteList[model.exerciseIndex] + 1;

    if (model.modifiedExercises[model.exerciseIndex].trackingFieldId == 1) {
      setInfoString =
          '$setSeq세트는 ${setInfo.weight! % 1 == 0 ? setInfo.weight!.toInt() : setInfo.weight}kg으로 ${setInfo.reps}회 진행해주세요!';
    } else if (model.modifiedExercises[model.exerciseIndex].trackingFieldId ==
        2) {
      setInfoString = '$setSeq세트는 ${setInfo.reps}회 진행해주세요!';
    } else {
      setInfoString =
          '$setSeq세트는 ${DataUtils.getTimerString(setInfo.seconds!)} 진행해주세요!';
    }

    return Positioned(
      left: 28,
      bottom: 250,
      right: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: widget.size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black.withOpacity(0.8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tooltipSeq == 0
                        ? '${state.exercises[state.exerciseIndex].trainerNickname} 🗣️'
                        : 'Tip 📣',
                    style: h5Headline.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  AutoSizeText(
                    widget.tooltipSeq == 0 &&
                            model.setInfoCompleteList[model.exerciseIndex] == 0
                        ? '이번 운동은 ${model.modifiedExercises[model.exerciseIndex].name} 입니다.\n$setInfoString'
                        : widget.tooltipSeq == 0 &&
                                model.setInfoCompleteList[model.exerciseIndex] >
                                    0
                            ? setInfoString
                            : model.modifiedExercises[model.exerciseIndex]
                                .description,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
          const MyClipPath(),
        ],
      ),
    );
  }
}
