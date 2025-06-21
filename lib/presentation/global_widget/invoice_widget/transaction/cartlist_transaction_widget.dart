import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../infrastructure/utils/display_format.dart';
import '../../../home/controllers/home.controller.dart';
import '../price_type_header_vertical.dart';
import 'horizontal_cart_transaction.dart';
import 'vertical_cart_transaction.dart';

class CartListTransactionWidget extends StatelessWidget {
  const CartListTransactionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();
    return Obx(
      () {
        final cartItems = controller.cart.value.items;
        return ListView.builder(
          shrinkWrap: true,
          controller: controller.scrollController,
          itemCount: vertical ? cartItems.length + 1 : cartItems.length,
          itemBuilder: (BuildContext context, int index) {
            if (vertical && index == 0) {
              return VerticalPriceTypeView(
                priceType: controller.invoice.priceType,
                datetime: controller.createdAt,
              );
            }
            final item = cartItems[vertical ? index - 1 : index];
            return vertical
                ? VerticalCartTransaction(
                    item: item,
                    priceType: controller.invoice.priceType,
                  )
                : HorizontalCartTransaction(
                    item: item,
                    index: index,
                    priceType: controller.invoice.priceType,
                  );
          },
        );
      },
    );
  }
}
