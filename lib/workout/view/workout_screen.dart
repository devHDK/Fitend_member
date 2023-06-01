import 'package:fitend_member/common/component/draggable_bottom_sheet.dart';
import 'package:fitend_member/common/component/workout_video_player.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/exercise_video_model.dart';
import 'package:fitend_member/exercise/model/setInfo_model.dart';
import 'package:fitend_member/exercise/view/exercise_screen.dart';
import 'package:fitend_member/workout/component/weight_reps_progress_card.dart';
import 'package:fitend_member/workout/model/workout_record_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  final List<Exercise> exercises;
  final DateTime date;

  const WorkoutScreen({
    super.key,
    required this.exercises,
    required this.date,
  });

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  bool isSwipeUp = false;

  int exerciseIndex = 0;

  List<int> setInfoCompleteCounts = [];
  bool isProcessing = false;
  List<SetInfo> tempSetInfos = [];

  @override
  void initState() {
    super.initState();

    setInfoCompleteCounts =
        List.generate(widget.exercises.length, (index) => 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final AsyncValue<Box> box = ref.read(hiveWorkoutRecordProvider);

    box.whenData(
      (value) {
        for (int i = 0; i < widget.exercises.length; i++) {
          if (value.get(widget.exercises[i].workoutPlanId) != null &&
              value.get(widget.exercises[i].workoutPlanId).setInfo.length > 0) {
            setInfoCompleteCounts[i] =
                value.get(widget.exercises[i].workoutPlanId).setInfo.length;

            if (setInfoCompleteCounts[i] >=
                    widget.exercises[i].setInfo.length &&
                widget.exercises.length - 1 > exerciseIndex) {
              exerciseIndex++;
            }
          } else {
            setInfoCompleteCounts[i] = 0;
          }
        }
      },
    );

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            left: 0.0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 690,
              child: WorkoutVideoPlayer(
                video: ExerciseVideo(
                  url:
                      'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
                  index: 1,
                  thumbnail:
                      'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg',
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            bottom: 0.0,
            curve: Curves.linear,
            duration: const Duration(milliseconds: 300),
            top: isSwipeUp ? size.height - 315 : size.height - 195,
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
                      WeightWrepsProgressCard(
                        exercise: widget.exercises[exerciseIndex],
                        setInfoIndex: setInfoCompleteCounts[exerciseIndex] - 1,
                        processOnTap: () {
                          tempSetInfos.add(
                              widget.exercises[exerciseIndex].setInfo[
                                  setInfoCompleteCounts[exerciseIndex] - 1]);

                          box.whenData(
                            (value) => value.put(
                              widget.exercises[exerciseIndex].workoutPlanId,
                              WorkoutRecordModel(
                                  workoutPlanId: widget
                                      .exercises[exerciseIndex].workoutPlanId,
                                  setInfo: tempSetInfos),
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      if (isSwipeUp)
                        Column(
                          children: [
                            const Divider(
                              height: 1,
                              color: GRAY_COLOR,
                            ),
                            const SizedBox(
                              height: 27,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _IconButton(
                                  img: 'asset/img/icon_change.png',
                                  name: '운동 변경',
                                  onTap: () {},
                                ),
                                _IconButton(
                                  img: 'asset/img/icon_guide.png',
                                  name: '운동 가이드',
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => ExerciseScreen(
                                          exercise: widget.exercises[0]),
                                    ));
                                  },
                                ),
                                _IconButton(
                                  img: 'asset/img/icon_record.png',
                                  name: '영상 녹화',
                                  textColor: LIGHT_GRAY_COLOR,
                                  onTap: () {},
                                ),
                                _IconButton(
                                  img: 'asset/img/icon_stop.png',
                                  name: '운동 종료',
                                  onTap: () {},
                                ),
                              ],
                            )
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InkWell _IconButton({
    required String img,
    required String name,
    required GestureTapCallback onTap,
    Color textColor = GRAY_COLOR,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          SizedBox(
            height: 44,
            width: 44,
            child: Image.asset(img),
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            name,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          )
        ],
      ),
    );
  }
}
