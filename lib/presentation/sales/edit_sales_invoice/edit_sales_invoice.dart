import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../global_widget/app_dialog_widget.dart';
import '../../global_widget/date_picker_widget/date_picker_widget_controller.dart';
import '../../global_widget/popup_page_widget.dart';
import '../buy_product_widget/buy_product_controller.dart';
import '../detail_sales/payment_sales/payment_sales_popup.dart';
import '../selected_product_sales_widget/calculate_sales.dart';
import 'cart_list_invoice_sales.dart';
import 'payment_list_sales.dart';

void editSalesInvoice(InvoiceSalesModel invoice) {
  final BuyProductController controller = Get.find();
  Get.lazyPut(() => DatePickerController());
  late DatePickerController datePickerC = Get.find();
  datePickerC.asignDateTime(invoice.createdAt.value!);

  InvoiceSalesModel editInvoice = InvoiceSalesModel.fromJson(invoice.toJson());

  showPopupPageWidget(
    title: 'Edit Invoice ${editInvoice.invoiceId}',
    height: MediaQuery.of(Get.context!).size.height * (6 / 7),
    width: MediaQuery.of(Get.context!).size.width * (0.6),
    content: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CardListInvoiceSales(editInvoice: editInvoice),
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
                  PaymentListSalesWidget(
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
                  CalculateSalesPrice(invoice: editInvoice, isEdit: true),
                  const SizedBox(height: 30),
                  if (editInvoice.totalPaid < editInvoice.totalCost)
                    ListTile(
                      title: PaymentButton(invoice: editInvoice, isEdit: true),
                    )
                ],
              ),
            ),
            const SizedBox(height: 30),
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
            onConfirm: () async {
              invoice.id = editInvoice.id;
              invoice.invoiceId = editInvoice.invoiceId;
              invoice.createdAt.value = editInvoice.createdAt.value;
              invoice.sales.value = editInvoice.sales.value;
              invoice.purchaseList.value = editInvoice.purchaseList.value;
              // invoice.returnList.value = editInvoice.returnList.value;

              invoice.discount.value = editInvoice.discount.value;

              invoice.payments.value = editInvoice.payments;
              invoice.debtAmount.value = editInvoice.debtAmount.value;
              invoice.isDebtPaid.value = editInvoice.isDebtPaid.value;

              await controller.updateInvoice(editInvoice);
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
                paymentSalesPopup(invoice, isEdit: isEdit);
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
