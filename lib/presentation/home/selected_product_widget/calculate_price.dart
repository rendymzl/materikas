import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/payment_widget/payment_popup_widget.dart';

class CalculatePrice extends StatelessWidget {
  const CalculatePrice({
    super.key,
    required this.invoice,
    this.isEdit = false,
  });

  final InvoiceModel invoice;
  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () {
                final cartItems = invoice.purchaseList.value.items;
                return SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      PropertiesRowWidget(
                        title: 'Total Harga (${cartItems.length} Barang)',
                        value: currency.format(
                          invoice.subtotalBill,
                        ),
                      ),
                      if (invoice.totalDiscount > 0)
                        PropertiesRowWidget(
                          title: 'Total Diskon',
                          value: '-${currency.format(invoice.totalDiscount)}',
                        ),
                      if (invoice.otherCosts.isNotEmpty)
                        ListTile(
                          title: Text(
                            'Biaya Lainnya:',
                            style: Get.context!.textTheme.bodySmall,
                          ),
                        ),
                      if (invoice.otherCosts.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: invoice.otherCosts.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              tileColor: Colors.grey[100],
                              dense: true,
                              title: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Text(invoice.otherCosts[index].name,
                                        style: Theme.of(Get.context!)
                                            .textTheme
                                            .titleSmall,
                                        textAlign: TextAlign.left),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                        'Rp${currency.format(invoice.otherCosts[index].amount)}',
                                        style: Theme.of(Get.context!)
                                            .textTheme
                                            .titleSmall,
                                        textAlign: TextAlign.end),
                                  ),
                                ],
                              ),
                              leading: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Container(
                                  height: 28,
                                  width: 28,
                                  decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(6))),
                                  child: IconButton(
                                    onPressed: () => invoice.removeOtherCost(
                                        invoice.otherCosts[index].name),
                                    icon: const Icon(
                                      Symbols.close,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      // PropertiesRowWidget(
                      //   title: 'Total Biaya Lainnya',
                      //   value: '-${currency.format(invoice.totalOtherCosts)}',
                      // ),
                      Divider(color: Colors.grey[200]),
                      if (isEdit)
                        PropertiesRowWidget(
                          title: 'Total Belanja',
                          value: currency.format(invoice.totalBill),
                        ),
                      if (isEdit)
                        PropertiesRowWidget(
                          title: 'Total Pembayaran',
                          value: currency.format(invoice.totalPaid),
                          color: Colors.green,
                        ),
                      if (isEdit)
                        PropertiesRowWidget(
                          title: 'Return Tambahan',
                          value: currency.format(invoice.totalAdditionalReturn),
                          color: Colors.red,
                        ),
                      if (invoice.totalPaid < invoice.totalBill)
                        SizedBox(
                          height: 48,
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                      isEdit ? 'Sisa Bayar' : 'Total Belanja:',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                                Text(
                                  'Rp${currency.format(isEdit ? invoice.remainingDebt : invoice.totalBill)}',
                                  style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                )
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 30),
                      if (invoice.totalPaid < invoice.totalBill)
                        ListTile(
                          title:
                              PaymentButton(invoice: invoice, isEdit: isEdit),
                        )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentButton extends StatelessWidget {
  const PaymentButton({
    super.key,
    required this.invoice,
    required this.isEdit,
  });

  final InvoiceModel invoice;
  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              if (invoice.totalBill > 0) {
                paymentPopup(invoice, isEdit: isEdit);
              } else {
                Get.defaultDialog(
                  title: 'Error',
                  middleText: 'Tidak ada Barang yang ditambahkan.',
                  confirm: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('OK'),
                  ),
                );
              }
            },
            child: Text(isEdit ? 'Bayar' : 'Pilih Pembayaran'),
          ),
        ),
      ],
    );
  }
}

class PropertiesRowWidget extends StatelessWidget {
  const PropertiesRowWidget({
    super.key,
    required this.title,
    required this.value,
    this.subValue,
    this.primary,
    this.color,
  });

  final String title;
  final String value;
  final String? subValue;
  final bool? primary;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: primary != null && primary == true
                        ? context.textTheme.titleLarge!
                            .copyWith(fontWeight: FontWeight.bold, color: color)
                        : context.textTheme.titleMedium!
                            .copyWith(color: color)),
                Row(
                  children: [
                    Text(
                      subValue ?? '',
                      style: context.textTheme.bodySmall!
                          .copyWith(fontStyle: FontStyle.italic, color: color),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ],
            ),
          ),
          Text(
            value == '0' || value == '-0' ? '-' : 'Rp$value',
            style: primary != null && primary == true
                ? context.textTheme.titleLarge!
                    .copyWith(fontWeight: FontWeight.bold, color: color)
                : context.textTheme.titleMedium!.copyWith(color: color),
          )
        ],
      ),
    );
  }
}
