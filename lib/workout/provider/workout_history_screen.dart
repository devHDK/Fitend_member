import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/workout/model/workout_history_model.dart';
import 'package:fitend_member/workout/provider/workout_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  void listener() {
    if (mounted) {
      final provider =
          ref.read(workoutHistoryProvider(widget.workoutPlanId).notifier);

      if (controller.offset > controller.position.maxScrollExtent - 100 &&
          workoutHistory.data.length < workoutHistory.total) {
        //스크롤을 아래로 내렸을때
        provider.paginate(start: workoutHistory.data.length, fetchMore: true);
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
          child: DialogWidgets.errorDialog(
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
      body: state.total == 0
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
              child: ListView.builder(
                controller: controller,
                itemCount: state.data.length + 1,
                itemBuilder: (context, index) {
                  if (index == workoutHistory.data.length &&
                      state.data.length < state.total) {
                    return const SizedBox(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(color: Pallete.point),
                      ),
                    );
                  }

                  if (index == workoutHistory.data.length &&
                      state.data.length == state.total) {
                    return const SizedBox();
                  }

                  return const SizedBox(
                    height: 50,
                  );
                },
              ),
            ),
    );
  }
}
