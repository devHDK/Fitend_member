import 'package:fitend_member/common/component/error_dialog.dart';
import 'package:fitend_member/common/component/logo_appbar.dart';
import 'package:fitend_member/common/component/reservation_schedule_card.dart';
import 'package:fitend_member/common/component/workout_schedule_card.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/data/global_varialbles.dart';
import 'package:fitend_member/common/provider/shared_preference_provider.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/common/utils/shared_pref_utils.dart';
import 'package:fitend_member/notifications/model/notification_confirm_model.dart';
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
  NotificationConfirmResponse notificationConfirmResponse =
      NotificationConfirmResponse(isConfirm: false);

  DateTime today = DateTime.now();
  DateTime fifteenDaysAgo = DateTime.now().subtract(const Duration(days: 15));
  DateTime minDate = DateTime(DateTime.now().year);
  DateTime maxDate = DateTime(DateTime.now().year);
  bool initial = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _getNotificationState();
    itemPositionsListener.itemPositions.addListener(_handleItemPositionChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initial) {
        _getScheduleInitial();
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

    // print('minIndex : $minIndex');
    // print('itemCount : $itemCount');
    // print('maxIndex : $maxIndex');

    if (maxIndex == itemCount - 1 && !isLoading) {
      //스크롤을 아래로 내렸을때
      isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ref
            .read(scheduleProvider(DataUtils.getDate(fifteenDaysAgo)).notifier)
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
            .read(scheduleProvider(DataUtils.getDate(fifteenDaysAgo)).notifier)
            .paginate(startDate: minDate, fetchMore: true, isUpScrolling: true)
            .then((value) {
          itemScrollController.jumpTo(index: 32);
          isLoading = false;
        });
      });
    }
  }

  void _getNotificationState() async {
    notificationConfirmResponse = await ref
        .read(notificationRepositoryProvider)
        .getNotificationsConfirm();

    setState(() {});
  }

  void _getScheduleInitial() async {
    await ref
        .read(scheduleProvider(DataUtils.getDate(fifteenDaysAgo)).notifier)
        .paginate(startDate: DataUtils.getDate(fifteenDaysAgo));

    initial = false;
  }

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
    }
  }

  @override
  void didPopNext() async {
    super.didPopNext();
    await _checkIsNeedUpdate();
  }

  Future<void> _checkIsNeedUpdate() async {
    _getNotificationState();

    final pref = await ref.read(sharedPrefsProvider);
    final isNeedUpdate = SharedPrefUtils.getIsNeedUpdateSchedule(pref);
    print('isNeedUpdate :$isNeedUpdate');
    if (isNeedUpdate) {
      await _resetScheduleList();
      await SharedPrefUtils.updateIsNeedUpdateSchedule(pref, false);
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
    WidgetsBinding.instance.removeObserver(this);
    ref.read(routeObserverProvider).unsubscribe(this);
    itemPositionsListener.itemPositions
        .removeListener(_handleItemPositionChange);
    super.dispose();
  }

  void _onChildEvent() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(scheduleProvider(DataUtils.getDate(fifteenDaysAgo)));

    if (state is ScheduleModelLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: POINT_COLOR,
        ),
      );
    }

    if (state is ScheduleModelError) {
      return ErrorDialog(error: state.message);
    }

    final schedules = state as ScheduleModel;
    minDate = schedules.data.first.startDate.subtract(const Duration(days: 31));
    maxDate = schedules.data.last.startDate.add(const Duration(days: 1));

    scheduleListGlobal = schedules.data;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        appBar: LogoAppbar(
          tapLogo: () async {
            await _resetScheduleList();
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
              child: !notificationConfirmResponse.isConfirm
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
          initialScrollIndex: 15,
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

  Future<void> _resetScheduleList() async {
    await ref
        .read(scheduleProvider(DataUtils.getDate(fifteenDaysAgo)).notifier)
        .paginate(
          startDate: DataUtils.getDate(fifteenDaysAgo),
        )
        .then((value) {
      itemScrollController.jumpTo(index: 15);
    });
  }
}
