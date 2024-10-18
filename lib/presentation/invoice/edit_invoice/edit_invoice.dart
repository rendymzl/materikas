import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/cart_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../global_widget/app_dialog_widget.dart';
import '../../global_widget/date_picker_widget/date_picker_widget_controller.dart';
import '../../global_widget/field_customer_widget/field_customer_widget.dart';
import '../../global_widget/field_customer_widget/field_customer_widget_controller.dart';
import '../../global_widget/payment_widget/payment_list_widget.dart';
import '../../global_widget/popup_page_widget.dart';
import '../../home/selected_product_widget/calculate_price.dart';
import '../cart_list_widget.dart';
import 'date_picker_bar.dart';
import 'edit_invoice_controller.dart';

void editInvoice(InvoiceModel invoice) {
  final EditInvoiceController controller = Get.put(EditInvoiceController());
  Get.lazyPut(() => DatePickerController());
  late DatePickerController datePickerC = Get.find();
  late CustomerInputFieldController customerInputFieldC =
      Get.put(CustomerInputFieldController());
  datePickerC.asignDateTime(invoice.createdAt.value!);

  InvoiceModel editInvoice = InvoiceModel.fromJson(invoice.toJson());

  if (invoice.customer.value != null) {
    customerInputFieldC.asignCustomer(editInvoice.customer.value!);
  }

  editInvoice.returnList.value ??= Cart(items: <CartItem>[].obs);
  showPopupPageWidget(
    title: 'Edit Invoice ${editInvoice.invoiceId}',
    height: MediaQuery.of(Get.context!).size.height * (6 / 7),
    width: MediaQuery.of(Get.context!).size.width * (0.65),
    content: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      children: [
        DatePickerBar(editInvoice: editInvoice),
        const CustomerInputField(),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CardListWidget(editInvoice: editInvoice),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      'Pembayaran',
                      style: Get.context!.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  PaymentListWidget(
                    editInvoice: editInvoice,
                  )
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CalculatePrice(invoice: editInvoice, isEdit: true),
                ],
              ),
            ),
          ],
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
              double prevTotalAppBill = invoice.appBillAmount.value;
              invoice.id = editInvoice.id;
              invoice.invoiceId = editInvoice.invoiceId;
              invoice.createdAt.value = datePickerC.selectedDate.value;
              invoice.customer.value =
                  customerInputFieldC.selectedCustomer.value;
              invoice.purchaseList.value = editInvoice.purchaseList.value;
              // invoice.returnList.value = editInvoice.returnList.value;
              invoice.priceType.value = editInvoice.priceType.value;
              invoice.discount.value = editInvoice.discount.value;
              invoice.returnFee.value = editInvoice.returnFee.value;
              invoice.payments.value = editInvoice.payments;
              invoice.debtAmount.value = editInvoice.debtAmount.value;
              // invoice.appBillAmount.value = editInvoice.appBillAmount.value;
              invoice.isDebtPaid.value = editInvoice.isDebtPaid.value;
              invoice.otherCosts.value = editInvoice.otherCosts;
              print('----edit invoice ${invoice.customer.value!.customerId}');
              controller.updateInvoice(invoice,
                  prevTotalAppBill: prevTotalAppBill);
              Get.back();
            },
            onCancel: () => Get.back(),
          );
        },
        child: const Text(
          'Simpan Perubahan',
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
