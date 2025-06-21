import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../buy_product_widget/buy_product_controller.dart';
import '../buy_product_widget/buy_product_popup.dart';
import '../controllers/sales.controller.dart';

class SalesInvoiceListFooter extends StatelessWidget {
  const SalesInvoiceListFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final SalesController controller = Get.find();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Text(controller.selectedSales.value != null
                ? 'Total Invoice ${controller.invoiceById.length}'
                : 'Total Invoice ${controller.displayedItems.length}'),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: controller.selectedSales.value == null
                  ? null
                  : () async {
                      Get.put(BuyProductController()).init();
                      await buyProductPopup();
                    },
              child: const Text('Beli Barang'),
            ),
          ),
        ],
      ),
    );
  }
}
