import 'package:flutter/material.dart';
// import 'package:flutter_thermal_printer/utils/printer.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../global_widget/app_dialog_widget.dart';
import '../../global_widget/invoice_print_widget/print_ble_controller.dart';
import '../controllers/invoice.controller.dart';
import '../detail_invoice/othercost_dialog_widget.dart';
import '../edit_invoice/edit_invoice_controller.dart';

class InvoiceDetailView extends GetView {
  const InvoiceDetailView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InvoiceController>();
    final printerC = Get.put(PrinterBluetoothController());
    var invoice = controller.displayInvoice;
    final updateCount = 0.obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Invoice'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                printerC.invoice = invoice;
                Get.toNamed(Routes.INVOICE_PRINT, arguments: invoice);
                // printerC.startScan();
              },
              icon: const Icon(
                Symbols.print_add,
                // size: 13,
                // color: Colors.white,
              ),
            ),
          ),
          // if (controller.destroyInvoice.value)
          PopupMenuButton(
            onSelected: (value) async {
              switch (value) {
                case 'edit':
                  final editC = Get.put(EditInvoiceController());
                  editC.init(invoice);
                  await Get.toNamed(Routes.INVOICE_EDIT);
                  break;
                case 'return':
                  final editC = Get.put(EditInvoiceController());
                  editC.init(invoice);
                  await Get.toNamed(Routes.INVOICE_RETURN);
                  // print('result value $result');
                  break;
                case 'otherCost':
                  otherCostDialogWidget(invoice);
                  break;
                case 'payment':
                  if (!invoice.isDebtPaid.value) {
                    final editC = Get.put(EditInvoiceController());
                    editC.init(invoice);

                    await Get.toNamed(Routes.PAYMENT_LIST_VIEW);
                  }
                  break;
                case 'print':
                  printerC.invoice = invoice;
                  printerC.printTransport(invoice);
                  // printInvoiceDialog(invoice);
                  break;
                case 'delete':
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
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit Invoice'),
              ),
              const PopupMenuItem<String>(
                value: 'return',
                child: Text('Return Barang'),
              ),
              const PopupMenuItem<String>(
                value: 'otherCost',
                child: Text('Tambahan Biaya'),
              ),
              if (!invoice.isDebtPaid.value)
                const PopupMenuItem<String>(
                  value: 'payment',
                  child: Text('Tambah Pembayaran'),
                ),
              const PopupMenuItem<String>(
                value: 'print',
                child: Text('Cetak Surat Jalan'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Hapus Invoice'),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        List<CartItem> returned = filterReturn(invoice);
        if (invoice.returnList.value != null) {
          //! RETURN LIST
          returned.addAll(invoice.returnList.value!.items);
        }

        var filteredPurchase = invoice.purchaseList.value.items
            .where((item) => item.quantity.value > 0)
            .toList();
        debugPrint('updateCount ${updateCount.value}');
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
                          child: buildText('${invoice.invoiceId}', bold: true)),
                      buildText(date.format(
                        invoice.createdAt.value!,
                      )),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildText('Pelanggan: ${invoice.customer.value!.name}'),
                      buildText('Kasir: ${invoice.account.value.name}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildText('No Telp: ${invoice.customer.value!.phone}'),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: invoice.isDebtPaid.value
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: buildText(
                            invoice.isDebtPaid.value ? 'LUNAS' : 'BELUM LUNAS',
                            color: Colors.white),
                      ),
                    ],
                  ),
                  buildText('Alamat: ${invoice.customer.value!.address}'),
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
                      var price = currency.format(
                          item.product.getPrice(invoice.priceType.value).value);

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
                                      currency.format(item
                                          .getSubBill(invoice.priceType.value)),
                                      textAlign: TextAlign.right)),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const Divider(thickness: 1),
                  if (invoice.isReturn)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildText('Subtotal:', bold: true),
                        buildText(currency.format(invoice.subtotalBill),
                            bold: true),
                      ],
                    ),
                  if (invoice.isReturn) const SizedBox(height: 20),
                  if (invoice.isReturn)
                    buildText('-- Barang yang direturn --', bold: true),
                  if (invoice.isReturn) const Divider(thickness: 1),
                  if (invoice.isReturn)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: returned.length,
                      itemBuilder: (context, index) {
                        var item = returned[index];
                        return item.quantityReturn.value > 0
                            ? Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                              width: 35,
                                              child: buildText('${index + 1}')),
                                          buildText(
                                              '${item.product.productName},'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                              width: 35, child: buildText('')),
                                          buildText(
                                              '${currency.format(item.product.getPrice(invoice.priceType.value).value)} x ${number.format(item.quantityReturn.value)} ${item.product.unit}'),
                                        ],
                                      ),
                                      buildText(currency.format(item
                                          .getReturn(invoice.priceType.value))),
                                    ],
                                  ),
                                ],
                              )
                            : const SizedBox();
                      },
                    ),
                  if (invoice.isReturn) const Divider(thickness: 1),
                  if (invoice.isReturn)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildText('Subtotal return:'),
                        buildText(invoice.totalReturn > 0
                            ? '-${currency.format((invoice.totalReturn))}'
                            : '0'),
                      ],
                    ),
                  if (invoice.isReturn)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildText('Biaya return:'),
                        buildText(currency.format(invoice.returnFee.value)),
                      ],
                    ),
                  if (invoice.isReturn)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        buildText('----------', bold: true),
                      ],
                    ),
                  if (invoice.isReturn)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildText('Total return:', bold: true),
                        buildText(
                            '-${currency.format(invoice.totalReturnFinal)}',
                            bold: true),
                      ],
                    ),
                  if (invoice.isReturn) const SizedBox(height: 20),
                  if (invoice.isReturn) const Divider(thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildText(
                          'SUBTOTAL HARGA (${invoice.purchaseList.value.items.length} Barang)',
                          bold: true),
                      buildText(currency.format(invoice.subTotalPurchase),
                          bold: true),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildText('Diskon:', color: Colors.red),
                      buildText(
                          invoice.totalDiscount > 0
                              ? '-${currency.format(invoice.totalInvididualDiscount)}'
                              : '0',
                          color: Colors.red),
                    ],
                  ),
                  if (invoice.additionalDIscount > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildText('Diskon Tambahan:', color: Colors.red),
                        buildText(
                            invoice.totalDiscount > 0
                                ? '-${currency.format(invoice.additionalDIscount)}'
                                : '0',
                            color: Colors.red),
                      ],
                    ),
                  // if (invoice.totalOtherCosts > 0) buildText('Biaya lainnya:'),
                  if (invoice.totalOtherCosts > 0)
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: invoice.otherCosts.length,
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildText(invoice.otherCosts[index].name),
                            buildText(currency
                                .format((invoice.otherCosts[index].amount))),
                          ],
                        );
                      },
                    ),

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     buildText('Biaya lainnya:'),
                  //     buildText(invoice.totalOtherCosts > 0
                  //         ? currency.format(invoice.totalOtherCosts)
                  //         : '0'),
                  //   ],
                  // ),
                  if (invoice.isReturn) const Divider(thickness: 1),
                  if (invoice.isReturn)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildText('Tagihan sebelum return:', bold: true),
                        buildText(currency.format(invoice.totalPurchase),
                            bold: true),
                      ],
                    ),
                  if (invoice.isReturn)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildText('Total return:'),
                        buildText(
                            '-${currency.format(invoice.totalReturnFinal)}'),
                      ],
                    ),
                  if (invoice.isReturn) const Divider(thickness: 1),
                  if (invoice.isReturn)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildText(
                            invoice.isReturn
                                ? 'Tagihan setelah return:'
                                : 'Total tagihan:',
                            bold: true),
                        buildText(currency.format(invoice.totalBill),
                            bold: true),
                      ],
                    ),
                  const SizedBox(height: 10),
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
                              currency.format(invoice.totalPaidByIndex(index) >=
                                      invoice.totalBill
                                  ? invoice.payments[index].amountPaid
                                  : invoice.payments[index].finalAmountPaid),
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
              child: Obx(() => printerC.message.value.isEmpty
                  ? Container()
                  : Text(
                      printerC.message.value,
                      style: TextStyle(
                        color: printerC.message.value
                                .toLowerCase()
                                .contains('menghubungkan')
                            ? null
                            : printerC.message.value
                                    .toLowerCase()
                                    .contains('berhasil')
                                ? Colors.green
                                : Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    )),
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
                                : () => printerC.printReceipt(invoice),
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

Widget buildHeader(InvoiceModel invoice) {
  AuthService controller = Get.find();
  String phone = controller.store.value!.phone.value;
  String telp = controller.store.value!.telp.value;
  String slash = (phone.isNotEmpty && telp.isNotEmpty) ? '/' : '';
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        controller.store.value!.name.value,
        style: const TextStyle(
          // fontFamily: 'Courier',
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        controller.store.value!.address.value,
        textAlign: TextAlign.center,
        style: const TextStyle(
          // fontFamily: 'Courier',
          fontSize: 14,
        ),
      ),
      Text(
        '$phone $slash $telp',
        style: const TextStyle(
          // fontFamily: 'Courier',
          fontSize: 14,
        ),
      ),
      const Divider(thickness: 1),
    ],
  );
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

List<CartItem> filterReturn(InvoiceModel invoice) {
  List<CartItem> workerData = invoice.purchaseList.value.items
      .where((p) => p.quantityReturn.value > 0)
      .map((purchased) => purchased)
      .toList();
  return workerData;
}
