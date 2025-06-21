import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../../infrastructure/models/payment_list_model.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../global_widget/app_dialog_widget.dart';
import '../../global_widget/date_picker_widget/date_picker_widget_controller.dart';
import '../buy_product_widget/buy_product_controller.dart';
import '../edit_sales_invoice/cart_list_invoice_sales.dart';
import '../edit_sales_invoice/payment_list_sales.dart';
import '../selected_product_sales_widget/calculate_sales.dart';

class EditInvoiceSalesView extends GetView {
  const EditInvoiceSalesView({super.key});
  @override
  Widget build(BuildContext context) {
    final BuyProductController controller = Get.find();

    Get.lazyPut(() => DatePickerController());
    late DatePickerController datePickerC = Get.find();

    var invoice = controller.currentInvoice;

    datePickerC.asignDateTime(invoice.createdAt.value!);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          title: Text('Edit Invoice ${controller.editInvoice.invoiceName}'),
          centerTitle: true,
        ),
        // backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                children: [
                  Card(
                      // padding: EdgeInsets.all(8),
                      // decoration: BoxDecoration(
                      //   border: Border.all(color: Colors.grey[300]!),
                      //   borderRadius: BorderRadius.circular(8),
                      // ),
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CardListInvoiceSales(
                        editInvoice: controller.editInvoice),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text(
                            'Pembayaran',
                            style: Get.context!.textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          PaymentListSalesWidget(
                            editInvoice: controller.editInvoice,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CalculateSalesPrice(
                      editableInvoice: controller.editInvoice, isEdit: true),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  AppDialog.show(
                    title: 'Simpan Perubahan',
                    content: 'Simpan perubahan Invoice?',
                    confirmText: 'Simpan',
                    cancelText: 'Batal',
                    onConfirm: () async {
                      await controller.updateInvoice();
                      Get.back();
                    },
                    onCancel: () => Get.back(),
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

class PaymentButton extends StatelessWidget {
  const PaymentButton({
    super.key,
    required this.invoice,
    required this.isEdit,
  });

  final InvoiceSalesModel invoice;
  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              if (invoice.totalCost > 0) {
                var result = await Get.toNamed(Routes.PAYMENT_SALES_INVOICE,
                    arguments:
                        PaymentArgsSalesModel(isEdit: true, invoice: invoice));
                print('resultInvoiceSales $result');
                // paymentSalesPopup(invoice, isEdit: isEdit);
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
