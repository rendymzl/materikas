import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import '../../../infrastructure/models/invoice_model/cart_model.dart';
import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/popup_page_widget.dart';
import '../../global_widget/product_list_widget/add_product_list_widget.dart';
import '../buy_product_widget/buy_product_controller.dart';

void addProductSalesDialog(
  InvoiceSalesModel invoiceSales,
) {
  final BuyProductController controller = Get.find();
  controller.cart.value = invoiceSales.purchaseList.value;
  showPopupPageWidget(
    title: 'Tambah Barang',
    height: MediaQuery.of(Get.context!).size.height * (vertical ? 0.65 : 0.8),
    width: MediaQuery.of(Get.context!).size.width * (vertical ? 0.9 : 0.4),
    content: Expanded(
      child: AddProductListWidget(
        onClick: (product) {
          controller.addToCart(product);
          invoiceSales.updateIsDebtPaid();
          Get.back();
        },
        isSales: true,
        cart: controller.cart.value,
      ),
    ),
  );
}
