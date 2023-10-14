import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/thread/component/emoji_button.dart';
import 'package:fitend_member/thread/component/network_video_player.dart';
import 'package:fitend_member/thread/component/network_video_player_mini.dart';
import 'package:fitend_member/thread/component/preview_image_network.dart';
import 'package:fitend_member/thread/component/thread_detail.dart';
import 'package:fitend_member/thread/model/threads/thread_model.dart';
import 'package:fitend_member/thread/provider/thread_detail_provider.dart';
import 'package:fitend_member/thread/view/media_page_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(threadDetailProvider(widget.threadId));

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: RefreshIndicator(
          backgroundColor: BACKGROUND_COLOR,
          color: POINT_COLOR,
          semanticsLabel: '새로고침',
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
                  profileImageUrl: model.writerType == 'trainer'
                      ? '$s3Url${model.trainer.profileImage}'
                      : model.user.gender == 'male'
                          ? maleProfileUrl
                          : femaleProfileUrl,
                  nickname: model.writerType == 'trainer'
                      ? model.trainer.nickname
                      : model.user.nickname,
                  dateTime: DateTime.parse(model.createdAt),
                  content: model.content,
                ),
              ),
              if (model.gallery != null && model.gallery!.isNotEmpty)
                _mediaListView(model),
              _emojiSection(context),
              _commentsDivider(model),
              if (model.comments != null && model.comments!.isNotEmpty)
                const SizedBox()
              else
                SliverToBoxAdapter(
                  child: Text(
                    '아직 댓글이 없어요 :)',
                    style: s2SubTitle.copyWith(
                      color: GRAY_COLOR,
                      height: 1,
                    ),
                  ),
                )
            ],
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

  SliverToBoxAdapter _emojiSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Row(
            children: [
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
          ),
          const SizedBox(
            height: 25,
          )
        ],
      ),
    );
  }

  SliverToBoxAdapter _mediaListView(ThreadModel model) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SizedBox(
          height: (80.w.toInt() - 56) * 0.8,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
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
                            ),
                    ),
                  ),
                ],
              );
            },
            itemCount: model.gallery!.length,
          ),
        ),
      ),
    );
  }
}
