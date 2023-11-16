import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/schedule/view/schedule_result_screen.dart';
import 'package:fitend_member/thread/component/emoji_button.dart';
import 'package:fitend_member/thread/component/link_preview.dart';
import 'package:fitend_member/thread/component/network_video_player_mini.dart';
import 'package:fitend_member/thread/component/preview_image_network.dart';
import 'package:fitend_member/thread/component/profile_image.dart';
import 'package:fitend_member/thread/component/thread_cell.dart';
import 'package:fitend_member/thread/model/emojis/emoji_model.dart';
import 'package:fitend_member/thread/model/threads/thread_edit_model.dart';
import 'package:fitend_member/thread/model/threads/thread_list_model.dart';
import 'package:fitend_member/thread/model/threads/thread_model.dart';
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

class ThreadDetail extends ConsumerStatefulWidget {
  const ThreadDetail({
    super.key,
    required this.dateTime,
    required this.threadId,
  });

  final DateTime dateTime;
  final int threadId;

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
    final threadListState = ref.watch(threadProvider);
    final userModel = userState as UserModel;

    final state = ref.watch(threadDetailProvider(widget.threadId));
    final threadCreateState = ref.watch(threadCreateProvider);

    final model = state as ThreadModel;
    final threadListModel = threadListState as ThreadListModel;

    List<TextSpan> contentTextSpans = [];

