import 'dart:ffi';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/thread/component/profile_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:responsive_sizer/responsive_sizer.dart';

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
          _calculateLines(widget.content, s1SubTitle, 74.w).toInt() * 24,
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
                mainAxisAlignment: MainAxisAlignment.start,
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
                    style: s2SubTitle.copyWith(color: GRAY_COLOR, height: 1),
                  )
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
                width: 74.w,
                child: AutoSizeText(
                  widget.content,
                  maxLines: 50,
                  style: s1SubTitle.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
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
}
