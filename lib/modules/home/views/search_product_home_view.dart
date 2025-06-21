import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../presentation/global_widget/product_list_widget/add_product_list_widget.dart';
import '../../../presentation/home/controllers/home.controller.dart';

class SearchProductHomeView extends GetView {
  const SearchProductHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    HomeController controller = Get.find();
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
