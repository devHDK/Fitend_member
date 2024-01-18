import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/trainer/model/trainer_list_model.dart';
import 'package:fitend_member/trainer/provider/trainer_list_provider.dart';
import 'package:fitend_member/trainer/screen/trainer_detail_screen.dart';
import 'package:fitend_member/user/provider/user_register_provider.dart';
import 'package:fitend_member/user/view/register_complete_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TrainerListScreen extends ConsumerStatefulWidget {
  const TrainerListScreen({
    super.key,
    required this.phone,
  });

  final String phone;

  @override
  ConsumerState<TrainerListScreen> createState() => _TrainerListScreenState();
}

class _TrainerListScreenState extends ConsumerState<TrainerListScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trainerListProvider);
    final registerModel = ref.watch(userRegisterProvider(widget.phone));
    String trainerName = '';
    String trainerProfileImage = '';

    if (state is TrainerListModelLoading) {
      return const Scaffold(
        backgroundColor: Pallete.background,
        body: Center(
          child: CircularProgressIndicator(
            color: Pallete.point,
          ),
        ),
      );
    }

    if (state is TrainerListModelError) {
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

    final trainerListModel = state as TrainerListModel;

    if (registerModel.trainerId != null) {
      int trainerIndex = trainerListModel.data
          .indexWhere((element) => element.id == registerModel.trainerId);

      trainerName = trainerListModel.data[trainerIndex].nickname;
      trainerProfileImage = trainerListModel.data[trainerIndex].profileImage;
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (registerModel.trainerId == null) {
        ref.read(userRegisterProvider(widget.phone).notifier).updateData(
              trainerId: trainerListModel.data[0].id,
            );
      }
    });

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 24,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              '원하시는 코치님을 선택해주세요 :)',
              style: h3Headline.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            height: 36,
          ),
          SizedBox(
            width: 100.w,
            height: 332,
            child: ListView.separated(
              itemBuilder: (context, index) {
                final trainer = trainerListModel.data[index];
                final selected = registerModel.trainerId == trainer.id;

                return Padding(
                  padding: index == 0
                      ? const EdgeInsets.only(left: 28)
                      : index + 1 == trainerListModel.data.length
                          ? const EdgeInsets.only(right: 28)
                          : const EdgeInsets.all(0),
                  child: GestureDetector(
                    onTap: () {
                      if (registerModel.trainerId == trainer.id) return;

                      ref
                          .read(userRegisterProvider(widget.phone).notifier)
                          .updateData(
                            trainerId: trainer.id,
                          );
                    },
                    child: Stack(
                      children: [
                        AnimatedOpacity(
                          opacity: selected ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            width: 214,
                            height: 332,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.red,
                                    Pallete.point,
                                    Colors.orange,
                                    Colors.pink
                                  ]),
                              color:
                                  selected ? Pallete.point : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          left: 5,
                          child: Center(
                            child: Container(
                              width: 204,
                              height: 324,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 204,
                                    height: 200,
                                    child: CustomNetworkImage(
                                      imageUrl:
                                          '${URLConstants.s3Url}${trainer.largeProfileImage}',
                                      boxFit: BoxFit.fitHeight,
                                    ),
                                  ),
                                  Container(
                                    width: 204,
                                    height: 124,
                                    decoration: const BoxDecoration(
                                      color: Pallete.lightGray,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0, vertical: 8),
                                      child: Column(
                                        children: [
                                          Text(
                                            trainer.nickname,
                                            style: h3Headline,
                                          ),
                                          const SizedBox(
                                            height: 2,
                                          ),
                                          AutoSizeText(
                                            trainer.shortIntro,
                                            style: s1SubTitle.copyWith(
                                              color: Pallete.darkGray,
                                            ),
                                            maxLines: 1,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                CupertinoPageRoute(
                                                  builder: (context) =>
                                                      TrainerDetailScreen(
                                                    phone: widget.phone,
                                                    trainerId: trainer.id,
                                                  ),
                                                  fullscreenDialog: true,
                                                ),
                                              );
                                            },
                                            child: Container(
                                              width: 111,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Pallete.gray,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '자세히 보기',
                                                  style: s2SubTitle.copyWith(
                                                    color: Colors.white,
                                                    height: 1,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (selected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: SvgPicture.asset(
                              SVGConstants.checkComplete,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
              scrollDirection: Axis.horizontal,
              itemCount: trainerListModel.data.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
            ),
          )
        ],
      ),
      floatingActionButton: TextButton(
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(
            builder: (context) => RegisterCompleteScreen(
              phone: widget.phone,
              trainerName: trainerName,
              trainerProfileImage: trainerProfileImage,
            ),
          ));
        },
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
                '$trainerName 코치와 함께하기',
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
