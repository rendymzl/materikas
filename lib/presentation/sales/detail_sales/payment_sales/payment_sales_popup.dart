import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../infrastructure/models/invoice_sales_model.dart';
import '../../../global_widget/popup_page_widget.dart';
import 'payment_sales_content.dart';
import 'payment_sales_controller.dart';

void paymentSalesPopup(InvoiceSalesModel invoice,
    {bool isEdit = false, bool onlyPayment = false}) {
  PaymentSalesController controller = Get.put(PaymentSalesController());

  controller.clear();
  controller.bill.value = invoice.remainingDebt;
  controller.moneyChange.value = invoice.remainingDebt;
  controller.additionalDiscountTextC.text = '';
  controller.isAdditionalDiscount.value = false;

  showPopupPageWidget(
    title: 'Pembayaran',
    height: MediaQuery.of(Get.context!).size.height * (6 / 7),
    width: MediaQuery.of(Get.context!).size.width * (4 / 11),
    content: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      children: [
        PaymentSalesContent(invoice: invoice),
      ],
    ),
    buttonList: [
      Obx(() {
        if (controller.selectedPaymentMethod.value != '') {
          return Expanded(
            child: ElevatedButton(
              onPressed: () async {
                if (isEdit) {
                  await controller.addPayment(invoice);
                  Get.back();
                } else {
                  await controller.saveInvoice(invoice,
                      onlyPayment: onlyPayment);
                }
              },
              child: const Text('Bayar'),
            ),
          );
        } else {
          return Container();
        }
      }),
    ],
  );
}
