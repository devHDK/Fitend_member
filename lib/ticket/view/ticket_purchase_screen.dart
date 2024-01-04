import 'package:bootpay/bootpay.dart';
import 'package:bootpay/model/item.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/user.dart';
import 'package:fitend_member/common/const/bootpay_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/flavors.dart';
import 'package:fitend_member/ticket/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TicketPurchaseScreen extends StatefulWidget {
  final Product purchaseProduct;

  const TicketPurchaseScreen({
    super.key,
    required this.purchaseProduct,
  });

  @override
  State<TicketPurchaseScreen> createState() => _TicketPurchaseScreenState();
}

class _TicketPurchaseScreenState extends State<TicketPurchaseScreen> {
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final expiredDate = DateTime(
      today.year,
      today.month + widget.purchaseProduct.month,
      today.day - 1,
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
                          '${DateFormat('yyyy.MM.dd').format(today)} ~ ${DateFormat('yyyy.MM.dd').format(expiredDate)}',
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
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () {
          Payload payload = getPayload(widget.purchaseProduct);

          Bootpay().requestPayment(
            context: context,
            payload: payload,
            showCloseButton: true,
            // closeButton: Icon(Icons.close, size: 35.0, color: Colors.black54),
            onCancel: (String data) {
              print('------- onCancel: $data');
              context.pop();
            },
            onError: (String data) {
              print('------- onError: $data');
            },
            onClose: () {
              print('------- onClose');
              Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
              //TODO - 원하시는 라우터로 페이지 이동
            },
            onIssued: (String data) {
              print('------- onIssued: $data');
            },
            onConfirm: (String data) {
              print('------- onConfirm: $data');
              /**
            1. 바로 승인하고자 할 때
            return true;
         **/
              /***
            2. 비동기 승인 하고자 할 때
            checkQtyFromServer(data);
            return false;
         ***/
              /***
            3. 서버승인을 하고자 하실 때 (클라이언트 승인 X)
            return false; 후에 서버에서 결제승인 수행
         */
              // checkQtyFromServer(data);
              return true;
            },
            onDone: (String data) {
              print('------- onDone: $data');
            },
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
                '결제하기',
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

    payload.metadata = {
      "callbackParam1": "value12",
      "callbackParam2": "value34",
      "callbackParam3": "value56",
      "callbackParam4": "value78",
    }; // 전달할 파라미터, 결제 후 되돌려 주는 값
    return payload;
  }
}
