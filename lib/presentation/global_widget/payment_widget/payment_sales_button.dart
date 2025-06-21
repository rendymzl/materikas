import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../sales/controllers/sales.controller.dart';
import '../../sales/detail_sales/payment_sales/payment_sales_controller.dart';

class PaySalesButtonWidget extends StatelessWidget {
  const PaySalesButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final salesC = Get.find<SalesController>();
    final paymentSalesC = Get.find<PaymentSalesController>();
    return Obx(() {
      if (paymentSalesC.selectedPaymentMethod.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return Expanded(
        child: ElevatedButton(
          onPressed: () async {
            final sales = paymentSalesC.editedInvoice.sales.value;
            await Future.delayed(const Duration(milliseconds: 500),
                () => salesC.selectedSalesHandle(sales!));
            await paymentSalesC.saveInvoice();
          },
          child: const Text('Bayar'),
        ),
      );
    });
  }
}
