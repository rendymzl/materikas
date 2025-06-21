import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../global_widget/payment_widget/payment_sales_button.dart';
import '../detail_sales/payment_sales/payment_sales_content.dart';

class PaymentSalesInvoiceView extends GetView {
  const PaymentSalesInvoiceView({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Pembayaran Sales'),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: PaymentSalesContent(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [PaySalesButtonWidget()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
