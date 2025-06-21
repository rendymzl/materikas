import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../global_widget/app_dialog_widget.dart';
import '../../global_widget/field_customer_widget/field_customer_widget.dart';
import '../../global_widget/invoice_widget/price_type_header_vertical.dart';
import '../../global_widget/payment_widget/payment_list_widget.dart';
import '../../global_widget/invoice_widget/transaction/calculate_price.dart';
import '../cart_list_widget.dart';
import '../edit_invoice/edit_invoice_controller.dart';

class InvoiceEditView extends GetView {
  const InvoiceEditView({super.key});
  @override
  Widget build(BuildContext context) {
    final editInvC = Get.find<EditInvoiceController>();
    // Get.lazyPut(() => DatePickerController());
    // late DatePickerController datePickerC = Get.find();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Symbols.arrow_back),
            onPressed: () {
              Get.back();
            },
          ),
          title: Text('Edit Invoice ${editInvC.editInvoice.invoiceId}'),
          centerTitle: true,
        ),
        // backgroundColor: Colors.blueGrey[50],
        body: Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(12),
                children: [
                  Card(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: VerticalPriceTypeView(
                      priceType: editInvC.editInvoice.priceType,
                      datetime: editInvC.editInvoice.createdAt,
                    ),
                  )),
                  const SizedBox(height: 12),
                  Card(
                    // padding: EdgeInsets.all(8),
                    // decoration: BoxDecoration(
                    //   border: Border.all(color: Colors.grey[300]!),
                    //   borderRadius: BorderRadius.circular(8),
                    // ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const CustomerInputField(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    // padding: EdgeInsets.all(8),
                    // decoration: BoxDecoration(
                    //   border: Border.all(color: Colors.grey[300]!),
                    //   borderRadius: BorderRadius.circular(8),
                    // ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CardListWidget(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    // decoration: BoxDecoration(
                    //   border: Border.all(color: Colors.grey[300]!),
                    //   borderRadius: BorderRadius.circular(8),
                    // ),
                    child: Column(
                      children: [
                        SizedBox(height: 8),
                        Text(
                          'Pembayaran',
                          style: Get.context!.textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        // const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PaymentListWidget(
                            editInvoice: editInvC.editInvoice,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  CalculatePrice(
                      editableInvoice: editInvC.editInvoice, isEdit: true),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(12),
              // height: 70,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  AppDialog.show(
                    title: 'Simpan Perubahan',
                    content: 'Simpan perubahan Invoice?',
                    confirmText: 'Simpan',
                    cancelText: 'Batal',
                    onConfirm: () async {
                      await editInvC.updateInvoice();
                      Get.back();
                    },
                    // onCancel: () => Get.back(),
                  );
                },
                child: const Text(
                  'Simpan Perubahan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
