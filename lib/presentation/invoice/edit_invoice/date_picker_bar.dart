import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../global_widget/date_picker_widget/date_picker_widget.dart';
import 'edit_invoice_controller.dart';

class DatePickerBar extends StatelessWidget {
  const DatePickerBar({
    super.key,
    required this.editInvoice,
  });

  final InvoiceModel editInvoice;

  @override
  Widget build(BuildContext context) {
    final EditInvoiceController controller = Get.find();
    // final AuthService accountC = Get.find();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Obx(
                () => InkWell(
                  onTap: () {
                    controller.priceTypeHandleCheckBox(2);
                    editInvoice.priceType.value == 1
                        ? editInvoice.priceType.value = 2
                        : editInvoice.priceType.value = 1;
                    editInvoice.updateIsDebtPaid();
                  },
                  child: SizedBox(
                    child: Row(
                      children: [
                        Checkbox(
                          value: editInvoice.priceType.value == 2,
                          onChanged: (value) {
                            controller.priceTypeHandleCheckBox(2);
                            editInvoice.priceType.value == 1
                                ? editInvoice.priceType.value = 2
                                : editInvoice.priceType.value = 1;
                            editInvoice.updateIsDebtPaid();
                          },
                        ),
                        Text(
                          'Harga ${controller.accountC.account.value!.name.toLowerCase() == 'arca nusantara' ? 'masuk gang' : '2'}',
                          style: editInvoice.priceType.value == 2
                              ? Get.context!.textTheme.bodySmall!.copyWith(
                                  color: Theme.of(context).colorScheme.primary)
                              : context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Obx(
                () => InkWell(
                  onTap: () {
                    controller.priceTypeHandleCheckBox(3);
                    editInvoice.priceType.value == 1
                        ? editInvoice.priceType.value = 3
                        : editInvoice.priceType.value = 1;
                    editInvoice.updateIsDebtPaid();
                  },
                  child: SizedBox(
                    child: Row(
                      children: [
                        Checkbox(
                          value: editInvoice.priceType.value == 3,
                          onChanged: (value) {
                            controller.priceTypeHandleCheckBox(3);
                            editInvoice.priceType.value == 1
                                ? editInvoice.priceType.value = 3
                                : editInvoice.priceType.value = 1;
                            editInvoice.updateIsDebtPaid();
                          },
                        ),
                        Text(
                          'Harga ${controller.accountC.account.value!.name.toLowerCase() == 'arca nusantara' ? 'material' : '3'}',
                          style: editInvoice.priceType.value == 3
                              ? context.textTheme.bodySmall!.copyWith(
                                  color: Theme.of(context).colorScheme.primary)
                              : context.textTheme.bodySmall,
                        ),
                      ],
                    ),
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
