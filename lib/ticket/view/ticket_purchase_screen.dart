import 'dart:convert';

import 'package:bootpay/bootpay.dart';
import 'package:bootpay/model/payload.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/bootpay_constants.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/flavors.dart';
import 'package:fitend_member/payment/model/bootpay_confirm_response.dart';
import 'package:fitend_member/payment/model/payment_confirm_req_model.dart';
import 'package:fitend_member/payment/provider/payment_provider.dart';
import 'package:fitend_member/ticket/model/product_model.dart';
import 'package:fitend_member/ticket/model/ticket_model.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slack_notifier/slack_notifier.dart';

class TicketPurchaseScreen extends ConsumerStatefulWidget {
  final Product purchaseProduct;
  final int? trainerId;
  final TicketModel? activeTicket;

  const TicketPurchaseScreen({
    super.key,
    required this.purchaseProduct,
    this.trainerId,
    this.activeTicket,
  });

  @override
  ConsumerState<TicketPurchaseScreen> createState() =>
      _TicketPurchaseScreenState();
}

class _TicketPurchaseScreenState extends ConsumerState<TicketPurchaseScreen> {
  bool isAgreed = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(getMeProvider);

    final userModel = state as UserModel;

    final now = DateTime.now();

    final startDate = widget.activeTicket != null
        ? widget.activeTicket!.expiredAt.add(const Duration(days: 1))
        : DateTime(now.year, now.month, now.day);

    final expiredDate = DateTime(
      startDate.year,
      startDate.month + widget.purchaseProduct.month,
      startDate.day - 1,
    );

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
          '멤버십 결제',
          style: h4Headline.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 100.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Pallete.darkGray,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '상품',
                          style: h5Headline.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '온라인 코칭 ${widget.purchaseProduct.month}개월',
                          style: s1SubTitle.copyWith(
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 1.0,
                    color: Pallete.gray,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '이용 기간',
                          style: h5Headline.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${DateFormat('yyyy.MM.dd').format(startDate)} ~ ${DateFormat('yyyy.MM.dd').format(expiredDate)}',
                          style: s1SubTitle.copyWith(
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 100.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Pallete.darkGray,
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '총 결제 금액',
                      style: h5Headline.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${NumberFormat('#,###').format(widget.purchaseProduct.price)}원',
                      style: h5Headline.copyWith(
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                setState(() {
                  isAgreed = !isAgreed;
                });
              },
              child: Container(
                width: 100.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Pallete.darkGray,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                  child: Row(
                    children: [
                      if (!isAgreed)
                        SvgPicture.asset(SVGConstants.checkVoid)
                      else
                        SvgPicture.asset(SVGConstants.checkComplete),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        '필수 유의사항 및 환불 규정을 확인했어요.',
                        style: s3SubTitle.copyWith(
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => DataUtils.onWebViewTap(
                            uri: URLConstants.notionPurcharse),
                        child: Text(
                          '보기',
                          style: s3SubTitle.copyWith(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: !isAgreed
            ? null
            : () {
                Payload payload = getPayload(widget.purchaseProduct);

                Bootpay().requestPayment(
                  context: context,
                  payload: payload,
                  showCloseButton: true,
                  // closeButton: Icon(Icons.close, size: 35.0, color: Colors.black54),
                  onCancel: (String data) {
                    // print('------- onCancel: $data');
                    Bootpay().dismiss(context);
                  },
                  onError: (String data) {
                    // print('------- onError: $data');
                  },
                  onClose: () {
                    // print('------- onClose');
                    // Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
                  },
                  onIssued: (String data) {
                    // print('------- onIssued: $data');
                  },
                  onConfirm: (String data) {
                    try {
                      final result = BootPayConfirmResponse.fromJson(
                        jsonDecode(data),
                      ); //bootPay responseData

                      _confirmPayment(result, startDate, expiredDate, userModel)
                          .then((value) {
                        Bootpay().transactionConfirm();
                      });
                    } catch (e) {
                      DialogWidgets.showToast(
                        content: '결제 중 오류가 발생하였습니다! 다시 시도해주세요',
                        gravity: ToastGravity.CENTER,
                      );
                      Bootpay().dismiss(context);
                    }
                    // Bootpay().dismiss(context);
                    return false;
                  },
                  onDone: (String data) {
                    // print('------- onDone: $data');
                    Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출

                    //route
                    context.pop({'buyTicket': true});
                  },
                );
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: !isAgreed ? Pallete.point.withOpacity(0.4) : Pallete.point,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '결제하기',
                style: h6Headline.copyWith(
                  color:
                      !isAgreed ? Colors.white.withOpacity(0.4) : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmPayment(BootPayConfirmResponse result,
      DateTime startDate, DateTime expiredDate, UserModel userModel) async {
    try {
      if (mounted) {
        await ref
            .read(paymentProvider.notifier)
            .postConfirmPayments(
              reqModel: PaymentConfirmReqModel(
                receiptId: result.receiptId,
                orderId: result.orderId,
                price: F.appFlavor == Flavor.production
                    ? widget.purchaseProduct.price
                    : 100,
                orderName: widget.purchaseProduct.name,
                startedAt: startDate,
                expiredAt: expiredDate,
                trainerId: userModel.user.activeTrainers.isNotEmpty
                    ? userModel.user.activeTrainers.first.id
                    : userModel.user.lastTrainers.first.id,
                userId: userModel.user.id,
                month: widget.purchaseProduct.month,
              ),
            )
            .then((value) {
          ref.read(getMeProvider.notifier).getMe();

          try {
            final slack = SlackNotifier(URLConstants.slackMembershipWebhook);
            slack.send(
              '${F.appFlavor != Flavor.production ? '[TEST]' : ''}[멤버십 구매 🎫][${userModel.user.activeTrainers.first.nickname} 코치님]-[${userModel.user.nickname}]님이 [${widget.purchaseProduct.month}개월] 멤버십 구매!',
              channel: '#cs8_결제-알림',
            );
          } catch (e) {
            debugPrint('$e');
          }
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Payload getPayload(Product purchaseProduct) {
    Payload payload = Payload();

    payload.androidApplicationId =
        BootPayConstants.aosKey; // android application id
    payload.iosApplicationId = BootPayConstants.iosKey; // ios application id

    payload.pg = '나이스페이';
    payload.orderName = 'FITEND 온라인 코칭 ${purchaseProduct.month}개월'; //결제할 상품명
    payload.price = F.appFlavor == Flavor.production
        ? purchaseProduct.price.toDouble()
        : 100; //정기결제시 0 혹은 주석

    payload.orderId = DateTime.now()
        .millisecondsSinceEpoch
        .toString(); //주문번호, 개발사에서 고유값으로 지정해야함

    return payload;
  }
}
