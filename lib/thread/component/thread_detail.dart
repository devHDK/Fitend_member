import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/thread/component/profile_image.dart';
import 'package:fitend_member/thread/model/threads/thread_model.dart';
import 'package:fitend_member/thread/provider/thread_detail_provider.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' as intl;
import 'package:responsive_sizer/responsive_sizer.dart';

class ThreadDetail extends ConsumerStatefulWidget {
  const ThreadDetail({
    super.key,
    required this.threadId,
    required this.profileImageUrl,
    this.title,
    required this.nickname,
    required this.dateTime,
    required this.content,
  });

  final int threadId;
  final String profileImageUrl;
  final String? title;
  final String nickname;
  final DateTime dateTime;
  final String content;

  @override
  ConsumerState<ThreadDetail> createState() => _ThreadDetailState();
}

class _ThreadDetailState extends ConsumerState<ThreadDetail> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(getMeProvider);
    final userModel = userState as UserModel;

    final state = ref.watch(threadDetailProvider(widget.threadId));
    final model = state as ThreadModel;

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
            if (model.writerType == 'user' &&
                model.user.id == userModel.user.id &&
                model.type == ThreadType.general.name)
              Positioned(
                top: -10,
                right: -10,
                child: InkWell(
                  onTap: () => DialogWidgets.editBottomModal(context),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SvgPicture.asset('asset/img/icon_edit.svg'),
                  ),
                ),
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
