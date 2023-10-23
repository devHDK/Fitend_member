import 'dart:convert';

import 'package:fitend_member/common/component/error_dialog.dart';
import 'package:fitend_member/common/component/logo_appbar.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/provider/shared_preference_provider.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/common/utils/shared_pref_utils.dart';
import 'package:fitend_member/notifications/model/notificatiion_main_state_model.dart';
import 'package:fitend_member/notifications/provider/notification_home_screen_provider.dart';
import 'package:fitend_member/notifications/view/notification_screen.dart';
import 'package:fitend_member/thread/component/thread_cell.dart';
import 'package:fitend_member/thread/model/common/thread_user_model.dart';
import 'package:fitend_member/thread/model/emojis/emoji_model.dart';
import 'package:fitend_member/thread/model/threads/thread_list_model.dart';
import 'package:fitend_member/thread/model/threads/thread_model.dart';
import 'package:fitend_member/thread/provider/thread_detail_provider.dart';

import 'package:fitend_member/thread/provider/thread_provider.dart';
import 'package:fitend_member/thread/view/thread_create_screen.dart';
import 'package:fitend_member/thread/view/thread_detail_screen.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:fitend_member/user/view/mypage_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ThreadScreen extends ConsumerStatefulWidget {
  const ThreadScreen({super.key});

  @override
  ConsumerState<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends ConsumerState<ThreadScreen>
    with WidgetsBindingObserver, RouteAware {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  ThreadListModel pstate = ThreadListModel(data: [], total: 0);

  bool isLoading = false;
  int startIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    itemPositionsListener.itemPositions.addListener(_handleItemPositionChange);

    //threadScreen 진입시 badgeCount => 0

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(notificationHomeProvider.notifier).updateBageCount(0);
    });
  }

  void _handleItemPositionChange() {
    int maxIndex = itemPositionsListener.itemPositions.value
        .where((position) => position.itemLeadingEdge > 0)
        .reduce((maxPosition, currPosition) =>
            currPosition.itemLeadingEdge > maxPosition.itemLeadingEdge
                ? currPosition
                : maxPosition)
        .index;

    int minIndex = itemPositionsListener.itemPositions.value
        .where((position) => position.itemTrailingEdge < 1)
        .reduce((minPosition, currPosition) =>
            currPosition.itemLeadingEdge < minPosition.itemLeadingEdge
                ? currPosition
                : minPosition)
        .index;

    if (minIndex < 0) minIndex = 0;
    ref.read(threadProvider.notifier).updateScrollIndex(minIndex);

    if (pstate.data.isNotEmpty &&
        maxIndex == pstate.data.length - 2 &&
        pstate.total > pstate.data.length &&
        !isLoading) {
      //스크롤을 아래로 내렸을때
      isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ref
            .read(threadProvider.notifier)
            .paginate(startIndex: startIndex, fetchMore: true)
            .then((value) {
          isLoading = false;
        });
      });
    }
  }

  void threadBadgeCountReset() async {
    final pref = await ref.read(sharedPrefsProvider);
    SharedPrefUtils.updateThreadBadgeCount(pref, 'reset');
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
  void didPush() async {
    await checkThreadNeedUpdate();
    super.didPush();
  }

  @override
  void didPop() async {
    await checkThreadNeedUpdate();
    super.didPop();
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

      await SharedPrefUtils.updateThreadBadgeCount(pref, 'add');
      ref.read(notificationHomeProvider.notifier).addBageCount(1);
      ref.read(notificationHomeProvider.notifier).updateIsConfirm(false);

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
      ref.read(notificationHomeProvider.notifier).updateIsConfirm(false);
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
    final state = ref.watch(threadProvider);
    final userState = ref.watch(getMeProvider);
    final notificationState = ref.watch(notificationHomeProvider);

    if (state is ThreadListModelLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: POINT_COLOR,
        ),
      );
    }

    if (state is ThreadListModelError) {
      return ErrorDialog(error: state.message);
    }

    final user = userState as UserModel;
    pstate = state as ThreadListModel;
    final notificationHomeModel = notificationState as NotificationMainModel;
    startIndex = state.data.length;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        appBar: LogoAppbar(
          title: 'T H R E A D S',
          tapLogo: () async {
            await ref
                .read(threadProvider.notifier)
                .paginate(
                  startIndex: 0,
                  isRefetch: true,
                )
                .then((value) {
              itemScrollController.jumpTo(index: 0);
              isLoading = false;
            });
          },
          actions: [
            InkWell(
              hoverColor: Colors.transparent,
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ));
              },
              child: !notificationHomeModel.isConfirmed
                  ? SvgPicture.asset('asset/img/icon_alarm_on.svg')
                  : SvgPicture.asset('asset/img/icon_alarm_off.svg'),
            ),
            const SizedBox(
              width: 12,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 28.0),
              child: InkWell(
                hoverColor: Colors.transparent,
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => const MyPageScreen(),
                    ),
                  );
                },
                child: SvgPicture.asset(
                  'asset/img/icon_my_page.svg',
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => ThreadCreateScreen(
                    trainer: user.user.activeTrainers.first,
                    user: ThreadUser(
                      id: user.user.id,
                      gender: user.user.gender,
                      nickname: user.user.nickname,
                    )),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          child: SvgPicture.asset('asset/img/icon_thread_create_button.svg'),
        ),
        body: RefreshIndicator(
          backgroundColor: BACKGROUND_COLOR,
          color: POINT_COLOR,
          semanticsLabel: '새로고침',
          onRefresh: () async {
            await ref
                .read(threadProvider.notifier)
                .paginate(
                  startIndex: 0,
                  isRefetch: true,
                )
                .then((value) {
              itemScrollController.jumpTo(index: 0);
              isLoading = false;
            });
          },
          child: state.data.isEmpty
              ? SingleChildScrollView(
                  child: Center(
                    child: Text(
                      '아직 코치님과 함께한 쓰레드가 없어요 🙂',
                      style: s2SubTitle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : ScrollablePositionedList.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  itemScrollController: itemScrollController,
                  initialScrollIndex: state.scrollIndex ?? 0,
                  itemPositionsListener: itemPositionsListener,
                  itemCount: state.data.length + 1,
                  itemBuilder: (context, index) {
                    if (index == state.data.length) {
                      if (state.data.length == state.total) {
                        return const SizedBox(
                          height: 100,
                        );
                      }

                      return const SizedBox(
                        height: 100,
                        child: Center(
                          child: CircularProgressIndicator(color: POINT_COLOR),
                        ),
                      );
                    }

                    final model = state.data[index];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (index == 0 ||
                            DataUtils.getDateFromDateTime(
                                    DateTime.parse(model.createdAt)
                                        .toUtc()
                                        .toLocal()) !=
                                DataUtils.getDateFromDateTime(DateTime.parse(
                                        state.data[index - 1].createdAt)
                                    .toUtc()
                                    .toLocal()))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Text(
                              DataUtils.getDateFromDateTime(
                                          DateTime.parse(model.createdAt)
                                              .toUtc()
                                              .toLocal()) ==
                                      DataUtils.getDateFromDateTime(
                                          DateTime.now())
                                  ? '오늘'
                                  : DataUtils.getDateFromDateTime(
                                              DateTime.parse(model.createdAt)
                                                  .toUtc()
                                                  .toLocal()) ==
                                          DataUtils.getDateFromDateTime(
                                              DateTime.now().subtract(
                                                  const Duration(days: 1)))
                                      ? '어제'
                                      : DataUtils.getMonthDayFromDateTime(
                                          DateTime.parse(model.createdAt)
                                              .toUtc()
                                              .toLocal()),
                              style: h4Headline.copyWith(color: Colors.white),
                            ),
                          ),
                        InkWell(
                          onTap: () =>
                              Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) => ThreadDetailScreen(
                              threadId: model.id,
                            ),
                          )),
                          child: ThreadCell(
                            id: model.id,
                            title: model.title,
                            content: model.content,
                            profileImageUrl: model.writerType == 'trainer'
                                ? '$s3Url${model.trainer.profileImage}'
                                : model.user.gender == 'male'
                                    ? maleProfileUrl
                                    : femaleProfileUrl,
                            nickname: model.user.nickname,
                            dateTime: DateTime.parse(model.createdAt)
                                .toUtc()
                                .toLocal(),
                            gallery: model.gallery,
                            emojis: model.emojis,
                            userCommentCount: model.userCommentCount != null
                                ? model.userCommentCount!
                                : 0,
                            trainerCommentCount:
                                model.trainerCommentCount != null
                                    ? model.trainerCommentCount!
                                    : 0,
                            user: model.user,
                            trainer: model.trainer,
                            writerType: model.writerType,
                            threadType: model.type,
                            workoutInfo: model.workoutInfo,
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}
