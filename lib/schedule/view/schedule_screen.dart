import 'package:fitend_member/common/component/error_dialog.dart';
import 'package:fitend_member/common/component/logo_appbar.dart';
import 'package:fitend_member/common/component/schedule_card.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
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
  final ScrollController controller = ScrollController();
  StateNotifierProviderFamily<WorkoutScheduleStateNotifier,
      WorkoutScheduleModelBase, DateTime> provider = workoutScheduleProvider;

  DateTime today = DateTime.now();
  DateTime yesterDay = DateTime.now().subtract(const Duration(days: 1));
  DateTime minDate = DateTime(DateTime.now().year);
  DateTime maxDate = DateTime(DateTime.now().year);

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void dispose() {
    controller.removeListener(listener);
    controller.dispose();
    super.dispose();
  }

  void listener() {
    print(controller.offset);

    if (controller.offset < controller.position.minScrollExtent - 90) {
      //스크롤을 맨위로 올렸을때
      ref
          .read(provider(minDate).notifier)
          .paginate(startDate: minDate, fetchMore: true, isUpScrolling: true);
    }

    if (controller.offset > controller.position.maxScrollExtent + 90) {
      //스크롤을 아래로 내렸을때
      ref
          .read(provider(maxDate).notifier)
          .paginate(startDate: maxDate, fetchMore: true, isDownScrolling: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(provider(DataUtils.getDate(yesterDay)));

    if (state is WorkoutScheduleModelLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is WorkoutScheduleModelError) {
      return ErrorDialog(error: state.message);
    }

    final scheduleList = state as WorkoutScheduleModel;
    final workoutData = scheduleList.data as List<WorkoutData>;

    minDate = workoutData[0].startDate.subtract(const Duration(days: 32));
    maxDate = workoutData[workoutData.length - 1].startDate;

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
        controller: controller,
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
                      isDateVisible: seq == 0 ? true : false,
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
