import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../global_widget/popup_page_widget.dart';
import 'payment_button_widget.dart';
import 'payment_content_widget.dart';
import 'payment_widget_controller.dart';

Future<void> paymentPopup() async {
  final paymentC = Get.find<PaymentController>();
  print('isEditing? ${paymentC.isEdit.value}');
  showPopupPageWidget(
    title: 'Pembayaran',
    height: MediaQuery.of(Get.context!).size.height * (6 / 7),
    width: MediaQuery.of(Get.context!).size.width * (4 / 11),
    content: Expanded(
      child: PaymentContent(),
    ),
    buttonList: [PayButtonWidget()],
  );
}
