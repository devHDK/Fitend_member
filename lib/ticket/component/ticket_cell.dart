import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/ticket/model/ticket_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class TicketCell extends StatelessWidget {
  const TicketCell({
    super.key,
    required this.ticket,
    this.child,
  });

  final TicketModel ticket;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    int fcMonths = 0;

    if (ticket.month != null) {
      fcMonths = ticket.month!;
    } else {
      fcMonths = 0;
    }

    bool isIn7days = ticket.expiredAt.difference(DateTime.now()).inDays <= 7;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Pallete.lightGray,
          ),
          child: Center(
            child: SvgPicture.asset(
              SVGConstants.ticket,
              width: 28,
            ),
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ticket.type == 'fitness' && fcMonths > 0
                  ? '온라인 코칭 $fcMonths개월'
                  : ticket.type == 'fitness' && fcMonths == 0
                      ? '온라인 코칭 14일 (무료체험)'
                      : '오프라인 PT ${ticket.totalSession}회',
              style: s1SubTitle.copyWith(
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                Text(
                  '${DateFormat('yyyy.MM.dd').format(
                    ticket.startedAt,
                  )} ~ ',
                  style: s2SubTitle.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  DateFormat('yyyy.MM.dd').format(
                    ticket.expiredAt,
                  ),
                  style: s2SubTitle.copyWith(
                    color: isIn7days ? Pallete.point : Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        if (child != null)
          Align(
            alignment: Alignment.centerRight,
            child: child,
          )
      ],
    );
  }
}
