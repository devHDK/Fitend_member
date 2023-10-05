import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:fitend_member/common/component/logo_appbar.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/notifications/view/notification_screen.dart';
import 'package:fitend_member/thread/component/comment_cell.dart';
import 'package:fitend_member/thread/component/emoji_button.dart';
import 'package:fitend_member/thread/component/profile_image.dart';
import 'package:fitend_member/thread/component/thread_cell.dart';
import 'package:fitend_member/thread/component/thread_detail.dart';
import 'package:fitend_member/thread/view/thread_create_screen.dart';
import 'package:fitend_member/user/view/mypage_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/foundation.dart' as foundation;

class ThreadScreen extends StatefulWidget {
  const ThreadScreen({super.key});

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  bool emojiShowing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: LogoAppbar(
        title: 'T H R E A D S',
        actions: [
          InkWell(
            hoverColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ));
            },
            child: SvgPicture.asset('asset/img/icon_alarm_off.svg'),
          ),
          const SizedBox(
            width: 12,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 28.0),
            child: InkWell(
              hoverColor: Colors.transparent,
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => const MyPageScreen(),
                  ),
                );
              },
              child: SvgPicture.asset(
                'asset/img/icon_my_page.svg',
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(
            builder: (context) => const ThreadCreateScreen(),
          ));
        },
        backgroundColor: Colors.transparent,
        child: SvgPicture.asset('asset/img/icon_thread_create_button.svg'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // EmojiButton(
              //   onTap: () {
              //     _showEmojiPicker(
              //       context: context,
              //       onEmojiSelect: (category, emoji) {
              //         context.pop();
              //       },
              //     );
              //   },
              // ),
              // EmojiButton(
              //   emoji: '🔥',
              //   count: 1,
              //   onTap: () {},
              // ),
              // EmojiButton(
              //   emoji: '🔥',
              //   count: 1,
              //   color: POINT_COLOR,
              //   onTap: () {},
              // ),
              ThreadCell(
                id: 1,
                profileImage: Image.asset(
                  'asset/img/couple-training-together-gym2.png',
                  fit: BoxFit.cover,
                  height: 34,
                  width: 34,
                ),
                nickname: '김시현',
                dateTime: DateTime.now(),
                title: '오늘 점심 식단인증 합니다!',
                content:
                    'fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 ',
              ),
              const SizedBox(
                height: 50,
              ),
              ThreadDetail(
                id: 1,
                profileImage: Image.asset(
                  'asset/img/couple-training-together-gym2.png',
                  fit: BoxFit.cover,
                  height: 34,
                  width: 34,
                ),
                nickname: '김시현',
                dateTime: DateTime.now(),
                title: '오늘 점심 식단인증 합니다!',
                content:
                    'fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 fitend최고 ',
              ),
              const SizedBox(
                height: 50,
              ),
              CommentCell(
                profileImage: Image.asset(
                  'asset/img/couple-training-together-gym2.png',
                  fit: BoxFit.cover,
                  height: 34,
                  width: 34,
                ),
                content:
                    '오늘 운동도 고생많으셨어요!데드리프트는 자세가 많이 좋아지셨는데, 힙힌지를 조금만 더 신경써주시면 좋을것 같아요 👍',
                nickname: 'Kelly',
                dateTime: DateTime.now(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
