import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/ticket/component/no_ticket_cell.dart';
import 'package:fitend_member/ticket/component/ticket_cell.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TicketScreen extends ConsumerStatefulWidget {
  const TicketScreen({super.key});

  @override
  ConsumerState<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends ConsumerState<TicketScreen> {
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(getMeProvider);

    final userModel = userState as UserModel;

    final activeTickets = userModel.user.activeTickets ?? [];

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
          '멤버십',
          style: h4Headline.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: RefreshIndicator(
          backgroundColor: Pallete.background,
          color: Pallete.point,
          semanticsLabel: '새로고침',
          onRefresh: () async {
            await ref.read(getMeProvider.notifier).getMe();
          },
          child: ListView(
            children: [
              Column(
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
                    ticket: activeTickets.first,
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
                  if (activeTickets.length > 1)
                    TicketCell(
                      ticket: activeTickets[1],
                    )
                  else
                    const NoTicketCell()
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: activeTickets.length >= 2
            ? () {
                DialogWidgets.showToast(
                    '이미 멤버십을 구매했어요!\n먼저 이용예정 상품을 취소해주세요 🙅‍♀️');
              }
            : () {
                DialogWidgets.ticketBuyModal(
                  context: context,
                  trainerId: userModel.user.activeTrainers.first.id,
                  activeTicket: userModel.user.activeTickets != null
                      ? userModel.user.activeTickets!.first
                      : null,
                );
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Pallete.point,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '멤버십 구매하기',
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
