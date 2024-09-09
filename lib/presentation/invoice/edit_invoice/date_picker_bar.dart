import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../global_widget/date_picker_widget/date_picker_widget.dart';

class DatePickerBar extends StatelessWidget {
  const DatePickerBar({
    super.key,
    required this.editInvoice,
  });

  final InvoiceModel editInvoice;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  editInvoice.priceType.value == 2
                      ? editInvoice.priceType.value = 1
                      : editInvoice.priceType.value = 2;
                  editInvoice.updateIsDebtPaid();
                },
                child: SizedBox(
                  child: Row(
                    children: [
                      Checkbox(
                        value: editInvoice.priceType.value == 2,
                        onChanged: (value) {
                          editInvoice.priceType.value == 2
                              ? editInvoice.priceType.value = 1
                              : editInvoice.priceType.value = 2;
                          editInvoice.updateIsDebtPaid();
                        },
                      ),
                      Text(
                        'Harga masuk gang',
                        style: editInvoice.priceType.value == 2
                            ? Get.context!.textTheme.bodySmall!.copyWith(
                                color: Theme.of(context).colorScheme.primary)
                            : context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              InkWell(
                onTap: () {
                  editInvoice.priceType.value == 3
                      ? editInvoice.priceType.value = 1
                      : editInvoice.priceType.value = 3;
                  editInvoice.updateIsDebtPaid();
                },
                child: SizedBox(
                  child: Row(
                    children: [
                      Checkbox(
                        value: editInvoice.priceType.value == 3,
                        onChanged: (value) {
                          editInvoice.priceType.value == 3
                              ? editInvoice.priceType.value = 1
                              : editInvoice.priceType.value = 3;
                          editInvoice.updateIsDebtPaid();
                        },
                      ),
                      Text(
                        'Harga material',
                        style: editInvoice.priceType.value == 3
                            ? context.textTheme.bodySmall!.copyWith(
                                color: Theme.of(context).colorScheme.primary)
                            : context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const DatePickerWidget(),
        ],
      ),
    );
  }
}
