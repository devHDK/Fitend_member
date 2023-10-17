import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/thread/component/profile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' as intl;
import 'package:responsive_sizer/responsive_sizer.dart';

class ThreadDetail extends StatefulWidget {
  const ThreadDetail({
    super.key,
    required this.profileImageUrl,
    this.title,
    required this.nickname,
    required this.dateTime,
    required this.content,
  });

  final String profileImageUrl;
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
    List<TextSpan> contentTextSpans = [];

    widget.content.splitMapJoin(
      urlRegExp,
      onMatch: (m) {
        contentTextSpans.add(TextSpan(
          text: '${m.group(0)} ',
          style: const TextStyle(color: Colors.blue),
          recognizer: TapAndPanGestureRecognizer()
            ..onTapDown = (detail) => DataUtils.launchURL('${m.group(0)}'),
        ));
        return m.group(0)!;
      },
      onNonMatch: (n) {
        var nonUrlParts = n.split(' ');
        for (var part in nonUrlParts) {
          if (nonUrlParts.last == part) {
            contentTextSpans.add(
              TextSpan(
                text: '$part ',
                style: s2SubTitle.copyWith(
                  color: Colors.white,
                ),
              ),
            );
          } else {
            contentTextSpans.add(
              TextSpan(
                text: '$part ',
                style: s2SubTitle.copyWith(
                  color: Colors.white,
                ),
              ),
            );
          }
        }
        return n;
      },
    );

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
                      image: CachedNetworkImage(
                        imageUrl: widget.profileImageUrl,
                        height: 34,
                        width: 34,
                      ),
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
          child: RichText(
            textScaleFactor: 1.0,
            text: TextSpan(
              children: contentTextSpans,
              style: s1SubTitle.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
