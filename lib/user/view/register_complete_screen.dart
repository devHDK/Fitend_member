import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/user/provider/user_register_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class RegisterCompleteScreen extends ConsumerStatefulWidget {
  const RegisterCompleteScreen({
    super.key,
    required this.phone,
    required this.trainerName,
  });

  final String phone;
  final String trainerName;

  @override
  ConsumerState<RegisterCompleteScreen> createState() =>
      _RegisterCompleteScreenState();
}

class _RegisterCompleteScreenState
    extends ConsumerState<RegisterCompleteScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final registerModel = ref.watch(userRegisterProvider(widget.phone));

    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Pallete.background,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(Icons.arrow_back),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 24,
            ),
            Text(
              '${widget.trainerName} 코치님과\n앞으로의 운동여정을 응원합니다 💪',
              style: h3Headline.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 36,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(SVGConstants.checkWhite),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '맞춤형 운동계획',
                      style: h4Headline.copyWith(color: Colors.white),
                    ),
                    Text(
                      '${registerModel.nickname}님의 사전설문 데이터를 바탕으로\n실현가능한 운동루틴을 만들어드려요.',
                      style: s1SubTitle.copyWith(color: Colors.white),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(SVGConstants.checkWhite),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1:1 관리 및 피드백',
                      style: h4Headline.copyWith(color: Colors.white),
                    ),
                    Text(
                      '자세 및 운동과 관련된 질문이 생기면\n코치님께 언제든지 물어볼 수 있어요.',
                      style: s1SubTitle.copyWith(color: Colors.white),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(SVGConstants.checkWhite),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '지속가능한 운동습관',
                      style: h4Headline.copyWith(color: Colors.white),
                    ),
                    Text(
                      '포기하지 않고 꾸준히 지속할 수 있도록\n동기부여와 멘탈케어를 해드릴게요.  ',
                      style: s1SubTitle.copyWith(color: Colors.white),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 135,
            ),
            RichText(
              text: TextSpan(
                style: s3SubTitle,
                children: <TextSpan>[
                  const TextSpan(text: '∙ 14일 무료체험 시작시 '),
                  TextSpan(
                    text: '개인정보 처리방침',
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                    ),
                    recognizer: TapAndPanGestureRecognizer()
                      ..onTapDown = (detail) => DataUtils.onWebViewTap(
                          uri:
                              "https://weareraid.notion.site/06b383e3c7aa4515a4637c2c11f3d908?pvs=4"),
                  ),
                  const TextSpan(text: ' 과 서비스 '),
                  TextSpan(
                    text: '이용약관',
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                    ),
                    recognizer: TapAndPanGestureRecognizer()
                      ..onTapDown = (detail) => DataUtils.onWebViewTap(
                            uri:
                                "https://weareraid.notion.site/87468f88c99b427b81ae3e44aeb1f37b?pvs=4",
                          ),
                  ),
                  const TextSpan(text: '에\n    동의하는 것으로 간주됩니다.'),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: TextButton(
        onPressed: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            height: 44,
            width: 100.w,
            decoration: BoxDecoration(
              color: Pallete.point,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '14일 무료체험 시작',
                style: h6Headline.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
