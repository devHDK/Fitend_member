import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/layout/default_layout.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnBoardingScreen extends StatelessWidget {
  static String get routeName => 'onboard';
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      backgroundColor: BACKGROUND_COLOR,
      child: Center(
        child: AnimatedTextKit(
          animatedTexts: [
            ColorizeAnimatedText('F I T E N D',
                textStyle: GoogleFonts.audiowide(
                    fontSize: 45,
                    // color: POINT_COLOR,
                    fontWeight: FontWeight.w500),
                colors: [
                  POINT_COLOR,
                  POINT_COLOR,
                  Colors.white,
                ],
                speed: const Duration(milliseconds: 300),
                textDirection: TextDirection.rtl),
          ],
        ),
      ),
    );
  }
}
