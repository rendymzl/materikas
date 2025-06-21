import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../global_widget/product_list_widget/add_product_list_widget.dart';

class ProductSalesListView extends GetView {
  const ProductSalesListView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Pilih Barang'),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: AddProductListWidget(
        onClick: (product) => controller.addToCart(product, po: true),
        isSales: true,
      ),
    );
  }
}
