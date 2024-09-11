import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../global_widget/popup_page_widget.dart';
import '../field_customer_widget/field_customer_widget.dart';
import '../field_customer_widget/field_customer_widget_controller.dart';
import 'payment_content_widget.dart';
import 'payment_widget_controller.dart';

void paymentWidget(InvoiceModel invoice) {
  PaymentController controller = Get.put(PaymentController());
  late CustomerInputFieldController customerFieldC =
      Get.put(CustomerInputFieldController());

  controller.clear();
  customerFieldC.clear();
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
        if (invoice.id == null) const CustomerInputField(),
        PaymentContent(invoice: invoice),
      ],
    ),
    buttonList: [
      Obx(() {
        if (controller.selectedPaymentMethod.value != '') {
          return Expanded(
            child: ElevatedButton(
              onPressed: () async => await controller.saveInvoice(invoice),
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
