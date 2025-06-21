import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../presentation/global_widget/payment_widget/payment_button_widget.dart';
import '../../../presentation/global_widget/payment_widget/payment_content_widget.dart';

class PaymentView extends GetView {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.back(result: true);
            },
          ),
          title: const Text('Pembayaran'),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: PaymentContent(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [PayButtonWidget()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
