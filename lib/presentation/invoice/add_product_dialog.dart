import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../infrastructure/models/invoice_model/cart_model.dart';
import '../global_widget/popup_page_widget.dart';
import '../global_widget/product_list_widget/add_product_list_widget.dart';
import '../product/controllers/product.controller.dart';
import 'edit_invoice/edit_invoice_controller.dart';

void addProductDialog(Cart editedCart,
    {bool isReturnPage = false}) {
  final EditInvoiceController controller = Get.find();
  Get.put(ProductController());
  showPopupPageWidget(
    title: 'Tambah Barang',
    height: MediaQuery.of(Get.context!).size.height * (0.8),
    width: MediaQuery.of(Get.context!).size.width * (0.4),
    content: Expanded(
      child: AddProductListWidget(
        cart: isReturnPage
              ?  controller.editInvoice.returnList.value : controller.editInvoice.purchaseList.value,
        onClick: (product) {
          print('add ${product.stock.value}');
          isReturnPage
              ? controller.addToNewReturnCart(product)
              : controller.addToCart(product);
          Get.back();
        },
      ),
    ),
  );
}
