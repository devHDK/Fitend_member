import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/component/guide_video_player.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/exercise/component/muscle_card.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/exercise_video_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExerciseScreen extends StatefulWidget {
  final int? id;
  final Exercise exercise;

  static String get routeName => 'exercise';
  const ExerciseScreen({
    super.key,
    this.id,
    required this.exercise,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor:
            _scrollOffset <= 5.0 ? Colors.transparent : BACKGROUND_COLOR,
        elevation: _scrollOffset <= 5.0 ? 0.0 : 1.0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
          color: _scrollOffset <= 5.0 ? Colors.black : Colors.white,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 660,
                child: GuideVideoPlayer(
                  videos: [
                    ExerciseVideo(
                        url:
                            'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
                        index: 1,
                        thumbnail:
                            'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg'),
                    ExerciseVideo(
                        url:
                            'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
                        index: 2,
                        thumbnail:
                            'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerFun.jpg'),
                    ExerciseVideo(
                        url:
                            'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
                        index: 3,
                        thumbnail:
                            'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg'),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 32,
                      ),
                      Text(
                        widget.exercise.name,
                        style: const TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      const Divider(
                        height: 1,
                        color: BODY_TEXT_COLOR,
                      ),
                    ],
                  ),

                  //코칭포인트
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 24,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: CircleAvatar(
                              backgroundColor: POINT_COLOR,
                              child: CustomNetworkImage(
                                imageUrl:
                                    '$s3Url${widget.exercise.trainerProfileImage}',
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '코칭 포인트',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                'by ${widget.exercise.trainerNickname} 트레이너',
                                style: const TextStyle(
                                  color: BODY_TEXT_COLOR,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        widget.exercise.description,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          height: 2,
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      const Divider(
                        height: 1,
                        color: BODY_TEXT_COLOR,
                      ),
                    ],
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                      ),
                      Text(
                        '머슬포인트',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          //머슬포인트
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final muscleModel = widget.exercise.targetMuscles[index];

                  return MuscleCard(
                    muscle: muscleModel,
                  );
                },
                childCount: widget.exercise.targetMuscles.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
