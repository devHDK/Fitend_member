import 'package:fitend_member/common/component/draggable_bottom_sheet.dart';
import 'package:fitend_member/common/component/workout_video_player.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/exercise_video_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WorkoutScreen extends StatefulWidget {
  final List<Exercise> exercises;
  final DateTime date;

  const WorkoutScreen({
    super.key,
    required this.exercises,
    required this.date,
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  bool isSwipeUp = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
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
                      Text(
                        '${widget.exercises[0].setInfo[0].weight}kg ∙ ${widget.exercises[0].setInfo[0].reps}회',
                        style: const TextStyle(
                          color: GRAY_COLOR,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        widget.exercises[0].name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: POINT_COLOR),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '1세트 진행중',
                            style: TextStyle(
                              color: POINT_COLOR,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {},
                            child: Image.asset(
                              'asset/img/icon_edit.png',
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: const BoxDecoration(
                                color: POINT_COLOR,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          InkWell(
                            onTap: () {},
                            child: Image.asset(
                              'asset/img/icon_foward.png',
                            ),
                          ),
                        ],
                      )
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
}
