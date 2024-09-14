import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../infrastructure/models/invoice_sales_model.dart';
import '../../../global_widget/popup_page_widget.dart';
import '../../controllers/sales.controller.dart';
import 'payment_sales_content.dart';
import 'payment_sales_controller.dart';

void paymentSalesPopup(InvoiceSalesModel invoice,
    {bool isEdit = false, bool onlyPayment = false}) {
  PaymentSalesController controller = Get.put(PaymentSalesController());
  SalesController salesC = Get.find();

  controller.clear();
  controller.bill.value = invoice.remainingDebt;
  controller.moneyChange.value = invoice.remainingDebt;

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
                final sales = invoice.sales.value!;
                if (isEdit) {
                  await controller.addPayment(invoice);
                  print('invoice.debtAmount.value ${invoice.debtAmount.value}');
                  print('totalPaid ${invoice.totalPaid}');
                  Get.back();
                } else {
                  await controller.saveInvoice(invoice,
                      onlyPayment: onlyPayment);
                }
                Future.delayed(const Duration(milliseconds: 500),
                    () => salesC.selectedSalesHandle(sales));
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
