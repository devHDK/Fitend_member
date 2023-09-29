import 'package:fitend_member/common/component/logo_appbar.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/notifications/view/notification_screen.dart';
import 'package:fitend_member/thread/component/emoji_button.dart';
import 'package:fitend_member/user/view/mypage_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ThreadScreen extends StatefulWidget {
  const ThreadScreen({super.key});

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
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
      body: Column(
        children: [
          EmojiButton(
            onTap: () {},
          ),
          EmojiButton(
            emoji: '🔥',
            count: 1,
            onTap: () {},
          ),
          EmojiButton(
            emoji: '🔥',
            count: 1,
            color: POINT_COLOR,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
