import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../global_widget/payment_widget/payment_sales_button.dart';
import '../../../global_widget/popup_page_widget.dart';
import 'payment_sales_content.dart';

Future<void> paymentSalesPopup() async {
  await showPopupPageWidget(
    title: 'Pembayaran',
    height: MediaQuery.of(Get.context!).size.height * (6 / 7),
    width: MediaQuery.of(Get.context!).size.width * (4 / 11),
    content: Expanded(
      child: PaymentSalesContent(),
    ),
    buttonList: [PaySalesButtonWidget()],
  );
}
