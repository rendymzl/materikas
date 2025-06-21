import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/app_dialog_widget.dart';
import '../../global_widget/invoice_print_widget/invoice_print.dart';
import '../../global_widget/payment_widget/payment_popup_widget.dart';
import '../../global_widget/popup_page_widget.dart';
import '../controllers/invoice.controller.dart';
import '../edit_invoice/edit_invoice.dart';
import '../edit_invoice/edit_invoice_controller.dart';
import 'othercost_dialog_widget.dart';
import 'product_table_card.dart';
import 'properties_row.dart';
import 'return_product.dart';

void detailDialog(InvoiceModel invoice) {
  final InvoiceController controller = Get.find();
  invoice.updateIsDebtPaid();
  controller.displayInvoice = invoice;

  showPopupPageWidget(
    title: 'Invoice ${invoice.invoiceId}',
    iconButton: controller.destroyInvoice.value
        ? IconButton(
            onPressed: () {
              AppDialog.show(
                title: 'Hapus Invoice',
                content: 'Hapus Invoice ini?',
                confirmText: 'Hapus',
                cancelText: 'Batal',
                onConfirm: () async {
                  await controller.destroyHandle(invoice);
                  Get.back();
                  Get.back();
                },
                onCancel: () => Get.back(),
              );
            },
            icon: const Icon(
              Symbols.delete,
              color: Colors.red,
            ),
          )
        : null,
    height: MediaQuery.of(Get.context!).size.height * 0.9,
    width: MediaQuery.of(Get.context!).size.width * 0.9,
    content: Obx(() => _buildContent(invoice)),
    buttonList: _buildButtonList(controller, invoice),
  );
}

Widget _buildContent(InvoiceModel invoice) {
  return Expanded(
      child: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildInvoiceHeader(invoice),
              const SizedBox(height: 16),
              ProductTableCard(invoice: invoice),
              _buildInvoiceTotals(invoice),
              if (invoice.totalPaid > 0) _buildPaymentDetails(invoice),
              _buildRemainingBalance(invoice),
            ],
          ),
        ),
      ),
    ),
  )

      // ListView(
      //   shrinkWrap: true,
      //   padding: const EdgeInsets.all(16),
      //   children: [
      //     _buildInvoiceHeader(invoice),
      //     const SizedBox(height: 12),
      //     ProductTableCard(invoice: invoice),
      //     _buildInvoiceTotals(invoice),
      //     if (invoice.totalPaid > 0) _buildPaymentDetails(invoice),
      //     _buildRemainingBalance(invoice),
      //   ],
      // ),
      );
}

Widget _buildInvoiceHeader(InvoiceModel invoice) {
  print('object ${invoice.toJson()}');
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        flex: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(flex: 2, child: Text('Tanggal Pembelian')),
                Expanded(
                    flex: 3,
                    child: Text(': ${date.format(invoice.createdAt.value!)}')),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(flex: 2, child: Text('Kasir')),
                Expanded(
                    flex: 3, child: Text(': ${invoice.account.value.name}')),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(flex: 2, child: Text('Status Pembayaran')),
                Expanded(
                    flex: 3,
                    child: Text(
                      invoice.isDebtPaid.value ? ': LUNAS' : ': BELUM LUNAS',
                      style: TextStyle(
                        color: invoice.isDebtPaid.value
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ],
            ),
          ],
        ),
      ),
      Expanded(flex: 3, child: SizedBox(width: 10)),
      Expanded(
        flex: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Expanded(child: Text('Pembeli')),
                Expanded(
                    flex: 3, child: Text(': ${invoice.customer.value!.name}')),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: Text('No Telp')),
                Expanded(
                    flex: 3, child: Text(': ${invoice.customer.value!.phone}')),
              ],
            ),
            SizedBox(height: 4),
            Row(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text('Alamat')),
                Expanded(
                    flex: 3,
                    child: Text(': ${invoice.customer.value!.address}')),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildInvoiceTotals(InvoiceModel invoice) {
  return Container(
    decoration: BoxDecoration(
      border: (invoice.isReturn)
          ? Border(bottom: BorderSide(color: Colors.red[100]!))
          : null,
    ),
    child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (invoice.isReturn)
                  Expanded(
                    child: PropertiesRow(
                      subtraction: true,
                      title: 'Pembelian di Return',
                      value: 'Rp-${currency.format(invoice.subtotalReturn)}',
                    ),
                  ),
                SizedBox(
                  width: 600,
                  child: PropertiesRow(
                    primary: true,
                    title:
                        'SUBTOTAL HARGA (${invoice.purchaseList.value.items.length} Barang)',
                    value: 'Rp${currency.format(invoice.subTotalPurchase)}',
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (invoice.isReturn)
                  Expanded(
                    child: PropertiesRow(
                      subtraction: true,
                      title: 'Tambahan Return',
                      value:
                          'Rp-${currency.format(invoice.subtotalAdditionalReturn)}',
                    ),
                  ),
                SizedBox(
                  width: 600,
                  child: PropertiesRow(
                    subtraction: true,
                    title: 'Total Diskon',
                    value: 'Rp-${currency.format(invoice.totalDiscount)}',
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (invoice.isReturn)
                  Expanded(
                    child: PropertiesRow(
                      title: 'Biaya Return',
                      value: 'Rp${currency.format(invoice.returnFee.value)}',
                    ),
                  ),
                (invoice.totalOtherCosts > 0)
                    ? SizedBox(
                        width: 600,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: invoice.otherCosts.length,
                          itemBuilder: (context, index) {
                            return PropertiesRow(
                              title: invoice.otherCosts[index].name,
                              value:
                                  'Rp${currency.format(invoice.otherCosts[index].amount)}',
                            );
                          },
                        ),
                      )
                    : const SizedBox(
                        width: 600,
                        child: PropertiesRow(
                          title: '',
                          value: '',
                        ),
                      ),
              ],
            ),
            Divider(color: Colors.grey[300]),
            if (invoice.isReturn)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(),
                  SizedBox(
                    width: 600,
                    child: PropertiesRow(
                      primary: true,
                      title:
                          'TOTAL TAGIHAN ${invoice.totalReturnFinal != 0 ? '(Sebelum Return)' : ''}',
                      value: 'Rp${currency.format(invoice.totalPurchase)}',
                    ),
                  ),
                ],
              ),
            if (invoice.isReturn)
              Row(
                children: [
                  Expanded(
                    child: PropertiesRow(
                      primary: true,
                      subtraction: true,
                      title: 'TOTAL RETURN',
                      value: 'Rp-${currency.format(invoice.totalReturnFinal)}',
                    ),
                  ),
                  SizedBox(
                    width: 600,
                    child: PropertiesRow(
                      primary: true,
                      subtraction: true,
                      title: 'TOTAL RETURN',
                      value: 'Rp-${currency.format(invoice.totalReturnFinal)}',
                    ),
                  ),
                ],
              ),
          ],
        )),
  );
}

