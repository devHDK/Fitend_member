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

    int mediaCount = model.gallery!.length + linkUrls.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
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
                              ? '$s3Url${model.trainer.profileImage}'
                              : model.user.gender == 'male'
                                  ? maleProfileUrl
                                  : femaleProfileUrl,
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
                        style:
                            s2SubTitle.copyWith(color: GRAY_COLOR, height: 1),
                      ),
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
                      child: SvgPicture.asset('asset/img/icon_edit.svg'),
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
              child: SizedBox(
                height: 400,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: NetworkVideoPlayerMini(
                      video: model.gallery!.first,
                      userOriginRatio: true,
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
                  url: '$s3Url${model.gallery!.first.url}',
                  width: (100.w - 70.0).toInt(),
                  height: 300,
                  boxFit: BoxFit.contain,
                ),
              ),
            ),
          if (mediaCount > 1)
            const SizedBox(
              height: 10,
            ),
          if (mediaCount > 2)
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
                color: GRAY_COLOR,
                height: 1,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const Expanded(
              child: Divider(
                thickness: 1,
                color: GRAY_COLOR,
              ),
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

    for (var emoji in model.emojis!) {
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
                      .addEmoji(model.user.id, key, index, emojiId);
                } else if (result['type'] == 'remove') {
                  final emojiId = result['emojiId'];
                  ref
                      .read(threadProvider.notifier)
                      .removeEmoji(model.user.id, key, index, emojiId);
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

                  ref
                      .read(threadProvider.notifier)
                      .addEmoji(model.user.id, emoji.emoji, index, emojiId);
                } else if (result['type'] == 'remove') {
                  final emojiId = result['emojiId'];
                  ref
                      .read(threadProvider.notifier)
                      .removeEmoji(model.user.id, emoji.emoji, index, emojiId);
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
        height: (80.w.toInt() - 56) * 0.8,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            if (index >= model.gallery!.length) {
              return Row(
                children: [
                  LinkPreview(
                    width: (80.w.toInt() - 56),
                    height: (80.w.toInt() - 56) * 0.8,
                    url: linkUrls[index - model.gallery!.length],
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
                        gallery: model.gallery!,
                      ),
                      fullscreenDialog: true,
                    ),
                  ),
                  child: Hero(
                    tag: model.gallery![index].url,
                    child: model.gallery![index].type == 'video'
                        ? Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: SizedBox(
                                  height: (80.w - 56) * 0.8,
                                  child: NetworkVideoPlayerMini(
                                    video: model.gallery![index],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              )
                            ],
                          )
                        : PreviewImageNetwork(
                            url: '$s3Url${model.gallery![index].url}',
                            width: 80.w.toInt() - 56,
                            height: ((80.w - 56) * 0.8).toInt(),
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
