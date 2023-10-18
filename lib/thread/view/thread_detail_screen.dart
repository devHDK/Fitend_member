import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/thread/component/comment_cell.dart';
import 'package:fitend_member/thread/component/emoji_button.dart';
import 'package:fitend_member/thread/component/link_preview.dart';
import 'package:fitend_member/thread/component/network_video_player_mini.dart';
import 'package:fitend_member/thread/component/preview_image.dart';
import 'package:fitend_member/thread/component/preview_image_network.dart';
import 'package:fitend_member/thread/component/preview_video_thumbnail.dart';
import 'package:fitend_member/thread/component/profile_image.dart';
import 'package:fitend_member/thread/component/thread_detail.dart';
import 'package:fitend_member/thread/model/comments/thread_comment_create_model.dart';
import 'package:fitend_member/thread/model/threads/thread_list_model.dart';
import 'package:fitend_member/thread/model/threads/thread_model.dart';
import 'package:fitend_member/thread/provider/comment_create_provider.dart';
import 'package:fitend_member/thread/provider/thread_detail_provider.dart';
import 'package:fitend_member/thread/provider/thread_provider.dart';
import 'package:fitend_member/thread/utils/media_utils.dart';
import 'package:fitend_member/thread/view/comment_asset_edit_screen.dart';
import 'package:fitend_member/thread/view/media_page_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ThreadDetailScreen extends ConsumerStatefulWidget {
  const ThreadDetailScreen({
    super.key,
    required this.threadId,
  });

  final int threadId;

  @override
  ConsumerState<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends ConsumerState<ThreadDetailScreen> {
  FocusNode commentFocusNode = FocusNode();
  final commentController = TextEditingController();
  int maxLine = 1;

  @override
  void initState() {
    super.initState();

    commentFocusNode.addListener(_commentFocusnodeListner);
  }

  @override
  void dispose() {
    commentFocusNode.removeListener(_commentFocusnodeListner);
    commentFocusNode.dispose();
    commentController.dispose();
    super.dispose();
  }

  void _commentFocusnodeListner() {
    if (commentFocusNode.hasFocus) {
      setState(() {
        commentFocusNode.requestFocus();
      });
    } else {
      setState(() {
        commentFocusNode.unfocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(threadDetailProvider(widget.threadId));
    final commentState = ref.watch(commentCreateProvider(widget.threadId));
    final threadListState = ref.watch(threadProvider);

    if (state is ThreadModelLoading) {
      return const Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        body: Center(
          child: CircularProgressIndicator(
            color: POINT_COLOR,
          ),
        ),
      );
    }

    if (state is ThreadModelError) {
      showDialog(
        context: context,
        builder: (context) => DialogWidgets.errorDialog(
          message: state.message,
          confirmText: '확인',
          confirmOnTap: () => context.pop(),
        ),
      );
    }

    final model = state as ThreadModel;
    final threadListModel = threadListState as ThreadListModel;

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

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 18),
          child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back)),
        ),
        centerTitle: true,
        title: Text(
          '${DateFormat('M월 d일').format(DateTime.parse(model.createdAt))} ${weekday[DateTime.parse(model.createdAt).weekday - 1]}요일',
          style: h4Headline,
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: RefreshIndicator(
              backgroundColor: BACKGROUND_COLOR,
              color: POINT_COLOR,
              onRefresh: () async {
                await ref
                    .read(threadDetailProvider(widget.threadId).notifier)
                    .getThreadDetail(
                      threadId: widget.threadId,
                    );
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: ThreadDetail(
                      threadId: model.id,
                      writerType: model.writerType,
                      user: model.user,
                      trainer: model.trainer,
                      title: model.title,
                      dateTime:
                          DateTime.parse(model.createdAt).toUtc().toLocal(),
                      content: model.content,
                      gallery: model.gallery,
                    ),
                  ),
                  if (mediaCount == 1 && linkUrls.length == 1)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: LinkPreview(
                          url: linkUrls.first,
                          width: 100.w - 110,
                          height: 120,
                        ),
                      ),
                    )
                  else if (mediaCount == 1 &&
                      model.gallery!.length == 1 &&
                      model.gallery!.first.type == 'video')
                    SliverToBoxAdapter(
                      child: InkWell(
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
                      ),
                    )
                  else if (mediaCount == 1 &&
                      model.gallery!.length == 1 &&
                      model.gallery!.first.type == 'image')
                    SliverToBoxAdapter(
                      child: InkWell(
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
                    ),
                  if (mediaCount > 1)
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 10,
                      ),
                    ),
                  if (mediaCount > 2)
                    _MediaListView(
                      model: model,
                      linkUrls: linkUrls,
                      mediaCount: mediaCount,
                    ),
                  _emojiSection(emojiHeight, emojiButtons),
                  _commentsDivider(model),
                  if (model.comments != null && model.comments!.isNotEmpty)
                    SliverList.separated(
                      itemBuilder: (context, index) {
                        if (index != 0 && index == model.comments!.length) {
                          return const SizedBox(
                            height: 150,
                          );
                        }

                        final commentModel = model.comments![index];

                        return Column(
                          children: [
                            CommentCell(
                              threadId: widget.threadId,
                              commentId: commentModel.id,
                              content: commentModel.content,
                              dateTime: DateTime.parse(commentModel.createdAt)
                                  .toUtc()
                                  .toLocal(),
                              user: commentModel.user,
                              trainer: commentModel.trainer,
                              emojis: commentModel.emojis!,
                              gallery: commentModel.gallery,
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 10,
                      ),
                      itemCount: model.comments!.length + 1,
                    )
                  else
                    SliverToBoxAdapter(
                      child: Text(
                        '아직 댓글이 없어요 :)',
                        style: s1SubTitle.copyWith(
                          color: GRAY_COLOR,
                          height: 1,
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
          _bottomInputBox(commentState, model, context),
        ],
      ),
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

  Positioned _bottomInputBox(ThreadCommentCreateTempModel commentState,
      ThreadModel model, BuildContext context) {
    List<String> commentCreateLinkUrl = [];
    String commentProcessedText = commentController.text.replaceAll('\n', ' ');

    commentProcessedText.split(' ').forEach(
      (word) {
        if (urlRegExp.hasMatch(word)) {
          commentCreateLinkUrl.add(word);
        }
      },
    );

    final tempList = [
      ...commentState.assetsPaths,
      ...commentCreateLinkUrl,
    ];

    return Positioned(
      child: SlidingUpPanel(
        minHeight:
            tempList.isNotEmpty ? 220 + maxLine * 10 : 120 + maxLine * 10,
        maxHeight:
            tempList.isNotEmpty ? 220 + maxLine * 10 : 120 + maxLine * 10,
        color: DARK_GRAY_COLOR,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        // onPanelClosed: () => setState(() {
        //   isSwipeUp = false;
        // }),
        // onPanelOpened: () => setState(() {
        //   isSwipeUp = true;
        // }),
        panel: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 34,
                    height: 34,
                    child: CircleProfileImage(
                      image: CachedNetworkImage(
                        imageUrl: model.user.gender == 'male'
                            ? maleProfileUrl
                            : femaleProfileUrl,
                      ),
                      borderRadius: 17,
                    ),
                  ),
                  SizedBox(
                    width: 100.w - 56 - 34,
                    child: _commentTextFormField(),
                  ),
                ],
              ),
              if (tempList.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: commentState.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: POINT_COLOR,
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            if (index >= commentState.assetsPaths.length) {
                              return Row(
                                children: [
                                  LinkPreview(
                                    url: tempList[index],
                                    width: 100,
                                    height: 80,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              );
                            }

                            final intPath =
                                utf8.encode(commentState.assetsPaths[index]);
                            final path = Uint8List.fromList(intPath);
                            final file = File.fromRawPath(path);
                            final type = MediaUtils.getMediaType(file.path);
                            return Stack(
                              children: [
                                SizedBox(
                                  child: Center(
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () => Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (context) {
                                            return CommentAssetEditScreen(
                                              pageIndex: index,
                                              threadId: widget.threadId,
                                            );
                                          },
                                        ),
                                      ),
                                      child: type == MediaType.image
                                          ? Hero(
                                              tag: file.path,
                                              child: PreviewImage(
                                                file: file,
                                                width: 100,
                                              ),
                                            )
                                          : Hero(
                                              tag: commentState
                                                  .assetsPaths[index],
                                              child: PreviewVideoThumbNail(
                                                file: file,
                                                width: 100,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -13,
                                  top: -13,
                                  child: IconButton(
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    onPressed: () {
                                      ref
                                          .read(commentCreateProvider(
                                                  widget.threadId)
                                              .notifier)
                                          .removeAsset(index);
                                    },
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: LIGHT_GRAY_COLOR,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          itemCount: tempList.length,
                        ),
                ),
              Row(
                children: [
                  InkWell(
                    onTap: () async {
                      await ref
                          .read(commentCreateProvider(widget.threadId).notifier)
                          .pickCamera(context);
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 10, bottom: 10, right: 10),
                      child: SvgPicture.asset('asset/img/icon_camera.svg'),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      await ref
                          .read(commentCreateProvider(widget.threadId).notifier)
                          .pickImage(context)
                          .then(
                        (assets) async {
                          if (assets != null && assets.isNotEmpty) {
                            ref
                                .read(commentCreateProvider(widget.threadId)
                                    .notifier)
                                .updateIsLoading(true);

                            for (var asset in assets) {
                              if (await asset.file != null) {
                                final file = await asset.file;

                                ref
                                    .read(commentCreateProvider(widget.threadId)
                                        .notifier)
                                    .addAssets(file!.path);

                                debugPrint('file.path : ${file.path}');
                              }
                            }

                            ref
                                .read(commentCreateProvider(widget.threadId)
                                    .notifier)
                                .updateIsLoading(false);
                          } else {
                            debugPrint('assets: $assets');
                          }
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset('asset/img/icon_picture.svg'),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: commentState.isLoading ||
                            commentController.text.isEmpty
                        ? null
                        : () async {
                            await ref
                                .read(commentCreateProvider(widget.threadId)
                                    .notifier)
                                .createComment(widget.threadId, model.user)
                                .then((value) {
                              setState(() {
                                commentController.text = '';
                              });
                            }).onError((error, stackTrace) {
                              showDialog(
                                context: context,
                                builder: (context) => DialogWidgets.errorDialog(
                                  message: '업도르에 실패하였습니다.',
                                  confirmText: '확인',
                                  confirmOnTap: () => context.pop(),
                                ),
                              );
                            });
                          },
                    child: Container(
                      width: 53,
                      height: 25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: commentController.text.isNotEmpty
                            ? POINT_COLOR
                            : POINT_COLOR.withOpacity(0.5),
                      ),
                      child: Center(
                        child:
                            commentState.isLoading || commentState.isUploading
                                ? const SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    '등록',
                                    style: h6Headline.copyWith(
                                      color: commentController.text.isNotEmpty
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.5),
                                      height: 1,
                                    ),
                                  ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _emojiSection(
      double emojiHeight, List<Widget> emojiButtons) {
    return SliverToBoxAdapter(
      child: Padding(
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
      ),
    );
  }

  SliverToBoxAdapter _commentsDivider(ThreadModel model) {
    return SliverToBoxAdapter(
      child: Column(
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
      ),
    );
  }

  TextFormField _commentTextFormField() {
    const baseBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.transparent,
        width: 1,
      ),
    );

    return TextFormField(
      onChanged: (value) {
        ref
            .read(commentCreateProvider(widget.threadId).notifier)
            .updateContent(value);

        setState(() {
          maxLine = '\n'.allMatches(value).length + 1;

          if (maxLine > 3) {
            maxLine = 3;
          }
        });
      },
      maxLines: maxLine > 1 ? maxLine : null,
      style: const TextStyle(color: Colors.white),
      controller: commentController,
      cursorColor: POINT_COLOR,
      focusNode: commentFocusNode,
      onTapOutside: (event) {
        commentFocusNode.unfocus();
      },
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        focusColor: POINT_COLOR,
        border: baseBorder,
        disabledBorder: baseBorder,
        enabledBorder: baseBorder,
        focusedBorder: baseBorder,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 11,
        ),
        filled: true,
        labelStyle: s1SubTitle.copyWith(
          color: commentFocusNode.hasFocus ? POINT_COLOR : GRAY_COLOR,
        ),
        label: Text(
          commentFocusNode.hasFocus || commentController.text.isNotEmpty
              ? ''
              : '댓글을 입력해주세요',
          style: s1SubTitle.copyWith(
            color: GRAY_COLOR,
          ),
        ),
      ),
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
    return SliverToBoxAdapter(
      child: Padding(
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
      ),
    );
  }
}
