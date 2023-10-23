import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/provider/shared_preference_provider.dart';
import 'package:fitend_member/common/utils/shared_pref_utils.dart';
import 'package:fitend_member/thread/component/comment_cell.dart';
import 'package:fitend_member/thread/component/link_preview.dart';
import 'package:fitend_member/thread/component/preview_image.dart';
import 'package:fitend_member/thread/component/preview_video_thumbnail.dart';
import 'package:fitend_member/thread/component/profile_image.dart';
import 'package:fitend_member/thread/component/thread_detail.dart';
import 'package:fitend_member/thread/model/comments/thread_comment_create_model.dart';
import 'package:fitend_member/thread/model/emojis/emoji_model.dart';
import 'package:fitend_member/thread/model/exception/thread_exceptios.dart';
import 'package:fitend_member/thread/model/threads/thread_comment_edit_model.dart';
import 'package:fitend_member/thread/model/threads/thread_list_model.dart';
import 'package:fitend_member/thread/model/threads/thread_model.dart';
import 'package:fitend_member/thread/provider/comment_create_provider.dart';
import 'package:fitend_member/thread/provider/thread_detail_provider.dart';
import 'package:fitend_member/thread/provider/thread_provider.dart';
import 'package:fitend_member/thread/utils/media_utils.dart';
import 'package:fitend_member/thread/view/comment_asset_edit_screen.dart';
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

