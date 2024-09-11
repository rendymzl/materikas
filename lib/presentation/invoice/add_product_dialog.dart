import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../infrastructure/models/invoice_model/cart_model.dart';
import '../global_widget/popup_page_widget.dart';
import '../global_widget/product_list_widget/product_list_widget.dart';
import 'edit_invoice/edit_invoice_controller.dart';

void addProductDialog(Cart cart) {
  final EditInvoiceController controller = Get.find();
  showPopupPageWidget(
    title: 'Tambah Barang',
    height: MediaQuery.of(Get.context!).size.height * (0.8),
    width: MediaQuery.of(Get.context!).size.width * (0.4),
    content: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: MediaQuery.of(Get.context!).size.height * (0.7),
          child: ProductListWidget(
            onClick: (product) {
              controller.addToCart(product, cart);
              Get.back();
            },
          ),
        ),
      ],
    ),
  );
}
