import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
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
        onTap: () {},
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
}
