import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../../infrastructure/utils/display_format.dart';

class PaymentListSalesWidget extends StatelessWidget {
  const PaymentListSalesWidget({
    super.key,
    required this.editInvoice,
  });

  final InvoiceSalesModel editInvoice;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(height: 4),
        shrinkWrap: true,
        itemCount: editInvoice.payments.length,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: editInvoice.payments[index].method == 'cash'
                ? editInvoice.payments[index].method == 'cash'
                    ? Colors.green[50]
                    : Colors.blue[50]
                : Colors.blue[50],
            child: ListTile(
              dense: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${editInvoice.payments[index].method}',
                      style: Theme.of(Get.context!)
                          .textTheme
                          .titleSmall!
                          .copyWith(
                              color:
                                  editInvoice.payments[index].method == 'cash'
                                      ? Colors.green
                                      : Colors.blue),
                      textAlign: TextAlign.left),
                  Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(6))),
                    child: IconButton(
                      onPressed: () => editInvoice
                          .removePayment(editInvoice.payments[index]),
                      icon: const Icon(
                        Symbols.close,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                children: [
                  Expanded(
                      flex: 5,
                      child: Text(
                          DateFormat('dd MMM y', 'id')
                              .format(editInvoice.payments[index].date!),
                          style: Theme.of(Get.context!)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  color: editInvoice.payments[index].method ==
                                          'cash'
                                      ? Colors.green
                                      : Colors.blue),
                          textAlign: TextAlign.left)),
                  Expanded(
                      flex: 3,
                      child: Text(
                          'Rp${currency.format(editInvoice.payments[index].amountPaid)}',
                          style: Theme.of(Get.context!)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  color: editInvoice.payments[index].method ==
                                          'cash'
                                      ? Colors.green
                                      : Colors.blue),
                          textAlign: TextAlign.end)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
