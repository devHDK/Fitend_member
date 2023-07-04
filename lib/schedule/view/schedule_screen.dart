import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/component/error_dialog.dart';
import 'package:fitend_member/common/component/logo_appbar.dart';
import 'package:fitend_member/common/component/schedule_card.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/data/global_varialbles.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/schedule/model/workout_schedule_model.dart';
import 'package:fitend_member/schedule/provider/workout_schedule_provider.dart';
import 'package:fitend_member/user/view/mypage_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  static String get routeName => 'schedule_main';
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  final ScrollController controller = ScrollController();

  DateTime today = DateTime.now();
  DateTime fifteenDaysAgo = DateTime.now().subtract(const Duration(days: 15));
  DateTime minDate = DateTime(DateTime.now().year);
  DateTime maxDate = DateTime(DateTime.now().year);
  int initListItemCount = 0;
  // int refetchItemCount = 0;
  int todayLocation = 0;
  bool initial = true;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initial) {
        _getScheduleInitial();
      }
    });
  }

  void _getScheduleInitial() async {
    await ref
        .read(
            workoutScheduleProvider(DataUtils.getDate(fifteenDaysAgo)).notifier)
        .paginate(startDate: DataUtils.getDate(fifteenDaysAgo))
        .then((value) {
      Future.delayed(const Duration(milliseconds: 200), () {
        todayLocation += 130 * 14 + 130 * initListItemCount;

        if (controller.hasClients) {
          controller.jumpTo(
            todayLocation.toDouble(),
          );
        }

        bool checkSchedule = false;

        for (var workout in scheduleListGlobal) {
          if (workout.workouts!.isNotEmpty) {
            checkSchedule = true;
            break;
          }
        }

        if (!checkSchedule) {
          showDialog(
            context: context,
            builder: (context) => DialogWidgets.errorDialog(
              message: '회원님을 위한 플랜을 준비중이에요!\n플랜이 완성되면 알려드릴게요 😊',
              confirmText: '확인',
              confirmOnTap: () => context.pop(),
            ),
          );
        }
      });
    });
    initial = false;
  }

  @override
  void dispose() {
    controller.removeListener(listener);
    controller.dispose();
    super.dispose();
  }

  void listener() {
    final provider = ref.read(
        workoutScheduleProvider(DataUtils.getDate(fifteenDaysAgo)).notifier);

    if (controller.offset < controller.position.minScrollExtent + 50) {
      //스크롤을 맨위로 올렸을때
      provider.paginate(
          startDate: minDate, fetchMore: true, isUpScrolling: true);

      double previousOffset = controller.offset;
      int temp = 0;

      scheduleListGlobal.map((element) {
        if (element.workouts!.length > 1) {
          temp += element.workouts!.length - 1;
        }
      });
      controller.jumpTo(previousOffset + (130.0 * 31 + 130 * temp));

      todayLocation += (130 * 31) + (130 * temp); //기존 위치로 이동
    } else if (controller.offset > controller.position.maxScrollExtent - 300) {
      //스크롤을 아래로 내렸을때
      provider.paginate(
          startDate: maxDate, fetchMore: true, isDownScrolling: true);
    }
  }

  void _onChildEvent() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(workoutScheduleProvider(DataUtils.getDate(fifteenDaysAgo)));

    if (state is WorkoutScheduleModelLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: POINT_COLOR,
        ),
      );
    }

    if (state is WorkoutScheduleModelError) {
      return ErrorDialog(error: state.message);
    }

    var schedules = state as WorkoutScheduleModel;

    if (scheduleListGlobal.length < schedules.data!.length) {
      scheduleListGlobal = schedules.data!;
    }

    minDate = schedules.data![0].startDate.subtract(const Duration(days: 31));
    maxDate = schedules.data![schedules.data!.length - 1].startDate
        .add(const Duration(days: 1));

    for (int i = 0; i < schedules.data!.length; i++) {
      if (i > 13) {
        break;
      }

      if (schedules.data![i].workouts!.length >= 2) {
        initListItemCount += schedules.data![i].workouts!.length - 1;
      }
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        appBar: LogoAppbar(
          tapLogo: () async {
            setState(() {
              todayLocation = 0;
              initListItemCount = 0;
            });
            scheduleListGlobal.removeRange(0, scheduleListGlobal.length - 1);

            await ref
                .read(workoutScheduleProvider(DataUtils.getDate(fifteenDaysAgo))
                    .notifier)
                .paginate(
                  startDate: DataUtils.getDate(fifteenDaysAgo),
                )
                .then((value) {
              Future.delayed(const Duration(milliseconds: 200), () {
                todayLocation += 130 * 14 + 130 * initListItemCount;

                if (controller.hasClients) {
                  controller.jumpTo(
                    todayLocation.toDouble(),
                    // duration: const Duration(milliseconds: 300),
                    // curve: Curves.ease,
                  );
                }
              });
            });

            // controller.animateTo(
            //   todayLocation.toDouble(),
            //   duration: const Duration(milliseconds: 300),
            //   curve: Curves.ease,
            // );
          },
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 28.0),
              child: GestureDetector(
                onTap: () {
                  // context.goNamed(MyPageScreen.routeName);

                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => const MyPageScreen(),
                    ),
                  );
                },
                child: SvgPicture.asset(
                  'asset/img/icon_my_page.svg',
                ),
              ),
            ),
          ],
        ),
        body: ListView.builder(
          controller: controller,
          itemCount: schedules.data!.length + 1,
          itemBuilder: <WorkoutScheduleModel>(context, index) {
            if (index == schedules.data!.length) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(color: POINT_COLOR),
                ),
              );
            }

            final model = schedules.data![index].workouts;

            if (model!.isEmpty) {
              return ScheduleCard(
                date: schedules.data![index].startDate,
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
                            for (var e in schedules.data!) {
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
                        date: schedules.data![index].startDate,
                        isDateVisible: seq == 0 ? true : false,
                        onNotifyParent: _onChildEvent,
                      ),
                    );
                  },
                ).toList(),
              );
            }
          },
        ),
      ),
    );
  }
}
