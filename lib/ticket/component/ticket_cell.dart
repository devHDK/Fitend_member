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

  final ActiveTicket ticket;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    int ticketLength = 0;
    final diff = ticket.expiredAt.difference(ticket.startedAt).inDays;
    if (diff > 92) {
      ticketLength = 6;
    } else if (diff > 31) {
      ticketLength = 3;
    } else {
      ticketLength = 1;
    }

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
              ticket.type == 'fitness'
                  ? '온라인 코칭 $ticketLength개월'
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
                  '${DateFormat('yyyy.MM.dd').format(
                    ticket.expiredAt,
                  )}  ',
                  style: s2SubTitle.copyWith(
                    color: Colors.white,
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
