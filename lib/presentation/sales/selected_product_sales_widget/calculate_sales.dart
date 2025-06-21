import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/date_picker_widget/date_picker_widget_controller.dart';
import '../../global_widget/properties_row_widget.dart';
import '../buy_product_widget/buy_product_controller.dart';
import '../detail_sales/payment_sales/payment_sales_controller.dart';
import '../detail_sales/payment_sales/payment_sales_popup.dart';

class CalculateSalesPrice extends StatelessWidget {
  const CalculateSalesPrice(
      {super.key, required this.editableInvoice, this.isEdit = false});

  final InvoiceSalesModel editableInvoice;
  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (editableInvoice.totalDiscount > 0)
            PropertiesRowWidget(
              primary: true,
              title: 'Diskon',
              value: '-${currency.format(editableInvoice.totalDiscount)}',
              color: Colors.red,
            ),
          if (isEdit)
            PropertiesRowWidget(
              title: 'Total Belanja',
              value: currency.format(editableInvoice.totalCost),
            ),
          if (isEdit)
            PropertiesRowWidget(
              title: 'Total Pembayaran',
              value: currency.format(editableInvoice.totalPaid),
              color: Colors.green,
            ),
          if (isEdit) const Divider(color: Colors.grey),
          if (editableInvoice.purchaseList.value.items.isNotEmpty)
            PaymentButton(invoice: editableInvoice, isEdit: isEdit),
        ],
      ),
    );
  }
}

class PaymentButton extends StatelessWidget {
  const PaymentButton({super.key, required this.invoice, required this.isEdit});

  final InvoiceSalesModel invoice;
  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    final buyProductC = Get.find<BuyProductController>();
    final datePickerC = Get.find<DatePickerController>();
    final cartItems = invoice.purchaseList.value.items;

    return Obx(
      () => Row(
        children: [
          Expanded(
            child: ListTile(
              onTap: isEdit
                  ? null
                  : () async {
                      invoice.createdAt.value = datePickerC.selectedDate.value;

                      if ((isEdit &&
                              (invoice.invoiceName.value == null ||
                                  invoice.invoiceName.value!.isEmpty)) ||
                          (!isEdit && buyProductC.nomorInvoice.value.isEmpty)) {
                        _showErrorDialog('Masukkan Nomor Invoice.');
                      } else if (invoice.totalCost > 0) {
                        final paymentSalesC = Get.put(PaymentSalesController());
                        if (!isEdit) {
                          invoice.invoiceName.value =
                              buyProductC.nomorInvoice.value;
                          invoice.purchaseOrder.value =
                              buyProductC.isPurchaseOrder.value;
                        }

                        if (buyProductC.isPurchaseOrder.value) {
                          paymentSalesC.displayInvoice = invoice;
                          paymentSalesC.assign(invoice, isEditMode: isEdit);
                          _showConfirmPurchaseOrder(paymentSalesC);
                        } else {
                          paymentSalesC.displayInvoice = invoice;
                          paymentSalesC.assign(invoice, isEditMode: isEdit);
                          if (vertical) {
                            await Get.toNamed(Routes.PAYMENT_SALES_INVOICE);
                          } else {
                            if (invoice.purchaseList.value.items.isNotEmpty) {
                              await paymentSalesPopup();
                            }
                          }
                        }
                      } else {
                        _showErrorDialog('Tidak ada Barang yang ditambahkan.');
                      }
                    },
              tileColor: isEdit ? null : Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: _buildPaymentButtonContent(cartItems, context),
              trailing: isEdit
                  ? null
                  : const Icon(Symbols.shopping_basket,
                      fill: 1, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButtonContent(List cartItems, BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'TOTAL' : 'Total Harga',
                style: context.textTheme.titleLarge!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isEdit
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                ),
              ),
              Text(
                '(${cartItems.length} Item)',
                style: context.textTheme.titleSmall!.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: isEdit
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Rp${currency.format(invoice.remainingDebt)}',
                style: context.textTheme.titleLarge!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isEdit
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                ),
              ),
              if (invoice.totalDiscount > 0 && !isEdit)
                Text(
                  'Rp-${currency.format(invoice.subtotalCost)}',
                  style: context.textTheme.titleLarge!.copyWith(
                    fontSize: 14,
                    color: isEdit
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                        : Colors.white.withOpacity(0.5),
                    decoration: TextDecoration.lineThrough,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showConfirmPurchaseOrder(
      PaymentSalesController paymentSalesC) async {
    await Get.defaultDialog(
      title: 'Konfirmasi',
      middleText: 'Apakah anda yakin ingin menyimpan invoice ini sebagai PO?',
      confirm: ElevatedButton(
        onPressed: () async => await paymentSalesC.saveToDatabase(),
        child: const Text('Ya'),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        child: const Text('Tidak'),
      ),
    );
  }

  void _showErrorDialog(String message) {
    Get.defaultDialog(
      title: 'Error',
      middleText: message,
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: const Text('OK'),
      ),
    );
  }
}
