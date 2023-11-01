import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/thread/component/emoji_button.dart';
import 'package:fitend_member/thread/component/link_preview.dart';
import 'package:fitend_member/thread/component/network_video_player_mini.dart';
import 'package:fitend_member/thread/component/preview_image_network.dart';
import 'package:fitend_member/thread/component/profile_image.dart';
import 'package:fitend_member/thread/model/common/gallery_model.dart';
import 'package:fitend_member/thread/model/common/thread_trainer_model.dart';
import 'package:fitend_member/thread/model/common/thread_user_model.dart';
import 'package:fitend_member/thread/model/emojis/emoji_model.dart';
import 'package:fitend_member/thread/provider/thread_detail_provider.dart';
import 'package:fitend_member/thread/view/media_page_screen.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CommentCell extends ConsumerStatefulWidget {
  const CommentCell({
    super.key,
    required this.threadId,
    required this.commentId,
    required this.content,
    required this.dateTime,
    this.trainer,
    this.user,
    this.gallery,
    required this.emojis,
    this.isEditting = false,
  });

  final int threadId;
  final int commentId;
  final String content;
  final DateTime dateTime;
  final ThreadTrainer? trainer;
  final ThreadUser? user;
  final List<GalleryModel>? gallery;
  final List<EmojiModel> emojis;
  final bool? isEditting;

  @override
  ConsumerState<CommentCell> createState() => _CommentCellState();
}

class _CommentCellState extends ConsumerState<CommentCell> {
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(getMeProvider);

    final userModel = userState as UserModel;

    double emojiHeight = 31;

    List<Widget> emojiButtons = [];

    if (widget.emojis.isNotEmpty) {
      emojiButtons = _buildEmojiButtons(userModel);
    }

    emojiButtons.add(
      _defaultEmojiButton(context, userModel),
    );

    int horizonEmojiCounts = (100.w - 135) ~/ 49;
    int verticalEmojiCounts = (emojiButtons.length / horizonEmojiCounts).ceil();

    emojiHeight = verticalEmojiCounts * 31;

    //url link 포함여부
    List<String> linkUrls = [];

    String processedText = widget.content.replaceAll('\n', ' ');
    processedText.split(' ').forEach(
      (word) {
        if (urlRegExp.hasMatch(word)) {
          linkUrls.add(word);
        }
      },
    );

    List<TextSpan> contentTextSpans = [];

