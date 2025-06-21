import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/cart_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../global_widget/app_dialog_widget.dart';
import '../../global_widget/date_picker_widget/date_picker_widget_controller.dart';
import '../../global_widget/field_customer_widget/field_customer_widget_controller.dart';
import '../../global_widget/popup_page_widget.dart';
import '../edit_invoice/edit_invoice_controller.dart';
import '../edit_invoice/return_cart_list.dart';
import '../views/invoice_return_view.dart';

Future<void> returnProduct(InvoiceModel invoice) async {
  final editInvC = Get.put(EditInvoiceController());
  final datePickerC = Get.put(DatePickerController());
  final customerInputFieldC = Get.put(CustomerInputFieldController());

  datePickerC.asignDateTime(invoice.createdAt.value!);
  editInvC.currentInvoice = invoice;
  editInvC.editInvoice = InvoiceModel.fromJson(invoice.toJson());
  editInvC.editInvoice.returnList.value ??= Cart(items: <CartItem>[].obs);

  if (invoice.customer.value != null) {
    customerInputFieldC.asignCustomer(editInvC.editInvoice.customer.value!);
  }

  await showPopupPageWidget(
    title: 'Return',
    height: MediaQuery.of(Get.context!).size.height * (6 / 7),
    width: MediaQuery.of(Get.context!).size.width * (0.6),
    content: _buildReturnContent(editInvC),
    buttonList: [
      ElevatedButton(
        onPressed: () =>
            _saveChanges(editInvC, invoice, datePickerC, customerInputFieldC),
        child: const Text('Simpan Perubahan'),
      ),
    ],
  );
}

Widget _buildReturnContent(EditInvoiceController editInvC) {
  return Expanded(
    child: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ReturnCartList(isPureReturn: true),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final hasAdditionalReturns =
              editInvC.editInvoice.returnList.value?.items.isNotEmpty ?? false;
          return hasAdditionalReturns
              ? Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          'Return Tambahan',
                          style: Theme.of(Get.context!).textTheme.titleLarge,
                          textAlign: TextAlign.end,
                        ),
                        const SizedBox(height: 12),
                        ReturnCartList(),
                      ],
                    ),
                  ),
                )
              : const SizedBox();
        }),
        ReturnFeeWidget(),
      ],
    ),
  );
}

void _saveChanges(
    EditInvoiceController controller,
    InvoiceModel invoice,
    DatePickerController datePickerController,
    CustomerInputFieldController customerInputFieldController) {
  // print('object ${invoice.toJson()}');
  // print('object ${controller.editInvoice.toJson()}');
  AppDialog.show(
    title: 'Simpan Return',
    content: 'Simpan Return?',
    confirmText: 'Simpan',
    cancelText: 'Batal',
    onConfirm: () async {
      // final editInvoice = controller.editInvoice;
      // invoice.id = editInvoice.id;
      // invoice.invoiceId = editInvoice.invoiceId;
      // invoice.createdAt.value = datePickerController.selectedDate.value;
      // invoice.customer.value =
      //     customerInputFieldController.selectedCustomer.value;
      // invoice.purchaseList.value = editInvoice.purchaseList.value;
      // invoice.returnList.value = editInvoice.returnList.value;
      // invoice.returnFee.value = editInvoice.returnFee.value;
      // invoice.priceType.value = editInvoice.priceType.value;
      // invoice.discount.value = editInvoice.discount.value;
      // invoice.payments.value = editInvoice.payments;
      // invoice.debtAmount.value = editInvoice.debtAmount.value;
      // invoice.isDebtPaid.value = editInvoice.isDebtPaid.value;
      // invoice.otherCosts.value = editInvoice.otherCosts;
      await controller.updateInvoice();
      Get.back();
    },
    onCancel: () => Get.back(),
  );
}
