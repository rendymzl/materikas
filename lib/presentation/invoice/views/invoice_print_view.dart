import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';

import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../global_widget/invoice_print_widget/print_ble_controller.dart';

class InvoicePrintView extends GetView {
  const InvoicePrintView({super.key});
  @override
  Widget build(BuildContext context) {
    final PrinterBluetoothController printerC = Get.find();
    // printerC.connected.value = false;
    var invoice = printerC.invoice;
    List<CartItem> filterReturn(InvoiceModel invoice) {
      List<CartItem> workerData = invoice.purchaseList.value.items
          .where((p) => p.quantityReturn.value > 0)
          .map((purchased) => purchased)
          .toList();
      return workerData;
    }

    List<CartItem> returned = filterReturn(invoice);
    if (invoice.returnList.value != null) {
      //! RETURN LIST
      returned.addAll(invoice.returnList.value!.items);
    }
    // printerC.connectLastPrinter();
    // printerController.setDefaultPrinter();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pengaturan Printer'),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () {
                  printerC.startScan();
                },
                icon: const Icon(
                  Symbols.refresh,
                  // size: 13,
                  // color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Obx(
          () {
            // var filteredPurchase = invoice.purchaseList.value.items
            //     .where((item) => item.quantity.value > 0)
            //     .toList();
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                // shrinkWrap: true,
                // padding: EdgeInsets.all(12),
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Ukuran Printer',
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
                    onChanged: (value) {
                      printerC.setPaperSize(value!);
                    },
                  ),
                  Divider(color: Colors.grey[200]),
                  Obx(
                    () {
                      if (printerC.store!.promo != null) {
                        printerC.textPromo.text = printerC.store!.promo!.value;
                      }
                      return printerC.isLoading.value
                          ? const CircularProgressIndicator()
                          : Expanded(
                              child: ListView.builder(
                                itemCount: printerC.devices.length,
                                itemBuilder: (context, index) {
                                  // var isLoading = false.obs;
                                  return Obx(() {
                                    // RxBool isConnected = RxBool(
                                    //     printerC.devices[index].isConnected ??
                                    //         false);
                                    return ListTile(
                                      selected: printerC
                                              .selectedDevice.value?.address ==
                                          printerC.devices[index].address,
                                      selectedColor:
                                          Theme.of(context).colorScheme.primary,
                                      // tileColor: printerC.selectedDevice.value ==
                                      //         printerC.devices[index]
                                      //     ? Theme.of(context).colorScheme.primary
                                      //     : null,
                                      onTap: printerC
                                              .connectingDevice.value.isNotEmpty
                                          ? null
                                          : () async {
                                              // isLoading.value = true;
                                              printerC.connectingDevice.value =
                                                  printerC.devices[index]
                                                          .address ??
                                                      '';
                                              await printerC.connect(
                                                  printerC.devices[index]);
                                              // isLoading.value = false;
                                              // printerC.selectedDevice.value =
                                              //     printerC.devices[index];
                                              // if (printerC.devices[index].isConnected ?? false) {
                                              //   await printerC.flutterThermalPrinterPlugin
                                              //       .disconnect(printerC.devices[index]);
                                              // } else {
                                              //   await printerC.flutterThermalPrinterPlugin
                                              //       .connect(printerC.devices[index]);
                                              // }
                                            },
                                      title: Text(
                                        printerC.devices[index].name ??
                                            'No Name',
                                        // selectionColor: Colors.white,
                                      ),
                                      subtitle: Text(
                                        "Terhubung: ${printerC.connectingDevice.value == printerC.devices[index].address ? ' Menghubungkan...' : printerC.selectedDevice.value?.address == printerC.devices[index].address ? 'Ya' : 'Tidak'}",
                                        // selectionColor: Colors.white,
                                      ),
                                      trailing: printerC
                                                  .connectingDevice.value ==
                                              printerC.devices[index].address
                                          ? const CircularProgressIndicator()
                                          : Icon(
                                              printerC.devices[index]
                                                          .connectionType ==
                                                      ConnectionType.USB
                                                  ? Icons.usb
                                                  : Icons.bluetooth,
                                            ),
                                    );
                                  });
                                },
                              ),
                            );
                    },
                  ),
                  Divider(color: Colors.grey[200]),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          height: 80,
                          child: TextField(
                            controller: printerC.textPromo,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: "Text Tambahan",
                                labelStyle: const TextStyle(color: Colors.grey),
                                suffixIcon: IconButton(
                                    onPressed: () => printerC.saveBottomText(),
                                    icon: const Icon(Symbols.save))),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // !printerC.isPrinting.value
                  //     ? (printerC.selectedDevice.value != null)
                  //         ? Row(
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             children: [
                  //               Expanded(
                  //                 child: ElevatedButton.icon(
                  //                   onPressed: () {
                  //                     printerC.printReceipt(invoice);
                  //                   },
                  //                   icon: const Icon(Icons.print),
                  //                   label: const Text('Struk'),
                  //                 ),
                  //               ),
                  //               const SizedBox(width: 12),
                  //               Expanded(
                  //                 child: ElevatedButton.icon(
                  //                   onPressed: () {
                  //                     printerC.printTransport(invoice);
                  //                   },
                  //                   icon: const Icon(Icons.print),
                  //                   label: const Text(
                  //                     'Surat Jalan',
                  //                     style: TextStyle(fontSize: 14),
                  //                   ),
                  //                 ),
                  //               ),
                  //             ],
                  //           )
                  //         : Center(
                  //             child: Text(
                  //               'Pilih printer untuk mencetak!',
                  //               style: Get.context!.textTheme.headlineSmall!
                  //                   .copyWith(
                  //                       color: Theme.of(Get.context!)
                  //                           .colorScheme
                  //                           .primary),
                  //             ),
                  //           )
                  //     : const Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           CircularProgressIndicator(),
                  //           SizedBox(width: 20),
                  //           Text('Sedang mencetak...')
                  //         ],
                  //       ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget buildHeader(InvoiceModel invoice) {
  final PrinterBluetoothController controller = Get.find();
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
