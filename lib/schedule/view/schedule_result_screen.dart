import 'package:collection/collection.dart';
import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/muscle_group.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/schedule/componet/last_schedule_box.dart';
import 'package:fitend_member/workout/model/workout_result_model.dart';
import 'package:fitend_member/workout/provider/workout_result_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

const List<String> _strengthResults = [
  '매우쉬움 😁',
  '쉬움 😀',
  '보통 😊',
  '힘듦 😓',
  '매우힘듦 🥵'
];

const List<String> _issuedResults = [
  '운동 부위에 통증이 있어요',
  '운동 자세를 잘 모르겠어요',
  '운동 자극이 잘 안 느껴져요',
];

class ScheduleResultScreen extends ConsumerStatefulWidget {
  static String get routeName => 'scheduleResult';

  final int workoutScheduleId;
  final List<Exercise>? exercises;

  const ScheduleResultScreen({
    super.key,
    required this.workoutScheduleId,
    this.exercises,
  });

  @override
  ConsumerState<ScheduleResultScreen> createState() =>
      _ScheduleResultScreenState();
}

class _ScheduleResultScreenState extends ConsumerState<ScheduleResultScreen> {
  //  WorkoutResultModel state;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getResults();
    });
  }

  void getResults() async {
    if (mounted) {
      await ref
          .read(workoutResultProvider(widget.workoutScheduleId).notifier)
          .getWorkoutResults(
            workoutScheduleId: widget.workoutScheduleId,
            exercises: widget.exercises,
          );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutResultProvider(widget.workoutScheduleId));

    if (state is WorkoutResultModelLoading) {
      return const Scaffold(
        backgroundColor: Pallete.background,
        body: Center(
          child: CircularProgressIndicator(
            color: Pallete.point,
          ),
        ),
      );
    }

    if (state is WorkoutResultModelError) {
      // context.pop();
      DialogWidgets.showToast('운동 평가를 완료해주세요');
      context.pop();
      return const Scaffold(
        backgroundColor: Pallete.background,
      );
    }

    final resultModel = state as WorkoutResultModel;

    List<int> muscleIds = [];
    List<int> muscleFirstRow = [];
    List<int> muscleSecondRow = [];
    int setCount = 0;

    for (var record in resultModel.workoutRecords) {
      for (var targetMuscle in record.targetMuscles) {
        if (muscleIdMap[targetMuscle] != null) {
          muscleIds.add(muscleIdMap[targetMuscle]!);
        }
      }

      for (var info in record.setInfo) {
        if (info.reps != null || info.seconds != null || info.weight != null) {
          setCount++;
        }
      }
    }

    muscleIds = muscleIds.toSet().toList();
    muscleFirstRow =
        muscleIds.sublist(0, muscleIds.length >= 4 ? 4 : muscleIds.length);
    if (muscleIds.length > 4) {
      muscleSecondRow =
          muscleIds.sublist(4, muscleIds.length > 8 ? 8 : muscleIds.length);
    }

    final workoutIndex = resultModel.lastSchedules!.indexWhere((schedule) =>
        schedule.startDate == DateTime.parse(resultModel.startDate));

    final resultIndex = resultModel.lastSchedules![workoutIndex].workouts
        ?.indexWhere(
            (workout) => workout.workoutScheduleId == widget.workoutScheduleId);

    final resultWorkout =
        resultModel.lastSchedules![workoutIndex].workouts?[resultIndex!];

    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        backgroundColor: Pallete.background,
        title: Text(
          '${DateFormat('M월 d일').format(DateTime.parse(resultModel.startDate))} ${weekday[DateTime.parse(resultModel.startDate).weekday - 1]}요일',
          style: h4Headline,
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () {
                context.pop();
              },
              icon: const Icon(
                Icons.close_sharp,
                color: Colors.white,
                size: 36,
              ),
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        backgroundColor: Pallete.background,
        color: Pallete.point,
        semanticsLabel: '새로고침',
        onRefresh: () async {
          await ref
              .read(workoutResultProvider(widget.workoutScheduleId).notifier)
              .getWorkoutResults(
                workoutScheduleId: widget.workoutScheduleId,
                exercises: widget.exercises,
              );
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _firstRowMuscleImage(muscleFirstRow),
                    const SizedBox(
                      height: 20,
                    ),
                    if (muscleSecondRow.isNotEmpty)
                      _secondRowMuscleImage(muscleSecondRow, muscleIds),
                    Text(resultWorkout!.title,
                        style: h4Headline.copyWith(color: Colors.white)),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(resultWorkout.subTitle,
                        style: s2SubTitle.copyWith(color: Pallete.lightGray)),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                ),
                child: Container(
                  color: Pallete.background,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _renderTitle('오늘의 결과 🎯'),
                      GestureDetector(
                        onTap: () {},
                        child: _borderContainer(
                          icon: SVGConstants.barbell,
                          title: '운동세트 수',
                          tail: Row(
                            children: [
                              Text(
                                '$setCount set',
                                style: h5Headline.copyWith(
                                    color: Pallete.lightGray, height: 1),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              const Icon(
                                Icons.navigate_next_outlined,
                                color: Pallete.lightGray,
                              )
                            ],
                          ),
                        ),
                      ),
                      if (resultModel.scheduleRecords != null &&
                          resultModel.scheduleRecords!.workoutDuration != null)
                        _borderContainer(
                          icon: SVGConstants.timer,
                          title: '총 운동시간',
                          tail: Text(
                            DataUtils.getTimeStringHour(
                              resultModel.scheduleRecords!.workoutDuration!,
                            ),
                            style: h5Headline.copyWith(
                                color: Pallete.lightGray, height: 1),
                          ),
                        ),
                      const SizedBox(
                        height: 30,
                      ),
                      _renderTitle('오늘의 평가 📝'),
                      _renderStrengthResult(resultModel),
                      const SizedBox(
                        height: 24,
                      ),
                      if (resultModel.issueIndexes != null &&
                          resultModel.issueIndexes!.isNotEmpty)
                        _renderIssueResult(resultModel),
                      if (resultModel.contents != null &&
                          resultModel.contents!.isNotEmpty)
                        _renderContentsResult(resultModel),
                      const SizedBox(
                        height: 40,
                      ),
                      _renderTitle('최근 운동일 🗓️'),
                      LastScheduleBox(
                        startDate: resultModel.startDate,
                        workoutSchedules: resultModel.lastSchedules!,
                      ),
                      const SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column _borderContainer(
      {required String icon, required String title, required Widget tail}) {
    return Column(
      children: [
        Container(
          width: 100.w,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Pallete.gray),
          ),
          child: Center(
            child: Row(
              children: [
                const SizedBox(
                  width: 18,
                ),
                SvgPicture.asset(
                  icon,
                  colorFilter: const ColorFilter.mode(
                      Pallete.lightGray, BlendMode.srcIn),
                  width: 24,
                ),
                const SizedBox(
                  width: 9,
                ),
                Text(
                  title,
                  style: s1SubTitle.copyWith(
                    color: Pallete.lightGray,
                    height: 1,
                  ),
                ),
                const Spacer(),
                tail,
                const SizedBox(
                  width: 18,
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }

  Wrap _secondRowMuscleImage(List<int> muscleSecondRow, List<int> muscleIds) {
    return Wrap(
      spacing: 10,
      children: [
        ...muscleSecondRow.mapIndexed((index, muscleId) {
          return Stack(
            children: [
              CustomNetworkImage(
                imageUrl:
                    '${URLConstants.s3Url}${URLConstants.muscleImageUrl}$muscleId.png',
                width: 62,
                height: 62,
                boxFit: BoxFit.cover,
              ),
              if (index == 3 && muscleIds.length > 8)
                Positioned(
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black54,
                    ),
                    child: Center(
                      child: Text(
                        '+${muscleIds.length - 8}',
                        style: h3Headline.copyWith(
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                )
            ],
          );
        }),
      ],
    );
  }

  Wrap _firstRowMuscleImage(List<int> muscleFirstRow) {
    return Wrap(
      spacing: 10,
      children: [
        ...muscleFirstRow.map(
          (muscleId) => CustomNetworkImage(
            imageUrl:
                '${URLConstants.s3Url}${URLConstants.muscleImageUrl}$muscleId.png',
            width: 62,
            height: 62,
            boxFit: BoxFit.cover,
          ),
        )
      ],
    );
  }

  Column _renderTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: h4Headline.copyWith(
              color: Colors.white,
            )),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Container _renderStrengthResult(WorkoutResultModel state) {
    return Container(
      width: 100.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Pallete.darkGray,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '운동의 강도는 어떠셨나요? 🔥',
              style: h5Headline.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              '  ∙  ${_strengthResults[state.strengthIndex - 1]}',
              style: s2SubTitle.copyWith(
                color: Pallete.lightGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _renderIssueResult(WorkoutResultModel state) {
    return Container(
      width: 100.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Pallete.darkGray,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('특이사항이 있다면 알려주세요 🙏',
                style: h5Headline.copyWith(
                  color: Colors.white,
                )),
            const SizedBox(
              height: 8,
            ),
            ...state.issueIndexes!.map(
              (e) {
                return Column(
                  children: [
                    Text(
                      '  ∙  ${_issuedResults[e - 1]}',
                      style: s2SubTitle.copyWith(
                        color: Pallete.lightGray,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Container _renderContentsResult(WorkoutResultModel state) {
    return Container(
      width: 100.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Pallete.darkGray,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '코치님께 전하고 싶은 내용을 적어주세요 📤',
              style: h5Headline.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              state.contents!,
              style: s2SubTitle.copyWith(
                color: Pallete.lightGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
