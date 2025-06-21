import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../field_customer_widget/field_customer_widget.dart';
import 'payment_card_widget.dart';
import 'payment_widget_controller.dart';

class PaymentContent extends StatelessWidget {
  const PaymentContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PaymentController>();
    print(
        'clickedaaaa PaymentContent ${controller.selectedPaymentMethod.value}');
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        if (controller.editedInvoice.id == null) _buildCustomerInputCard(),
        _buildPaymentContentCard(),
      ],
    );
  }

  Widget _buildCustomerInputCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: const CustomerInputField(),
      ),
    );
  }

  Widget _buildPaymentContentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: PaymentCard(),
      ),
    );
  }
}
