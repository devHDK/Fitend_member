import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/component/guide_video_player.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/exercise/component/muscle_card.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/exercise/model/exercise_video_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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
      backgroundColor: Pallete.background,
      appBar: AppBar(
        backgroundColor:
            _scrollOffset <= 5.0 ? Colors.transparent : Pallete.background,
        elevation: _scrollOffset <= 5.0 ? 0.0 : 1.0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Icon(Icons.arrow_back)),
          color: _scrollOffset <= 5.0 ? Colors.black : Colors.white,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Pallete.gray,
              child: Center(
                child: SizedBox(
                  width: 100.w > 600 //테블릿이면
                      ? (100.h - 175) * 9 / 16
                      : 100.w,
                  height: 100.w > 600 ? 100.h - 175 : 100.w * 16 / 9,
                  child: GuideVideoPlayer(
                    videos: widget.exercise.videos
                        .map((e) => ExerciseVideo(
                            url: '$s3Url${e.url}',
                            index: e.index,
                            thumbnail: '$s3Url${e.thumbnail}'))
                        .toList(),
                  ),
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
                      AutoSizeText(
                        widget.exercise.name,
                        style: h1Headline.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      const Divider(
                        height: 1,
                        color: Pallete.lightGray,
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
                              backgroundColor: Pallete.point,
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
                              Text(
                                '코칭 포인트',
                                style: h5Headline.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                'by ${widget.exercise.trainerNickname}',
                                style: s3SubTitle.copyWith(
                                  color: Pallete.lightGray,
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
                        style: s2SubTitle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      const Divider(
                        height: 1,
                        color: Pallete.lightGray,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        '머슬 포인트',
                        style: h5Headline.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
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
