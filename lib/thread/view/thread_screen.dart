import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/component/logo_appbar.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/common/utils/shared_pref_utils.dart';
import 'package:fitend_member/notifications/model/notificatiion_main_state_model.dart';
import 'package:fitend_member/notifications/provider/notification_home_screen_provider.dart';
import 'package:fitend_member/notifications/view/notification_screen.dart';
import 'package:fitend_member/thread/component/thread_cell.dart';
import 'package:fitend_member/thread/model/common/thread_user_model.dart';
import 'package:fitend_member/thread/model/threads/thread_list_model.dart';
import 'package:fitend_member/thread/provider/thread_create_provider.dart';

import 'package:fitend_member/thread/provider/thread_provider.dart';
import 'package:fitend_member/thread/utils/thread_push_update_utils.dart';
import 'package:fitend_member/thread/view/thread_create_screen.dart';
import 'package:fitend_member/thread/view/thread_detail_screen.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:fitend_member/user/provider/go_router.dart';
import 'package:fitend_member/user/view/mypage_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThreadScreen extends ConsumerStatefulWidget {
  static String get routeName => 'thread';

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
      updateBadge();
    });
  }

  void fetch() async {
    if (mounted && ref.read(threadProvider) is ThreadListModelError) {
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
    }
  }

  void updateBadge() {
    if (mounted) {
      threadBadgeCountReset();
      ref.read(notificationHomeProvider.notifier).updateBageCount(0);
    }
  }

  void _handleItemPositionChange() {
    if (mounted) {
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
          maxIndex > pstate.data.length - 2 &&
          pstate.total > pstate.data.length &&
          !isLoading) {
        //스크롤을 아래로 내렸을때
        isLoading = true;

        ref
            .read(threadProvider.notifier)
            .paginate(startIndex: startIndex, fetchMore: true)
            .then((value) {
          isLoading = false;
          if (mounted) {
            setState(() {});
          }
        });
      }
    }
  }

  void threadBadgeCountReset() async {
    final pref = await SharedPreferences.getInstance();
    SharedPrefUtils.updateThreadBadgeCount(pref, 'reset');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (mounted) {
          await ThreadUpdateUtils.checkThreadNeedUpdate(ref);
        }
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
    if (mounted) {
      await ThreadUpdateUtils.checkThreadNeedUpdate(ref);
    }
    super.didPush();
  }

  @override
  void didPop() async {
    if (mounted) {
      await ThreadUpdateUtils.checkThreadNeedUpdate(ref);
    }
    super.didPop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    itemPositionsListener.itemPositions
        .removeListener(_handleItemPositionChange);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref
        .read(routeObserverProvider)
        .subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(getMeProvider);
    final state = ref.watch(threadProvider);
    final notificationState = ref.watch(notificationHomeProvider);
    final threadCreateState = ref.watch(threadCreateProvider);

    if (state is ThreadListModelLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Pallete.point,
        ),
      );
    }

    if (state is ThreadListModelError) {
      return Scaffold(
        backgroundColor: Pallete.background,
        body: Center(
          child: DialogWidgets.oneButtonDialog(
            message: '데이터를 불러오지 못했습니다.',
            confirmText: '새로 고침',
            confirmOnTap: () {
              ref.invalidate(threadProvider);
            },
          ),
        ),
      );
    }

    final user = userState as UserModel;
    pstate = state as ThreadListModel;
    final notificationHomeModel = notificationState as NotificationMainModel;
    startIndex = state.data.length;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Pallete.background,
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
                  ? SvgPicture.asset(SVGConstants.alarmOn)
                  : SvgPicture.asset(SVGConstants.alarmOff),
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
                  SVGConstants.mypage,
                ),
              ),
            ),
          ],
          bottom: threadCreateState.isUploading &&
                  threadCreateState.totalCount > 0
              ? PreferredSize(
                  preferredSize: Size(100.w, 30),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 28, vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'UPLOADING',
                          style: h6Headline.copyWith(
                            color: Pallete.lightGray,
                            height: 1,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        LoadingAnimationWidget.dotsTriangle(
                          color: Pallete.lightGray,
                          size: 15,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: LinearProgressIndicator(
                            color: Pallete.point,
                            value: (threadCreateState.doneCount) /
                                threadCreateState.totalCount,
                            backgroundColor: Pallete.gray,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : null,
        ),
        floatingActionButton: threadCreateState.isUploading
            ? null
            : FloatingActionButton(
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
                child: SvgPicture.asset(SVGConstants.threadCreateButton),
              ),
        body: RefreshIndicator(
          backgroundColor: Pallete.background,
          color: Pallete.point,
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
              ? Scaffold(
                  backgroundColor: Pallete.background,
                  body: Center(
                    child: Text(
                      '아직 코치님과 함께한 쓰레드가 없어요 🙂',
                      style: s2SubTitle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : ScrollablePositionedList.builder(
                  // padding: const EdgeInsets.only(left: 28),
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
                          child:
                              CircularProgressIndicator(color: Pallete.point),
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
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 28),
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
                        GestureDetector(
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
                                ? '${URLConstants.s3Url}${model.trainer.profileImage}'
                                : model.user.gender == 'male'
                                    ? URLConstants.maleProfileUrl
                                    : URLConstants.femaleProfileUrl,
                            nickname: model.writerType == 'trainer'
                                ? model.trainer.nickname
                                : model.user.nickname,
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