    widget.content.splitMapJoin(
      urlRegExp,
      onMatch: (m) {
        contentTextSpans.add(TextSpan(
          text: '${m.group(0)} ',
          style: const TextStyle(color: Colors.blue),
          recognizer: TapAndPanGestureRecognizer()
            ..onTapDown = (detail) => DataUtils.launchURL(
                  m.group(0)!.contains('https://')
                      ? '${m.group(0)} '
                      : 'https://${m.group(0)}',
                ),
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

    int mediaCount = widget.gallery!.length + linkUrls.length;

    return Container(
      width: 100.w,
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.isEditting! ? POINT_COLOR : Colors.transparent,
        ),
        color: widget.isEditting! ? Colors.black54 : null,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 7, 0, 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleProfileImage(
                  image: CachedNetworkImage(
                    imageUrl: widget.trainer != null
                        ? '$s3Url${widget.trainer!.profileImage}'
                        : widget.user != null && widget.user!.gender == 'male'
                            ? maleProfileUrl
                            : femaleProfileUrl,
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
                          widget.trainer != null
                              ? widget.trainer!.nickname
                              : widget.user!.nickname,
                          style: s1SubTitle.copyWith(
                            color: LIGHT_GRAY_COLOR,
                            height: 1,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          DataUtils.getElapsedTimeStringFromNow(
                              widget.dateTime),
                          style:
                              s2SubTitle.copyWith(color: GRAY_COLOR, height: 1),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 100.w - 100,
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
                ),
              ],
            ),
            if (mediaCount == 1 && linkUrls.length == 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(39, 10, 28, 10),
                child: LinkPreview(
                  url: linkUrls.first,
                  width: 100.w - 110,
                  height: 150,
                ),
              )
            else if (mediaCount == 1 &&
                widget.gallery!.length == 1 &&
                widget.gallery!.first.type == 'video')
              InkWell(
                onTap: () => Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => MediaPageScreen(
                      pageIndex: 0,
                      gallery: widget.gallery!,
                    ),
                    fullscreenDialog: true,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(39, 10, 0, 10),
                  child: SizedBox(
                    width: (100.w - 110),
                    height: 220,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: NetworkVideoPlayerMini(
                          video: widget.gallery!.first,
                          userOriginRatio: true,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else if (mediaCount == 1 &&
                widget.gallery!.length == 1 &&
                widget.gallery!.first.type == 'image')
              InkWell(
                onTap: () => Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => MediaPageScreen(
                      pageIndex: 0,
                      gallery: widget.gallery!,
                    ),
                    fullscreenDialog: true,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(39, 10, 0, 10),
                  child: PreviewImageNetwork(
                    url: '$s3Url${widget.gallery!.first.url}',
                    width: (100.w - 110).toInt(),
                    height: 250,
                    boxFit: BoxFit.cover,
                  ),
                ),
              ),
            if (mediaCount > 1)
              const SizedBox(
                height: 10,
              ),
            if (mediaCount > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(39, 0, 0, 10),
                child: SizedBox(
                  height: 150,
                  width: 100.w,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      if (index >= widget.gallery!.length) {
                        return Row(
                          children: [
                            LinkPreview(
                              url: linkUrls[index - widget.gallery!.length],
                              height: 140,
                              width: 180,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        );
                      }

                      return Stack(
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => MediaPageScreen(
                                  pageIndex: index,
                                  gallery: widget.gallery!,
                                ),
                                fullscreenDialog: true,
                              ),
                            ),
                            child: widget.gallery![index].type == 'video'
                                ? Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: SizedBox(
                                          height: 150,
                                          child: NetworkVideoPlayerMini(
                                            video: widget.gallery![index],
                                            userOriginRatio: true,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      )
                                    ],
                                  )
                                : PreviewImageNetwork(
                                    url: '$s3Url${widget.gallery![index].url}',
                                    width: 140,
                                    height: 150,
                                  ),
                          ),
                        ],
                      );
                    },
                    itemCount: mediaCount,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(39, 5, 0, 0),
              child: SizedBox(
                height: emojiHeight,
                width: 100.w - 135,
                child: Wrap(
                  spacing: 2.0,
                  runSpacing: 5.0,
                  children: emojiButtons,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEmojiButtons(UserModel userModel) {
    Map<String, int> emojiCounts = {};

    List<Widget> emojiButtons = [];

    List<EmojiModel> tempEmojis = widget.emojis;

    print('_buildEmojiButtons comment');
    print(tempEmojis);
    tempEmojis = tempEmojis.toSet().toList();
    print(tempEmojis);

    for (var emoji in tempEmojis) {
      String emojiChar = emoji.emoji;

      if (!emojiCounts.containsKey(emojiChar)) {
        emojiCounts[emojiChar] = 1;
      } else {
        emojiCounts[emojiChar] = (emojiCounts[emojiChar] ?? 0) + 1;
      }
    }

    emojiCounts.forEach((key, value) {
      emojiButtons.add(EmojiButton(
        emoji: key,
        count: value,
        isSelected: widget.emojis.indexWhere((e) {
              return e.emoji == key && e.userId == userModel.user.id;
            }) >
            -1,
        onTap: () async {
          await ref
              .read(threadDetailProvider(widget.threadId).notifier)
              .updateCommentEmoji(widget.commentId, userModel.user.id, key);
        },
      ));
    });

    return emojiButtons;
  }

  EmojiButton _defaultEmojiButton(BuildContext context, UserModel userModel) {
    return EmojiButton(
      onTap: () {
        DialogWidgets.emojiPickerDialog(
          context: context,
          onEmojiSelect: (category, emoji) async {
            if (emoji != null) {
              await ref
                  .read(threadDetailProvider(widget.threadId).notifier)
                  .updateCommentEmoji(
                      widget.commentId, userModel.user.id, emoji.emoji);
            }

            context.pop();
          },
        );
      },
    );
  }
}
