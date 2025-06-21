import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../global_widget/popup_page_widget.dart';
import '../../global_widget/product_list_widget/add_product_list_widget.dart';
import '../buy_product_widget/buy_product_controller.dart';
// import '../controllers/sales.controller.dart';

void selectSalesProduct() async {
  // final SalesController salesC = Get.find();
  final BuyProductController controller = Get.find();

  showPopupPageWidget(
    title: 'Tambah Barang',
    height: MediaQuery.of(Get.context!).size.height * (0.65),
    width: MediaQuery.of(Get.context!).size.width * (0.8),
    content: Expanded(
      child: AddProductListWidget(
        onClick: (product) => controller.addToCart(product),
        isSales: true,
        cart: controller.cart.value,
      ),
    ),
  );
}
