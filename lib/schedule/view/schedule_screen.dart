import 'package:fitend_member/common/component/logo_appbar.dart';
import 'package:fitend_member/common/component/schedule_card.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/schedule/model/workout_schedule_model.dart';
import 'package:fitend_member/schedule/provider/workout_schedule_provider.dart';
import 'package:fitend_member/user/provider/user_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  static String get routeName => 'schedule_main';
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  DateTime today = DateTime.now();
  DateTime yesterDay = DateTime.now().subtract(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutScheduleProvider(yesterDay));

    if (state is WorkoutScheduleModelLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final scheduleList = state as WorkoutScheduleModel;
    final workoutData = scheduleList.data as List<WorkoutData>;

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
      body: ListView.builder(
        itemBuilder: <WorkoutScheduleModel>(context, index) {
          final model = workoutData[index].workouts;

          if (model!.isEmpty) {
            return ScheduleCard(
              date: workoutData[index].startDate,
              selected: false,
              isComplete: null,
            );
          }

          if (model.isNotEmpty) {
            return Column(
              children: model.mapIndexed(
                (seq, e) {
                  return InkWell(
                    onTap: () {
                      if (model[seq].selected!) {
                        return;
                      }

                      setState(
                        () {
                          for (var e in workoutData) {
                            for (var element in e.workouts!) {
                              element.selected = false;
                            }
                          }

                          model![seq].selected = true;
                        },
                      );
                    },
                    child: ScheduleCard.fromModel(
                      model: e,
                      date: workoutData[index].startDate,
                      isDateVisibel: seq == 0 ? true : false,
                    ),
                  );
                },
              ).toList(),
            );
          }
        },
        itemCount: workoutData.length,
      ),
    );
  }
}
