import 'package:collection/collection.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/ticket/model/product_model.dart';
import 'package:fitend_member/ticket/model/ticket_model.dart';
import 'package:fitend_member/ticket/provider/product_provider.dart';
import 'package:fitend_member/ticket/view/ticket_purchase_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TicketContainer extends ConsumerStatefulWidget {
  const TicketContainer({
    super.key,
    this.trainerId,
    this.activeTicket,
  });

  final int? trainerId;
  final ActiveTicket? activeTicket;

  @override
  ConsumerState<TicketContainer> createState() => _TicketContainerState();
}

class _TicketContainerState extends ConsumerState<TicketContainer> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetch();
    });
  }

  void fetch() async {
    if (mounted) {
      await ref.read(productProvider.notifier).getProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productProvider);

    if (state == null ||
        state is ProductsModelLoading ||
        state is ProductsModelError) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Pallete.darkGray,
        ),
        width: 100.w,
        height: 300,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 23),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '구매 상품 선택',
                    style: h5Headline.copyWith(color: Colors.white),
                  ),
                  InkWell(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      fill: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final model = state as ProductsModel;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Pallete.darkGray,
      ),
      width: 100.w,
      height: 300,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 23),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '구매 상품 선택',
                  style: h5Headline.copyWith(color: Colors.white),
                ),
                InkWell(
                  onTap: () => context.pop(),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    fill: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 11,
            ),
            ...model.data.mapIndexed(
              (index, product) => _productCell(index, model, product),
            ),
            const SizedBox(
              height: 23,
            ),
            GestureDetector(
              onTap: () {
                context.pop();
                Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => TicketPurchaseScreen(
                    purchaseProduct: model.data[model.selectedIndex!],
                    trainerId: widget.trainerId,
                    activeTicket: widget.activeTicket,
                  ),
                ));
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Pallete.point,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '확인',
                    style: h6Headline.copyWith(
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector _productCell(
      int index, ProductsModel model, Product product) {
    return GestureDetector(
      onTap: () {
        ref.read(productProvider.notifier).updateSelectedProduct(index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            model.selectedIndex != null && model.selectedIndex == index
                ? SvgPicture.asset(SVGConstants.checkComplete)
                : SvgPicture.asset(SVGConstants.checkVoid),
            const SizedBox(
              width: 13,
            ),
            Text(
              product.name,
              style: s2SubTitle.copyWith(color: Colors.white, height: 1),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              '${NumberFormat('#,###').format(product.price)}원',
              style: h5Headline.copyWith(color: Colors.white, height: 1),
            ),
            const SizedBox(
              width: 10,
            ),
            if (product.discountRate > 0)
              Text(
                '${NumberFormat('#,###').format(product.originPrice)}원',
                style: s3SubTitle.copyWith(
                    color: Pallete.lightGray,
                    decoration: TextDecoration.lineThrough,
                    height: 1),
              ),
            const SizedBox(
              width: 10,
            ),
            if (product.discountRate > 0)
              Container(
                width: 57,
                height: 21,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadiusDirectional.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${product.discountRate}% 할인',
                    style: s3SubTitle.copyWith(
                      color: Pallete.point,
                      height: 1,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
