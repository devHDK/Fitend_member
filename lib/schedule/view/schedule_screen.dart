import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/component/logo_appbar.dart';
import 'package:fitend_member/common/component/reservation_schedule_card.dart';
import 'package:fitend_member/common/component/workout_schedule_card.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/data/global_varialbles.dart';
import 'package:fitend_member/common/provider/shared_preference_provider.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/common/utils/shared_pref_utils.dart';
import 'package:fitend_member/notifications/model/notificatiion_main_state_model.dart';
import 'package:fitend_member/notifications/model/notification_confirm_model.dart';
import 'package:fitend_member/notifications/provider/notification_home_screen_provider.dart';
import 'package:fitend_member/notifications/repository/notifications_repository.dart';
import 'package:fitend_member/notifications/view/notification_screen.dart';
import 'package:fitend_member/schedule/model/reservation_schedule_model.dart';
import 'package:fitend_member/schedule/model/schedule_model.dart';
import 'package:fitend_member/schedule/model/workout_schedule_model.dart';
import 'package:fitend_member/schedule/provider/schedule_provider.dart';
import 'package:fitend_member/user/provider/go_router.dart';
import 'package:fitend_member/user/view/mypage_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  static String get routeName => 'schedule_main';
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen>
    with WidgetsBindingObserver, RouteAware {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  DateTime today = DateTime.now();
  DateTime fifteenDaysAgo = DateTime.now().subtract(const Duration(days: 15));
  DateTime minDate = DateTime(DateTime.now().year);
  DateTime maxDate = DateTime(DateTime.now().year);
  bool initial = true;
  bool buildInitial = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    itemPositionsListener.itemPositions.addListener(_handleItemPositionChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initial) {
        // _getScheduleInitial();
        _checkHasData(scheduleListGlobal, context);
        initial = false;
      }
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

    int itemCount = scheduleListGlobal.length;

    ref.read(scheduleProvider.notifier).updateScrollIndex(minIndex);

    if (maxIndex == itemCount - 1 && !isLoading) {
      //스크롤을 아래로 내렸을때
      isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ref
            .read(scheduleProvider.notifier)
            .paginate(
                startDate: maxDate, fetchMore: true, isDownScrolling: true)
            .then((value) {
          isLoading = false;
        });
      });
    } else if (minIndex == 1 && !isLoading) {
      isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ref
            .read(scheduleProvider.notifier)
            .paginate(startDate: minDate, fetchMore: true, isUpScrolling: true)
            .then((value) {
          itemScrollController.jumpTo(index: 32);
          isLoading = false;
        });
      });
    }
  }

  // void _getScheduleInitial() async {
  //   await ref
  //       .read(scheduleProvider.notifier)
  //       .paginate(startDate: DataUtils.getDate(fifteenDaysAgo))
  //       .then((value) {
  //     _checkHasData(scheduleListGlobal, context);
  //   });

  //   initial = false;
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await _checkIsNeedUpdate();
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
    await _checkIsNeedUpdate();
  }

  @override
  void didPopNext() async {
    super.didPopNext();
    await _checkIsNeedUpdate();
  }

  Future<void> _checkIsNeedUpdate() async {
    final pref = await ref.read(sharedPrefsProvider);
    final isNeedUpdate =
        SharedPrefUtils.getIsNeedUpdate(needScheduleUpdate, pref);
    if (isNeedUpdate) {
      await _resetScheduleList();
      await SharedPrefUtils.updateIsNeedUpdate(needScheduleUpdate, pref, false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref
        .read(routeObserverProvider)
        .subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    ref.read(routeObserverProvider).unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    itemPositionsListener.itemPositions
        .removeListener(_handleItemPositionChange);
    super.dispose();
  }

  void _onChildEvent() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationHomeProvider);
    final state = ref.watch(scheduleProvider);

    if (state is ScheduleModelLoading ||
        notificationState is NotificationMainModelLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: POINT_COLOR,
        ),
      );
    }

    if (state is ScheduleModelError) {
      DialogWidgets.errorDialog(
        message: state.message,
        confirmText: '확인',
        confirmOnTap: () {
          int count = 0;
          Navigator.of(context).popUntil((_) => count++ >= 2);
        },
      ).show(context);
    }

    final schedules = state as ScheduleModel;
    final notificationHomeModel = notificationState as NotificationMainModel;

    minDate = schedules.data.first.startDate.subtract(const Duration(days: 31));
    maxDate = schedules.data.last.startDate.add(const Duration(days: 1));

    scheduleListGlobal = schedules.data;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        appBar: LogoAppbar(
          title: 'P L A N',
          tapLogo: () async {
            await ref
                .read(scheduleProvider.notifier)
                .paginate(
                  startDate: DataUtils.getDate(fifteenDaysAgo),
                )
                .then((value) {
              itemScrollController.jumpTo(index: 15);
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
        body: ScrollablePositionedList.builder(
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          initialScrollIndex:
              schedules.scrollIndex != null ? schedules.scrollIndex! : 15,
          itemCount: schedules.data.length + 2,
          itemBuilder: (context, index) {
            if (index == schedules.data.length + 1 || index == 0) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(color: POINT_COLOR),
                ),
              );
            }

            final model = schedules.data[index - 1].schedule;

            if (model!.isEmpty) {
              return Column(
                children: [
                  if (schedules.data[index - 1].startDate.day == 1)
                    Container(
                      height: 34,
                      color: DARK_GRAY_COLOR,
                      child: Center(
                        child: Text(
                          DateFormat('yyyy년 M월')
                              .format(schedules.data[index - 1].startDate),
                          style: h3Headline.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  WorkoutScheduleCard(
                    date: schedules.data[index - 1].startDate,
                    selected: false,
                    isComplete: null,
                  ),
                ],
              );
            }

            if (model.isNotEmpty) {
              return Column(
                children: [
                  if (schedules.data[index - 1].startDate.day == 1)
                    Container(
                      height: 34,
                      color: DARK_GRAY_COLOR,
                      child: Center(
                        child: Text(
                          DateFormat('yyyy년 M월')
                              .format(schedules.data[index - 1].startDate),
                          style: h3Headline.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ...model.mapIndexed(
                    (seq, e) {
                      return InkWell(
                        onTap: () {
                          if (model[seq].selected!) {
                            return;
                          }

                          setState(
                            () {
                              for (var e in schedules.data) {
                                for (var element in e.schedule!) {
                                  element.selected = false;
                                }
                              }
                              model[seq].selected = true;
                            },
                          );
                        },
                        child: e is Workout
                            ? WorkoutScheduleCard.fromWorkoutModel(
                                model: e,
                                date: schedules.data[index - 1].startDate,
                                isDateVisible: seq == 0 ? true : false,
                                onNotifyParent: _onChildEvent,
                              )
                            : ReservationScheduleCard.fromReservationModel(
                                date: schedules.data[index - 1].startDate,
                                isDateVisible: seq == 0 ? true : false,
                                model: e as Reservation,
                              ),
                      );
                    },
                  ).toList()
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  void _checkHasData(List<ScheduleData> schedules, BuildContext context) {
    if (schedules.length < 33 && schedules.length > 1 && buildInitial) {
      bool hasData = false;

      for (ScheduleData element in schedules) {
        // debugPrint('element $element');
        if (element.schedule!.isNotEmpty) {
          hasData = true;
          break;
        }
      }

      if (!hasData) {
        DialogWidgets.errorDialog(
          message: '회원님을 위한 플랜을 준비중이에요!\n플랜이 완성되면 알려드릴게요 😊',
          confirmText: '확인',
          confirmOnTap: () => context.pop(),
        ).show(context);
      }

      buildInitial = false;
    }
  }

  Future<void> _resetScheduleList() async {
    await ref
        .read(scheduleProvider.notifier)
        .paginate(
          startDate: DataUtils.getDate(fifteenDaysAgo),
        )
        .then((value) {
      itemScrollController.jumpTo(index: 15);
    });
  }
}
