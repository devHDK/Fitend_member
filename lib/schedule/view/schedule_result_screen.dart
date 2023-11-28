import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:fitend_member/workout/model/workout_result_model.dart';
import 'package:fitend_member/workout/provider/workout_result_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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

    getResults();
  }

  void getResults() async {
    final workoutResult =
        ref.read(workoutResultProvider(widget.workoutScheduleId));

    if (workoutResult is! WorkoutResultModel) {
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

    var resultModel = state as WorkoutResultModel;

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: Container(
                  color: Pallete.background,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 270,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 27,
                          children: [],
                        ),
                      ),
                      const SizedBox(
                        height: 23,
                      ),
                      _renderTitle('오늘의 결과 🎯'),
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
                        height: 20,
                      ),
                      _renderTitle('최근 운동일 🗓️'),
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

  Column _renderTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
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
          '  ∙  ${_strengthResults[state.strengthIndex - 1]}',
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
}
