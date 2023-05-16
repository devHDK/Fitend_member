import 'package:fitend_member/common/const/colors.dart';
import 'package:flutter/material.dart';

class WorkoutScreen extends StatefulWidget {
  static String get routeName => 'workout';

  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back)),
        centerTitle: true,
        title: const Text(
          '4월 19일 수요일',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('asset/img/schedule_image_pt.png'),
                  fit: BoxFit.fill,
                  opacity: 0.4,
                ),
              ),
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '자신감이 넘치는 둔근 만들기🔥',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    const Text(
                      '기초 코어 기르기',
                      style: TextStyle(
                        color: BODY_TEXT_COLOR,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Divider(
                      thickness: 1,
                      color: BODY_TEXT_COLOR,
                    ),
                    const SizedBox(
                      height: 19,
                    ),
                    Row(
                      children: [
                        const Text(
                          '총 4개의 운동',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Expanded(
                          child: SizedBox(),
                        ),
                        Image.asset(
                          'asset/img/timer.png',
                          width: 14,
                        ),
                        const Text(
                          '1시간 10분',
                          style: TextStyle(
                            color: BODY_TEXT_COLOR,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
