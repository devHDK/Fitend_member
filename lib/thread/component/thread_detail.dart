import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/thread/component/profile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' as intl;
import 'package:responsive_sizer/responsive_sizer.dart';

class ThreadDetail extends StatefulWidget {
  const ThreadDetail({
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
  State<ThreadDetail> createState() => _ThreadDetailState();
}

class _ThreadDetailState extends State<ThreadDetail> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    CircleProfileImage(
                      borderRadius: 17,
                      image: widget.profileImage,
                    ),
                    const SizedBox(
                      width: 9,
                    ),
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
                    ),
                    const SizedBox(),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 15,
              right: 0,
              child: SvgPicture.asset('asset/img/icon_edit.svg'),
            )
          ],
        ),
        const SizedBox(
          height: 17,
        ),
        if (widget.title != null)
          Column(
            children: [
              Text(
                widget.title!,
                style: h5Headline.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 8,
              )
            ],
          ),
        SizedBox(
          width: 100.w - 56,
          child: AutoSizeText(
            widget.content,
            maxLines: 50,
            style: s1SubTitle.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
