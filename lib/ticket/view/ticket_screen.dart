import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/ticket/component/no_ticket_cell.dart';
import 'package:fitend_member/ticket/component/ticket_cell.dart';
import 'package:fitend_member/ticket/model/ticket_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key, required this.tickets});

  final List<ActiveTicket> tickets;

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  @override
  Widget build(BuildContext context) {
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
          '멤버쉽',
          style: h4Headline.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              '이용중인 상품',
              style: s2SubTitle.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            TicketCell(
              ticket: widget.tickets.first,
            ),
            const SizedBox(height: 32),
            const Divider(
              thickness: 1,
              color: Pallete.gray,
            ),
            const SizedBox(height: 32),
            Text(
              '이용예정 상품',
              style: s2SubTitle.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.tickets.length > 1)
              TicketCell(
                ticket: widget.tickets[1],
              )
            else
              const NoTicketCell()
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          onPressed: widget.tickets.length >= 2
              ? () {
                  DialogWidgets.showToast(
                      '이미 멤버십을 구매했어요!\n먼저 이용예정 상품을 취소해주세요 🙅‍♀️');
                }
              : () {
                  DialogWidgets.ticketBuyModal(context);
                },
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Pallete.point,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '멤버쉽 구매하기',
                style: h6Headline.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
