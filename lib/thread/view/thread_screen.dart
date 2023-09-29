import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:fitend_member/common/component/logo_appbar.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/notifications/view/notification_screen.dart';
import 'package:fitend_member/thread/component/emoji_button.dart';
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            EmojiButton(
              onTap: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) => SizedBox(
                    height: 250,
                    child: EmojiPicker(
                      onEmojiSelected: (category, emoji) {
                        // Do something when emoji is tapped (optional)
                      },
                      config: Config(
                        columns: 7,
                        emojiSizeMax: 32 *
                            (foundation.defaultTargetPlatform ==
                                    TargetPlatform.iOS
                                ? 1.30
                                : 1.0),
                        verticalSpacing: 0,
                        horizontalSpacing: 0,
                        gridPadding: EdgeInsets.zero,
                        initCategory: Category.RECENT,
                        bgColor: BACKGROUND_COLOR,
                        indicatorColor: Colors.blue,
                        iconColor: Colors.grey,
                        iconColorSelected: Colors.blue,
                        backspaceColor: Colors.blue,
                        skinToneDialogBgColor: Colors.white,
                        skinToneIndicatorColor: Colors.grey,
                        enableSkinTones: true,
                        recentTabBehavior: RecentTabBehavior.RECENT,
                        recentsLimit: 28,
                        noRecents: const Text(
                          'No Recents',
                          style: TextStyle(fontSize: 20, color: Colors.black26),
                          textAlign: TextAlign.center,
                        ), // Needs to be const Widget
                        loadingIndicator:
                            const SizedBox.shrink(), // Needs to be const Widget
                        tabIndicatorAnimDuration: kTabScrollDuration,
                        categoryIcons: const CategoryIcons(),
                        buttonMode: ButtonMode.MATERIAL,
                      ),
                    ),
                  ),
                );
              },
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
      ),
    );
  }
}
