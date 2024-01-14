import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/meeting/model/meeting_date_model.dart';
import 'package:fitend_member/meeting/provider/meeting_date_provider.dart';
import 'package:fitend_member/trainer/model/get_trainer_schedule_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MeetingDateScreen extends ConsumerStatefulWidget {
  static String get routeName => 'meetingDate';
  const MeetingDateScreen({
    super.key,
    required this.trainerId,
  });

  final int trainerId;

  @override
  ConsumerState<MeetingDateScreen> createState() => _MeetingDateScreenState();
}

class _MeetingDateScreenState extends ConsumerState<MeetingDateScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetch();
    });
  }

  void fetch() async {
    if (mounted) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final endDate = today.add(const Duration(days: 5));

      await ref
          .read(meetingDateProvider(widget.trainerId).notifier)
          .getTrainerSchedules(widget.trainerId,
              GetTrainerScheduleModel(startDate: today, endDate: endDate));
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainerScheduleState =
        ref.watch(meetingDateProvider(widget.trainerId));

    if (trainerScheduleState is MeetingDateModelLoading) {
      return const Scaffold(
        backgroundColor: Pallete.background,
        body: Center(
          child: CircularProgressIndicator(
            color: Pallete.point,
          ),
        ),
      );
    }

    if (trainerScheduleState is MeetingDateModelError) {
      return Scaffold(
        backgroundColor: Pallete.background,
        body: DialogWidgets.oneButtonDialog(
          message: trainerScheduleState.message,
          confirmText: '확인',
          confirmOnTap: () => context.pop(),
        ),
      );
    }

    final scheduleModel = trainerScheduleState as MeetingDateModel;

    print(scheduleModel.data.first.toJson());

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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const SizedBox(
              height: 24,
            ),
            Text(
              '가능하신 일정을 선택해주세요',
              style: h3Headline.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () {},
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 28),
        ),
      ),
    );
  }
}
