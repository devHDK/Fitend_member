import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/component/error_dialog.dart';
import 'package:fitend_member/common/component/logo_appbar.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/notifications/view/notification_screen.dart';
import 'package:fitend_member/thread/component/comment_cell.dart';
import 'package:fitend_member/thread/component/emoji_button.dart';
import 'package:fitend_member/thread/component/thread_cell.dart';
import 'package:fitend_member/thread/component/thread_detail.dart';
import 'package:fitend_member/thread/model/threads/thread_list_model.dart';
import 'package:fitend_member/thread/model/threads/thread_model.dart';
import 'package:fitend_member/thread/provider/thread_provider.dart';
import 'package:fitend_member/thread/view/thread_create_screen.dart';
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
    with WidgetsBindingObserver {
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
  }

  void _handleItemPositionChange() {
    int maxIndex = itemPositionsListener.itemPositions.value
        .where((position) => position.itemLeadingEdge > 0)
        .reduce((maxPosition, currPosition) =>
            currPosition.itemLeadingEdge > maxPosition.itemLeadingEdge
                ? currPosition
                : maxPosition)
        .index;

    if (pstate.data.isNotEmpty &&
        maxIndex == pstate.data.length - 1 &&
        !isLoading) {
      //스크롤을 아래로 내렸을때
      isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ref
            .read(threadProvider.notifier)
            .paginate(startIndex: startIndex + 1, fetchMore: true)
            .then((value) {
          isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(threadProvider);

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

    pstate = state as ThreadListModel;
    startIndex = state.data.length;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        appBar: LogoAppbar(
          title: 'T H R E A D S',
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
              child: SvgPicture.asset('asset/img/icon_alarm_off.svg'),
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
        floatingActionButton: FloatingActionButton.small(
          onPressed: () {
            Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) => const ThreadCreateScreen(),
            ));
          },
          backgroundColor: Colors.transparent,
          child: SvgPicture.asset('asset/img/icon_thread_create_button.svg'),
        ),
        body: ScrollablePositionedList.builder(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          itemScrollController: itemScrollController,
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
              children: [
                ThreadCell(
                  id: model.id,
                  title: model.title,
                  content: model.content,
                  profileImageUrl:
                      'https://api-dev-minimal-v4.vercel.app/assets/images/avatars/avatar_7.jpg',
                  nickname: model.user.nickname,
                  dateTime: DateTime.parse(model.createdAt),
                  gallery: model.gallery,
                  emojis: model.emojis,
                  userCommentCount: model.userCommentCount,
                  trainerCommentCount: model.trainerCommentCount,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
