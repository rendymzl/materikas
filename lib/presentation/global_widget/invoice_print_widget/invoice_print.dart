import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:thermal_printer/thermal_printer.dart';

import '../../../../main.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/invoice_model.dart';
import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../popup_page_widget.dart';
import 'invoice_print_controller.dart';

void printInvoiceDialog(BuildContext context, Invoice invoice) {
  final PrinterController printerController = Get.put(PrinterController());
  printerController.connected.value = false;
  // List<CartItem> purchase = printerController.filterPurchase(invoice);
  List<CartItem> returned = printerController.filterReturn(invoice);
  if (invoice.returnList.value != null) {
    //! RETURN LIST
    returned.addAll(invoice.returnList.value!.items);
  }
  // printerController.selectedDeviceIndex.value = -1;
  printerController.setDefaultPrinter();

  showPopupPageWidget(
    title: 'Print Invoice',
    height: MediaQuery.of(context).size.height * (5 / 7),
    width: MediaQuery.of(context).size.width * (2 / 3),
    content: Container(
        margin: const EdgeInsets.all(8),
        height: MediaQuery.of(context).size.height * (5 / 7),
        width: MediaQuery.of(context).size.width * (2 / 3),
        child: Obx(() {
          return Row(
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
                              style: context.textTheme.titleLarge,
                            ),
                            IconButton(
                              onPressed: () =>
                                  printerController.scan(PrinterType.usb),
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
                                printerController.store!.promo.value ?? '';
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              printerController.textPromo.text = promo;
                            });
                            return Expanded(
                              child: ListView.separated(
                                shrinkWrap: true,
                                separatorBuilder: (context, index) =>
                                    Divider(color: Colors.grey[200]),
                                itemCount: printerController.devices.length,
                                itemBuilder: (context, index) {
                                  final device =
                                      printerController.devices[index];
                                  return Obx(
                                    () => ListTile(
                                      selectedColor:
                                          Theme.of(context).colorScheme.primary,
                                      selected: printerController
                                              .selectedDeviceIndex.value ==
                                          index,
                                      title: Text(device.name),
                                      subtitle: Text(
                                          'Vendor ID: ${device.vendorId}, Product ID: ${device.productId}'),
                                      onTap: () {
                                        printerController
                                            .selectedPrinterIndex(index);
                                        printerController.connect(
                                            device,
                                            PrinterType
                                                .usb); // Sesuaikan dengan jenis printer yang digunakan
                                      },
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        // ElevatedButton(
                        //   onPressed: () =>
                        //       printerController.scan(PrinterType.usb),
                        //   child: const Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       Icon(
                        //         Symbols.refresh,
                        //         color: Colors.white,
                        //       ),
                        //       SizedBox(width: 12),
                        //       Text('Perbarui daftar printer'),
                        //     ],
                        //   ),
                        // ),
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
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    labelText: "Tambahkan Text Promo",
                                    labelStyle: TextStyle(color: Colors.grey),
                                    // suffixIcon: Icon(Symbols.search),
                                  ),
                                  // onChanged: (value) => controller.filterCustomers(value),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                                onPressed: () =>
                                    printerController.savePromoText(),
                                child: const Text('Simpan')),
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
                                          buildHeader(
                                              invoice, printerController),
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
                                          if (invoice.isReturn)
                                            buildText('-- Pesanan Awal --',
                                                bold: true),
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
                                            itemCount: invoice.purchaseList
                                                .value.items.length,
                                            itemBuilder: (context, index) {
                                              var item = invoice.purchaseList
                                                  .value.items[index];
                                              var price = currency.format(
                                                  item.product.getPrice(
                                                      invoice.priceType.value));
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
                                                              child: buildText(
                                                                  '')),
                                                          buildText(
                                                              '$price x ${decimal.format(item.totalQuantity)} ${item.product.unit}'),
                                                        ],
                                                      ),
                                                      buildText(currency.format(
                                                          item.getSubTotalPurchase(
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
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              buildText('Subtotal:'),
                                              buildText(currency.format(
                                                  invoice.subTotalPurchase)),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              buildText('Total diskon:'),
                                              buildText(invoice.totalDiscount >
                                                      0
                                                  ? '-${currency.format(invoice.totalDiscount)}'
                                                  : '0'),
                                            ],
                                          ),
                                          if (invoice.totalOtherCosts > 0)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              buildText('----------',
                                                  bold: true),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              buildText('Total tagihan:',
                                                  bold: true),
                                              buildText(
                                                  currency.format(
                                                      invoice.totalPurchase),
                                                  bold: true),
                                            ],
                                          ),
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
                                                return item.quantityReturn
                                                            .value >
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
                                                                      child: buildText(
                                                                          '')),
                                                                  buildText(
                                                                      '${currency.format(item.product.getPrice(invoice.priceType.value))} x ${decimal.format(item.quantityReturn.value)} ${item.product.unit}'),
                                                                ],
                                                              ),
                                                              buildText(currency.format(
                                                                  item.getTotalReturn(invoice
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                buildText('Subtotal return:'),
                                                buildText(invoice.totalReturn >
                                                        0
                                                    ? '-${currency.format((invoice.totalReturn + invoice.returnFee.value))}'
                                                    : '0'),
                                              ],
                                            ),

                                          if (invoice.isReturn)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                buildText('Total return:',
                                                    bold: true),
                                                buildText(
                                                    '-${currency.format(invoice.totalReturn)}',
                                                    bold: true),
                                              ],
                                            ),
                                          // if (invoice.totalReturn > 0)
                                          //   const SizedBox(
                                          //       height: 20), //! RETURN LIST
                                          if (invoice.isReturn)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                buildText('Total tagihan:',
                                                    bold: true),
                                                buildText(
                                                    currency.format(
                                                        invoice.totalPurchase),
                                                    bold: true),
                                              ],
                                            ),
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
                                          if (invoice.isReturn)
                                            const Divider(thickness: 1),
                                          if (invoice.isReturn)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                buildText(
                                                    'Total setelah return:',
                                                    bold: true),
                                                buildText(
                                                    currency.format(
                                                        invoice.totalFinal),
                                                    bold: true),
                                              ],
                                            ),
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
                                          if (!invoice.isReturn)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                buildText('Bayar:', bold: true),
                                                buildText(
                                                    currency.format(
                                                        invoice.totalPaid),
                                                    bold: true),
                                              ],
                                            ),
                                          if (!invoice.isReturn)
                                            const Divider(thickness: 1),
                                          if (!invoice.isReturn)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                buildText(
                                                    invoice.change <= 0
                                                        ? 'Kembalian:'
                                                        : 'Kurang Bayar:',
                                                    bold: true),
                                                buildText(
                                                    currency.format(
                                                        invoice.change * -1),
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
                                          printerController
                                                  .store!.promo.value ??
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
                            ? printerController.connected.value
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            printerController
                                                .printReceipt(invoice);
                                            Get.back();
                                          },
                                          child: const Text('Cetak struk'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            printerController
                                                .printInvoice(invoice);
                                            Get.back();
                                          },
                                          child: const Text('Cetak invoice'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            printerController
                                                .printTransport(invoice);
                                            Get.back();
                                          },
                                          child:
                                              const Text('Cetak surat jalan'),
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    'Pilih printer untuk mencetak!',
                                    style: context.textTheme.headlineSmall!
                                        .copyWith(
                                            color: Theme.of(context)
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
      );,
  );

}

Widget buildHeader(Invoice invoice, PrinterController controller) {
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
      fontFamily: 'Courier', // Monospace font similar to thermal printer
      fontSize: 12, // Adjust the size to match the print size
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    ),
  );
}
