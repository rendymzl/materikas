import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/payment_widget/payment_popup_widget.dart';
import '../../global_widget/popup_page_widget.dart';
import '../controllers/invoice.controller.dart';
import '../edit_invoice/edit_invoice.dart';
import 'othercost_dialog_widget.dart';
import 'product_table_card.dart';
import 'properties_row.dart';
import 'return_product.dart';

void detailDialog(InvoiceModel invoice) {
  final InvoiceController controller = Get.find();

  controller.initInvoice = InvoiceModel.fromJson(invoice.toJson());

  invoice.updateIsDebtPaid();

  showPopupPageWidget(
      title: 'Invoice ${invoice.invoiceId}',
      iconButton: IconButton(
          // onPressed: () => controller.destroyHandle(foundProduct),
          onPressed: () {},
          icon: const Icon(
            Symbols.delete,
            color: Colors.red,
          )),
      height: MediaQuery.of(Get.context!).size.height * (0.9),
      width: MediaQuery.of(Get.context!).size.width * (0.9),
      content: Obx(
        () => ListView(
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
                        title: 'Kasir',
                        value: ': ${invoice.account.value.role}',
                        titleTextAlign: TextAlign.left,
                        valueTextAlign: TextAlign.left,
                      ),
                      PropertiesRow(
                        title: 'Status Pembayaran',
                        value:
                            ': ${invoice.isDebtPaid.value ? 'LUNAS' : 'BELUM LUNAS'}',
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
                            title: 'Pembeli',
                            value: ': ${invoice.customer.value!.name}',
                            titleTextAlign: TextAlign.left,
                            valueTextAlign: TextAlign.left,
                          ),
                          PropertiesRow(
                            title: 'No Telp',
                            value: ': ${invoice.customer.value!.phone}',
                            titleTextAlign: TextAlign.left,
                            valueTextAlign: TextAlign.left,
                          ),
                          PropertiesRow(
                            title: 'Alamat',
                            value: ': ${invoice.customer.value!.address}',
                            titleTextAlign: TextAlign.left,
                            valueTextAlign: TextAlign.left,
                          ),
                          // Container(
                          //   margin: EdgeInsets.all(12),
                          //   child: IconButton(
                          //     onPressed: () {},
                          //     // child: Text('Edit Pelanggan'),
                          //     icon: Icon(Symbols.edit_square),
                          //     // style: ElevatedButton.styleFrom(
                          //     //   padding: EdgeInsets.all(8),
                          //     //   textStyle: TextStyle(
                          //     //       fontSize: 12, fontWeight: FontWeight.bold),
                          //     // ),
                          //   ),
                          // )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ProductTableCard(invoice: invoice),
            Container(
              decoration: BoxDecoration(
                  border: (invoice.isReturn)
                      ? Border(bottom: BorderSide(color: Colors.red[100]!))
                      : null),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (invoice.isReturn)
                          Expanded(
                            child: PropertiesRow(
                              subtraction: true,
                              title: 'Total Pesanan di Return',
                              value:
                                  'Rp-${currency.format(invoice.subtotalReturn)}',
                            ),
                          ),
                        SizedBox(
                          width: 500,
                          child: PropertiesRow(
                            primary: true,
                            title:
                                'SUBTOTAL HARGA (${invoice.purchaseList.value.items.length} Barang)',
                            value:
                                'Rp${currency.format((invoice.subTotalPurchase))}',
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
                              title: 'Total Tambahan Return',
                              value:
                                  'Rp-${currency.format(invoice.subtotalAdditionalReturn)}',
                            ),
                          ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (invoice.isReturn)
                          Expanded(
                            child: PropertiesRow(
                              title: 'Biaya Return',
                              value:
                                  'Rp${currency.format(invoice.returnFee.value)}',
                            ),
                          ),
                        (invoice.totalOtherCosts > 0)
                            ? SizedBox(
                                width: 500,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: invoice.otherCosts.length,
                                  itemBuilder: (context, index) {
                                    return PropertiesRow(
                                      title: invoice.otherCosts[index].name,
                                      value:
                                          'Rp${currency.format((invoice.otherCosts[index].amount))}',
                                    );
                                  },
                                ),
                              )
                            : const SizedBox(
                                width: 500,
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
                            width: 500,
                            child: PropertiesRow(
                              primary: true,
                              title:
                                  'TOTAL TAGIHAN ${invoice.totalReturnFinal != 0 ? '(Sebelum Return)' : ''}',
                              value:
                                  'Rp${currency.format((invoice.totalPurchase))}',
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
                              value:
                                  'Rp-${currency.format(invoice.totalReturnFinal)}',
                            ),
                          ),
                          SizedBox(
                            width: 500,
                            child: PropertiesRow(
                              primary: true,
                              subtraction: true,
                              title: 'TOTAL RETURN',
                              value:
                                  'Rp-${currency.format(invoice.totalReturnFinal)}',
                            ),
                          ),
                        ],
                      ),
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
                        title:
                            'TOTAL TAGIHAN ${invoice.isReturn ? '(Setelah Return)' : ''}',
                        value: 'Rp${currency.format((invoice.totalBill))}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (invoice.totalPaid > 0 && !invoice.isDebtPaid.value)
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
                          itemCount: invoice.payments.length,
                          itemBuilder: (context, index) {
                            return PropertiesRow(
                              primary: true,
                              payment: true,
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
                  SizedBox(width: 500, child: Divider(color: Colors.grey[300])),
                ],
              ),
            // if (invoice.totalPaid > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(),
                Container(
                  color: invoice.totalPaid < invoice.totalBill
                      ? Colors.red[50]
                      : invoice.isReturn
                          ? Colors.yellow[50]
                          : Colors.green[50],
                  width: 500,
                  child: PropertiesRow(
                    primary: true,
                    subtraction: invoice.totalPaid < invoice.totalBill,
                    payment: !(invoice.totalPaid < invoice.totalBill),
                    title: invoice.totalPaid < invoice.totalBill
                        ? 'SISA TAGIHAN'
                        : invoice.isReturn
                            ? ''
                            : '',
                    value: invoice.totalPaid < invoice.totalBill
                        ? 'Rp${currency.format((invoice.totalBill - invoice.totalPaid))}'
                        : 'LUNAS',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      buttonList: [
        ElevatedButton(
          onPressed: () => returnProduct(invoice),
          child: const Text(
            'Return Barang',
          ),
        ),
        ElevatedButton(
          onPressed: () => editInvoice(invoice),
          child: const Text(
            'Edit Invoice',
          ),
        ),
        ElevatedButton(
          onPressed: () => otherCostDialogWidget(invoice),
          child: const Text('Tambahan Biaya'),
        ),
        if (!invoice.isDebtPaid.value)
          ElevatedButton(
            onPressed: () => paymentPopup(
              invoice,
              onlyPayment: true,
            ),
            child: Text((invoice.totalPaid > 0)
                ? 'Tambah Pembayaran'
                : 'Bayar Tagihan'),
          ),
        // Expanded(
        //   child: OutlinedButton(
        //     onPressed: () => Get.back(),
        //     child: const Text('Batal'),
        //   ),
        // ),
        // SizedBox(width: 8),
        // Expanded(
        //   child: ElevatedButton(
        //     onPressed: () async => await controller.handleSave(foundProduct),
        //     child: const Text('Simpan'),
        //   ),
        // ),
      ]);
}
