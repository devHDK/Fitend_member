import 'package:fitend_member/common/component/custom_one_button_dialog.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/flavors.dart';
import 'package:fitend_member/payment/provider/payment_provider.dart';
import 'package:fitend_member/ticket/component/no_ticket_cell.dart';
import 'package:fitend_member/ticket/component/ticket_cell.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:slack_notifier/slack_notifier.dart';

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
                  Column(
                    children: [
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
                                                    ticketId:
                                                        activeTickets[1].id)
                                                .then((value) {
                                              _.pop();

                                              final slack = SlackNotifier(
                                                  URLConstants
                                                      .slackMembershipWebhook);
                                              slack.send(
                                                '${F.appFlavor != Flavor.production ? '[TEST]' : ''}[결제 취소😓][${userModel.user.activeTrainers.first.nickname} 코치님]-[${userModel.user.nickname}]님이 멤버십 결제 취소!',
                                                channel: '#cs8_결제-알림',
                                              );

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
                                                confirmOnTap: () =>
                                                    context.pop(),
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
                        ),
                      const SizedBox(
                        height: 32,
                      ),
                      const Divider(
                        thickness: 1,
                        color: Pallete.gray,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Text(
                    '멤버십 공통혜택',
                    style: s2SubTitle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  _benefitCell(
                      '맞춤형 운동계획', '회원님의 사전설문 데이터를 바탕으로\n실현가능한 운동루틴을 만들어드려요.'),
                  _benefitCell('1:1 관리 및 피드백',
                      '자세 및 운동과 관련된 질문이 생기면\n코치님께 언제든지 물어볼 수 있어요.'),
                  _benefitCell('지속가능한 운동습관',
                      '포기하지 않고 꾸준히 지속할 수 있도록\n동기부여와 멘탈케어를 해드릴게요.'),
                  const SizedBox(
                    height: 35,
                  ),
                  const Divider(
                    thickness: 1,
                    color: Pallete.gray,
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  Text(
                    '필수 유의사항',
                    style: s2SubTitle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    '''· 모든 멤버십 상품은 부가세(VAT) 포함 가격입니다.\n· 유효기간 만료시 멤버십 권한은 자동으로 소멸됩니다.\n· 이용중인 상품의 유효기간 만료 전 이용예정 상품을 미리 구매할 수 있으며, 이때 시작일은 이용중인 상품의 종료일 다음날로 지정됩니다.\n· 구매하신 상품은 타인에게 판매하거나 양도할 수 없습니다.\n· 유효기간 내 서비스 이용이 어려우실 경우 3개월권은 1회, 6개월권은 2회에 한하여 회당 최대 7일까지 이용을 중지할 수 있으며, 중지 신청은 핏엔드 고객센터로 접수한 건에 대해서만 처리 가능합니다.\n· 이용 중 코치변경은 핏엔드 고객센터로 접수를 통해 가능합니다.\n· 담당 코치가 더 이상 코칭을 지속할 수 없을 경우 동일한 자격을 갖춘 코치로 대체될 수 있습니다.\n''',
                    style: s3SubTitle.copyWith(
                      color: Pallete.gray,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    '환불 유의사항',
                    style: s2SubTitle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    '''· 구매하신 상품의 시작일로부터 7일 이내에 고객센터로 접수한 경우에만 취소 및 환불이 가능하며, 이 기간 내에 상품에 해당하는 채팅 및 콘텐츠 제공 등의 이용이력이 있을 경우 환불에 제한이 있을 수 있습니다.\n· 다개월권은 장기 이용에 대한 할인 혜택이 적용된 금액이므로 중도 해지 시 1개월권 정상가 기준으로 환불 신청일까지 이용하신 개월 수를 제외한 남은 개월 수에 대해 월할계산 후 환불 금액이 정산됩니다.\n· 이용예정 상품은 구매 후 시작일 전까지 앱 내에서 취소가 가능합니다.\n· 환불 요청 접수시 처리완료까지 영업일 기준 최대 3일이 소요되며, 환불대상 기간을 제외하고 이미 결제가 완료된 잔여 유효기간에 대해서는 서비스를 계속해서 이용할 수 있습니다.\n· 환불은 회원이 결제한 동일 결제수단으로 환불함을 원칙으로 합니다. 단, 회사가 사전에 회원에게 공지한 경우 및 아래의 각 경우와 같이 개별 결제 수단별 환불방법, 환불가능 기간 등이 차이가 있을 수 있습니다.\n 1. 신용카드 등 수납확인이 필요한 결제수단의 경우 수납 확인일로부터 3영업일 이내\n 2. 회원이 환불처리에 필요한 정보 내지 자료를 회사에 즉시 제공하지 않는 경우\n 3. 해당 회원의 명시적 의사표시가 있는 경우 ''',
                    style: s3SubTitle.copyWith(
                      color: Pallete.gray,
                    ),
                  ),
                  const SizedBox(
                    height: 70,
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

  Widget _benefitCell(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(SVGConstants.checkWhite),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: h4Headline.copyWith(color: Colors.white),
              ),
              Text(
                content,
                style: s2SubTitle.copyWith(color: Colors.white),
              ),
            ],
          )
        ],
      ),
    );
  }
}
