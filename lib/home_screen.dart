import 'dart:io';

import 'package:camera/camera.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/provider/avail_camera_provider.dart';
import 'package:fitend_member/notifications/model/notificatiion_main_state_model.dart';
import 'package:fitend_member/notifications/provider/notification_home_screen_provider.dart';
import 'package:fitend_member/schedule/view/schedule_screen.dart';
import 'package:fitend_member/thread/view/thread_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static String get routeName => 'home_screen';
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  final children = [const ScheduleScreen(), const ThreadScreen()];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.watch(notificationHomeProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    NotificationMainModel? model;

    final notificationState = ref.watch(notificationHomeProvider);
    if (notificationState is NotificationMainModel) model = notificationState;

    AsyncValue<List<CameraDescription>> camerasAsyncValue =
        ref.watch(availableCamerasProvider);

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      bottomNavigationBar: BottomAppBar(
        color: BACKGROUND_COLOR,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(
              height: 1,
              color: GRAY_COLOR,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () => setState(() {
                    _currentIndex = 0;
                  }),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 10,
                    ),
                    child: SvgPicture.asset(
                      _currentIndex == 0
                          ? 'asset/img/icon_schedule_active.svg'
                          : 'asset/img/icon_schedule.svg',
                    ),
                  ),
                ),
                const VerticalDivider(
                  color: GRAY_COLOR,
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
                      label: Text(
                        model is NotificationMainModel
                            ? model.threadBadgeCount.toString()
                            : 0.toString(),
                      ),
                      isLabelVisible:
                          model != null && model.threadBadgeCount != 0,
                      child: SvgPicture.asset(
                        _currentIndex == 1
                            ? 'asset/img/icon_message_active.svg'
                            : 'asset/img/icon_message.svg',
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
      body: children[_currentIndex],
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
