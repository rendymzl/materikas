import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../../infrastructure/utils/display_format.dart';

class CalculateSalesPrice extends StatelessWidget {
  const CalculateSalesPrice({
    super.key,
    required this.invoice,
    this.isEdit = false,
    this.po = false,
  });

  final InvoiceSalesModel invoice;
  final bool isEdit;
  final bool po;

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
                          invoice.subtotalCost,
                        ),
                      ),
                      if (invoice.totalDiscount > 0)
                        PropertiesRowWidget(
                          title: 'Total Diskon',
                          value: '-${currency.format(invoice.totalDiscount)}',
                        ),
                      Divider(color: Colors.grey[200]),
                      if (isEdit)
                        PropertiesRowWidget(
                          title: 'Total Belanja',
                          value: currency.format(invoice.totalCost),
                        ),
                      if (isEdit)
                        PropertiesRowWidget(
                          title: 'Total Pembayaran',
                          value: currency.format(invoice.totalPaid),
                          color: Colors.green,
                        ),
                      // if (invoice.totalPaid < invoice.totalCost)
                      SizedBox(
                        height: 48,
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 300,
                                child: Text(
                                    po
                                        ? 'Total Purchase Order'
                                        : isEdit
                                            ? 'Sisa Bayar'
                                            : 'Total Belanja:',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                              Text(
                                'Rp${currency.format(isEdit ? invoice.remainingDebt : invoice.totalCost)}',
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // if (invoice.totalPaid < invoice.totalCost)
                      //   ListTile(
                      //     title:
                      //         PaymentButton(invoice: invoice, isEdit: isEdit),
                      //   )
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

class PropertiesRowWidget extends StatelessWidget {
  const PropertiesRowWidget({
    super.key,
    required this.title,
    required this.value,
    this.subValue,
    this.primary = false,
    this.italic = false,
    this.color,
  });

  final String title;
  final String value;
  final String? subValue;
  final bool primary;
  final bool italic;
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
                    style: primary
                        ? context.textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontStyle: italic ? FontStyle.italic : null,
                            color: color)
                        : context.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w400,
                            fontStyle: italic ? FontStyle.italic : null,
                            color: color)),
                Row(
                  children: [
                    Text(
                      subValue != null
                          ? subValue!.isEmpty ||
                                  subValue == '0' ||
                                  subValue == '-0'
                              ? '-'
                              : '$subValue'
                          : '',
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
            value == '0' || value == '-0'
                ? '-'
                : value == 'title'
                    ? ''
                    : 'Rp$value',
            style: primary
                ? context.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontStyle: italic ? FontStyle.italic : null,
                    color: color)
                : context.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w400,
                    fontStyle: italic ? FontStyle.italic : null,
                    color: color),
          )
        ],
      ),
    );
  }
}
