import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/pallete.dart';
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
import 'package:fitend_member/thread/model/common/thread_workout_info_model.dart';
import 'package:fitend_member/thread/model/emojis/emoji_model.dart';
import 'package:fitend_member/thread/model/threads/thread_edit_model.dart';
import 'package:fitend_member/thread/provider/thread_create_provider.dart';
import 'package:fitend_member/thread/provider/thread_detail_provider.dart';
import 'package:fitend_member/thread/provider/thread_provider.dart';
import 'package:fitend_member/thread/view/media_page_screen.dart';
import 'package:fitend_member/thread/view/thread_create_screen.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:collection/collection.dart';

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
    required this.workoutInfo,
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
  final ThreadWorkoutInfo? workoutInfo;

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
    final threadCreateState = ref.watch(threadCreateProvider);

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
          style: s1SubTitle.copyWith(color: Colors.blue),
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
                style: s1SubTitle.copyWith(
                  color: Colors.white,
                ),
              ),
            );
          } else {
            contentTextSpans.add(
              TextSpan(
                text: '$part ',
                style: s1SubTitle.copyWith(
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
        ? 250.0
        : 0;

    int mediaCount = widget.gallery != null
        ? widget.gallery!.length + linkUrls.length
        : 0 + linkUrls.length;

    final galleryHeight = mediaCount > 1
        ? 250
        : widget.gallery != null && widget.gallery!.length == 1
            ? 300
            : 0;

    double recordHeight = widget.workoutInfo != null ? 195 : 0;

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 28),
          height: 26 +
              (widget.title != null ? 25 : 0) +
              _calculateLinesHeight(widget.content, s1SubTitle, 100.w - 130)
                      .toInt() *
                  22 +
              10 +
              20 + //padding
              28 + //댓글 높이
              emojiHeight +
              galleryHeight.toDouble() +
              linkHeight +
              recordHeight,
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
                          color: Pallete.gray,
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
                              color: Pallete.lightGray,
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
                                color: Pallete.gray, height: 1),
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
                    width: 100.w - 110,
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
                  if (widget.threadType == ThreadType.record.name &&
                      widget.workoutInfo != null)
                    RecordTypeThread(
                      height: recordHeight - 5,
                      width: 100.w - 110,
                      info: widget.workoutInfo!,
                    ),
                  if (mediaCount == 1 && linkUrls.length == 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: LinkPreview(
                        url: linkUrls.first,
                        width: 100.w - 110,
                        height: linkHeight - 20,
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
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: galleryHeight.toDouble() - 20,
                            width: 100.w - 110,
                            child: NetworkVideoPlayerMini(
                              video: widget.gallery!.first,
                              userOriginRatio: true,
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
                          width: (100.w - 110).toInt(),
                          height: galleryHeight - 20,
                        ),
                      ),
                    ),
                  if (mediaCount > 1)
                    const SizedBox(
                      height: 10,
                    ),
                  if (mediaCount > 1)
                    SizedBox(
                      height: galleryHeight.toDouble() - 20,
                      width: 100.w - 71,
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
                          color: Pallete.gray,
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
            widget.threadType == ThreadType.general.name &&
            !threadCreateState.isUploading)
          Positioned(
            top: -15,
            right: 18,
            child: InkWell(
              onTap: () => DialogWidgets.editBottomModal(
                context,
                delete: () async {
                  context.pop();

                  await ref
                      .read(threadDetailProvider(widget.id).notifier)
                      .deleteThread();
                },
                edit: () {
                  context.pop();

                  Navigator.of(context)
                      .push(
                    CupertinoDialogRoute(
                      builder: (context) => ThreadCreateScreen(
                        trainer: widget.trainer,
                        user: widget.user,
                        threadEditModel: ThreadEditModel(
                          threadId: widget.id,
                          content: widget.content,
                          gallery: widget.gallery,
                          title: widget.title,
                        ),
                      ),
                      context: context,
                    ),
                  )
                      .then((value) {
                    if (value is bool && value) {
                      ref.read(threadCreateProvider.notifier).init();
                    }
                  });
                },
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SvgPicture.asset('asset/img/icon_edit.svg'),
              ),
            ),
          ),
        if (mediaCount > 1)
          Positioned(
            top: 24 +
                (widget.title != null ? 25 : 0) +
                ((_calculateLinesHeight(
                                widget.content, s1SubTitle, 100.w - 130) -
                            1)
                        .toInt() *
                    23),
            child: SizedBox(
              height: galleryHeight.toDouble() - 20,
              width: 100.w,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => const SizedBox(
                  width: 10,
                ),
                itemBuilder: (context, index) {
                  int galleryLenth = 0;

                  if (widget.gallery != null) {
                    galleryLenth = widget.gallery!.length;
                  }

                  if (index == 0) {
                    return const SizedBox(
                      width: 60,
                    );
                  }

                  if (index >= galleryLenth + 1) {
                    return LinkPreview(
                      url: linkUrls[index - (galleryLenth + 1)],
                      height: galleryHeight - 20,
                      width: 100.w - 110,
                    );
                  }

                  return Stack(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => MediaPageScreen(
                              pageIndex: index - 1,
                              gallery: widget.gallery!,
                            ),
                            fullscreenDialog: true,
                          ),
                        ),
                        child: widget.gallery![index - 1].type == 'video'
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  height: galleryHeight.toDouble() - 20,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: 95.w,
                                    ),
                                    child: IntrinsicWidth(
                                      child: NetworkVideoPlayerMini(
                                        video: widget.gallery![index - 1],
                                        userOriginRatio: true,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : PreviewImageNetwork(
                                url: '$s3Url${widget.gallery![index - 1].url}',
                                width: (100.w - 110).toInt(),
                                // ((galleryHeight - 20) * 1.25)
                                //     .toInt(),
                                height: (galleryHeight - 20),
                              ),
                      ),
                    ],
                  );
                },
                itemCount: mediaCount + 1,
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildEmojiButtons() {
    Map<String, int> emojiCounts = {};
    List<Widget> emojiButtons = [];

    List<EmojiModel> tempEmojis = widget.emojis!;

    tempEmojis = tempEmojis.toSet().toList();

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
                  .addThreadEmoji(widget.user.id, null, key, emojiId);
            } else if (result['type'] == 'remove') {
              final emojiId = result['emojiId'];
              ref
                  .read(threadDetailProvider(widget.id).notifier)
                  .removeThreadEmoji(widget.user.id, null, key, emojiId);
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
                      .addThreadEmoji(
                          widget.user.id, null, emoji.emoji, emojiId);
                } else if (result['type'] == 'remove') {
                  final emojiId = result['emojiId'];
                  ref
                      .read(threadDetailProvider(widget.id).notifier)
                      .removeThreadEmoji(
                          widget.user.id, null, emoji.emoji, emojiId);
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

    return textPainter.computeLineMetrics().length + 1;
  }
}