Widget _buildPaymentDetails(InvoiceModel invoice) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(),
          SizedBox(
            width: 600,
            child: Obx(() {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: invoice.payments.length,
                itemBuilder: (context, index) {
                  return PropertiesRow(
                    primary: true,
                    payment: true,
                    paymentMethod: invoice.payments[index].method!,
                    title:
                        'Pembayaran (${invoice.payments[index].method}) ${(!invoice.isDebtPaid.value || invoice.payments.length > 1) ? '${index + 1} (${DateFormat('dd MMM y', 'id').format(invoice.payments[index].date!)})' : ''}',
                    value:
                        'Rp${currency.format(invoice.totalPaidByIndex(index) == invoice.totalBill ? invoice.payments[index].amountPaid : invoice.payments[index].finalAmountPaid)}',
                  );
                },
              );
            }),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(),
          SizedBox(width: 600, child: Divider(color: Colors.grey[300])),
        ],
      ),
    ],
  );
}

Widget _buildRemainingBalance(InvoiceModel invoice) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      const SizedBox(),
      Container(
        color: invoice.totalPaid < invoice.totalBill
            ? Colors.red[50]
            : invoice.isReturn
                ? Colors.yellow[50]
                : Colors.green[50],
        width: 600,
        child: PropertiesRow(
          primary: true,
          subtraction: invoice.totalPaid < invoice.totalBill,
          payment: !(invoice.totalPaid < invoice.totalBill),
          title: invoice.totalPaid < invoice.totalBill
              ? 'SISA TAGIHAN'
              : 'Kembalian',
          value: invoice.totalPaid < invoice.totalBill
              ? 'Rp${currency.format(invoice.remainingDebt)}'
              : 'Rp${currency.format(invoice.remainingDebt * -1)}',
        ),
      ),
    ],
  );
}

List<Widget> _buildButtonList(
    InvoiceController controller, InvoiceModel invoice) {
  return [
    if (controller.returnInvoice.value)
      OutlinedButton.icon(
        onPressed: () {
          final editC = Get.put(EditInvoiceController());
          editC.init(invoice);
          returnProduct(invoice);
        },
        icon: const Icon(Symbols.rotate_left, fill: 1),
        label: const Text('Return Barang'),
      ),
    if (controller.editInvoice.value)
      OutlinedButton.icon(
        onPressed: () {
          final editC = Get.put(EditInvoiceController());
          editC.init(invoice);
          editInvoice();
        },
        icon: const Icon(Symbols.contract_edit, fill: 1),
        label: const Text('Edit Invoice'),
      ),
    OutlinedButton.icon(
      onPressed: () => otherCostDialogWidget(invoice),
      icon: const Icon(Symbols.add_card, fill: 1),
      label: const Text('Tambahan Biaya'),
    ),
    Obx(
      () => Visibility(
        visible: controller.paymentInvoice.value && !invoice.isDebtPaid.value,
        child: ElevatedButton.icon(
          onPressed: () {
            final editC = Get.put(EditInvoiceController());
            editC.init(invoice);
            paymentPopup();
          },
          icon: const Icon(Symbols.payments, fill: 1),
          label: Text(
              invoice.totalPaid > 0 ? 'Tambah Pembayaran' : 'Bayar Tagihan'),
        ),
      ),
    ),
    ElevatedButton.icon(
      onPressed: () => printInvoiceDialog(invoice),
      icon: const Icon(Symbols.print, fill: 1),
      label: const Text('Cetak/Simpan'),
    ),
  ];
}
