import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:materikas/infrastructure/models/payment_list_model.dart';

import '../../../infrastructure/navigation/routes.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/app_dialog_widget.dart';
import '../../global_widget/invoice_print_widget/print_ble_controller.dart';
import '../buy_product_widget/buy_product_controller.dart';
import '../controllers/sales.controller.dart';

class DetailInvoiceSalesView extends GetView {
  const DetailInvoiceSalesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SalesController>();
    final printerC = Get.put(PrinterBluetoothController());
    var invoice = controller.displayInvoice;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Detail Invoice Sales'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            onSelected: (value) async {
              switch (value) {
                case 'edit':
                  final buyC = Get.put(BuyProductController());
                  buyC.assign(invoice);
                  await Get.toNamed(Routes.EDIT_INVOICE_SALES);

                  break;
                case 'payment':
                  if (!invoice.isDebtPaid.value) {
                    var result = await Get.toNamed(Routes.PAYMENT_SALES_INVOICE,
                        arguments: PaymentArgsSalesModel(
                            onlyPayment: true, invoice: invoice));
                    print('resultInvoiceSales $result');
                  }
                  break;
                case 'delete':
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
                      // Get.back();
                    },
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                  value: 'edit', child: Text('Edit Invoice')),
              if (!invoice.isDebtPaid.value)
                const PopupMenuItem<String>(
                    value: 'payment', child: Text('Tambah Pembayaran')),
              const PopupMenuItem<String>(
                  value: 'delete', child: Text('Hapus Invoice')),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        var filteredPurchase = invoice.purchaseList.value.items
            .where((item) => item.quantity.value > 0)
            .toList();
        // debugPrint('updateCount ${updateCount.value}');
        // invoice = invoiceEdited;
        return Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                // physics: NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // buildHeader(invoice),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                          child: buildText('${invoice.invoiceNumber}',
                              bold: true)),
                      buildText(date.format(
                        invoice.createdAt.value!,
                      )),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildText('Sales: ${invoice.sales.value!.name}'),
                      // buildText('Kasir: ${invoice.account.value.name}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildText('No Telp: ${invoice.sales.value!.phone}'),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: invoice.purchaseOrder.value
                              ? Colors.amber
                              : invoice.isDebtPaid.value
                                  ? Colors.green
                                  : Colors.red,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: buildText(
                            invoice.purchaseOrder.value
                                ? 'PO'
                                : invoice.isDebtPaid.value
                                    ? 'LUNAS'
                                    : 'BELUM LUNAS',
                            color: Colors.white),
                      ),
                    ],
                  ),
                  buildText('Alamat: ${invoice.sales.value!.address}'),
                  const SizedBox(height: 10),
                  const Divider(thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            SizedBox(
                                width: 35, child: buildText('No', bold: true)),
                            buildText('Item', bold: true),
                          ],
                        ),
                      ),
                      Expanded(
                          child: buildText('Diskon',
                              bold: true, textAlign: TextAlign.right)),
                      Expanded(
                          flex: 2,
                          child: buildText('Harga',
                              bold: true, textAlign: TextAlign.right)),
                    ],
                  ),
                  const Divider(thickness: 1),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filteredPurchase.length,
                    itemBuilder: (context, index) {
                      var item = filteredPurchase[index];
                      var price = currency.format(item.product.costPrice.value);

                      return Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                  width: 35, child: buildText('${index + 1}')),
                              buildText('${item.product.productName},'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    SizedBox(width: 35, child: buildText('')),
                                    buildText(
                                        '$price x ${number.format(item.quantity.value)} ${item.product.unit}'),
                                  ],
                                ),
                              ),
                              Expanded(
                                  child: buildText(
                                      item.individualDiscount.value > 0
                                          ? currency.format(
                                              item.individualDiscount.value)
                                          : '',
                                      textAlign: TextAlign.right)),
                              Expanded(
                                  flex: 2,
                                  child: buildText(
                                      currency.format(item.subCost),
                                      textAlign: TextAlign.right)),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const Divider(thickness: 1),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildText('Diskon:', color: Colors.red),
                      buildText(
                          invoice.totalDiscount > 0
                              ? '-${currency.format(invoice.totalDiscount)}'
                              : '0',
                          color: Colors.red),
                    ],
                  ),

                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: invoice.payments.length,
                    itemBuilder: (context, index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildText(
                              'Pembayaran ${(!invoice.isDebtPaid.value || invoice.payments.length > 1) ? '${index + 1}' ' (${DateFormat('dd MMM y', 'id').format(invoice.payments[index].date!)})' : ''}',
                              bold: true,
                              color: invoice.payments[index].method == 'cash'
                                  ? Colors.green
                                  : Colors.blue),
                          buildText(
                              'Rp${currency.format(invoice.payments[index].amountPaid)}',
                              bold: true,
                              color: invoice.payments[index].method == 'cash'
                                  ? Colors.green
                                  : Colors.blue),
                        ],
                      );
                    },
                  ),
                  const Divider(thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildText(
                          invoice.remainingDebt <= 0
                              ? 'Kembalian:'
                              : 'Kurang Bayar:',
                          bold: true),
                      buildText(currency.format(invoice.remainingDebt * -1),
                          bold: true),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    // flex: 4,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Printer',
                        border: OutlineInputBorder(),
                      ),
                      value: printerC.selectedDevice.value?.address,
                      items: printerC.devices
                          .map((device) => DropdownMenuItem<String>(
                                value: device.address,
                                child: Text(device.name!),
                              ))
                          .toList(),
                      onChanged: printerC.message.value
                              .toLowerCase()
                              .contains('menghubungkan')
                          ? null
                          : (value) {
                              var device = printerC.devices.firstWhereOrNull(
                                  (device) => device.address == value);
                              if (device != null) {
                                print('Menghubungkan Printer...');
                                printerC.connect(device);
                              }
                            },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    // flex: 3,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Ukuran',
                        border: OutlineInputBorder(),
                      ),
                      value: printerC.selectedPaperSize.value.isEmpty
                          ? null
                          : printerC.selectedPaperSize.value,
                      items: printerC.paperSize
                          .map((size) => DropdownMenuItem<String>(
                                value: size,
                                child: Text(size),
                              ))
                          .toList(),
                      onChanged: printerC.message.value
                              .toLowerCase()
                              .contains('menghubungkan')
                          ? null
                          : (value) {
                              printerC.setPaperSize(value!);
                            },
                    ),
                  ),

                  SizedBox(width: 12),
                  // Container(
                  //   decoration: BoxDecoration(
                  //     color: Get.theme.primaryColor,
                  //     borderRadius: BorderRadius.circular(20),
                  //   ),
                  //   child: IconButton(
                  //     icon: const Icon(Icons.print, color: Colors.white),
                  //     onPressed: () => printerC.printReceipt(invoice),
                  //   ),
                  // )

                  Obx(() {
                    return printerC.message.value
                            .toLowerCase()
                            .contains('menghubungkan')
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const CircularProgressIndicator(),
                          )
                        : ElevatedButton(
                            onPressed: printerC.selectedDevice.value == null
                                ? null
                                : () => printerC.printTransportSales(invoice),
                            child: const Icon(Icons.print));
                  }),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

Widget buildText(String text,
    {bool bold = false,
    TextAlign textAlign = TextAlign.left,
    Color color = Colors.black}) {
  return Text(
    text,
    textAlign: textAlign,
    style: TextStyle(
      fontSize: 14,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: color,
    ),
    overflow: TextOverflow.visible,
  );
}
