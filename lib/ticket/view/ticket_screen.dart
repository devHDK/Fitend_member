import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/ticket/model/ticket_model.dart';
import 'package:fitend_member/ticket/provider/ticket_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TicketScreen extends ConsumerStatefulWidget {
  static String get routeName => 'ticket';

  const TicketScreen({super.key});

  @override
  ConsumerState<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends ConsumerState<TicketScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetch();
    });
  }

  void fetch() async {
    if (mounted && ref.read(ticketProvider) is TicketDetailListModelError) {
      await ref.read(ticketProvider.notifier).getTickets();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ticketProvider);

    if (state is TicketDetailListModelLoading) {
      return const Scaffold(
        backgroundColor: Pallete.background,
        body: Center(
          child: CircularProgressIndicator(
            color: Pallete.point,
          ),
        ),
      );
    }

    if (state is TicketDetailListModelError) {
      return Scaffold(
        backgroundColor: Pallete.background,
        body: DialogWidgets.oneButtonDialog(
          message: state.message,
          confirmText: '확인',
          confirmOnTap: () => context.pop(),
        ),
      );
    }

    final model = state as TicketDetailListModel;

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
          '멤버십 결제 내역',
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
            await ref.read(ticketProvider.notifier).getTickets();
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              final ticket = model.data[index];

              int fcMonths = 0;
              final diff = ticket.expiredAt.difference(ticket.startedAt).inDays;
              if (diff > 92) {
                fcMonths = 6;
              } else if (diff > 31) {
                fcMonths = 3;
              } else if (diff > 15) {
                fcMonths = 1;
              } else {
                fcMonths = 0;
              }

              int price = ticket.totalSession * ticket.sessionPrice +
                  ticket.coachingPrice;

              price += (price * 0.1).toInt();

              String ticketName = ticket.type == 'fitness' && fcMonths > 0
                  ? '온라인 코칭 $fcMonths개월'
                  : ticket.type == 'fitness' && fcMonths == 0
                      ? '온라인 코칭 14일 (무료체험)'
                      : '오프라인 PT ${ticket.totalSession}회';

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ticketName,
                              style: h5Headline.copyWith(color: Colors.white),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              '${DateFormat('yyyy.MM.dd').format(
                                ticket.startedAt,
                              )} ~ ${DateFormat('yyyy.MM.dd').format(
                                ticket.expiredAt,
                              )}',
                              style: s2SubTitle.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${NumberFormat('#,###').format(price)}원',
                          style: h4Headline.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: Pallete.gray,
                  )
                ],
              );
            },
            itemCount: model.data.length,
          ),
        ),
      ),
    );
  }
}
