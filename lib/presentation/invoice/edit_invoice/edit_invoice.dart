import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../global_widget/date_picker_widget/date_picker_widget_controller.dart';
import '../../global_widget/field_customer_widget/field_customer_widget.dart';
import '../../global_widget/field_customer_widget/field_customer_widget_controller.dart';
import '../../global_widget/popup_page_widget.dart';
import 'date_picker_bar.dart';
import 'edit_invoice_controller.dart';

void editInvoice(InvoiceModel invoice) {
  late EditInvoiceController controller = Get.put(EditInvoiceController());
  Get.lazyPut(() => DatePickerController());
  late DatePickerController _datePickerC = Get.find();
  late CustomerInputFieldController _customerInputFieldC =
      Get.put(CustomerInputFieldController());
  _datePickerC.asignDateTime(invoice.createdAt.value!);

  if (invoice.customer.value != null) {
    _customerInputFieldC.asignCustomer(invoice.customer.value!);
  }

  InvoiceModel editInvoice = InvoiceModel.fromJson(invoice.toJson());

  showPopupPageWidget(
    title: 'Edit Invoice ${editInvoice.invoiceId}',
    height: MediaQuery.of(Get.context!).size.height * (6 / 7),
    width: MediaQuery.of(Get.context!).size.width * (5 / 11),
    content: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      children: [
        DatePickerBar(editInvoice: editInvoice),
        const CustomerInputField()
      ],
    ),
    buttonList: [],
  );
}
