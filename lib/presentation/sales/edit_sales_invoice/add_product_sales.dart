import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_model/cart_model.dart';
import '../../global_widget/popup_page_widget.dart';
import '../../global_widget/product_list_widget/product_list_widget.dart';
import '../buy_product_widget/buy_product_controller.dart';

void addProductSalesDialog(Cart cart, {bool isPopUp = false}) {
  final BuyProductController controller = Get.find();
  showPopupPageWidget(
    title: 'Tambah Barang',
    height: MediaQuery.of(Get.context!).size.height * (0.8),
    width: MediaQuery.of(Get.context!).size.width * (0.4),
    content: SizedBox(
      height: MediaQuery.of(Get.context!).size.height * (0.7),
      child: ProductListWidget(
        isPopUp: isPopUp,
        onClick: (product) {
          controller.addToCartEdit(product, cart);
          Get.back();
        },
      ),
    ),
  );
}
