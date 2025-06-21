import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:printing/printing.dart';

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../popup_page_widget.dart';
import 'generate_invoice_preview.dart';
import 'print_ble_controller.dart';
import 'print_usb_controller.dart';
import 'printer_setting.dart';
import 'receipt_preview.dart';

void printInvoiceDialog(InvoiceModel invoice) {
  final printerC = Get.put(PrinterUsbController());
  // printerC.connected.value = false;

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
  // printerC.setDefaultPrinter();

  showPopupPageWidget(
    title: 'Print Invoice',
    height: MediaQuery.of(Get.context!).size.height,
    width: MediaQuery.of(Get.context!).size.width * 0.75,
    content: Obx(() {
      var filteredPurchase = invoice.purchaseList.value.items
          .where((item) => item.quantity.value > 0)
          .toList();
      print(printerC.store?.textPrint?.length);
      print(printerC.isPrintTransport.value);
      return Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 320,
              // flex: 2,
              child: Card(
                elevation: 0,
                child: PrinterSetting(),
              ),
            ),
            Expanded(
              child: Card(
                color: Colors.grey[200],
                elevation: 0,
                child: printerC.initLoading.value || printerC.isLoading.value
                    ? Center(child: CircularProgressIndicator())
                    : printerC.selectedPaperSize.value == '210 mm'
                        ? Column(
                            // mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: printerC.isReorder.value
                                    ? Center(child: CircularProgressIndicator())
                                    : PdfPreview(
                                        scrollViewDecoration: BoxDecoration(
                                            color: Colors.transparent),
                                        build: (format) =>
                                            generateInvoice(invoice),
                                        useActions: false,
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: PrintButtonBarWindows(invoice: invoice),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: RepaintBoundary(
                                        key: printerC.globalKey,
                                        child: ReceiptPreview(
                                          invoice: invoice,
                                          printerC: printerC,
                                          filteredPurchase: filteredPurchase,
                                          returned: returned,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Expanded(
                              //   child: SingleChildScrollView(
                              //     child: Obx(() => printerC.imageBytes.value !=
                              //             null
                              //         ? Image.file(printerC.imageBytes.value!)
                              //         : Text("Gambar belum dibuat")),
                              //   ),
                              // ),
                              // const SizedBox(height: 12),
                              if (android)
                                Obx(() {
                                  final printerC =
                                      Get.find<PrinterBluetoothController>();
                                  return printerC.message.value
                                          .toLowerCase()
                                          .contains('menghubungkan')
                                      ? const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: CircularProgressIndicator(),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: printerC.selectedDevice
                                                          .value ==
                                                      null
                                                  ? null
                                                  : () => printerC
                                                      .printReceipt(invoice),
                                              icon: const Icon(Icons.print),
                                              label: const Text('Cetak'),
                                            ),
                                            // SizedBox(width: 4),
                                            // ElevatedButton.icon(
                                            //   onPressed: printerC.selectedDevice
                                            //               .value ==
                                            //           null
                                            //       ? null
                                            //       : () => printerC
                                            //           .printTransport(invoice),
                                            //   icon: const Icon(Icons.print),
                                            //   label: const Text('Surat Jalan'),
                                            // ),
                                          ],
                                        );
                                })
                              else
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child:
                                      PrintButtonBarWindows(invoice: invoice),
                                ),
                            ],
                          ),
              ),
            ),
          ],
        ),
      );
    }),
  );
}

class PrintButtonBarWindows extends StatelessWidget {
  const PrintButtonBarWindows({super.key, required this.invoice});
  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final printerC = Get.find<PrinterUsbController>();
      return printerC.message.value.toLowerCase().contains('menghubungkan')
          ? CircularProgressIndicator()
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                // border: Border.all(color: Colors.grey),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Symbols.file_save, fill: 1),
                    label: const Text("Download PDF"),
                    onPressed: () => printerC.savePdf(invoice),
                  ),
                  // SizedBox(width: 4),
                  // OutlinedButton.icon(
                  //   onPressed: printerC.selectedPrinter.value == null
                  //       ? null
                  //       : () => printerC.printTransport(invoice),
                  //   icon: const Icon(Symbols.print, fill: 1),
                  //   label: const Text('Surat Jalan'),
                  // ),
                  Obx(() {
                    return Container(
                      width: 180,
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CheckboxListTile(
                        title: Row(
                          children: [
                            Icon(
                              Symbols.delivery_truck_speed,
                              color: Theme.of(Get.context!).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Surat Jalan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        value: printerC.isPrintTransport.value,
                        onChanged: (bool? value) {
                          printerC.setPrintTransport(value);
                        },
                        activeColor: Theme.of(Get.context!).primaryColor,
                        checkboxShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 0),
                        dense: true,
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  }),
                  // SizedBox(width: 4),
                  ElevatedButton.icon(
                    onPressed: printerC.selectedPrinter.value == null
                        ? null
                        : () => printerC.printReceipt(invoice),
                    icon: const Icon(Symbols.print, fill: 1),
                    label: const Text('Cetak'),
                  ),
                ],
              ),
            );
    });
  }
}
