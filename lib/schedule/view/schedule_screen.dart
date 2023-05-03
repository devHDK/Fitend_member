import 'package:fitend_member/common/component/logo_appbar.dart';
import 'package:fitend_member/common/component/schedule_card.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  static String get routeName => 'schedule_main';

  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: LogoAppbar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Padding(
              padding: EdgeInsets.only(right: 28),
              child: Icon(
                Icons.person_outline_sharp,
                size: 30,
              ),
            ),
          )
        ],
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          return ScheduleCard(
            date: DateTime.now(),
            title: '이것',
            result: '저것',
            type: '이것',
            selected: true,
          );
        },
        separatorBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 28),
            child: Divider(
              color: DARK_GRAY_COLOR,
              height: 1,
            ),
          );
        },
        itemCount: 10,
      ),
    );
  }
}
