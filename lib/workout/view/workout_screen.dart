import 'dart:async';
import 'package:fitend_member/common/component/custom_clipper.dart';
import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/component/draggable_bottom_sheet.dart';
import 'package:fitend_member/common/component/workout_video_player.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/hive_box_utils.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/exercise_video_model.dart';
import 'package:fitend_member/workout/component/timer_x_more_progress_card%20.dart';
import 'package:fitend_member/workout/component/timer_x_one_progress_card.dart';
import 'package:fitend_member/workout/component/weight_reps_progress_card.dart';
import 'package:fitend_member/workout/model/workout_model.dart';
import 'package:fitend_member/workout/model/workout_process_model.dart';
import 'package:fitend_member/workout/provider/workout_process_provider.dart';
import 'package:fitend_member/workout/provider/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
    with SingleTickerProviderStateMixin {
  bool isSwipeUp = false;
  bool initial = true;
  bool isPoped = false;
  bool isTooltipVisible = false;
  int tooltipCount = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() {}

  @override
  void dispose() {
    if (timer.isActive) {
      timer.cancel();
    }

    super.dispose();
  }

  void onTooltipPressed() {
    if (isTooltipVisible) {
      timer.cancel();
      setState(() {
        isTooltipVisible = !isTooltipVisible;
        tooltipCount = 0;
      });
    } else {
      setState(() {
        isTooltipVisible = !isTooltipVisible;
        tooltipCount = 3;
      });
      timer = Timer.periodic(
        const Duration(seconds: 1),
        onTick,
      );
    }
  }

  void onTick(Timer timer) {
    if (tooltipCount == 0) {
      //0초가 됬을때 저장
      timer.cancel();
      setState(() {
        isTooltipVisible = false;
      });
    } else {
      setState(() {
        tooltipCount -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final state = ref.watch(workoutProcessProvider(widget.workoutScheduleId));

    if (state is WorkoutProcessModelLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: POINT_COLOR,
        ),
      );
    }

    final model = state as WorkoutProcessModel;

    print(model.setInfoCompleteList);

    return WillPopScope(
      onWillPop: () async {
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: GRAY_COLOR,
        floatingActionButton: isSwipeUp
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('button'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('button'),
                  ),
                ],
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 18),
            child: IconButton(
              // onPressed: () => GoRouter.of(context).pop('result'),
              onPressed: () {
                if (mounted) {}
              },
              icon: const Icon(Icons.arrow_back),
              color: Colors.black,
            ),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 18.0),
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned(
              // left: 0.0,
              right: MediaQuery.of(context).size.width > 600 //테블릿이면
                  ? (MediaQuery.of(context).size.width -
                          (MediaQuery.of(context).size.height) * 9 / 16) /
                      2
                  : 0,
              child: SizedBox(
                width: MediaQuery.of(context).size.width > 600 //테블릿이면
                    ? (MediaQuery.of(context).size.height) * 9 / 16
                    : MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width > 600
                    ? MediaQuery.of(context).size.height
                    : MediaQuery.of(context).size.width * 16 / 9,
                child: WorkoutVideoPlayer(
                  video: ExerciseVideo(
                      url:
                          '$s3Url${widget.exercises[model.exerciseIndex].videos.first.url}',
                      index: widget
                          .exercises[model.exerciseIndex].videos.first.index,
                      thumbnail:
                          '$s3Url${widget.exercises[model.exerciseIndex].videos.first.thumbnail}'),
                ),
              ),
            ),
            Positioned(
              bottom: 210,
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
                        '$s3Url${widget.exercises[model.exerciseIndex].trainerProfileImage}',
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
                exerciseIndex: model.exerciseIndex,
              ),
            AnimatedPositioned(
              bottom: 0.0,
              curve: Curves.ease,
              duration: const Duration(milliseconds: 300),
              top: isSwipeUp
                  ? (MediaQuery.of(context).padding.top + kToolbarHeight)
                  : size.height - 195,
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.velocity.pixelsPerSecond.direction < 0) {
                    setState(() {
                      isSwipeUp = true;
                    });
                  } else {
                    setState(() {
                      isSwipeUp = false;
                    });
                  }
                },
                child: CustomDraggableBottomSheet(
                  isSwipeUp: isSwipeUp,
                  content: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        if (model.modifiedExercises[model.exerciseIndex]
                                    .trackingFieldId ==
                                1 ||
                            model.modifiedExercises[model.exerciseIndex]
                                    .trackingFieldId ==
                                2)
                          WeightWrepsProgressCard(
                            exercise:
                                model.modifiedExercises[model.exerciseIndex],
                            setInfoIndex:
                                model.setInfoCompleteList[model.exerciseIndex],
                            updateSeinfoTap: state
                                        .modifiedExercises[model.exerciseIndex]
                                        .trackingFieldId ==
                                    1
                                ? () {}
                                : () {},
                            proccessOnTap: () {},

                            //운동 변경
                          ),
                        // Timer X 1set
                        if ((model.modifiedExercises[model.exerciseIndex]
                                        .trackingFieldId ==
                                    3 ||
                                model.modifiedExercises[model.exerciseIndex]
                                        .trackingFieldId ==
                                    4) &&
                            model.modifiedExercises[model.exerciseIndex].setInfo
                                    .length ==
                                1)
                          TimerXOneProgressCard(
                            exercise:
                                model.modifiedExercises[model.exerciseIndex],
                            setInfoIndex:
                                model.setInfoCompleteList[model.exerciseIndex],
                            proccessOnTap: () {},
                            updateSeinfoTap: () {},
                          ),

                        // Timer X more
                        if ((model.modifiedExercises[model.exerciseIndex]
                                        .trackingFieldId ==
                                    3 ||
                                model.modifiedExercises[model.exerciseIndex]
                                        .trackingFieldId ==
                                    4) &&
                            model.modifiedExercises[model.exerciseIndex].setInfo
                                    .length >
                                1)
                          TimerXMoreProgressCard(
                            exercise:
                                model.modifiedExercises[model.exerciseIndex],
                            setInfoIndex:
                                model.setInfoCompleteList[model.exerciseIndex],
                            updateSeinfoTap: () {},
                            proccessOnTap: () {},
                            resetSet: () {},
                          ),
                      ],

                      // if (isSwipeUp)
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _screenPop(
      AsyncValue<Box<dynamic>> processingExerciseIndexBox,
      BuildContext context,
      AsyncValue<Box<dynamic>> modifiedBox,
      AsyncValue<Box<dynamic>> recordBox,
      AsyncValue<Box<dynamic>> timerWorkoutBox,
      AsyncValue<Box<dynamic>> timerXMoreBox) {
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
        BoxUtils.deleteBox(recordBox, widget.exercises);
        BoxUtils.deleteBox(modifiedBox, widget.exercises);
        BoxUtils.deleteTimerBox(timerWorkoutBox, widget.exercises);
        BoxUtils.deleteTimerBox(timerXMoreBox, widget.exercises);
        // BoxUtils.deleteBox(workoutResultBox, widget.exercises);

        processingExerciseIndexBox.whenData(
          (value) {
            value.delete(
              widget.workoutScheduleId,
            );
          },
        );

        int count = 0;
        if (mounted) {
          Navigator.of(context).popUntil((_) => count++ >= 2);
        }
      },
    ).show(context);
  }
}

class _ShowTip extends StatelessWidget {
  const _ShowTip({
    required this.size,
    required this.widget,
    required this.exerciseIndex,
  });

  final Size size;
  final WorkoutScreen widget;
  final int exerciseIndex;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 28,
      bottom: 260,
      right: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: size.width,
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
                    'Tip 📣',
                    style: h5Headline.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    widget.exercises[exerciseIndex].description,
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
