import 'package:fitend_member/common/component/logo_appbar.dart';
import 'package:fitend_member/common/component/schedule_card.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/schedule/model/workout_schedule_pagenate_params.dart';
import 'package:fitend_member/schedule/repository/workout_schedule_repository.dart';
import 'package:fitend_member/user/provider/user_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  static String get routeName => 'schedule_main';
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  DateTime today = DateTime.now();

  List<DateTime> dates = List.generate(
    14,
    (index) => DateTime.now()
        .subtract(const Duration(days: 1))
        .add(Duration(days: index)),
  );
  List<bool> listSelected = [];

  @override
  void initState() {
    super.initState();

    final state =
        ref.read(workoutScheduleRepositoryProvider).getWorkoutSchedule(
              startDate: WorkoutSchedulePagenateParams(
                startDate: today.subtract(
                  const Duration(days: 5),
                ),
              ),
            );
    print(state);

    listSelected = List.generate(
      14,
      (index) {
        return dates[index].year == today.year &&
            dates[index].month == today.month &&
            dates[index].day == today.day;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: LogoAppbar(
        actions: [
          IconButton(
            onPressed: () {
              ref.read(userMeProvider.notifier).logout();
            },
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
          return InkWell(
            onTap: () {
              setState(() {
                final newListSelected = listSelected.map((e) => false).toList();

                listSelected = newListSelected;

                if (listSelected[index]) return;
                listSelected[index] = !listSelected[index];
              });
            },
            child: ScheduleCard(
              date: dates[index],
              title: '자신감이 넘치는 둔근 만들기🔥',
              subTitle: '스트렝스 훈련',
              result: '예스',
              type: '이것',
              selected: listSelected[index],
            ),
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
        itemCount: dates.length,
      ),
    );
  }
}
