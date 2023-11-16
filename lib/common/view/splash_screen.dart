import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitend_member/common/component/logo_appbar.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/user/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  static String get routeName => 'splash';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("asset/img/couple-training-together-gym2.png"),
            fit: BoxFit.fill,
            opacity: 0.4),
      ),
      child: const Scaffold(
        backgroundColor: Colors.transparent,
        appBar: LogoAppbar(
          title: 'F I T E N D',
        ),
        body: _BottomView(),
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
          const Expanded(
            child: SizedBox(),
          ),
          Text(
            '운동이 숙제가 아닌,\n일상의 즐거움이 될 수 있도록!',
            style: h3Headline.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          AutoSizeText(
            'Routine for 4 Weeks!\n디지털 PT의 새로운 패러다임을 지금 바로 경험해보세요!',
            style: s2SubTitle.copyWith(
              color: Pallete.lightGray,
            ),
            maxLines: 2,
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
                  backgroundColor: Pallete.point,
                ),
                onPressed: () {
                  context.goNamed(LoginScreen.routeName);
                },
                child: Text(
                  '시작하기',
                  style: h6Headline,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          )
        ],
      ),
    );
  }
}
