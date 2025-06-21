import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../global_widget/app_dialog_widget.dart';
import '../../global_widget/popup_page_widget.dart';
import '../buy_product_widget/buy_product_controller.dart';
import '../selected_product_sales_widget/calculate_sales.dart';
import 'cart_list_invoice_sales.dart';
import 'payment_list_sales.dart';

void editSalesInvoicePopup() {
  final controller = Get.find<BuyProductController>();

  showPopupPageWidget(
    title: 'Edit Invoice',
    height: MediaQuery.of(Get.context!).size.height * (6 / 7),
    width: MediaQuery.of(Get.context!).size.width * (0.6),
    content: Expanded(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CardListInvoiceSales(editInvoice: controller.editInvoice),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        'Pembayaran',
                        style: Get.context!.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    PaymentListSalesWidget(editInvoice: controller.editInvoice),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CalculateSalesPrice(
                      editableInvoice: controller.editInvoice,
                      isEdit: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    buttonList: [
      ElevatedButton(
        onPressed: () async {
          AppDialog.show(
            title: 'Simpan Perubahan',
            content: 'Simpan perubahan Invoice?',
            confirmText: 'Simpan',
            cancelText: 'Batal',
            onConfirm: () async {
              await controller.updateInvoice();
              Get.back();
            },
          );
        },
        child: const Text('Simpan Perubahan'),
      ),
    ],
  );
}
