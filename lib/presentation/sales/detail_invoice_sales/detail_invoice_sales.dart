import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/app_dialog_widget.dart';
import '../../global_widget/popup_page_widget.dart';
import '../../invoice/detail_invoice/properties_row.dart';
import '../buy_product_widget/buy_product_controller.dart';
import '../controllers/sales.controller.dart';
import '../detail_sales/payment_sales/payment_sales_popup.dart';
import '../edit_sales_invoice/edit_sales_invoice.dart';
import '../invoice_sales_print.dart';
import '../print_sales_dialog.dart';
import 'product_table_sales.dart';

void detailSalesInvoice(InvoiceSalesModel invoice) {
  final SalesController controller = Get.find();

  invoice.updateIsDebtPaid();

  showPopupPageWidget(
      title: 'Invoice ${invoice.invoiceName}',
      iconButton: IconButton(
          onPressed: () {
            AppDialog.show(
              title: 'Hapus Invoice',
              content: 'Hapus Invoice ini?',
              confirmText: 'Hapus',
              cancelText: 'Batal',
              onConfirm: () async {
                final sales = invoice.sales.value!;
                await controller.destroyInvoiceHandle(invoice);

                Future.delayed(const Duration(milliseconds: 500),
                    () => controller.selectedSalesHandle(sales));
                Get.back();
                Get.back();
              },
              onCancel: () => Get.back(),
            );
          },
          icon: const Icon(
            Symbols.delete,
            color: Colors.red,
          )),
      height: MediaQuery.of(Get.context!).size.height * (0.9),
      width: MediaQuery.of(Get.context!).size.width * (0.9),
      content: Obx(
        () => Expanded(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PropertiesRow(
                          title: 'Tanggal Pembelian',
                          value: ': ${date.format(invoice.createdAt.value!)}',
                          titleTextAlign: TextAlign.left,
                          valueTextAlign: TextAlign.left,
                        ),
                        PropertiesRow(
                          title: 'Status Pembayaran',
                          value:
                              ': ${invoice.purchaseOrder.value ? 'PO' : invoice.isDebtPaid.value ? 'LUNAS' : 'BELUM LUNAS'}',
                          primary: true,
                          payment: invoice.isDebtPaid.value,
                          subtraction: !invoice.isDebtPaid.value,
                          titleTextAlign: TextAlign.left,
                          valueTextAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Card(
                      shadowColor: Colors.grey[200],
                      elevation: 2,
                      child: Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            PropertiesRow(
                              title: 'Sales',
                              value: ': ${invoice.sales.value!.name}',
                              titleTextAlign: TextAlign.left,
                              valueTextAlign: TextAlign.left,
                            ),
                            PropertiesRow(
                              title: 'No Telp',
                              value: ': ${invoice.sales.value!.phone}',
                              titleTextAlign: TextAlign.left,
                              valueTextAlign: TextAlign.left,
                            ),
                            PropertiesRow(
                              title: 'Alamat',
                              value: ': ${invoice.sales.value!.address}',
                              titleTextAlign: TextAlign.left,
                              valueTextAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ProductTableSales(invoice: invoice),
              SizedBox(
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 500,
                            child: PropertiesRow(
                              primary: true,
                              title:
                                  'SUBTOTAL HARGA (${invoice.purchaseList.value.items.length} Barang)',
                              value:
                                  'Rp${currency.format((invoice.subtotalCost))}',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 500,
                            child: PropertiesRow(
                              subtraction: true,
                              title: 'Total Diskon',
                              value:
                                  'Rp-${currency.format((invoice.totalDiscount))}',
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey[300]),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(),
                  SizedBox(
                    width: 500,
                    child: Column(
                      children: [
                        PropertiesRow(
                          primary: true,
                          title: 'TOTAL TAGIHAN',
                          value: 'Rp${currency.format((invoice.totalCost))}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // if (invoice.totalPaid > 0 && !invoice.isDebtPaid.value)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(),
                  SizedBox(
                    width: 500,
                    child: Obx(
                      () {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: invoice.payments.length,
                          itemBuilder: (context, index) {
                            return PropertiesRow(
                              primary: true,
                              payment: true,
                              paymentMethod: invoice.payments[index].method!,
                              title:
                                  'Pembayaran ${(!invoice.isDebtPaid.value || invoice.payments.length > 1) ? '${index + 1}' ' (${DateFormat('dd MMM y', 'id').format(invoice.payments[index].date!)})' : ''}',
                              value:
                                  'Rp${currency.format(invoice.payments[index].amountPaid)}',
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (invoice.totalPaid > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(),
                    SizedBox(
                        width: 500, child: Divider(color: Colors.grey[300])),
                  ],
                ),
              // if (invoice.totalPaid > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(),
                  Container(
                    color: invoice.totalPaid < invoice.totalCost
                        ? Colors.red[50]
                        : Colors.green[50],
                    width: 500,
                    child: PropertiesRow(
                      primary: true,
                      subtraction: invoice.totalPaid < invoice.totalCost,
                      payment: !(invoice.totalPaid < invoice.totalCost),
                      title: invoice.totalPaid < invoice.totalCost
                          ? 'SISA TAGIHAN'
                          : '',
                      value: invoice.totalPaid < invoice.totalCost
                          ? 'Rp${currency.format((invoice.totalCost - invoice.totalPaid))}'
                          : 'LUNAS',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      buttonList: [
        ElevatedButton(
          onPressed: () {
            final buyC = Get.put(BuyProductController());
            buyC.assign(invoice);
            editSalesInvoicePopup();
          },
          child: const Text('Edit Invoice'),
        ),
        Obx(() => Visibility(
              visible: !invoice.isDebtPaid.value,
              child: ElevatedButton(
                onPressed: () {
                  final buyC = Get.put(BuyProductController());
                  buyC.assign(invoice);
                  paymentSalesPopup();
                },
                child: Text((invoice.totalPaid > 0)
                    ? 'Tambah Pembayaran'
                    : 'Bayar Tagihan'),
              ),
            )),
        ElevatedButton(
            onPressed: () => printInvoiceSalesDialog(invoice),
            child: Text('Cetak ${invoice.purchaseOrder.value ? 'PO' : ''}')),
      ]);
}
