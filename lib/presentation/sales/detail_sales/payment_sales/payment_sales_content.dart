import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../../infrastructure/utils/display_format.dart';
import 'payment_sales_controller.dart';

class PaymentSalesContent extends StatelessWidget {
  const PaymentSalesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [_buildPaymentContentCard()],
    );
  }

  Widget _buildPaymentContentCard() {
    final controller = Get.find<PaymentSalesController>();
    final invoice = controller.editedInvoice;

    Widget buildPaymentMethodButton(
        String label, String paymentMethod, IconData icon) {
      return Expanded(
        child: InkWell(
          onTap: () => controller.setPaymentMethod(paymentMethod),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: controller.selectedPaymentMethod.value == paymentMethod
                    ? Theme.of(Get.context!).colorScheme.primary
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Theme.of(Get.context!).colorScheme.primary)),
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
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: controller.selectedPaymentMethod.value ==
                                paymentMethod
                            ? Colors.white
                            : null)),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildPaymentMethodButton(
                      'Cash', controller.paymentMethod[0], Symbols.payments),
                  const SizedBox(width: 12),
                  buildPaymentMethodButton(
                      'Transfer', controller.paymentMethod[1], Symbols.payment),
                ],
              ),
              const SizedBox(height: 14),
              Obx(
                () {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Text(
                            invoice.totalCost != invoice.remainingDebt
                                ? 'SISA TAGIHAN:'
                                : 'TAGIHAN:',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Obx(
                            () => Text(
                              'Rp${currency.format(controller.bill.value)}',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(Get.context!)
                                      .colorScheme
                                      .primary),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      )
                    ],
                  );
                },
              ),
              if ((invoice.totalDiscount > 0 &&
                  invoice.totalCost == invoice.remainingDebt))
                Text(
                  'Rp${currency.format(invoice.subtotalCost)}',
                  style: Get.context!.textTheme.bodySmall!.copyWith(
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.lineThrough),
                ),
              const SizedBox(height: 12),
              if (controller.selectedPaymentMethod.value != '')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: SizedBox(
                        child: Text('Bayar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        child: TextField(
                          focusNode: controller.paymentTextFocusNode,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                          controller: controller.paymentTextC,
                          decoration: const InputDecoration(
                            prefixIcon: Text('Rp. ',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            prefixIconConstraints:
                                BoxConstraints(minWidth: 0, minHeight: 0),
                            hintText: '0',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                          ],
                          onChanged: (value) => controller.onPayChanged(value),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              if (controller.selectedPaymentMethod.value != '')
                Obx(
                  () {
                    return Container(
                      key: controller.lastWidgetKey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              controller.moneyChange.value < 0
                                  ? 'Kembalian'
                                  : 'Kurang',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Rp. ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 3),
                                  child: Text(
                                    currency.format(
                                        controller.moneyChange.value * -1),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
