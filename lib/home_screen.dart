import 'dart:io';

import 'package:fitend_member/common/component/logo_appbar.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/provider/avail_camera_provider.dart';
import 'package:fitend_member/notifications/model/notificatiion_main_state_model.dart';
import 'package:fitend_member/notifications/provider/notification_home_screen_provider.dart';
import 'package:fitend_member/notifications/view/notification_screen.dart';
import 'package:fitend_member/schedule/view/schedule_screen.dart';
import 'package:fitend_member/thread/view/thread_screen.dart';
import 'package:fitend_member/trainer/view/trainer_list_screen.dart';
import 'package:fitend_member/user/view/mypage_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static String get routeName => 'home_screen';
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final GlobalKey<ScheduleScreenState> scheduleScreenKey = GlobalKey();
  final GlobalKey<ThreadScreenState> threadScreenKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.watch(notificationHomeProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationHomeProvider);

    if (notificationState is NotificationMainModelLoading) {
      return const Scaffold(
        backgroundColor: Pallete.background,
        body: Center(
          child: CircularProgressIndicator(
            color: Pallete.point,
          ),
        ),
      );
    }

    final notificationHomeModel = notificationState as NotificationMainModel;

    // AsyncValue<List<CameraDescription>> camerasAsyncValue =
    ref.watch(availableCamerasProvider);

    return WillPopScope(
      onWillPop: () async => false,
      child: ScrollsToTop(
        onScrollsToTop: (event) async {
          if (_currentIndex == 0 && scheduleScreenKey.currentState != null) {
            scheduleScreenKey.currentState!.tapLogo();
          } else if (_currentIndex == 1 &&
              threadScreenKey.currentState != null) {
            threadScreenKey.currentState!.tapTop();
          }
        },
        child: Scaffold(
          backgroundColor: Pallete.background,
          appBar: LogoAppbar(
            title: _currentIndex == 0 ? 'P L A N' : 'T H R E A D S',
            tapLogo: () {
              if (_currentIndex == 0 &&
                  scheduleScreenKey.currentState != null) {
                scheduleScreenKey.currentState!.tapLogo();
              } else if (_currentIndex == 1 &&
                  threadScreenKey.currentState != null) {
                threadScreenKey.currentState!.tapLogo();
              }
            },
            actions: [
              InkWell(
                hoverColor: Colors.transparent,
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) =>
                          const TrainerListScreen(phone: '01089811082'),
                    ),
                  );
                },
                child: !notificationHomeModel.isConfirmed
                    ? SvgPicture.asset(SVGConstants.alarmOn)
                    : SvgPicture.asset(SVGConstants.alarmOff),
              ),
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
                  child: SvgPicture.asset(SVGConstants.mypage),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            color: Pallete.background,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(
                  height: 1,
                  color: Pallete.gray,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        if (mounted) {
                          setState(() {
                            _currentIndex = 0;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 10,
                        ),
                        child: SvgPicture.asset(
                          _currentIndex == 0
                              ? SVGConstants.scheduleActive
                              : SVGConstants.schedule,
                        ),
                      ),
                    ),
                    const VerticalDivider(
                      color: Pallete.gray,
                      width: 1, // specify the width of the divider
                    ),
                    InkWell(
                      onTap: () {
                        if (mounted) {
                          ref
                              .read(notificationHomeProvider.notifier)
                              .updateBageCount(0);
                          setState(() {
                            _currentIndex = 1;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 10,
                        ),
                        child: Badge(
                          label: Text(notificationHomeModel.threadBadgeCount
                              .toString()),
                          isLabelVisible:
                              notificationHomeModel.threadBadgeCount != 0,
                          child: SvgPicture.asset(
                            _currentIndex == 1
                                ? SVGConstants.messageActive
                                : SVGConstants.message,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (Platform.isAndroid)
                  const SizedBox(
                    height: 10,
                  ),
              ],
            ),
          ),
          body: _currentIndex == 0
              ? ScheduleScreen(
                  key: scheduleScreenKey,
                )
              : ThreadScreen(
                  key: threadScreenKey,
                ),
        ),
      ),
    );
  }

  void onTabTapped(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }
}
