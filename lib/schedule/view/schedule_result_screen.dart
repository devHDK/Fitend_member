import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/provider/hive_workout_feedback_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/schedule/model/workout_feedback_record_model.dart';
import 'package:fitend_member/workout/model/workout_record_simple_model.dart';
import 'package:fitend_member/workout/model/workout_result_model.dart';
import 'package:fitend_member/workout/provider/workout_result_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

const List<String> strengthResults = [
  '매우쉬움 😁',
  '쉬움 😀',
  '보통 😊',
  '힘듦 😓',
  '매우힘듦 🥵'
];

const List<String> issuedResults = [
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
  WorkoutFeedbackRecordModel? feedback;
  List<WorkoutRecord> workoutResults = [];
  List<WorkoutRecordSimple> workoutRecords = [];
  bool initial = true;
  bool hasLocal = false;
  DateTime startDate = DateTime(
    DateTime.now().year,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initial && !hasLocal) {
        getResults();

        initial = false;
      }
    });
  }

  void getResults() async {
    final provider =
        ref.read(workoutResultProvider(widget.workoutScheduleId).notifier);

    await provider.getWorkoutResults(
        workoutScheduleId: widget.workoutScheduleId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pstate = ref.watch(workoutResultProvider(widget.workoutScheduleId));
    final workoutFeedbackBox = ref.watch(hiveWorkoutFeedbackProvider);
    final workoutRecordBox = ref.watch(hiveWorkoutRecordSimpleProvider);

    workoutFeedbackBox.whenData(
      (value) {
        feedback = value.get(widget.workoutScheduleId);
      },
    );

    if (feedback == null || widget.exercises != null) {
      if (pstate is WorkoutResultModelLoading) {
        return const Scaffold(
          backgroundColor: Pallete.background,
          body: Center(
            child: CircularProgressIndicator(
              color: Pallete.point,
            ),
          ),
        );
      }

      if (pstate is WorkoutResultModelError) {
        return Scaffold(
          backgroundColor: Pallete.background,
          body: Center(
            child: DialogWidgets.errorDialog(
              message: pstate.message,
              confirmText: '확인',
              confirmOnTap: () => context.pop(),
            ),
          ),
        );
      }

      workoutRecordBox.whenData(
        (value) {
          workoutRecords = [];

          for (var i = 0; i < widget.exercises!.length; i++) {
            final record = value.get(widget.exercises![i].workoutPlanId);
            if (record != null && record is WorkoutRecordSimple) {
              workoutRecords.add(record);
            } else {
              hasLocal = false;
            }
          }
        },
      );

      for (var i = 0; i < workoutResults.length; i++) {
        for (var j = 0; j < workoutResults[i].setInfo.length; j++) {
          workoutResults[i].setInfo[j] = workoutRecords[i].setInfo[j];
        }
      }

      if (pstate is WorkoutResultModel) {
        startDate = DateTime.parse(pstate.startDate);
        pstate.copyWith(
          startDate:
              '${DateFormat('M월 dd일').format(DateTime.parse(pstate.startDate))} ${weekday[DateTime.parse(pstate.startDate).weekday - 1]}요일',
        );
      }
    }

    if (pstate is WorkoutResultModelLoading) {
      return const Scaffold(
        backgroundColor: Pallete.background,
        body: Center(
          child: CircularProgressIndicator(
            color: Pallete.point,
          ),
        ),
      );
    }

    if (pstate is WorkoutResultModelError) {
      // context.pop();
      DialogWidgets.showToast('운동 평가를 완료해주세요');
      context.pop();
      return const Scaffold(
        backgroundColor: Pallete.background,
      );
    }

    var state = pstate as WorkoutResultModel;

    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        backgroundColor: Pallete.background,
        title: Text(
          '${DateFormat('M월 d일').format(DateTime.parse(state.startDate))} ${weekday[DateTime.parse(state.startDate).weekday - 1]}요일',
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Pallete.darkGray,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _renderTitle(),
                    _renderStrengthResult(state),
                    const SizedBox(
                      height: 24,
                    ),
                    if (state.issueIndexes != null &&
                        state.issueIndexes!.isNotEmpty)
                      _renderIssueResult(state),
                    if (state.contents != null && state.contents!.isNotEmpty)
                      _renderContentsResult(state),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 24,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '오늘의 운동결과 🎯',
                        style: h4Headline.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      if (state.scheduleRecords != null &&
                          state.scheduleRecords!.workoutDuration != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SvgPicture.asset(SVGConstants.timer),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              DataUtils.getTimeStringHour(
                                  state.scheduleRecords!.workoutDuration!),
                              style: s2SubTitle.copyWith(
                                color: Colors.white,
                                height: 1.3,
                              ),
                            )
                          ],
                        )
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Divider(
                    color: Pallete.gray,
                    height: 1,
                  )
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            sliver: SliverList.separated(
              itemCount: state.workoutRecords.length,
              itemBuilder: (context, index) {
                final model = state.workoutRecords[index];

                return _renderExerciseResult(model, index, state);
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  color: Pallete.gray,
                  height: 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Column _renderTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('오늘의 운동평가 📝',
            style: h4Headline.copyWith(
              color: Colors.white,
            )),
        const SizedBox(
          height: 12,
        ),
        const Divider(
          color: Pallete.gray,
          height: 1,
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Column _renderStrengthResult(WorkoutResultModel state) {
    return Column(
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
          '  ∙  ${strengthResults[state.strengthIndex - 1]}',
          style: s2SubTitle.copyWith(
            color: Pallete.lightGray,
          ),
        ),
      ],
    );
  }

  Column _renderIssueResult(WorkoutResultModel state) {
    return Column(
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
                  '  ∙  ${issuedResults[e - 1]}',
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
        const SizedBox(
          height: 24,
        )
      ],
    );
  }

  Column _renderContentsResult(WorkoutResultModel state) {
    return Column(
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
    );
  }

  Column _renderExerciseResult(
      WorkoutRecord model, int index, WorkoutResultModel state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20,
        ),
        Text(
          model.exerciseName,
          style: h5Headline.copyWith(
            color: Colors.white,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          model.targetMuscles[0],
          style: s2SubTitle.copyWith(
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        ...model.setInfo.mapIndexed((seq, e) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${e.index} SET',
                  style: s2SubTitle.copyWith(
                    color: Colors.white,
                  ),
                ),
                if (model.trackingFieldId == 1)
                  Text(
                    e.weight != null ? '${e.weight}kg' : '-',
                    style: s2SubTitle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                if (model.trackingFieldId == 1 || model.trackingFieldId == 2)
                  Text(
                    e.reps != null ? '${e.reps}회' : '-',
                    style: s2SubTitle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                if (model.trackingFieldId == 3 || model.trackingFieldId == 4)
                  Text(
                    e.seconds != null
                        ? DataUtils.getTimeStringHour(e.seconds!)
                        : '-',
                    style: s2SubTitle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                Text(
                  e.reps != null || e.seconds != null || e.weight != null
                      ? '✅'
                      : '❌',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(
          height: 16,
        ),
        if (index == state.workoutRecords.length - 1)
          const Column(
            children: [
              Divider(
                color: Pallete.gray,
                height: 1,
              ),
              SizedBox(
                height: 40,
              ),
            ],
          )
      ],
    );
  }
}
