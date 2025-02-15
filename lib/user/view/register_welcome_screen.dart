import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bubble/bubble.dart';
import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/meeting/view/meeting_date_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class RegisterWelcomeScreen extends StatefulWidget {
  const RegisterWelcomeScreen({
    super.key,
    required this.trainerName,
    required this.trainerProfileImage,
    required this.userNickname,
    required this.trainerId,
  });

  final String trainerName;
  final String trainerProfileImage;
  final String userNickname;
  final int trainerId;

  @override
  State<RegisterWelcomeScreen> createState() => _RegisterWelcomeScreenState();
}

class _RegisterWelcomeScreenState extends State<RegisterWelcomeScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final List<Widget> _items = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addItems();
    });
  }

  void _addItems() {
    final userName = widget.userNickname.substring(1);

    List<String> chattingStrings = [
      '안녕하세요 $userName님! ',
      '회원님의 건강한 운동여정을 함께할\n${widget.trainerName} 코치입니다 💪',
      '시작에 앞서 저와 15분 정도 간단히\n미팅을 진행하실텐데',
      '$userName님을 위한 맞춤형 운동설계에 있어\n꼭 필요한 과정이에요!',
      '준비되셨으면 아래 버튼을 눌러\n가능하신 일정을 선택해주세요 :)'
    ];

    Future ft = Future(() {});
    for (int index = 0; index < 6; index++) {
      ft = ft.then((_) {
        return Future.delayed(const Duration(milliseconds: 1500), () {
          if (index == 5) {
            setState(() {});
          } else {
            _items.insert(
              index,
              _chattingBubble(
                index,
                chattingStrings[index],
                widget.trainerName,
                '${URLConstants.s3Url}${widget.trainerProfileImage}',
              ),
            );
            _listKey.currentState?.insertItem(index);
          }
        });
      });
    }
  }

  Widget _chattingBubble(
      int index, String text, String trainerName, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        height: index == 0 ? 75 : 85,
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: CustomNetworkImage(
                    width: 36,
                    imageUrl: imageUrl,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Text(
                  trainerName,
                  style: h5Headline.copyWith(
                    color: Colors.white,
                  ),
                )
              ],
            ),
            Positioned(
              left: 31,
              top: 15,
              child: Bubble(
                margin: const BubbleEdges.only(top: 10),
                nipOffset: 5,
                alignment: Alignment.topRight,
                nipWidth: 20,
                nipHeight: 7,
                nip: BubbleNip.leftTop,
                color: Pallete.darkGray,
                child: DefaultTextStyle(
                  style: s2SubTitle.copyWith(
                    color: Colors.white,
                  ),
                  child: AnimatedTextKit(
                    totalRepeatCount: 1,
                    animatedTexts: [
                      TypewriterAnimatedText(
                        text,
                        curve: Curves.linear,
                        speed: const Duration(
                          milliseconds: 15,
                        ),
                        textAlign: TextAlign.left,
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: Pallete.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: AnimatedList(
              key: _listKey,
              initialItemCount: _items.length,
              itemBuilder: (context, index, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: _items[index],
                );
              },
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: AnimatedOpacity(
            opacity: _items.length > 4 ? 1.0 : 0.0,
            duration: const Duration(seconds: 1),
            child: TextButton(
              onPressed: () {
                context.goNamed(
                  MeetingDateScreen.routeName,
                  pathParameters: {
                    'trainerId': widget.trainerId.toString(),
                  },
                );
              },
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
                      '일정 선택하기 🗓️',
                      style: h6Headline.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
