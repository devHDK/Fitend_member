import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/user/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  static String get routeName => 'splash';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("asset/img/couple-training-together-gym2.png"),
            fit: BoxFit.cover,
            opacity: 0.4),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            'F I T E N D',
            style: GoogleFonts.audiowide(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: const _BottomView(),
      ),
    );
  }
}

class _BottomView extends StatelessWidget {
  const _BottomView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 461,
          ),
          const Text(
            '운동 졸업은 핏엔드에서!\n핏엔드에 오신 것을 환영합니다!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          const Text(
            'Routine for 4 Weeks!\n새로운 디지털 PT의 패러다임을 지금 바로 경험해보세요',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: BODY_TEXT_COLOR),
          ),
          const SizedBox(
            height: 40,
          ),
          SizedBox(
            height: 44,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: POINT_COLOR,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  '시작하기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
