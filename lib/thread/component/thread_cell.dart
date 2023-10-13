import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/thread/component/emoji_button.dart';
import 'package:fitend_member/thread/component/preview_image_network.dart';
import 'package:fitend_member/thread/component/profile_image.dart';
import 'package:fitend_member/thread/model/common/gallery_model.dart';
import 'package:fitend_member/thread/model/common/thread_trainer_model.dart';
import 'package:fitend_member/thread/model/common/thread_user_model.dart';
import 'package:fitend_member/thread/model/emojis/emoji_model.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter/foundation.dart' as foundation;

class ThreadCell extends ConsumerStatefulWidget {
  const ThreadCell({
    super.key,
    required this.id,
    required this.profileImageUrl,
    this.title,
    required this.nickname,
    required this.dateTime,
    required this.content,
    this.gallery,
    this.emojis,
    required this.userCommentCount,
    required this.trainerCommentCount,
    required this.user,
    required this.trainer,
  });

  final int id;
  final String profileImageUrl;
  final String? title;
  final String nickname;
  final DateTime dateTime;
  final String content;
  final List<GalleryModel>? gallery;
  final List<EmojiModel>? emojis;
  final int userCommentCount;
  final int trainerCommentCount;
  final ThreadUser user;
  final ThreadTrainer trainer;

  @override
  ConsumerState<ThreadCell> createState() => _ThreadCellState();
}

class _ThreadCellState extends ConsumerState<ThreadCell> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(getMeProvider);

    final user = userState as UserModel;

    final galleryHeight =
        widget.gallery != null && widget.gallery!.isNotEmpty ? 100 : 0;

    return Stack(
      children: [
        SizedBox(
          //TODO: gallery, url, 댓글, emoji 추가시 높이 조정 필요
          height: 16 +
              (widget.title != null ? 24 : 0) +
              _calculateLines(widget.content, s1SubTitle, 74.w).toInt() * 24 +
              10 +
              28 +
              10 +
              10 +
              20 +
              10 +
              galleryHeight.toDouble(),

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
                      image: CachedNetworkImage(
                        imageUrl: widget.profileImageUrl,
                        width: 34,
                        height: 34,
                      ),
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
                    children: [
                      Row(
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
                            style: s2SubTitle.copyWith(
                                color: GRAY_COLOR, height: 1),
                          ),
                        ],
                      ),
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
                  if (widget.gallery != null)
                    const SizedBox(
                      height: 10,
                    ),
                  if (widget.gallery != null)
                    SizedBox(
                      height: 100,
                      width: 100.w - 56 - 34 - 9,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              PreviewImageNetwork(
                                url: widget.gallery![index].type == 'video'
                                    ? '$s3Url${widget.gallery![index].thumbnail!}'
                                    : '$s3Url${widget.gallery![index].url}',
                                width: 120,
                              ),
                            ],
                          );
                        },
                        itemCount: widget.gallery!.length,
                      ),
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
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
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      if (widget.userCommentCount > 0)
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircleProfileImage(
                                image: CachedNetworkImage(
                                  imageUrl: widget.user.gender == 'male'
                                      ? maleProfileUrl
                                      : femaleProfileUrl,
                                ),
                                borderRadius: 12,
                              ),
                            ),
                            const SizedBox(
                              width: 3,
                            )
                          ],
                        ),
                      if (widget.trainerCommentCount > 0)
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircleProfileImage(
                                image: CachedNetworkImage(
                                  imageUrl:
                                      '$s3Url${widget.trainer.profileImage}',
                                ),
                                borderRadius: 12,
                              ),
                            ),
                            const SizedBox(
                              width: 3,
                            )
                          ],
                        ),
                      Text(
                        widget.userCommentCount == 0 &&
                                widget.trainerCommentCount == 0
                            ? '아직 댓글이 없어요 :)'
                            : '${widget.userCommentCount + widget.trainerCommentCount} 개의 댓글이 있어요 :)',
                        style: s2SubTitle.copyWith(
                          color: GRAY_COLOR,
                          height: 1,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              )
            ],
          ),
        ),
        Positioned(
          top: 5,
          right: 0,
          child: SvgPicture.asset('asset/img/icon_edit.svg'),
        )
      ],
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
