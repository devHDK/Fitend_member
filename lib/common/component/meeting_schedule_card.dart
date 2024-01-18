import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/meeting/model/meeting_schedule_model.dart';
import 'package:fitend_member/thread/model/common/thread_trainer_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingScheduleCard extends ConsumerStatefulWidget {
  final DateTime? date;
  final String? title;
  final String? subTitle;
  final DateTime startTime;
  final DateTime endTime;
  final bool? isDateVisible;
  final int? id;
  final String? status;
  final ThreadTrainer trainer;
  final String? userNickname;
  final String meetingLink;
  final bool selected;

  const MeetingScheduleCard({
    this.date,
    this.title,
    this.subTitle,
    super.key,
    required this.selected,
    required this.startTime,
    required this.endTime,
    this.isDateVisible = true,
    this.id,
    this.status,
    required this.trainer,
    this.userNickname,
    required this.meetingLink,
  });

  factory MeetingScheduleCard.fromMeetingSchedule({
    required MeetingSchedule model,
    DateTime? date,
    bool? isDateVisible,
  }) {
    return MeetingScheduleCard(
      date: date,
      title: '코치님과 미팅이 있어요 👋',
      subTitle:
          '${DateFormat('HH:mm').format(model.startTime.toUtc().toLocal())} ~ ${DateFormat('HH:mm').format(model.endTime.toUtc().toLocal())} (${model.endTime.difference(model.startTime.toUtc().toLocal()).inMinutes}분)',
      selected: model.selected!,
      isDateVisible: isDateVisible,
      trainer: model.trainer,
      meetingLink: model.meetingLink,
      startTime: model.startTime,
      endTime: model.endTime,
    );
  }

  @override
  ConsumerState<MeetingScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends ConsumerState<MeetingScheduleCard> {
  DateTime today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.selected ? 175 : 130,
      width: 100.w,
      decoration: BoxDecoration(
        color: Colors.transparent,
        image: widget.selected
            ? const DecorationImage(
                image: AssetImage(IMGConstants.scheduleMeeting),
                fit: BoxFit.fill,
                opacity: 0.3,
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 35,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: (widget.selected &&
                                  widget.isDateVisible! &&
                                  widget.date != null) ||
                              (widget.date != null &&
                                  widget.date!.compareTo(today) == 0 &&
                                  widget.isDateVisible == true) ||
                              widget.selected
                          ? Colors.white
                          : Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    // image: ,
                  ),
                  width: 39,
                  height: 58,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        if (widget.date != null)
                          Text(
                            weekday[widget.date!.weekday - 1],
                            style: s2SubTitle.copyWith(
                              color: widget.isDateVisible! || widget.selected
                                  ? Colors.white
                                  : Colors.transparent,
                              letterSpacing: 0,
                              height: 1.2,
                            ),
                          ),
                        const SizedBox(
                          height: 5,
                        ),
                        if (widget.date != null)
                          Text(
                            widget.date!.day.toString(),
                            style: s2SubTitle.copyWith(
                              color: widget.isDateVisible! || widget.selected
                                  ? Colors.white
                                  : Colors.transparent,
                              letterSpacing: 0,
                              height: 1.2,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title != null ? widget.title! : '',
                        style: h4Headline.copyWith(
                          color: Colors.white,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.subTitle != null ? widget.subTitle! : '',
                        style: s2SubTitle.copyWith(
                          color: Pallete.lightGray,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      )
                    ],
                  ),
                ),
                CustomNetworkImage(
                  imageUrl:
                      '${URLConstants.s3Url}${widget.trainer.profileImage}',
                  width: 20,
                )
              ],
            ),
            if (widget.selected)
              Column(
                children: [
                  const SizedBox(
                    height: 23,
                  ),
                  SizedBox(
                    width: 100.w,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Pallete.point,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent, elevation: 0),
                        onPressed: () {
                          final now = DateTime.now();

                          final timeDiffStart =
                              widget.startTime.difference(now).inMinutes;
                          final timeDiffEnd =
                              widget.endTime.difference(now).inMinutes;

                          if (timeDiffStart > 5) {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  DialogWidgets.oneButtonDialog(
                                message: '미팅 5분 전부터 입장할 수 있어요 🙌 ',
                                confirmText: '확인',
                                confirmOnTap: () => context.pop(),
                              ),
                            );
                            return;
                          }

                          if (timeDiffEnd < 0) {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  DialogWidgets.oneButtonDialog(
                                message: '초대링크가 이미 만료되었어요 😯  ',
                                confirmText: '확인',
                                confirmOnTap: () => context.pop(),
                              ),
                            );
                            return;
                          }

                          launchUrl(
                            Uri.parse(widget.meetingLink),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: Text(
                          '초대링크 열기 👥',
                          style: h6Headline.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            if (!widget.selected)
              const SizedBox(
                height: 35,
              ),
            const Divider(
              color: Pallete.darkGray,
              height: 1,
            ),
          ],
        ),
      ),
    );
  }
}
