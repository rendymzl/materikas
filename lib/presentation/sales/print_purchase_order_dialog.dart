import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:thermal_printer/thermal_printer.dart';

import '../../../infrastructure/utils/display_format.dart';
import '../../infrastructure/models/purchase_order_model.dart';
import '../global_widget/popup_page_widget.dart';
import 'print_purchase_order_controller.dart';

void printPurchaseOrderDialog(PurchaseOrderModel invoice) {
  final PrintPurchaseOrderController printerController =
      Get.put(PrintPurchaseOrderController());
  printerController.connected.value = false;

  printerController.setDefaultPrinter();

  showPopupPageWidget(
    title: 'Print Invoice',
    height: MediaQuery.of(Get.context!).size.height * (0.85),
    width: MediaQuery.of(Get.context!).size.width * (0.6),
    content: Obx(() {
      return Expanded(
        child: Row(
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
                              printerController.store!.promo?.value ?? '';
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            printerController.textPromo.text = promo;
                          });
                          return Obx(
                            () => DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: 'Pilih Printer',
                                border: OutlineInputBorder(),
                              ),
                              value:
                                  printerController.selectedDeviceIndex.value,
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
                                printerController.selectedPrinterIndex(value!);
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
                                      printerController.setPrintMethod(value!);
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
                                      printerController.setPrintMethod(value!);
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
                                            buildText('${invoice.orderId}',
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
                                                'Pelanggan: ${invoice.sales.value!.name}'),
                                          ],
                                        ),
                                        // const SizedBox(height: 10),
                                        // buildText('Customer:', bold: true),
            
                                        buildText(
                                            'No Telp: ${invoice.sales.value!.phone}'),
                                        buildText(
                                            'Alamat: ${invoice.sales.value!.address}'),
                                        const SizedBox(height: 10),
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
                                          itemCount: invoice
                                              .purchaseList.value.items.length,
                                          itemBuilder: (context, index) {
                                            var item = invoice.purchaseList
                                                .value.items[index];
            
                                            return Column(
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
                                                            ' x ${number.format(item.purchaseQuantity)} ${item.product.unit}'),
                                                      ],
                                                    ),
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
                                              MainAxisAlignment.end,
                                          children: [
                                            buildText('----------', bold: true),
                                          ],
                                        ),
            
                                        const SizedBox(height: 20),
                                      ],
                                    ),
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
                                          printerController.selectedPrintMethod
                                                      .value ==
                                                  'receipt'
                                              ? printerController
                                                  .printTransport(invoice)
                                              : printerController
                                                  .printTransportInv(invoice);
                                          Get.back();
                                        },
                                        child: const Text('Cetak PO'),
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
        ),
      );
    }),
  );
}

Widget buildHeader(
    PurchaseOrderModel invoice, PrintPurchaseOrderController controller) {
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
