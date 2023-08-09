import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/schedule/model/reservation_schedule_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class ReservationScheduleCard extends ConsumerStatefulWidget {
  final DateTime? date;
  final String? title;
  final String? subTitle;
  final String? time;
  final bool? isComplete;
  final bool selected;
  final bool? isDateVisible;
  final int? seq;
  final int? totalSession;
  final String? ticketStartedAt;
  final String? ticketExpiredAt;
  final bool? isNoshow;

  const ReservationScheduleCard({
    super.key,
    this.date,
    this.title,
    this.subTitle,
    this.time,
    this.isComplete,
    required this.selected,
    this.isDateVisible = true,
    this.seq,
    this.totalSession,
    this.ticketStartedAt,
    this.ticketExpiredAt,
    this.isNoshow,
  });

  factory ReservationScheduleCard.fromReservationModel({
    DateTime? date,
    required Reservation model,
    bool? isDateVisible,
  }) {
    return ReservationScheduleCard(
      date: date,
      title: '오프라인 레슨이 있어요  💪',
      subTitle:
          '${DateFormat('HH:mm').format(model.startTime.toUtc().toLocal())} ~ ${DateFormat('HH:mm').format(model.endTime.toUtc().toLocal())} (${model.endTime.difference(model.startTime.toUtc().toLocal()).inMinutes}분)',
      selected: model.selected!,
      isComplete: model.status == 'attendance' ? true : false,
      seq: model.seq,
      totalSession: model.totalSession,
      ticketStartedAt: model.ticketStartedAt,
      ticketExpiredAt: model.ticketExpiredAt,
      isDateVisible: isDateVisible,
      isNoshow: model.status == 'cancel' && model.times == 1,
    );
  }

  @override
  ConsumerState<ReservationScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends ConsumerState<ReservationScheduleCard> {
  DateTime today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.selected ? 175 : 130,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.transparent,
        image: widget.selected
            ? const DecorationImage(
                image: AssetImage("asset/img/schedule_image_offline_pt.png"),
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
                          color: LIGHT_GRAY_COLOR,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      )
                    ],
                  ),
                ),
                if (widget.isComplete == null)
                  const SizedBox(
                    width: 24,
                  )
                else if ((widget.isComplete!) || widget.isNoshow!)
                  // Image.asset('asset/img/round_success.png'),
                  SvgPicture.asset('asset/img/icon_check_complete.svg')
                else if (!widget.isComplete!) //스케줄이 미완료
                  SvgPicture.asset(
                      'asset/img/icon_check.svg') // 스케줄이 완료(nowhow 포함) 일때
              ],
            ),
            if (widget.selected)
              Column(
                children: [
                  const SizedBox(
                    height: 23,
                  ),
                  const Divider(
                    height: 1,
                    color: LIGHT_GRAY_COLOR,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 22,
                  ),
                  Row(
                    children: [
                      Text(
                        '${widget.seq}회차 ',
                        style: h6Headline.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '/ ${widget.totalSession}회',
                        style: s2SubTitle.copyWith(
                          color: LIGHT_GRAY_COLOR,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Text(
                        '${DateFormat('yyyy.MM.dd').format(DateTime.parse(widget.ticketStartedAt!))} ~ ${DateFormat('yyyy.MM.dd').format(DateTime.parse(widget.ticketExpiredAt!))} ',
                        style: s2SubTitle.copyWith(
                          color: LIGHT_GRAY_COLOR,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            if (!widget.selected)
              const SizedBox(
                height: 35,
              ),
            const Divider(
              color: DARK_GRAY_COLOR,
              height: 1,
            ),
          ],
        ),
      ),
    );
  }
}
