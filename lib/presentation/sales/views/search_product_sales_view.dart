import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../global_widget/product_list_widget/add_product_list_widget.dart';
import '../buy_product_widget/buy_product_controller.dart';

class SearchProductSalesView extends GetView {
  const SearchProductSalesView({super.key});
  @override
  Widget build(BuildContext context) {
      BuyProductController controller = Get.find();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Pilih Barang'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AddProductListWidget(
          isSales: true,
          onClick: (product) {
            controller.addToCart(product);
            Get.back();
          },
          cart: controller.cart.value,
        ),
      ),
    );
  }
}
