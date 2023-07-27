import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/component/error_dialog.dart';
import 'package:fitend_member/common/component/logo_appbar.dart';
import 'package:fitend_member/common/component/reservation_schedule_card.dart';
import 'package:fitend_member/common/component/workout_schedule_card.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/data/global_varialbles.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
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
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  static String get routeName => 'schedule_main';
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen>
    with WidgetsBindingObserver, RouteAware {
  final ScrollController controller = ScrollController();
  NotificationConfirmResponse notificationConfirmResponse =
      NotificationConfirmResponse(isConfirm: false);

  DateTime today = DateTime.now();
  DateTime fifteenDaysAgo = DateTime.now().subtract(const Duration(days: 15));
  DateTime minDate = DateTime(DateTime.now().year);
  DateTime maxDate = DateTime(DateTime.now().year);
  int initListItemCount = 0;
  int monthCount = 0;
  // int refetchItemCount = 0;
  int todayLocation = 0;
  bool initial = true;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);

    _getNotificationState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initial) {
        _getScheduleInitial();
      }
    });
  }

  void _getNotificationState() async {
    notificationConfirmResponse = await ref
        .read(notificationRepositoryProvider)
        .getNotificationsConfirm();
  }

  void _getScheduleInitial() async {
    await ref
        .read(scheduleProvider(DataUtils.getDate(fifteenDaysAgo)).notifier)
        .paginate(startDate: DataUtils.getDate(fifteenDaysAgo))
        .then((value) {
      Future.delayed(const Duration(milliseconds: 200), () {
        todayLocation +=
            130 * 14 + (130 * initListItemCount) + (monthCount * 34);

        if (controller.hasClients) {
          controller.jumpTo(
            todayLocation.toDouble(),
          );
        }

        bool checkSchedule = false;

        for (var schedule in scheduleListGlobal) {
          if (schedule.schedule!.isNotEmpty) {
            checkSchedule = true;
            break;
          }
        }

        if (!checkSchedule) {
          showDialog(
            context: context,
            builder: (context) => DialogWidgets.errorDialog(
              message: '회원님을 위한 플랜을 준비 중이에요!\n플랜이 완성되면 알려드릴게요 😊',
              confirmText: '확인',
              confirmOnTap: () => context.pop(),
            ),
          );
        }
      });
    });
    initial = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print('resumed');
        break;
      case AppLifecycleState.inactive:
        print('inactive');
        break;
      case AppLifecycleState.paused:
        print('paused');
        break;
      case AppLifecycleState.detached:
        print('detached');
        break;
    }
  }

  @override
  void didPopNext() {
    super.didPopNext();
    print('scheduleScreen didPopNext');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref
        .read(routeObserver)
        .subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    ref.read(routeObserver).unsubscribe(this);
    controller.removeListener(listener);
    controller.dispose();
    super.dispose();
  }

  void listener() {
    final provider =
        ref.read(scheduleProvider(DataUtils.getDate(fifteenDaysAgo)).notifier);

    if (controller.offset < controller.position.minScrollExtent + 50) {
      //스크롤을 맨위로 올렸을때
      provider.paginate(
          startDate: minDate, fetchMore: true, isUpScrolling: true);

      double previousOffset = controller.offset;
      int tempListCount = 0;
      int tempMonthCount = 0;

      scheduleListGlobal.map((element) {
        if (element.schedule!.length > 1) {
          tempListCount += element.schedule!.length - 1;
        }

        if (element.startDate.day == 1) {
          tempMonthCount += 1;
        }
      });
      controller.jumpTo(
        previousOffset +
            (130.0 * 31 + 130 * tempListCount) +
            (34 * tempMonthCount),
      );

      todayLocation += (130 * 31) +
          (130 * tempListCount) +
          (34 * tempMonthCount); //기존 위치로 이동
    } else if (controller.offset > controller.position.maxScrollExtent - 100) {
      //스크롤을 아래로 내렸을때
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        provider.paginate(
            startDate: maxDate, fetchMore: true, isDownScrolling: true);
      });
    }
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

    var schedules = state as ScheduleModel;
    minDate = schedules.data.first.startDate.subtract(const Duration(days: 31));
    maxDate = schedules.data.last.startDate.add(const Duration(days: 1));

    // if (scheduleListGlobal.length < schedules.data!.length) {
    scheduleListGlobal = schedules.data;
    // }

    for (int i = 0; i < schedules.data.length; i++) {
      if (i > 13) {
        break;
      }

      if (schedules.data[i].schedule!.length >= 2) {
        initListItemCount += schedules.data[i].schedule!.length - 1;
      }

      if (schedules.data[i].startDate.day == 1) {
        monthCount += 1;
      }
    }

    // _getNotificationState();

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        appBar: LogoAppbar(
          tapLogo: () async {
            setState(() {
              todayLocation = 0;
              initListItemCount = 0;
              monthCount = 0;
            });
            scheduleListGlobal.removeRange(0, scheduleListGlobal.length - 1);

            await ref
                .read(scheduleProvider(DataUtils.getDate(fifteenDaysAgo))
                    .notifier)
                .paginate(
                  startDate: DataUtils.getDate(fifteenDaysAgo),
                )
                .then((value) {
              Future.delayed(const Duration(milliseconds: 200), () {
                todayLocation += 130 * 14 + 130 * initListItemCount;

                if (controller.hasClients) {
                  controller.jumpTo(
                    todayLocation.toDouble(),
                    // duration: const Duration(milliseconds: 300),
                    // curve: Curves.ease,
                  );
                }
              });
            });

            // controller.animateTo(
            //   todayLocation.toDouble(),
            //   duration: const Duration(milliseconds: 300),
            //   curve: Curves.ease,
            // );
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
                  // context.goNamed(MyPageScreen.routeName);

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
        body: ListView.builder(
          controller: controller,
          itemCount: schedules.data.length + 1,
          itemBuilder: <WorkoutScheduleModel>(context, index) {
            if (index == schedules.data!.length) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(color: POINT_COLOR),
                ),
              );
            }

            final model = schedules.data![index].schedule;

            if (model!.isEmpty) {
              return Column(
                children: [
                  if (schedules.data![index].startDate.day == 1)
                    Container(
                      height: 34,
                      color: DARK_GRAY_COLOR,
                      child: Center(
                        child: Text(
                          DateFormat('yyyy년 M월')
                              .format(schedules.data![index].startDate),
                          style: h3Headline.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  WorkoutScheduleCard(
                    date: schedules.data![index].startDate,
                    selected: false,
                    isComplete: null,
                  ),
                ],
              );
            }

            if (model.isNotEmpty) {
              return Column(
                children: [
                  if (schedules.data![index].startDate.day == 1)
                    Container(
                      height: 34,
                      color: DARK_GRAY_COLOR,
                      child: Center(
                        child: Text(
                          DateFormat('yyyy년 M월')
                              .format(schedules.data![index].startDate),
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
                              for (var e in schedules.data!) {
                                for (var element in e.schedule!) {
                                  element.selected = false;
                                }
                              }
                              model![seq].selected = true;
                            },
                          );
                        },
                        child: e is Workout
                            ? WorkoutScheduleCard.fromWorkoutModel(
                                model: e,
                                date: schedules.data![index].startDate,
                                isDateVisible: seq == 0 ? true : false,
                                onNotifyParent: _onChildEvent,
                              )
                            : ReservationScheduleCard.fromReservationModel(
                                date: schedules.data![index].startDate,
                                isDateVisible: seq == 0 ? true : false,
                                model: e as Reservation,
                              ), //여기에 reservationCard 추가
                      );
                    },
                  ).toList()
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