class RecordTypeThread extends StatelessWidget {
  const RecordTypeThread({
    super.key,
    required this.height,
    required this.width,
    required this.info,
    this.isbigSize = false,
  });

  final double height;
  final double width;
  final ThreadWorkoutInfo info;
  final bool? isbigSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Container(
        width: width,
        height: height.toDouble(),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Pallete.gray,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(
                      info.targetMuscleIds.length >= 4
                          ? 4
                          : info.targetMuscleIds.length,
                      (index) => 0).mapIndexed((index, element) {
                    return Row(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CustomNetworkImage(
                                imageUrl:
                                    '$s3Url$muscleImageUrl${info.targetMuscleIds[index]}.png',
                                width: isbigSize! ? 52 : 40,
                                height: isbigSize! ? 52 : 40,
                                boxFit: BoxFit.cover,
                              ),
                            ),
                            if (index == 3 && info.targetMuscleIds.length > 4)
                              Positioned(
                                child: Container(
                                  width: isbigSize! ? 52 : 40,
                                  height: isbigSize! ? 52 : 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.black54,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '+${info.targetMuscleIds.length - 4}',
                                      style: h6Headline.copyWith(
                                        color: Colors.white,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                      ],
                    );
                  })
                ],
              ),
              const SizedBox(
                height: 18,
              ),
              Text(
                info.title,
                style: h6Headline.copyWith(
                  fontSize: isbigSize! ? 18 : 14,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(
                height: 9,
              ),
              Text(
                info.subTitle,
                style: s3SubTitle.copyWith(
                  color: Colors.white,
                  fontSize: isbigSize! ? 16 : 12,
                  height: 1,
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'asset/img/icon_timer.svg',
                    width: isbigSize! ? 18.5 : 16,
                    color: Pallete.gray,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    DataUtils.getTimeStringMinutes(info.workoutDuration!),
                    style: c1Caption.copyWith(
                      fontSize: isbigSize! ? 14 : 12,
                      color: Pallete.lightGray,
                      height: 1,
                    ),
                  ),
                  const SizedBox(
                    width: 11,
                  ),
                  SvgPicture.asset(
                    'asset/img/icon_barbell.svg',
                    width: isbigSize! ? 18.5 : 16,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    '${info.totalSet} set',
                    style: c1Caption.copyWith(
                      fontSize: isbigSize! ? 14 : 12,
                      color: Pallete.lightGray,
                      height: 1,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
