import 'package:fitend_member/common/component/custom_one_button_dialog.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/payment/provider/payment_provider.dart';
import 'package:fitend_member/ticket/component/no_ticket_cell.dart';
import 'package:fitend_member/ticket/component/ticket_cell.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ActiveTicketScreen extends ConsumerStatefulWidget {
  static String get routeName => 'active_ticket';

  const ActiveTicketScreen({super.key});

  @override
  ConsumerState<ActiveTicketScreen> createState() => _ActiveTicketScreenState();
}

class _ActiveTicketScreenState extends ConsumerState<ActiveTicketScreen> {
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
                  if (activeTickets.isNotEmpty)
                    TicketCell(
                      ticket: activeTickets.first,
                    )
                  else
                    const NoTicketCell(
                      title: '멤버십을 구매하여',
                      content: '맞춤형 운동플랜과 코칭을 받아보세요!',
                    ),
                  const SizedBox(height: 32),
                  const Divider(
                    thickness: 1,
                    color: Pallete.gray,
                  ),
                  const SizedBox(height: 32),
                  if (activeTickets.isNotEmpty)
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
                      child: activeTickets[1].receiptId != null
                          ? GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => CustomOneButtonDialog(
                                    content:
                                        '멤버십 결제를 취소할까요?\n기간만료시 더 이상 코칭을 받을 수 없어요 🥲',
                                    confirmText: '결제 취소하기',
                                    confirmOnTap: () async {
                                      try {
                                        await ref
                                            .read(paymentProvider.notifier)
                                            .deletePayments(
                                                ticketId: activeTickets[1].id)
                                            .then((value) {
                                          _.pop();

                                          ref
                                              .read(getMeProvider.notifier)
                                              .updateActiveTickets(
                                                  activeTickets: [
                                                activeTickets[0]
                                              ]);

                                          DialogWidgets.oneButtonDialog(
                                            message:
                                                '결제하신 멤버십을 취소했어요.\n환불은 영업일 기준 3~5일 소요되요 👌️',
                                            confirmText: '확인',
                                            confirmOnTap: () => context.pop(),
                                          ).show(context);
                                        });
                                      } catch (e) {
                                        DialogWidgets.showToast(
                                            content: 'error - $e');
                                      }
                                    },
                                  ),
                                );
                              },
                              child: Text(
                                '결제취소',
                                style: s2SubTitle.copyWith(
                                    color: Pallete.gray,
                                    height: 1,
                                    decoration: TextDecoration.underline),
                              ),
                            )
                          : null,
                    )
                  else if (activeTickets.length == 1)
                    const NoTicketCell(
                      title: '없음',
                      content: '만료 전 멤버십을 미리 구매해주세요!',
                    )
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
                DialogWidgets.showToast(content: '이미 멤버십을 구매했어요!');
              }
            : () {
                DialogWidgets.ticketBuyModal(
                  context: context,
                  trainerId: userModel.user.activeTrainers.isNotEmpty
                      ? userModel.user.activeTrainers.first.id
                      : userModel.user.lastTrainers.first.id,
                  activeTicket: userModel.user.activeTickets != null &&
                          userModel.user.activeTickets!.isNotEmpty
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
