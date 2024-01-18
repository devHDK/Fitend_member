import 'package:fitend_member/common/component/logo_appbar.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/user/view/login_screen.dart';
import 'package:fitend_member/verification/model/post_verification_model.dart';
import 'package:fitend_member/verification/view/verification_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

List<String> title = [
  '디지털 트레이닝의 시작',
  '나만의 맞춤형 운동루틴',
  '체계적인 관리와 피드백',
  '담당코치와 언제든 소통',
];

List<String> content = [
  '원하는 시간에, 원하는 곳에서\n당신의 트레이너와 함께 운동하세요.',
  '다이어트, 근력강화, 체형교정 등\n목표달성에 필요한 계획을 세워드려요.',
  '매일 당신의 운동결과를 확인하고\n부족한 점에 대한 해결방안을 알려드려요.',
  '운동을 하며 궁금한 점이 생기면\n담당코치에게 언제든지 물어보세요.'
];

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static String get routeName => 'splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int pageIndex = 0;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      initialPage: pageIndex,
    );

    _pageController?.addListener(_pageControllerListner);
  }

  void _pageControllerListner() {
    setState(() {
      pageIndex = _pageController!.page!.round();
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _pageController?.removeListener(_pageControllerListner);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            IMGConstants.onboardBackground[pageIndex],
          ),
          fit: BoxFit.fill,
          // opacity: 0.4,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const LogoAppbar(
          title: 'F I T E N D',
        ),
        body: _BottomView(
          pageController: _pageController,
          pageIndex: pageIndex,
        ),
      ),
    );
  }
}

class _BottomView extends StatefulWidget {
  const _BottomView({
    required this.pageController,
    required this.pageIndex,
  });
  final PageController? pageController;
  final int pageIndex;

  @override
  State<_BottomView> createState() => _BottomViewState();
}

class _BottomViewState extends State<_BottomView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: 30,
        ),
        Expanded(
          child: PageView.builder(
            controller: widget.pageController,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    height: 320,
                    child: Image.asset(
                      IMGConstants.onboardComponent[index],
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  const SizedBox(
                    height: 64,
                  ),
                  Text(
                    title[index],
                    style: h2Headline.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    content[index],
                    style: s3SubTitle.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
            itemCount: 4,
          ),
        ),
        SizedBox(
          height: 30,
          child: PageViewDotIndicator(
            currentItem: widget.pageIndex,
            count: 4,
            unselectedColor: Pallete.gray,
            selectedColor: Colors.white,
            size: const Size(6, 6),
            unselectedSize: const Size(6, 6),
          ),
        ),
        const SizedBox(
          height: 35,
        ),
        Column(
          children: [
            SizedBox(
              height: 44,
              width: 100.w - 56,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallete.point,
                  ),
                  onPressed: () {
                    // context.goNamed(RegisterScreen.routeName);
                    Navigator.of(context).push(CupertinoPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => VerificationScreen(
                          verificationType: VerificationType.register),
                    ));
                  },
                  child: Text(
                    '14일 무료 체험 하기',
                    style: h6Headline,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            SizedBox(
              height: 44,
              width: 100.w - 56,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    context.goNamed(LoginScreen.routeName);
                  },
                  child: Text(
                    '로그인',
                    style: h6Headline.copyWith(
                      color: Pallete.point,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            )
          ],
        ),
      ],
    );
  }
}
