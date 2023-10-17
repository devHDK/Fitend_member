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
import 'package:fitend_member/thread/provider/thread_provider.dart';
import 'package:fitend_member/thread/view/media_page_screen.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:responsive_sizer/responsive_sizer.dart';

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
    required this.writerType,
    required this.threadType,
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
  final String writerType;
  final String threadType;

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

    final userModel = userState as UserModel;

    double emojiHeight = 31;

    List<Widget> emojiButtons = [];

    if (widget.emojis != null && widget.emojis!.isNotEmpty) {
      emojiButtons = _buildEmojiButtons();
    }

    emojiButtons.add(
      _defualtEmojiButton(context),
    );

    int horizonEmojiCounts = (100.w - 100) ~/ 49;
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

    double linkHeight = linkUrls.length == 1 &&
            (widget.gallery == null || widget.gallery!.isEmpty)
        ? 140.0 * linkUrls.length
        : 0;

    int mediaCount = widget.gallery!.length + linkUrls.length;

    final galleryHeight = mediaCount > 1
        ? 120
        : widget.gallery!.length == 1
            ? 220
            : 0;

    return Stack(
      children: [
        SizedBox(
          height: 16 +
              (widget.title != null ? 24 : 0) +
              _calculateLinesHeight(widget.content, s1SubTitle, 100.w - 120)
                      .toInt() *
                  24 +
              10 +
              20 + //padding
              24 +
              emojiHeight +
              galleryHeight.toDouble() +
              linkHeight,
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
                  if (mediaCount == 1 && linkUrls.length == 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: LinkPreview(
                        url: linkUrls.first,
                        width: 100.w - 110,
                        height: 120,
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
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            height: 200,
                            child: NetworkVideoPlayerMini(
                              video: widget.gallery!.first,
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
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: PreviewImageNetwork(
                          url: '$s3Url${widget.gallery!.first.url}',
                          width: (100.w - 140).toInt(),
                          height: 200,
                        ),
                      ),
                    ),
                  if (mediaCount > 1)
                    const SizedBox(
                      height: 10,
                    ),
                  if (mediaCount > 2)
                    SizedBox(
                      height: 100,
                      width: 100.w - 56 - 34 - 9,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          if (index >= widget.gallery!.length) {
                            return Row(
                              children: [
                                LinkPreview(
                                  url: linkUrls[index - widget.gallery!.length],
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
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: SizedBox(
                                              height: 150 * 0.8,
                                              width: 150,
                                              child: NetworkVideoPlayerMini(
                                                video: widget.gallery![index],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          )
                                        ],
                                      )
                                    : PreviewImageNetwork(
                                        url:
                                            '$s3Url${widget.gallery![index].url}',
                                        width: 150,
                                      ),
                              ),
                            ],
                          );
                        },
                        itemCount: mediaCount,
                      ),
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: emojiHeight,
                    width: 100.w - 99,
                    child: Wrap(
                      spacing: 2.0,
                      runSpacing: 5.0,
                      children: emojiButtons,
                    ),
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
                            ? ' 아직 댓글이 없어요 :)'
                            : ' ${widget.userCommentCount + widget.trainerCommentCount}개의 댓글이 있어요 :)',
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
        if (widget.writerType == 'user' &&
            widget.user.id == userModel.user.id &&
            widget.threadType == ThreadType.general.name)
          Positioned(
            top: -15,
            right: -10,
            child: InkWell(
              onTap: () => DialogWidgets.editBottomModal(
                context,
                delete: () async {
                  context.pop();

                  await ref
                      .read(threadDetailProvider(widget.id).notifier)
                      .deleteThread();
                },
                edit: () {},
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SvgPicture.asset('asset/img/icon_edit.svg'),
              ),
            ),
          )
      ],
    );
  }

  List<Widget> _buildEmojiButtons() {
    Map<String, int> emojiCounts = {};
    List<Widget> emojiButtons = [];

    for (var emoji in widget.emojis!) {
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
        isSelected: widget.emojis!.indexWhere((e) {
              return e.emoji == key && e.userId == widget.user.id;
            }) >
            -1,
        onTap: () async {
          final result = await ref
              .read(threadProvider.notifier)
              .updateEmoji(widget.id, widget.user.id, key);

          try {
            if (result['type'] == 'add') {
              final emojiId = result['emojiId'];

              ref
                  .read(threadDetailProvider(widget.id).notifier)
                  .addThreadEmoji(widget.user.id, key, emojiId);
            } else if (result['type'] == 'remove') {
              final emojiId = result['emojiId'];
              ref
                  .read(threadDetailProvider(widget.id).notifier)
                  .removeThreadEmoji(widget.user.id, key, emojiId);
            }
          } catch (e) {
            debugPrint('$e');
          }
        },
      ));
    });

    return emojiButtons;
  }

  EmojiButton _defualtEmojiButton(BuildContext context) {
    return EmojiButton(
      onTap: () {
        DialogWidgets.emojiPickerDialog(
          context: context,
          onEmojiSelect: (category, emoji) async {
            if (emoji != null) {
              final result = await ref
                  .read(threadProvider.notifier)
                  .updateEmoji(widget.id, widget.user.id, emoji.emoji);

              try {
                if (result['type'] == 'add') {
                  final emojiId = result['emojiId'];

                  ref
                      .read(threadDetailProvider(widget.id).notifier)
                      .addThreadEmoji(widget.user.id, emoji.emoji, emojiId);
                } else if (result['type'] == 'remove') {
                  final emojiId = result['emojiId'];
                  ref
                      .read(threadDetailProvider(widget.id).notifier)
                      .removeThreadEmoji(widget.user.id, emoji.emoji, emojiId);
                }
              } catch (e) {
                debugPrint('$e');
              }
            }

            context.pop();
          },
        );
      },
    );
  }

  int _calculateLinesHeight(String text, TextStyle style, double width) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: null,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: width);

    return textPainter.computeLineMetrics().length;
  }
}