    model.content.splitMapJoin(
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

    double emojiHeight = 31;

    List<Widget> emojiButtons = [];

    if (model.emojis != null && model.emojis!.isNotEmpty) {
      emojiButtons = _buildEmojiButtons(model, threadListModel);
    }

    emojiButtons.add(
      _defaultEmojiButton(context, model, threadListModel),
    );

    int horizonEmojiCounts = (100.w - 56) ~/ 49;
    int verticalEmojiCounts = (emojiButtons.length / horizonEmojiCounts).ceil();

    emojiHeight = verticalEmojiCounts * 31;

    List<String> linkUrls = [];

    String processedText = model.content.replaceAll('\n', ' ');
    processedText.split(' ').forEach(
      (word) {
        if (urlRegExp.hasMatch(word)) {
          linkUrls.add(word);
        }
      },
    );

    int mediaCount = model.gallery != null
        ? model.gallery!.length + linkUrls.length
        : 0 + linkUrls.length;

    return Padding(
      padding: const EdgeInsets.only(left: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleProfileImage(
                        borderRadius: 17,
                        image: CachedNetworkImage(
                          imageUrl: model.writerType == 'trainer'
                              ? '${URLConstants.s3Url}${model.trainer.profileImage}'
                              : model.user.gender == 'male'
                                  ? URLConstants.maleProfileUrl
                                  : URLConstants.femaleProfileUrl,
                          height: 34,
                          width: 34,
                        ),
                      ),
                      const SizedBox(
                        width: 9,
                      ),
                      Text(
                        model.writerType == 'trainer'
                            ? model.trainer.nickname
                            : model.user.nickname,
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
                        style:
                            s2SubTitle.copyWith(color: Pallete.gray, height: 1),
                      ),
                    ],
                  ),
                ],
              ),
              if (model.writerType == 'user' &&
                  model.user.id == userModel.user.id &&
                  model.type == ThreadType.general.name &&
                  !threadCreateState.isUploading)
                Positioned(
                  top: -10,
                  right: 18,
                  child: InkWell(
                    onTap: () => DialogWidgets.editBottomModal(
                      context,
                      delete: () async {
                        context.pop();

                        await ref
                            .read(threadDetailProvider(model.id).notifier)
                            .deleteThread()
                            .then((value) => context.pop());
                      },
                      edit: () {
                        context.pop();

                        Navigator.of(context)
                            .push(
                          CupertinoDialogRoute(
                            builder: (context) => ThreadCreateScreen(
                              trainer: model.trainer,
                              user: model.user,
                              threadEditModel: ThreadEditModel(
                                threadId: model.id,
                                content: model.content,
                                gallery: model.gallery,
                                title: model.title,
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
                      child: SvgPicture.asset(SVGConstants.edit),
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(
            height: 17,
          ),
          if (model.title != null)
            Column(
              children: [
                Text(
                  model.title!,
                  style: h5Headline.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
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
          if (model.type == ThreadType.record.name && model.workoutInfo != null)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => ScheduleResultScreen(
                      workoutScheduleId: model.workoutInfo!.workoutScheduleId,
                    ),
                    fullscreenDialog: true,
                  ),
                );
              },
              child: RecordTypeThread(
                height: 216,
                width: 100.w - 56,
                info: model.workoutInfo!,
                isbigSize: true,
              ),
            ),
          if (mediaCount == 1 && linkUrls.length == 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: LinkPreview(
                url: linkUrls.first,
                width: 100.w - 56,
                height: 300,
              ),
            )
          else if (mediaCount == 1 &&
              model.gallery != null &&
              model.gallery!.length == 1 &&
              model.gallery!.first.type == 'video')
            InkWell(
              onTap: () => Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => MediaPageScreen(
                    pageIndex: 0,
                    gallery: model.gallery!,
                  ),
                  fullscreenDialog: true,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  width: 100.w - 56,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 400,
                      child: NetworkVideoPlayerMini(
                        video: model.gallery!.first,
                        userOriginRatio: true,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else if (mediaCount == 1 &&
              model.gallery!.length == 1 &&
              model.gallery!.first.type == 'image')
            InkWell(
              onTap: () => Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => MediaPageScreen(
                    pageIndex: 0,
                    gallery: model.gallery!,
                  ),
                  fullscreenDialog: true,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: PreviewImageNetwork(
                  url: '${URLConstants.s3Url}${model.gallery!.first.url}',
                  width: (100.w - 56).toInt(),
                  height: 320,
                  boxFit: BoxFit.cover,
                ),
              ),
            ),
          if (mediaCount > 1)
            const SizedBox(
              height: 10,
            ),
          if (mediaCount > 1)
            _MediaListView(
              model: model,
              linkUrls: linkUrls,
              mediaCount: mediaCount,
            ),
          _emojiSection(emojiHeight, emojiButtons),
          _commentsDivider(model),
        ],
      ),
    );
  }

  Widget _emojiSection(double emojiHeight, List<Widget> emojiButtons) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: emojiHeight,
        width: 100.w - 56,
        child: Wrap(
          spacing: 2.0,
          runSpacing: 5.0,
          children: emojiButtons,
        ),
      ),
    );
  }

  Widget _commentsDivider(ThreadModel model) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              model.comments != null ? '${model.comments!.length}개의 댓글' : '',
              style: s2SubTitle.copyWith(
                color: Pallete.gray,
                height: 1,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const Expanded(
              child: Divider(
                thickness: 1,
                color: Pallete.gray,
              ),
            ),
            const SizedBox(
              width: 28,
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  List<Widget> _buildEmojiButtons(
      ThreadModel model, ThreadListModel threadListModel) {
    Map<String, int> emojiCounts = {};
    List<Widget> emojiButtons = [];

    List<EmojiModel> tempEmojis = model.emojis!;
    tempEmojis = tempEmojis.toSet().toList();

    for (var emoji in tempEmojis) {
      String emojiChar = emoji.emoji;

      if (!emojiCounts.containsKey(emojiChar)) {
        emojiCounts[emojiChar] = 1;
      } else {
        emojiCounts[emojiChar] = (emojiCounts[emojiChar] ?? 0) + 1;
      }
    }

    emojiCounts.forEach(
      (key, value) {
        emojiButtons.add(
          EmojiButton(
            emoji: key,
            count: value,
            isSelected: model.emojis!.indexWhere((e) {
                  return e.emoji == key && e.userId == model.user.id;
                }) >
                -1,
            onTap: () async {
              final result = await ref
                  .read(threadDetailProvider(widget.threadId).notifier)
                  .updateThreadEmoji(widget.threadId, model.user.id, key);

              int index = threadListModel.data.indexWhere(
                (thread) {
                  return thread.id == widget.threadId;
                },
              );

              try {
                if (result['type'] == 'add') {
                  final emojiId = result['emojiId'];

                  ref
                      .read(threadProvider.notifier)
                      .addEmoji(model.user.id, null, key, index, emojiId);
                } else if (result['type'] == 'remove') {
                  final emojiId = result['emojiId'];
                  ref
                      .read(threadProvider.notifier)
                      .removeEmoji(model.user.id, null, key, index, emojiId);
                }
              } catch (e) {
                debugPrint('$e');
              }
            },
          ),
        );
      },
    );

    return emojiButtons;
  }

  EmojiButton _defaultEmojiButton(BuildContext context, ThreadModel model,
      ThreadListModel threadListModel) {
    return EmojiButton(
      onTap: () {
        DialogWidgets.emojiPickerDialog(
          context: context,
          onEmojiSelect: (category, emoji) async {
            if (emoji != null) {
              final result = await ref
                  .read(threadDetailProvider(widget.threadId).notifier)
                  .updateThreadEmoji(
                      widget.threadId, model.user.id, emoji.emoji);

              int index = threadListModel.data.indexWhere(
                (thread) {
                  return thread.id == widget.threadId;
                },
              );

              try {
                if (result['type'] == 'add') {
                  final emojiId = result['emojiId'];

                  ref.read(threadProvider.notifier).addEmoji(
                      model.user.id, null, emoji.emoji, index, emojiId);
                } else if (result['type'] == 'remove') {
                  final emojiId = result['emojiId'];
                  ref.read(threadProvider.notifier).removeEmoji(
                      model.user.id, null, emoji.emoji, index, emojiId);
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
}

class _MediaListView extends StatelessWidget {
  const _MediaListView({
    required this.model,
    required this.linkUrls,
    required this.mediaCount,
  });

  final ThreadModel model;
  final List<String> linkUrls;
  final int mediaCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 250,
        child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            int galleryLenth = 0;

            if (model.gallery != null) {
              galleryLenth = model.gallery!.length;
            }

            if (index >= galleryLenth) {
              return LinkPreview(
                width: 100.w - 56,
                height: 250,
                url: linkUrls[index - galleryLenth],
              );
            }

            return Stack(
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => MediaPageScreen(
                        pageIndex: index,
                        gallery: model.gallery!,
                      ),
                      fullscreenDialog: true,
                    ),
                  ),
                  child: Hero(
                    tag: model.gallery![index].url,
                    child: model.gallery![index].type == 'video'
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              constraints: BoxConstraints(maxWidth: 100.w - 56),
                              child: IntrinsicWidth(
                                child: NetworkVideoPlayerMini(
                                  video: model.gallery![index],
                                  userOriginRatio: true,
                                ),
                              ),
                            ),
                          )
                        : PreviewImageNetwork(
                            url:
                                '${URLConstants.s3Url}${model.gallery![index].url}',
                            width: (100.w - 56).toInt(),
                            height: 250,
                          ),
                  ),
                ),
              ],
            );
          },
          itemCount: mediaCount,
        ),
      ),
    );
  }
}
