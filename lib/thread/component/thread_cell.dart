import 'package:auto_size_text/auto_size_text.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/thread/component/emoji_button.dart';
import 'package:fitend_member/thread/component/profile_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter/foundation.dart' as foundation;

class ThreadCell extends StatefulWidget {
  const ThreadCell({
    super.key,
    required this.id,
    required this.profileImage,
    this.title,
    required this.nickname,
    required this.dateTime,
    required this.content,
  });

  final int id;
  final Image profileImage;
  final String? title;
  final String nickname;
  final DateTime dateTime;
  final String content;

  @override
  State<ThreadCell> createState() => _ThreadCellState();
}

class _ThreadCellState extends State<ThreadCell> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //TODO: gallery, url, 댓글, emoji 추가시 높이 조정 필요
      height: 16 +
          (widget.title != null ? 24 : 0) +
          _calculateLines(widget.content, s1SubTitle, 74.w).toInt() * 24 +
          10 +
          28,

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            child: Stack(
              children: [
                SizedBox(
                  width: 34,
                  child: Center(
                    child: Container(
                      width: 0.5,
                      color: GRAY_COLOR,
                    ),
                  ),
                ),
                CircleProfileImage(
                  borderRadius: 17,
                  image: widget.profileImage,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 9,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: 70.w,
                    child: Row(
                      children: [
                        Text(
                          widget.nickname,
                          style: s1SubTitle.copyWith(
                            color: LIGHT_GRAY_COLOR,
                            height: 1,
                          ),
                        ),
                        const SizedBox(
                          width: 9,
                        ),
                        Text(
                          intl.DateFormat('h:mm a')
                              .format(widget.dateTime)
                              .toString(),
                          style:
                              s2SubTitle.copyWith(color: GRAY_COLOR, height: 1),
                        ),
                      ],
                    ),
                  ),
                  SvgPicture.asset('asset/img/icon_edit.svg')
                ],
              ),
              if (widget.title != null)
                Text(
                  widget.title!,
                  style: h5Headline.copyWith(
                    color: Colors.white,
                  ),
                ),
              SizedBox(
                width: 100.w - 56 - 34 - 9,
                child: AutoSizeText(
                  widget.content,
                  maxLines: 50,
                  style: s1SubTitle.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  EmojiButton(
                    emoji: '😂',
                    count: 1,
                    onTap: () {},
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  EmojiButton(
                    emoji: '🔥',
                    count: 1,
                    color: POINT_COLOR,
                    onTap: () {},
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  EmojiButton(
                    onTap: () {
                      _showEmojiPicker(
                        context: context,
                        onEmojiSelect: (category, emoji) {
                          context.pop();
                        },
                      );
                    },
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  int _calculateLines(String text, TextStyle style, double width) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: null,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: width);

    return textPainter.computeLineMetrics().length;
  }

  Future<dynamic> _showEmojiPicker({
    required BuildContext context,
    required Function(Category? category, Emoji? emoji) onEmojiSelect,
  }) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) => SizedBox(
        height: 250,
        child: EmojiPicker(
          onEmojiSelected: onEmojiSelect,
          config: Config(
            columns: 7,
            emojiSizeMax: 32 *
                (foundation.defaultTargetPlatform == TargetPlatform.iOS
                    ? 1.30
                    : 1.0),
            verticalSpacing: 0,
            horizontalSpacing: 0,
            gridPadding: EdgeInsets.zero,
            initCategory: Category.RECENT,
            bgColor: BACKGROUND_COLOR,
            indicatorColor: POINT_COLOR,
            iconColor: Colors.grey,
            iconColorSelected: POINT_COLOR,
            backspaceColor: POINT_COLOR,
            skinToneDialogBgColor: Colors.white,
            skinToneIndicatorColor: Colors.grey,
            enableSkinTones: true,
            recentTabBehavior: RecentTabBehavior.RECENT,
            recentsLimit: 28,
            noRecents: const Text(
              'No Recents',
              style: TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            loadingIndicator:
                const SizedBox.shrink(), // Needs to be const Widget
            tabIndicatorAnimDuration: kTabScrollDuration,
            categoryIcons: const CategoryIcons(),
            buttonMode: ButtonMode.MATERIAL,
          ),
        ),
      ),
    );
  }
}
