import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home.controller.dart';
import 'cart.dart';

class CartListWidget extends StatelessWidget {
  const CartListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();
    return Obx(
      () {
        final cartItems = controller.cart.value.items;
        return ListView.builder(
          shrinkWrap: true,
          controller: controller.scrollController,
          itemCount: cartItems.length,
          itemBuilder: (BuildContext context, int index) {
            final item = cartItems[index];
            return CartWidget(
              item: item,
              index: index,
            );
          },
        );
      },
    );
  }
}
