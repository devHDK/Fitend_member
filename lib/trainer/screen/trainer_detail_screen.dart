import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/trainer/model/trainer_detail_model.dart';
import 'package:fitend_member/trainer/provider/trainer_detail_provider.dart';
import 'package:fitend_member/user/provider/user_register_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TrainerDetailScreen extends ConsumerStatefulWidget {
  const TrainerDetailScreen(
      {super.key, required this.phone, required this.trainerId});

  final String phone;
  final int trainerId;

  @override
  ConsumerState<TrainerDetailScreen> createState() => _TrainerListScreenState();
}

class _TrainerListScreenState extends ConsumerState<TrainerDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (ref.read(trainerDetailProvider(widget.trainerId))
          is TrainerDetailModelError) {
        ref
            .read(trainerDetailProvider(widget.trainerId).notifier)
            .getTrainerDetail(widget.trainerId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trainerDetailProvider(widget.trainerId));
    final registerModel = ref.watch(userRegisterProvider(widget.phone));

    if (state is TrainerDetailModelLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Pallete.point,
        ),
      );
    }

    if (state is TrainerDetailModelError) {
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

    final trainerModel = state as TrainerDetailModel;

    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Pallete.background,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(Icons.arrow_back),
          ),
        ),
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [],
      ),
      floatingActionButton: TextButton(
        onPressed: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            height: 44,
            width: 100.w,
            decoration: BoxDecoration(
              color: Pallete.point,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                ' 코치와 함께하기',
                style: h6Headline.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
