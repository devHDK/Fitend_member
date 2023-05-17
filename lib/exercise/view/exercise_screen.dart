import 'package:fitend_member/common/component/custom_video_player.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/exercise/component/muscle_card.dart';
import 'package:flutter/material.dart';

class ExerciseScreen extends StatefulWidget {
  static String get routeName => 'exercise';
  const ExerciseScreen({super.key});

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
          onPressed: () => Navigator.pop(context),
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
                child: const CustomVideoPlayer(
                  firstUrl:
                      "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
                  secondUrl:
                      'https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
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
                    children: const [
                      SizedBox(
                        height: 32,
                      ),
                      Text(
                        '로우 머신',
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      Divider(
                        height: 1,
                        color: BODY_TEXT_COLOR,
                      ),
                    ],
                  ),

                  //코칭포인트
                  Column(
                    children: [
                      const SizedBox(
                        height: 24,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'asset/img/trainer_profile.png',
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                '코칭 포인트',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                'by Kelly 트레이너',
                                style: TextStyle(
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
                      const Text(
                        '수축과 이완을 반복하실 때 수축시 팔꿈치가 뒤로 빠지시는 것을 주의해 주시고, 이완시 허리가 뽑히지 않게 복압을 유지해주세요.',
                        style: TextStyle(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
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
                  return const MuscleCard();
                },
                childCount: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4
// https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4
// https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4
// https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4
// https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4
// https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4
// https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4
// https://storage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4
// https://storage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4
// https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4

// https://storage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg
// https://storage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg
// https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg
// https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg
// https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerFun.jpg
// https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerJoyrides.jpg
// https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerMeltdowns.jpg
// https://storage.googleapis.com/gtv-videos-bucket/sample/images/Sintel.jpg
// https://storage.googleapis.com/gtv-videos-bucket/sample/images/SubaruOutbackOnStreetAndDirt.jpg
// https://storage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg
