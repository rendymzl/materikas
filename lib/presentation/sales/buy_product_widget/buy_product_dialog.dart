import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../global_widget/popup_page_widget.dart';
import '../../global_widget/product_list_widget/product_list_widget.dart';
import '../controllers/sales.controller.dart';
import '../detail_sales/payment_sales/payment_sales_popup.dart';
import '../selected_product_sales_widget/selected_product_sales.dart';
import 'buy_product_controller.dart';

void buyProductDialog() async {
  final SalesController salesC = Get.find();
  final BuyProductController controller = Get.put(BuyProductController());
  controller.clear();
  // controller.cart.value.items.clear();
  // controller.updatedStockProducts.clear();
  controller.nomorInvoice.value = '';
  controller.filterProducts('');
  // if (selectecSales == null) {
  //   controller.selectedSales.value = selectecSales;
  //   controller.salesTextC.text = selectecSales.name!;
  // }

  // if (controller.initStockProducts.isNotEmpty) {
  //   for (var initStock in controller.initStockProducts) {
  //     var initProduct = controller.foundProducts
  //         .firstWhereOrNull((item) => item.id == initStock.id);
  //     if (initProduct != null) {
  //       initProduct.stock.value = initStock.stock.value;
  //     }
  //   }
  // }

  showPopupPageWidget(
    title: 'Beli Barang: ${salesC.selectedSales.value!.name!}',
    height: MediaQuery.of(Get.context!).size.height * (6 / 7),
    width: MediaQuery.of(Get.context!).size.width * (0.75),
    content: SizedBox(
      height: MediaQuery.of(Get.context!).size.height * (0.68),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ProductListWidget(
              onClick: (product) => controller.addToCart(product),
              isSales: true,
            ),
          ),
          VerticalDivider(
            thickness: 2,
            color: Colors.grey[200],
          ),
          const Expanded(
            flex: 5,
            child: SelectedProductSales(),
          ),
        ],
      ),
    ),
    buttonList: [
      ElevatedButton(
        onPressed: () async {
          controller.invoice.invoiceId = controller.nomorInvoice.value;
          if (controller.cart.value.items.isEmpty) {
            Get.defaultDialog(
              title: 'Error',
              middleText: 'Tidak ada Barang yang ditambahkan.',
              confirm: TextButton(
                onPressed: () => Get.back(),
                child: const Text('OK'),
              ),
            );
          } else if (controller.invoice.invoiceId == '') {
            Get.defaultDialog(
              title: 'Error',
              middleText: 'Masukkan Nomor Invoice.',
              confirm: TextButton(
                onPressed: () => Get.back(),
                child: const Text('OK'),
              ),
            );
          } else {
            paymentSalesPopup(controller.invoice);
          }
        },
        child: const Text('Bayar'),
      ),
    ],
    onClose: () {
      for (var cartItem in controller.initCartList) {
        var product = controller.foundProducts.firstWhereOrNull(
          (p) => p.id == cartItem.product.id,
        );
        if (product != null) {
          product.stock.value = cartItem.product.stock.value;
        }
      }
      controller.clear();
    },
  );
}
