import 'package:collection/collection.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/workout/model/workout_history_model.dart';
import 'package:fitend_member/workout/provider/workout_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  final int workoutPlanId;

  const WorkoutHistoryScreen({
    super.key,
    required this.workoutPlanId,
  });

  @override
  ConsumerState<WorkoutHistoryScreen> createState() =>
      _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> {
  final ScrollController controller = ScrollController();
  late WorkoutHistoryModel workoutHistory;

  @override
  void initState() {
    super.initState();

    controller.addListener(listener);
  }

  @override
  void dispose() {
    super.dispose();

    controller.removeListener(listener);
  }

  void listener() async {
    if (mounted) {
      final provider =
          ref.read(workoutHistoryProvider(widget.workoutPlanId).notifier);

      if (controller.offset > controller.position.maxScrollExtent - 100 &&
          workoutHistory.data.length < workoutHistory.total) {
        //스크롤을 아래로 내렸을때
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          await provider.paginate(
              start: workoutHistory.data.length, fetchMore: true);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutHistoryProvider(widget.workoutPlanId));

    if (state is WorkoutHistoryModelLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Pallete.point,
        ),
      );
    }

    if (state is WorkoutHistoryModelError) {
      return Scaffold(
        backgroundColor: Pallete.background,
        body: Center(
          child: DialogWidgets.oneButtonDialog(
            message: state.message,
            confirmText: '확인',
            confirmOnTap: () => context.pop(),
          ),
        ),
      );
    }

    workoutHistory = state as WorkoutHistoryModel;

    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Pallete.background,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(Icons.arrow_back),
          ),
        ),
        title: Text(
          '히스토리',
          style: h4Headline.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      body: workoutHistory.total == 0
          ? Center(
              child: Text(
                '아직 진행된 운동기록이 없어요 :(',
                style: s1SubTitle.copyWith(
                  color: Pallete.gray,
                ),
              ),
            )
          : RefreshIndicator(
              backgroundColor: Pallete.background,
              color: Pallete.point,
              semanticsLabel: '새로고침',
              onRefresh: () async {
                await ref
                    .read(workoutHistoryProvider(widget.workoutPlanId).notifier)
                    .paginate();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: CustomScrollView(
                  controller: controller,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workoutHistory.data.first.exerciseName,
                            style: h4Headline.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    SliverList.builder(
                      itemCount: workoutHistory.data.length + 1,
                      itemBuilder: (context, index) {
                        if (index == workoutHistory.data.length &&
                            state.data.length < state.total) {
                          return const SizedBox(
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Pallete.point,
                              ),
                            ),
                          );
                        }

                        if (workoutHistory.data.length == index &&
                            workoutHistory.data.length == state.total) {
                          return const SizedBox();
                        }

                        bool isComplete = false;
                        int setInfoCount = 0;

                        for (var set in workoutHistory.data[index].setInfo) {
                          if (set.reps != null ||
                              set.weight != null ||
                              set.seconds != null) {
                            isComplete = true;
                            setInfoCount++;
                          }
                        }

                        if (!isComplete) return const SizedBox();

                        return SizedBox(
                          width: 100.w,
                          height: 34 * setInfoCount + 67,
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  const SizedBox(
                                    width: 13,
                                    child: VerticalDivider(
                                      width: 1,
                                      color: Pallete.gray,
                                    ),
                                  ),
                                  Container(
                                    width: 13,
                                    height: 13,
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Pallete.lightGray),
                                      borderRadius: BorderRadius.circular(7),
                                      color: Pallete.gray,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 14,
                              ),
                              SizedBox(
                                width: 100.w - 83,
                                child: Column(
                                  children: [
                                    _renderDate(index),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    ...workoutHistory.data[index].setInfo
                                        .where((set) => (set.reps != null ||
                                            set.seconds != null ||
                                            set.weight != null))
                                        .toList()
                                        .mapIndexed(
                                          (i, e) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  '${i + 1} Set',
                                                  style: s1SubTitle.copyWith(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                if (e.weight != null)
                                                  Text(
                                                    '${e.weight}kg',
                                                    style: s1SubTitle.copyWith(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                if (e.reps != null)
                                                  Text(
                                                    '${e.reps}회',
                                                    style: s1SubTitle.copyWith(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                if (e.seconds != null)
                                                  Text(
                                                    DataUtils.getTimeStringHour(
                                                        e.seconds!),
                                                    style: s1SubTitle.copyWith(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    const SizedBox(
                                      height: 30,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Row _renderDate(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('yyyy. MM. dd').format(
            DateTime.parse(
              workoutHistory.data[index].startDate,
            ),
          ),
          style: s2SubTitle.copyWith(
            color: Pallete.lightGray,
            height: 1,
          ),
        ),
        Text(
          DataUtils.getDateFromDateTime(
                      DateTime.parse(workoutHistory.data[index].startDate)
                          .toUtc()
                          .toLocal()) ==
                  DataUtils.getDateFromDateTime(DateTime.now())
              ? '오늘'
              : DataUtils.getDateFromDateTime(
                          DateTime.parse(workoutHistory.data[index].startDate)
                              .toUtc()
                              .toLocal()) ==
                      DataUtils.getDateFromDateTime(
                          DateTime.now().subtract(const Duration(days: 1)))
                  ? '어제'
                  : DataUtils.getElapsedTimeStringFromNow(
                      DateTime.parse(workoutHistory.data[index].startDate),
                    ),
          style: s2SubTitle.copyWith(
            color: Pallete.lightGray,
            height: 1,
          ),
        ),
      ],
    );
  }
}
