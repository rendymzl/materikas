import 'dart:io';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:thermal_printer/thermal_printer.dart';

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../popup_page_widget.dart';
import 'print_controller.dart';

void printInvoiceDialog(InvoiceModel invoice) {
  final PrinterController printerController = Get.put(PrinterController());
  printerController.connected.value = false;
  List<CartItem> returned = printerController.filterReturn(invoice);
  if (invoice.returnList.value != null) {
    //! RETURN LIST
    returned.addAll(invoice.returnList.value!.items);
  }
  printerController.setDefaultPrinter();

  showPopupPageWidget(
    title: 'Print Invoice',
    height: MediaQuery.of(Get.context!).size.height * (0.85),
    width: MediaQuery.of(Get.context!).size.width * (0.6),
    content: Container(
      margin: const EdgeInsets.all(8),
      height: MediaQuery.of(Get.context!).size.height * (0.7),
      width: MediaQuery.of(Get.context!).size.width * (0.6),
      child: Obx(() {
        var filteredPurchase = invoice.purchaseList.value.items
            .where((item) => item.quantity.value > 0)
            .toList();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pilih Printer',
                            style: Get.context!.textTheme.titleLarge,
                          ),
                          IconButton(
                            onPressed: () => Platform.isAndroid
                                ? printerController.getBlue()
                                : printerController.scan(PrinterType.usb),
                            icon: const Icon(
                              Symbols.refresh,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () {
                          String promo =
                              printerController.store!.promo?.value ?? '';
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            printerController.textPromo.text = promo;
                          });
                          return Obx(
                            () => Platform.isAndroid
                                ? DropdownButtonFormField<BluetoothDevice>(
                                    decoration: const InputDecoration(
                                      labelText: 'Pilih Printer',
                                      border: OutlineInputBorder(),
                                    ),
                                    value: printerController.selectedBlue.value,
                                    items: printerController.blueDevices
                                        .map((entry) {
                                      return DropdownMenuItem<BluetoothDevice>(
                                        value: entry,
                                        child: Text(
                                          entry.name!,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      printerController.selectedBlue.value =
                                          value;
                                      // printerController.connect(
                                      //   printerController.devices[value],
                                      //   PrinterType.usb,
                                      // );
                                      if (printerController
                                              .selectedBlue.value !=
                                          null) {
                                        printerController.bluePrint.connect(
                                            printerController
                                                .selectedBlue.value!);
                                      }
                                      printerController.connected.value = true;
                                      Get.snackbar('Status Printer',
                                          '${printerController.selectedBlue.value} $value');
                                    },
                                  )
                                : DropdownButtonFormField<int>(
                                    decoration: const InputDecoration(
                                      labelText: 'Pilih Printer',
                                      border: OutlineInputBorder(),
                                    ),
                                    value: printerController
                                        .selectedDeviceIndex.value,
                                    items: printerController.devices
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      return DropdownMenuItem<int>(
                                        value: entry.key,
                                        child: Text(
                                          entry.value.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      printerController
                                          .selectedPrinterIndex(value!);
                                      printerController.connect(
                                        printerController.devices[value],
                                        PrinterType.usb,
                                      );
                                    },
                                  ),
                          );
                        },
                      ),
                      Divider(color: Colors.grey[200]),
                      if (!Platform.isAndroid)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: ListTile(
                                tileColor: Colors.grey[100],
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Radio<String>(
                                      value: printerController.printMethod[0],
                                      groupValue: printerController
                                          .selectedPrintMethod.value,
                                      onChanged: (value) {
                                        printerController
                                            .setPrintMethod(value!);
                                        // if (printerController
                                        //         .selectedBlue.value !=
                                        //     null) {
                                        //   printerController.bluePrint.connect(
                                        //       printerController
                                        //           .selectedBlue.value!);
                                        // }
                                      },
                                    ),
                                    const Text('Struk'),
                                  ],
                                ),
                                onTap: () => printerController.setPrintMethod(
                                    printerController.printMethod[0]),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ListTile(
                                tileColor: Colors.grey[100],
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Radio<String>(
                                      value: printerController.printMethod[1],
                                      groupValue: printerController
                                          .selectedPrintMethod.value,
                                      onChanged: (value) {
                                        printerController
                                            .setPrintMethod(value!);
                                        if (printerController
                                                .selectedBlue.value !=
                                            null) {
                                          printerController.bluePrint.connect(
                                              printerController
                                                  .selectedBlue.value!);
                                        }
                                      },
                                    ),
                                    const Text('Invoice'),
                                  ],
                                ),
                                onTap: () => printerController.setPrintMethod(
                                    printerController.printMethod[1]),
                              ),
                            ),
                          ],
                        ),
                      Divider(color: Colors.grey[200]),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              height: 50,
                              child: TextField(
                                controller: printerController.textPromo,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    labelText: "Tambahkan Text Promo",
                                    labelStyle:
                                        const TextStyle(color: Colors.grey),
                                    // suffixIcon: Icon(Symbols.search),
                                    suffixIcon: IconButton(
                                        onPressed: () =>
                                            printerController.savePromoText(),
                                        icon: const Icon(Symbols.save))),
                                // onChanged: (value) => controller.filterCustomers(value),
                              ),
                            ),
                          ),
                          // IconButton(
                          //     onPressed: () =>
                          //         printerController.savePromoText(),
                          //     icon: const Icon(Symbols.save))
                          // ElevatedButton(
                          //     onPressed: () =>
                          //         printerController.savePromoText(),
                          //     child: const Text('Simpan')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Obx(
                          () => ListView(
                            controller: printerController.scrollController,
                            shrinkWrap: true,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildHeader(invoice, printerController),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            buildText('${invoice.invoiceId}',
                                                bold: true),
                                            buildText(DateFormat(
                                                    'dd-MM-y, HH:mm', 'id')
                                                .format(
                                              invoice.createdAt.value!,
                                            )),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            buildText(
                                                'Pelanggan: ${invoice.customer.value!.name}'),
                                            buildText(
                                                'Kasir: ${invoice.account.value.name}'),
                                          ],
                                        ),
                                        // const SizedBox(height: 10),
                                        // buildText('Customer:', bold: true),

                                        buildText(
                                            'No Telp: ${invoice.customer.value!.phone}'),
                                        buildText(
                                            'Alamat: ${invoice.customer.value!.address}'),
                                        const SizedBox(height: 10),
                                        // if (invoice.isReturn)
                                        //   buildText('-- Pesanan Awal --',
                                        //       bold: true),
                                        const Divider(thickness: 1),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                    width: 35,
                                                    child: buildText('No',
                                                        bold: true)),
                                                buildText('Nama Barang',
                                                    bold: true),
                                              ],
                                            ),
                                            buildText('Harga', bold: true),
                                          ],
                                        ),
                                        const Divider(thickness: 1),

                                        ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: filteredPurchase.length,
                                          itemBuilder: (context, index) {
                                            var item = filteredPurchase[index];
                                            var price = currency.format(item
                                                .product
                                                .getPrice(
                                                    invoice.priceType.value)
                                                .value);
                                            // bool isDiscount =
                                            //     item.individualDiscount.value > 0;
                                            // var discount = isDiscount
                                            //     ? '(-${currency.format(item.individualDiscount.value)})'
                                            //     : '';
                                            return
                                                // item.quantity.value > 0
                                                //     ?
                                                Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        SizedBox(
                                                            width: 35,
                                                            child: buildText(
                                                                '${index + 1}')),
                                                        buildText(
                                                            '${item.product.productName},'),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        SizedBox(
                                                            width: 35,
                                                            child:
                                                                buildText('')),
                                                        buildText(
                                                            '$price x ${number.format(item.quantity.value)} ${item.product.unit}'),
                                                      ],
                                                    ),
                                                    buildText(currency.format(
                                                        item.getSubPurchase(
                                                            invoice.priceType
                                                                .value))),
                                                  ],
                                                ),
                                              ],
                                            );
                                            // : const SizedBox();
                                          },
                                        ),
                                        const Divider(thickness: 1),
                                        if (invoice.isReturn)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              buildText('Subtotal:',
                                                  bold: true),
                                              buildText(
                                                  currency.format(
                                                      invoice.subtotalBill),
                                                  bold: true),
                                            ],
                                          ),
                                        // Row(
                                        //   mainAxisAlignment:
                                        //       MainAxisAlignment.end,
                                        //   children: [
                                        //     buildText('----------', bold: true),
                                        //   ],
                                        // ),

                                        if (invoice.isReturn)
                                          const SizedBox(height: 20),
                                        if (invoice.isReturn)
                                          buildText(
                                              '-- Barang yang direturn --',
                                              bold: true),
                                        if (invoice.isReturn)
                                          const Divider(thickness: 1),
                                        if (invoice.isReturn)
                                          ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: returned.length,
                                            itemBuilder: (context, index) {
                                              var item = returned[index];
                                              return item.quantityReturn.value >
                                                      0
                                                  ? Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                    width: 35,
                                                                    child: buildText(
                                                                        '${index + 1}')),
                                                                buildText(
                                                                    '${item.product.productName},'),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                    width: 35,
                                                                    child:
                                                                        buildText(
                                                                            '')),
                                                                buildText(
                                                                    '${currency.format(item.product.getPrice(invoice.priceType.value).value)} x ${number.format(item.quantityReturn.value)} ${item.product.unit}'),
                                                              ],
                                                            ),
                                                            buildText(currency.format(
                                                                item.getReturn(
                                                                    invoice
                                                                        .priceType
                                                                        .value))),
                                                          ],
                                                        ),
                                                      ],
                                                    )
                                                  : const SizedBox();
                                            },
                                          ),
                                        if (invoice.isReturn)
                                          const Divider(thickness: 1),
                                        if (invoice.isReturn)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              buildText('Subtotal return:'),
                                              buildText(invoice.totalReturn > 0
                                                  ? '-${currency.format((invoice.totalReturn))}'
                                                  : '0'),
                                            ],
                                          ),

                                        if (invoice.isReturn)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              buildText('Biaya return:'),
                                              buildText(currency.format(
                                                  invoice.returnFee.value)),
                                            ],
                                          ),
                                        if (invoice.isReturn)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              buildText('----------',
                                                  bold: true),
                                            ],
                                          ),
                                        if (invoice.isReturn)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              buildText('Total return:',
                                                  bold: true),
                                              buildText(
                                                  '-${currency.format(invoice.totalReturnFinal)}',
                                                  bold: true),
                                            ],
                                          ),
                                        if (invoice.isReturn)
                                          const SizedBox(height: 20),
                                        // if (invoice.totalReturn > 0)
                                        //   const SizedBox(
                                        //       height: 20), //! RETURN LIST
                                        if (invoice.isReturn)
                                          const Divider(thickness: 1),
                                        // Row(
                                        //   mainAxisAlignment:
                                        //       MainAxisAlignment.spaceBetween,
                                        //   children: [
                                        //     buildText('Total tagihan:',
                                        //         bold: true),
                                        //     buildText(
                                        //         currency.format(
                                        //             invoice.totalPurchase),
                                        //         bold: true),
                                        //   ],
                                        // ),
                                        // if (invoice.isReturn &&
                                        //     invoice.totalPaid > 0)
                                        //   Row(
                                        //     mainAxisAlignment:
                                        //         MainAxisAlignment
                                        //             .spaceBetween,
                                        //     children: [
                                        //       buildText(
                                        //           'Total pembayaran masuk:'),
                                        //       buildText(
                                        //           '-${currency.format(invoice.totalPaid)}'),
                                        //     ],
                                        //   ),
                                        // if (invoice.isReturn)
                                        //   const Divider(thickness: 1),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            buildText(
                                                'SUBTOTAL HARGA (${invoice.purchaseList.value.items.length} Barang)',
                                                bold: true),
                                            buildText(
                                                currency.format(
                                                    invoice.subTotalPurchase),
                                                bold: true),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            buildText('Total diskon:'),
                                            buildText(invoice.totalDiscount > 0
                                                ? '-${currency.format(invoice.totalDiscount)}'
                                                : '0'),
                                          ],
                                        ),
                                        if (invoice.totalOtherCosts > 0)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              buildText('Biaya lainnya:'),
                                              buildText(invoice
                                                          .totalOtherCosts >
                                                      0
                                                  ? currency.format(
                                                      invoice.totalOtherCosts)
                                                  : '0'),
                                            ],
                                          ),
                                        if (invoice.isReturn)
                                          const Divider(thickness: 1),
                                        if (invoice.isReturn)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              buildText(
                                                  'Tagihan sebelum return:',
                                                  bold: true),
                                              buildText(
                                                  currency.format(
                                                      invoice.totalPurchase),
                                                  bold: true),
                                            ],
                                          ),

                                        if (invoice.isReturn)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              buildText('Total return:'),
                                              buildText(
                                                  '-${currency.format(invoice.totalReturnFinal)}'),
                                            ],
                                          ),
                                        if (invoice.isReturn)
                                          const Divider(thickness: 1),
                                        if (invoice.isReturn)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              buildText(
                                                  invoice.isReturn
                                                      ? 'Tagihan setelah return:'
                                                      : 'Total tagihan:',
                                                  bold: true),
                                              buildText(
                                                  currency.format(
                                                      invoice.totalBill),
                                                  bold: true),
                                            ],
                                          ),

                                        // if (invoice.isReturn)
                                        //   Row(
                                        //     mainAxisAlignment:
                                        //         MainAxisAlignment.spaceBetween,
                                        //     children: [
                                        //       buildText(
                                        //           'Tagihan setelah return:',
                                        //           bold: true),
                                        //       buildText(
                                        //           currency.format(
                                        //               invoice.totalBill),
                                        //           bold: true),
                                        //     ],
                                        //   ),
                                        // if (invoice.totalOtherCosts > 0)
                                        //   Row(
                                        //     mainAxisAlignment:
                                        //         MainAxisAlignment
                                        //             .spaceBetween,
                                        //     children: [
                                        //       buildText('Total:', bold: true),
                                        //       buildText(
                                        //           currency.format(invoice
                                        //                   .total -
                                        //               invoice.totalReturn),
                                        //           bold: true),
                                        //     ],
                                        //   ),
                                        // if (!invoice.isReturn)
                                        ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: invoice.payments.length,
                                          itemBuilder: (context, index) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                buildText(
                                                    'Pembayaran ${(!invoice.isDebtPaid.value || invoice.payments.length > 1) ? '${index + 1}' ' (${DateFormat('dd MMM y', 'id').format(invoice.payments[index].date!)})' : ''}',
                                                    bold: true),
                                                buildText(
                                                    currency.format(invoice
                                                                .totalPaidByIndex(
                                                                    index) ==
                                                            invoice.totalBill
                                                        ? invoice
                                                            .payments[index]
                                                            .amountPaid
                                                        : invoice
                                                            .payments[index]
                                                            .finalAmountPaid),
                                                    bold: true),
                                              ],
                                            );

                                            // PropertiesRow(
                                            //   primary: true,
                                            //   payment: true,
                                            //   title:
                                            //       'Pembayaran ${(!invoice.isDebtPaid.value || invoice.payments.length > 1) ? '${index + 1}' ' (${DateFormat('dd MMM y', 'id').format(invoice.payments[index].date!)})' : ''}',
                                            //   value:
                                            //       'Rp${currency.format(invoice.payments[index].amountPaid)}',
                                            // );
                                          },
                                        ),
                                        // Row(
                                        //   mainAxisAlignment:
                                        //       MainAxisAlignment.spaceBetween,
                                        //   children: [
                                        //     buildText('Bayar:', bold: true),
                                        //     buildText(
                                        //         currency
                                        //             .format(invoice.totalPaid),
                                        //         bold: true),
                                        //   ],
                                        // ),
                                        // if (!invoice.isReturn)
                                        const Divider(thickness: 1),
                                        // if (!invoice.isReturn)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            buildText(
                                                invoice.remainingDebt <= 0
                                                    ? 'Kembalian:'
                                                    : 'Kurang Bayar:',
                                                bold: true),
                                            buildText(
                                                currency.format(
                                                    invoice.remainingDebt * -1),
                                                bold: true),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                    const Text(
                                      'Barang yang sudah dibeli',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Courier',
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Text(
                                      'tidak dapat ditukar/dikembalikan!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Courier',
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Obx(
                                      () => Text(
                                        printerController.store!.promo?.value ??
                                            '',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontFamily: 'Courier',
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Terimakasih atas pembelian anda!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Courier',
                                        fontSize: 12,
                                      ),
                                    ),
                                    // const SizedBox(height: 2)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      !printerController.isPrinting.value
                          ? (printerController.connected.value)
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          printerController.selectedPrintMethod
                                                      .value ==
                                                  'receipt'
                                              ? printerController
                                                  .printReceipt(invoice)
                                              : printerController
                                                  .printInvoice(invoice);
                                          Get.back();
                                        },
                                        child: const Text('Cetak'),
                                      ),
                                    ),
                                    // const SizedBox(width: 12),
                                    // Expanded(
                                    //   child: ElevatedButton(
                                    //     onPressed: () {
                                    //       printerController
                                    //           .printInvoice(invoice);
                                    //       Get.back();
                                    //     },
                                    //     child: const Text('Cetak invoice'),
                                    //   ),
                                    // ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          printerController.selectedPrintMethod
                                                      .value ==
                                                  'receipt'
                                              ? printerController
                                                  .printTransport(invoice)
                                              : printerController
                                                  .printTransportInv(invoice);
                                          Get.back();
                                        },
                                        child: const Text('Cetak surat jalan'),
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Pilih printer untuk mencetak!',
                                  style: Get.context!.textTheme.headlineSmall!
                                      .copyWith(
                                          color: Theme.of(Get.context!)
                                              .colorScheme
                                              .primary),
                                )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(width: 20),
                                Text('Sedang mencetak...')
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    ),
  );
}

Widget buildHeader(InvoiceModel invoice, PrinterController controller) {
  String phone = controller.store!.phone.value;
  String telp = controller.store!.telp.value;
  String slash = (phone.isNotEmpty && telp.isNotEmpty) ? '/' : '';
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        controller.store!.name.value,
        style: const TextStyle(
          fontFamily: 'Courier',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        controller.store!.address.value,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Courier',
          fontSize: 12,
        ),
      ),
      Text(
        '$phone $slash $telp',
        style: const TextStyle(
          fontFamily: 'Courier',
          fontSize: 12,
        ),
      ),
      const Divider(thickness: 1),
    ],
  );
}

Widget buildText(String text, {bool bold = false}) {
  return Text(
    text,
    style: TextStyle(
      fontFamily: 'Courier',
      fontSize: 12,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    ),
  );
}