class _ThreadDetailScreenState extends ConsumerState<ThreadDetailScreen>
    with WidgetsBindingObserver, RouteAware {
  FocusNode commentFocusNode = FocusNode();
  final commentController = TextEditingController();
  int maxLine = 1;

  int edittingCommentId = -1;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
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
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await checkThreadNeedUpdate();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void didPushNext() async {
    super.didPush();
    await checkThreadNeedUpdate();
  }

  @override
  void didPopNext() async {
    super.didPopNext();
    await checkThreadNeedUpdate();
  }

  Future<void> checkThreadNeedUpdate() async {
    final pref = await ref.read(sharedPrefsProvider);
    final isNeedListUpdate =
        SharedPrefUtils.getIsNeedUpdate(needThreadUpdate, pref);
    var threadUpdateList =
        SharedPrefUtils.getNeedUpdateList(needThreadUpdateList, pref);
    var threadDeleteList =
        SharedPrefUtils.getNeedUpdateList(needThreadDelete, pref);
    var commentCreateList =
        SharedPrefUtils.getNeedUpdateList(needCommentCreate, pref);
    var commentDeleteList =
        SharedPrefUtils.getNeedUpdateList(needCommentDelete, pref);
    var emojiCreateList =
        SharedPrefUtils.getNeedUpdateList(needEmojiCreate, pref);
    var emojiDeleteList =
        SharedPrefUtils.getNeedUpdateList(needEmojiDelete, pref);

    bool isListRefreshed = false;
    List<int> detailRefreshedList = [];

    if (isNeedListUpdate) {
      ref
          .read(threadProvider.notifier)
          .paginate(startIndex: 0, isRefetch: true);

      await SharedPrefUtils.updateIsNeedUpdate(needScheduleUpdate, pref, false);
      await SharedPrefUtils.updateNeedUpdateList(needThreadDelete, pref, []);
      threadDeleteList = [];
      isListRefreshed = true;
    }

    if (threadUpdateList.isNotEmpty) {
      for (var e in threadUpdateList) {
        final tempState = ref.read(threadProvider);

        final model = tempState as ThreadListModel;
        final index = model.data.indexWhere((thread) {
          return thread.id == int.parse(e);
        });

        if (index != -1) {
          ref
              .read(threadDetailProvider(int.parse(e)).notifier)
              .getThreadDetail(threadId: int.parse(e));

          detailRefreshedList.add(int.parse(e));
        }
      }
    }

    if (threadDeleteList.isNotEmpty && !isListRefreshed) {
      for (var e in threadDeleteList) {
        final tempState = ref.read(threadProvider);

        final model = tempState as ThreadListModel;
        final index = model.data.indexWhere((thread) {
          return thread.id == int.parse(e);
        });

        if (index != -1) {
          ref
              .read(threadProvider.notifier)
              .removeThreadWithId(int.parse(e), index);
        }
      }
    }

    if (commentCreateList.isNotEmpty) {
      for (var e in commentCreateList) {
        if (ref.read(threadDetailProvider(int.parse(e))) is ThreadModel &&
            !detailRefreshedList.contains(int.parse(e))) {
          ref
              .read(threadDetailProvider(int.parse(e)).notifier)
              .getThreadDetail(threadId: int.parse(e));

          detailRefreshedList.add(int.parse(e));
        }

        var tempState = ref.read(threadProvider);
        var model = tempState as ThreadListModel;

        int index =
            model.data.indexWhere((thread) => thread.id == int.parse(e));

        if (index != -1 && !isListRefreshed) {
          ref
              .read(threadProvider.notifier)
              .updateTrainerCommentCount(int.parse(e), 1);
        }
      }
      await SharedPrefUtils.updateNeedUpdateList(needCommentCreate, pref, []);
      commentCreateList = [];
    }

    if (commentDeleteList.isNotEmpty) {
      for (var e in commentDeleteList) {
        if (ref.read(threadDetailProvider(int.parse(e))) is ThreadModel &&
            !detailRefreshedList.contains(int.parse(e))) {
          ref
              .read(threadDetailProvider(int.parse(e)).notifier)
              .getThreadDetail(threadId: int.parse(e));

          detailRefreshedList.add(int.parse(e));
        }

        var tempState = ref.read(threadProvider);
        var model = tempState as ThreadListModel;

        int index =
            model.data.indexWhere((thread) => thread.id == int.parse(e));

        if (index != -1 && !isListRefreshed) {
          ref
              .read(threadProvider.notifier)
              .updateTrainerCommentCount(int.parse(e), -1);
        }
      }
    }

    if (emojiCreateList.isNotEmpty) {
      var tempList = emojiCreateList;

      for (var emoji in tempList) {
        var emojiMap = jsonDecode(emoji);
        var emojiModel = EmojiModelFromPushData.fromJson(emojiMap);

        if (emojiModel.commentId == null) {
          //thread에 추가
          if (!isListRefreshed) {
            final tempState = ref.read(threadProvider) as ThreadListModel;
            int index = tempState.data
                .indexWhere((element) => element.id == emojiModel.threadId);

            ref.read(threadProvider.notifier).addEmoji(null,
                emojiModel.trainerId, emojiModel.emoji, index, emojiModel.id);
          }

          if (!detailRefreshedList.contains(emojiModel.threadId!)) {
            ref
                .read(threadDetailProvider(emojiModel.threadId!).notifier)
                .addThreadEmoji(null, emojiModel.trainerId, emojiModel.emoji,
                    emojiModel.id);
          }
        } else if (emojiModel.commentId != null &&
            !detailRefreshedList.contains(emojiModel.threadId)) {
          ThreadModel? tempState;
          if (ref.read(threadDetailProvider(emojiModel.threadId!))
              is ThreadModel) {
            tempState = ref.read(threadDetailProvider(emojiModel.threadId!))
                as ThreadModel;
          }

          if (tempState != null &&
              tempState.comments != null &&
              tempState.comments!.isNotEmpty) {
            final index = tempState.comments!
                .indexWhere((element) => element.id == emojiModel.commentId);

            if (index != -1) {
              ref
                  .read(threadDetailProvider(emojiModel.threadId!).notifier)
                  .addCommentEmoji(null, emojiModel.trainerId, emojiModel.emoji,
                      index, emojiModel.id);
            }
          }
        }

        emojiCreateList.remove(emoji);
      }

      await SharedPrefUtils.updateNeedUpdateList(
          needEmojiCreate, pref, emojiCreateList);
    }

    if (emojiDeleteList.isNotEmpty) {
      var tempList = emojiDeleteList;

      for (var emoji in tempList) {
        var emojiMap = jsonDecode(emoji);
        var emojiModel = EmojiModelFromPushData.fromJson(emojiMap);

        if (emojiModel.commentId == null) {
          //thread에서 삭제
          if (!isListRefreshed) {
            final tempState = ref.read(threadProvider) as ThreadListModel;
            int index = tempState.data
                .indexWhere((element) => element.id == emojiModel.threadId);

            ref.read(threadProvider.notifier).removeEmoji(null,
                emojiModel.trainerId, emojiModel.emoji, index, emojiModel.id);
          }

          if (!detailRefreshedList.contains(emojiModel.threadId!)) {
            ref
                .read(threadDetailProvider(emojiModel.threadId!).notifier)
                .removeThreadEmoji(null, emojiModel.trainerId, emojiModel.emoji,
                    emojiModel.id);
          }
        } else if (emojiModel.commentId != null &&
            !detailRefreshedList.contains(emojiModel.threadId)) {
          ThreadModel? tempState;
          if (ref.read(threadDetailProvider(emojiModel.threadId!))
              is ThreadModel) {
            tempState = ref.read(threadDetailProvider(emojiModel.threadId!))
                as ThreadModel;
          }

          if (tempState != null &&
              tempState.comments != null &&
              tempState.comments!.isNotEmpty) {
            final index = tempState.comments!
                .indexWhere((element) => element.id == emojiModel.commentId);

            if (index != -1) {
              ref
                  .read(threadDetailProvider(emojiModel.threadId!).notifier)
                  .removeCommentEmoji(null, emojiModel.trainerId,
                      emojiModel.emoji, index, emojiModel.id);
            }
          }
        }

        emojiDeleteList.remove(emoji);
      }
      await SharedPrefUtils.updateNeedUpdateList(
          needEmojiDelete, pref, emojiDeleteList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(threadDetailProvider(widget.threadId));
    final commentState = ref.watch(commentCreateProvider(widget.threadId));

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
          confirmOnTap: () {
            int count = 0;
            Navigator.of(context).popUntil((_) => count++ >= 2);
          },
        ),
      );
    }

    final model = state as ThreadModel;

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
          RefreshIndicator(
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
                    dateTime: DateTime.parse(model.createdAt).toUtc().toLocal(),
                    threadId: widget.threadId,
                  ),
                ),
                if (model.comments != null && model.comments!.isNotEmpty)
                  SliverList.separated(
                    itemBuilder: (context, index) {
                      if (index != 0 && index == model.comments!.length) {
                        return const SizedBox(
                          height: 150,
                        );
                      }

                      final commentModel = model.comments![index];

                      return Stack(
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
                            isEditting: commentModel.id == edittingCommentId,
                          ),
                          if (commentModel.user != null &&
                              model.user.id == commentModel.user!.id &&
                              edittingCommentId == -1)
                            Positioned(
                              top: -5,
                              right: 15,
                              child: InkWell(
                                onTap: () => DialogWidgets.editBottomModal(
                                  context,
                                  delete: () async {
                                    context.pop();

                                    await ref
                                        .read(threadDetailProvider(
                                                widget.threadId)
                                            .notifier)
                                        .deleteComment(commentModel.id);
                                  },
                                  edit: () async {
                                    context.pop();

                                    ref
                                        .read(commentCreateProvider(
                                                commentModel.threadId)
                                            .notifier)
                                        .updateFromEditModel(
                                            ThreadCommentEditModel(
                                                threadId: commentModel.threadId,
                                                content: commentModel.content,
                                                gallery: commentModel.gallery));

                                    setState(() {
                                      commentController.text =
                                          commentModel.content;

                                      edittingCommentId = commentModel.id;
                                    });
                                  },
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: SvgPicture.asset(
                                      'asset/img/icon_edit.svg'),
                                ),
                              ),
                            )
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        '아직 댓글이 없어요 :)',
                        style: s1SubTitle.copyWith(
                          color: GRAY_COLOR,
                          height: 1,
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
          _bottomInputBox(commentState, model, context),
        ],
      ),
    );
  }

  Positioned _bottomInputBox(
    ThreadCommentCreateTempModel commentState,
    ThreadModel model,
    BuildContext context,
  ) {
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

                                      if (edittingCommentId != -1) {
                                        ref
                                            .read(commentCreateProvider(
                                                    widget.threadId)
                                                .notifier)
                                            .updateFileCheck('remove', index);

                                        ref
                                            .read(commentCreateProvider(
                                                    commentState.threadId)
                                                .notifier)
                                            .removeAssetFromGallery(index);
                                      }
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

                                if (edittingCommentId != -1) {
                                  ref
                                      .read(
                                          commentCreateProvider(widget.threadId)
                                              .notifier)
                                      .updateFileCheck('add', 0);
                                }

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
                  if (edittingCommentId == -1)
                    InkWell(
                      onTap: commentState.isLoading ||
                              commentController.text.isEmpty
                          ? null
                          : () async {
                              try {
                                await ref
                                    .read(commentCreateProvider(widget.threadId)
                                        .notifier)
                                    .createComment(widget.threadId, model.user)
                                    .then((value) {
                                  setState(() {
                                    commentController.text = '';
                                  });
                                });
                              } catch (e) {
                                if (e is FileException) {
                                  if (e.message ==
                                      'oversize_file_include_error') {
                                    DialogWidgets.showToast(
                                        '200MB가 넘는 사진 또는 영상은 첨부할수 없습니다.');
                                  }
                                }
                              }
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
                    )
                  else
                    commentState.isLoading || commentState.isUploading
                        ? Container(
                            width: 53,
                            height: 25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: POINT_COLOR.withOpacity(0.5),
                            ),
                            child: const Center(
                              child: SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  ref
                                      .read(commentCreateProvider(model.id)
                                          .notifier)
                                      .init();

                                  setState(() {
                                    edittingCommentId = -1;
                                  });
                                },
                                child: Container(
                                  width: 45,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    border: Border.all(
                                        color: POINT_COLOR, width: 1),
                                  ),
                                  child: const Icon(Icons.close,
                                      color: POINT_COLOR),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  try {
                                    await ref
                                        .read(commentCreateProvider(
                                                commentState.threadId)
                                            .notifier)
                                        .updateComment(
                                          edittingCommentId,
                                          commentState.gallery,
                                        )
                                        .then((value) {
                                      ref
                                          .read(commentCreateProvider(
                                                  commentState.threadId)
                                              .notifier)
                                          .init();

                                      setState(() {
                                        edittingCommentId = -1;
                                        commentController.text = '';
                                      });
                                    });
                                  } catch (e) {
                                    if (e is FileException) {
                                      if (e.message ==
                                          'oversize_file_include_error') {
                                        DialogWidgets.showToast(
                                            '200MB가 넘는 사진 또는 영상은 첨부할수 없습니다.');
                                      }
                                    }
                                  }
                                },
                                child: Container(
                                  width: 45,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: POINT_COLOR,
                                  ),
                                  child: SvgPicture.asset(
                                    'asset/img/icon_check_save.svg',
                                  ),
                                ),
                              ),
                            ],
                          )
                ],
              )
            ],
          ),
        ),
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
      autocorrect: false,
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
