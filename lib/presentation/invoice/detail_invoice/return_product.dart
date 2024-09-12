import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../global_widget/app_dialog_widget.dart';
import '../../global_widget/date_picker_widget/date_picker_widget_controller.dart';
import '../../global_widget/field_customer_widget/field_customer_widget_controller.dart';
import '../../global_widget/popup_page_widget.dart';
import '../cart_list_widget.dart';
import '../edit_invoice/edit_invoice_controller.dart';

void returnProduct(InvoiceModel invoice) {
  final EditInvoiceController controller = Get.put(EditInvoiceController());
  Get.lazyPut(() => DatePickerController());
  late DatePickerController datePickerC = Get.find();
  late CustomerInputFieldController customerInputFieldC =
      Get.put(CustomerInputFieldController());
  datePickerC.asignDateTime(invoice.createdAt.value!);

  if (invoice.customer.value != null) {
    customerInputFieldC.asignCustomer(invoice.customer.value!);
  }

  InvoiceModel editInvoice = InvoiceModel.fromJson(invoice.toJson());

  showPopupPageWidget(
    title: 'Return',
    height: MediaQuery.of(Get.context!).size.height * (6 / 7),
    width: MediaQuery.of(Get.context!).size.width * (0.6),
    content: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                CardListWidget(editInvoice: editInvoice, isReturnPage: true),
              ],
            ),
          ),
        ),
      ],
    ),
    buttonList: [
      ElevatedButton(
        onPressed: () {
          AppDialog.show(
            title: 'Simpan Perubahan',
            content: 'Simpan perubahan Invoice?',
            confirmText: 'Simpan',
            cancelText: 'Batal',
            onConfirm: () {
              invoice.id = editInvoice.id;
              invoice.invoiceId = editInvoice.invoiceId;
              invoice.createdAt.value = editInvoice.createdAt.value;
              invoice.customer.value = editInvoice.customer.value;
              invoice.purchaseList.value = editInvoice.purchaseList.value;
              invoice.returnList.value = editInvoice.returnList.value;
              invoice.priceType.value = editInvoice.priceType.value;
              invoice.discount.value = editInvoice.discount.value;
              invoice.returnFee.value = editInvoice.returnFee.value;
              invoice.payments.value = editInvoice.payments;
              invoice.debtAmount.value = editInvoice.debtAmount.value;
              invoice.isDebtPaid.value = editInvoice.isDebtPaid.value;
              invoice.otherCosts.value = editInvoice.otherCosts;
              controller.updateInvoice(invoice);
              Get.back();
            },
            onCancel: () => Get.back(),
          );
        },
        child: const Text(
          'Simpan Return',
        ),
      ),
    ],
    onClose: () {
      for (var cartItem in controller.initCartList) {
        var product = controller.foundProducts.firstWhereOrNull(
          (p) => p.id == cartItem.product.id,
        );
        if (product != null) {
          product.stock.value = cartItem.product.stock.value;
        }
      }
      controller.clear();
      print('closed');
    },
  );
}
