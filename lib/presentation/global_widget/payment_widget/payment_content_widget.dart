import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import 'payment_widget_controller.dart';

class PaymentContent extends StatelessWidget {
  const PaymentContent({super.key, required this.invoice});

  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    late PaymentController controller = Get.find();
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Divider(color: Colors.grey[200]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: ListTile(
                  tileColor: Colors.grey[100],
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<String>(
                        value: controller.paymentMethod[0],
                        groupValue: controller.selectedPaymentMethod.value,
                        onChanged: (value) {
                          controller.setPaymentMethod(value!);
                        },
                      ),
                      const Text('Cash'),
                    ],
                  ),
                  onTap: () =>
                      controller.setPaymentMethod(controller.paymentMethod[0]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ListTile(
                  tileColor: Colors.grey[100],
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<String>(
                        value: controller.paymentMethod[1],
                        groupValue: controller.selectedPaymentMethod.value,
                        onChanged: (value) {
                          controller.setPaymentMethod(value!);
                        },
                      ),
                      const Text('Transfer'),
                    ],
                  ),
                  onTap: () =>
                      controller.setPaymentMethod(controller.paymentMethod[1]),
                ),
              ),
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
                        invoice.totalBill != invoice.remainingDebt
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
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  )
                ],
              );
            },
          ),
          // const SizedBox(height: 12),
          if ((invoice.totalDiscount > 0 &&
                  invoice.totalBill == invoice.remainingDebt) ||
              controller.isAdditionalDiscount.value)
            Text(
              'Rp${currency.format(invoice.subtotalBill)}',
              style: context.textTheme.bodySmall!.copyWith(
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.lineThrough),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SizedBox(
                  child: InkWell(
                    onTap: () => controller.checkBoxAdditionalDiscount(invoice),
                    child: Row(
                      children: [
                        Checkbox(
                          value: controller.isAdditionalDiscount.value,
                          onChanged: (value) =>
                              controller.checkBoxAdditionalDiscount(invoice),
                        ),
                        controller.isAdditionalDiscount.value
                            ? const Text('Diskon Tambahan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ))
                            : const Text('Tambahan Diskon',
                                style: TextStyle(
                                    fontSize: 12, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  child: !controller.isAdditionalDiscount.value
                      ? null
                      : TextField(
                          focusNode: controller.additionalDiscountFocusNode,
                          // autofocus: true,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                          controller: controller.additionalDiscountTextC,
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
                          onChanged: (value) =>
                              controller.additionalDiscount(invoice, value)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (controller.selectedPaymentMethod.value != '')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: SizedBox(
                    // width: 120,
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
                      // autofocus: true,
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
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                      ],
                      onChanged: (value) =>
                          controller.onPayChanged(invoice, value),
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
                                currency
                                    .format(controller.moneyChange.value * -1),
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
    );
  }
}
