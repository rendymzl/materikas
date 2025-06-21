import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'payment_widget_controller.dart';

class PayButtonWidget extends StatelessWidget {
  const PayButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentC = Get.find<PaymentController>();
    print('isEditing? paybuttin ${paymentC.isEdit.value}');
    return Obx(() {
      if (paymentC.selectedPaymentMethod.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return Expanded(
        child: ElevatedButton(
          onPressed: () async {
            await paymentC.saveInvoice();
          },
          child: const Text('Bayar'),
        ),
      );
    });
  }
}
