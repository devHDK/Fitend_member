import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/thread/component/emoji_button.dart';
import 'package:fitend_member/thread/component/profile_image.dart';
import 'package:fitend_member/thread/model/common/gallery_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CommentCell extends StatelessWidget {
  const CommentCell({
    super.key,
    required this.profileImageUrl,
    required this.content,
    required this.dateTime,
    required this.nickname,
    this.gallery,
  });

  final String profileImageUrl;
  final String content;
  final DateTime dateTime;
  final String nickname;
  final List<GalleryModel>? gallery;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleProfileImage(
                  image: CachedNetworkImage(
                    imageUrl: profileImageUrl,
                    width: 34,
                    height: 34,
                  ),
                  borderRadius: 17,
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          nickname,
                          style: s1SubTitle.copyWith(
                            color: LIGHT_GRAY_COLOR,
                            height: 1,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          DateFormat('h:mm a').format(dateTime).toString(),
                          style:
                              s2SubTitle.copyWith(color: GRAY_COLOR, height: 1),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 100.w - 56 - 44,
                      child: AutoSizeText(
                        content,
                        maxLines: 50,
                        style: s1SubTitle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 39,
                ),
                EmojiButton(
                  onTap: () {
                    DialogWidgets.emojiPickerDialog(
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
        ),
        Positioned(
          top: 5,
          right: 0,
          child: SvgPicture.asset('asset/img/icon_edit.svg'),
        )
      ],
    );
  }
}
