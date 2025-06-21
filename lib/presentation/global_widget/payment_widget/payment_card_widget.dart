import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import 'payment_widget_controller.dart';

class PaymentCard extends StatelessWidget {
  const PaymentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PaymentController>();
    final invoice = controller.editedInvoice;
    print('clickedaaaa PaymentCard ${controller.selectedPaymentMethod.value}');
    return Obx(() {
      final selectedCustomer = controller.customerFieldC.selectedCustomer.value;
      var isDepositActive = selectedCustomer != null &&
          selectedCustomer.deposit != null &&
          selectedCustomer.deposit! > 0;

      if (!isDepositActive &&
          controller.selectedPaymentMethod.value == 'deposit') {
        Future.delayed(Duration.zero, () async {
          controller.selectedPaymentMethod.value = '';
        });
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // if (isDepositActive) _buildPaymentDeposit(controller),
          // if (isDepositActive) const SizedBox(height: 14),
          _buildPaymentMethodRow(controller),
          const SizedBox(height: 14),
          _buildTotalAmountRow(context, invoice, controller),
          if ((invoice.totalDiscount > 0 &&
                  invoice.totalBill == invoice.remainingDebt) ||
              controller.isAdditionalDiscount.value)
            _buildOriginalPrice(invoice),
          const SizedBox(height: 12),
          if (!controller.isEdit.value)
            _buildAdditionalDiscountSection(controller, invoice),
          const SizedBox(height: 12),
          if (controller.selectedPaymentMethod.value != '')
            _buildPaymentAndChangeSection(controller, invoice),
        ],
      );
    });
  }

  Widget _buildPaymentDeposit(PaymentController controller) {
    print(
        'clickedaaaa _buildPaymentMethodRow ${controller.selectedPaymentMethod.value}');
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildPaymentMethodButton(
                controller,
                'Deposit   (Rp${currency.format(controller.customerFieldC.selectedCustomer.value!.deposit!)})',
                controller.paymentMethod[2],
                Symbols.account_balance_wallet),
          ],
        ));
  }

  Widget _buildPaymentMethodRow(PaymentController controller) {
    print(
        'clickedaaaa _buildPaymentMethodRow ${controller.selectedPaymentMethod.value}');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildPaymentMethodButton(
            controller, 'Cash', controller.paymentMethod[0], Symbols.payments),
        const SizedBox(width: 12),
        buildPaymentMethodButton(controller, 'Transfer',
            controller.paymentMethod[1], Symbols.payment),
      ],
    );
  }

  Widget buildPaymentMethodButton(PaymentController controller, String label,
      String paymentMethod, IconData icon) {
    print(
        'clickedaaaa buildPaymentMethodButton ${controller.selectedPaymentMethod.value}');
    print('clickedaaaa buildPaymentMethodButton $paymentMethod');
    return Obx(
      () => Expanded(
        child: InkWell(
          onTap: () => controller.setPaymentMethod(paymentMethod),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: controller.selectedPaymentMethod.value == paymentMethod
                  ? Theme.of(Get.context!).colorScheme.primary
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: Theme.of(Get.context!).colorScheme.primary),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: controller.selectedPaymentMethod.value == paymentMethod
                      ? Colors.white
                      : Theme.of(Get.context!).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: controller.selectedPaymentMethod.value ==
                                  paymentMethod
                              ? Colors.white
                              : null),
                    ),
                    if (paymentMethod == 'deposit' && controller.pay.value > 0)
                      SizedBox(width: 12),
                    if (paymentMethod == 'deposit' && controller.pay.value > 0)
                      Text(
                        'Rp${currency.format(controller.customerFieldC.selectedCustomer.value!.deposit! - controller.pay.value)}',
                        style: TextStyle(
                            color: controller.selectedPaymentMethod.value ==
                                    paymentMethod
                                ? Colors.grey[200]
                                : null),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalAmountRow(BuildContext context, InvoiceModel invoice,
      PaymentController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            invoice.totalBill != invoice.remainingDebt
                ? 'SISA TAGIHAN:'
                : 'TAGIHAN:',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Obx(
          () => Text(
            'Rp${currency.format(controller.bill.value)}',
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildOriginalPrice(InvoiceModel invoice) {
    return Text(
      'Rp${currency.format(invoice.subtotalBill)}',
      style: Get.context!.textTheme.bodySmall!.copyWith(
          fontStyle: FontStyle.italic, decoration: TextDecoration.lineThrough),
    );
  }

  Widget _buildAdditionalDiscountSection(
      PaymentController controller, InvoiceModel invoice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: InkWell(
            onTap: () => controller.checkBoxAdditionalDiscount(invoice),
            child: Row(
              children: [
                Checkbox(
                    value: controller.isAdditionalDiscount.value,
                    onChanged: (value) =>
                        controller.checkBoxAdditionalDiscount(invoice)),
                Text(
                  'Diskon Tambahan',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: controller.isAdditionalDiscount.value
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Visibility(
            visible: controller.isAdditionalDiscount.value,
            child: TextField(
              focusNode: controller.additionalDiscountFocusNode,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
              controller: controller.additionalDiscountTextC,
              decoration: const InputDecoration(
                prefixIcon: Text('Rp. ',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                prefixIconConstraints:
                    BoxConstraints(minWidth: 0, minHeight: 0),
                hintText: '0',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
              ],
              onChanged: (value) =>
                  controller.additionalDiscount(invoice, value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentAndChangeSection(
      PaymentController controller, InvoiceModel invoice) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
                child: Text('Bayar',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                focusNode: controller.paymentTextFocusNode,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
                controller: controller.paymentTextC,
                decoration: const InputDecoration(
                  prefixIcon: Text('Rp. ',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  prefixIconConstraints:
                      BoxConstraints(minWidth: 0, minHeight: 0),
                  hintText: '0',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                ],
                onChanged: (value) => controller.onPayChanged(invoice, value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  controller.moneyChange.value < 0 ? 'Kembalian' : 'Kurang',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700]),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp.',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700]),
                      ),
                      Text(
                        currency.format(controller.moneyChange.value.abs()),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
