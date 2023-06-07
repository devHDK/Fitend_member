import 'package:fitend_member/common/component/dialog_tools.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/provider/hive_workout_edit_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_feedback_provider.dart';
import 'package:fitend_member/common/provider/hive_workout_record_provider.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/schedule/model/workout_feedback_record_model.dart';
import 'package:fitend_member/workout/model/workout_record_model.dart';
import 'package:fitend_member/workout/model/workout_result_model.dart';
import 'package:fitend_member/workout/provider/workout_records_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final List<Exercise> exercises;

  const ScheduleResultScreen({
    super.key,
    required this.workoutScheduleId,
    required this.exercises,
  });

  @override
  ConsumerState<ScheduleResultScreen> createState() =>
      _ScheduleResultScreenState();
}

class _ScheduleResultScreenState extends ConsumerState<ScheduleResultScreen> {
  WorkoutFeedbackRecordModel? feedback;
  List<WorkoutRecordResult> workoutResults = [];
  List<WorkoutRecordModel> workoutRecords = [];
  bool initial = true;
  bool hasLocalData = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPersistentFrameCallback((_) {
      if (initial && !hasLocalData) {
        getResults();

        initial = false;
      }
    });
  }

  void getResults() async {
    final provider = ref.read(workoutRecordsProvider.notifier);

    await provider.getWorkoutResults(
        workoutScheduleId: widget.workoutScheduleId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutFeedbackBox = ref.watch(hiveWorkoutFeedbackProvider);
    final workoutEditBox = ref.watch(hiveWorkoutEditProvider);
    final workoutRecordBox = ref.watch(hiveWorkoutRecordProvider);

    final pstate = ref.watch(workoutRecordsProvider);

    late WorkoutResultModel state;

    workoutFeedbackBox.whenData(
      (value) {
        feedback = value.get(widget.workoutScheduleId);
      },
    );

    workoutEditBox.whenData(
      (value) {
        for (var i = 0; i < widget.exercises.length; i++) {
          final record = value.get(widget.exercises[i].workoutPlanId);
          if (record != null && record is WorkoutRecordResult) {
            workoutResults.add(record);
          }
        }
      },
    );

    workoutRecordBox.whenData(
      (value) {
        for (var i = 0; i < widget.exercises.length; i++) {
          final record = value.get(widget.exercises[i].workoutPlanId);
          if (record != null && record is WorkoutRecordModel) {
            workoutRecords.add(record);
          }
        }
      },
    );

    if (workoutRecords.length < widget.exercises.length ||
        workoutResults.length < widget.exercises.length ||
        feedback == null ||
        feedback!.strengthIndex == null) {
      //local 데이터가 없을때!

      if (pstate is WorkoutResultModelLoading) {
        return const Scaffold(
          backgroundColor: BACKGROUND_COLOR,
          body: Center(
            child: CircularProgressIndicator(
              color: POINT_COLOR,
            ),
          ),
        );
      }

      if (pstate is WorkoutResultModelError) {
        showDialog(
          context: context,
          builder: (context) => DialogTools.errorDialog(
            message: pstate.message,
            confirmText: '확인',
            confirmOnTap: () => context.pop(),
          ),
        );
      }

      if (pstate is WorkoutResultModel) {
        state = pstate;
        state = state.copyWith(
            startDate:
                '${DateFormat('M월 dd일').format(DateTime.parse(state.startDate))} ${weekday[DateTime.parse(state.startDate).weekday]}요일');
      }
    } else {
      for (var i = 0; i < workoutResults.length; i++) {
        for (var j = 0; j < workoutResults[i].setInfo.length; j++) {
          workoutResults[i].setInfo[j] = workoutRecords[i].setInfo[j];
        }
      }

      state = WorkoutResultModel(
        startDate:
            '${DateFormat('M월 dd일').format(feedback!.startDate)} ${weekday[feedback!.startDate.weekday]}요일',
        strengthIndex: feedback!.strengthIndex!,
        issueIndexes: feedback!.issueIndexes!,
        contents: feedback!.contents!,
        workoutRecords: workoutResults,
      );
      hasLocalData = true;
    }

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: BACKGROUND_COLOR,
        title: Text(
          state.startDate,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () => context.pop(),
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
              color: DARK_GRAY_COLOR,
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
                    if (state.issueIndexes.isNotEmpty)
                      _renderIssueResult(state),
                    if (state.contents.isNotEmpty) _renderContentsResult(state),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ),
          ),
          _renderWorkoutResultTitle(),
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
                  color: GRAY_COLOR,
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 운동평가📝',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Divider(
          color: GRAY_COLOR,
          height: 1,
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Column _renderStrengthResult(WorkoutResultModel state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '운동의 강도는 어떠셨나요? 🔥',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          '  ∙  ${strengthResults[state.strengthIndex - 1]}',
          style: const TextStyle(
            color: LIGHT_GRAY_COLOR,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Column _renderIssueResult(WorkoutResultModel state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '특이사항이 있다면 알려주세요 🙏',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        ...state.issueIndexes.map(
          (e) {
            return Column(
              children: [
                Text(
                  '  ∙  ${issuedResults[e - 1]}',
                  style: const TextStyle(
                    color: LIGHT_GRAY_COLOR,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(
                  height: 8,
                )
              ],
            );
          },
        ).toList(),
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
        const Text(
          '코치님께 전하고 싶은 내용을 적어주세요 📤',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          state.contents,
          style: const TextStyle(
            color: LIGHT_GRAY_COLOR,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  SliverToBoxAdapter _renderWorkoutResultTitle() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
            ),
            Text(
              '오늘의 운동결과🎯',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Divider(
              color: GRAY_COLOR,
              height: 1,
            )
          ],
        ),
      ),
    );
  }

  Column _renderExerciseResult(
      WorkoutRecordResult model, int index, WorkoutResultModel state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20,
        ),
        Text(
          model.exerciseName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          model.targetMuscles[0],
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w400,
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (model.trackingFieldId == 1)
                  Text(
                    e.weight != null ? '${e.weight}kg' : '-',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                if (model.trackingFieldId == 1 || model.trackingFieldId == 2)
                  Text(
                    e.reps != null ? '${e.reps}kg' : '-',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                if (model.trackingFieldId == 3 || model.trackingFieldId == 4)
                  Text(
                    e.seconds != null
                        ? '${(e.seconds! / 3600).floor().toString().padLeft(2, '0')} : ${(e.seconds! / 60).floor().toString().padLeft(2, '0')} : ${(e.seconds! % 60).toString().padLeft(2, '0')}  '
                        : '-',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
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
        }).toList(),
        const SizedBox(
          height: 16,
        ),
        if (index == state.workoutRecords.length - 1)
          const Column(
            children: [
              Divider(
                color: GRAY_COLOR,
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
