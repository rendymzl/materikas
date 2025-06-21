import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:printing/printing.dart';

import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../infrastructure/models/customer_model.dart';
import '../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../infrastructure/models/invoice_sales_model.dart';
import '../global_widget/invoice_print_widget/generate_invoice_backup.dart';
import '../global_widget/invoice_print_widget/print_ble_controller.dart';
import '../global_widget/invoice_print_widget/print_usb_controller.dart';
import '../global_widget/invoice_print_widget/printer_setting.dart';
import '../global_widget/invoice_print_widget/receipt_preview.dart';
import '../global_widget/popup_page_widget.dart';

void printInvoiceSalesDialog(InvoiceSalesModel invoiceSales) {
  final printerC = Get.put(PrinterUsbController());

  final isPO = invoiceSales.purchaseOrder.value;

  final invoice = InvoiceModel(
    id: invoiceSales.id,
    storeId: invoiceSales.storeId,
    invoiceId: invoiceSales.invoiceName.value,
    createdAt: invoiceSales.createdAt.value,
    customer: CustomerModel(
        name: invoiceSales.sales.value?.name ?? '',
        phone: invoiceSales.sales.value?.phone ?? '',
        address: invoiceSales.sales.value?.address ?? ''),
    purchaseList: invoiceSales.purchaseList.value,
    discount: invoiceSales.discount.value,
    tax: invoiceSales.tax.value,
    payments: invoiceSales.payments,
    debtAmount: invoiceSales.debtAmount.value,
    isDebtPaid: invoiceSales.isDebtPaid.value,
    removeAt: invoiceSales.removeAt.value,
    account: printerC.account!,
    priceType: 1,
  );

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
                                        build: (format) => generateInvoice(
                                            invoice,
                                            isSupplier: true),
                                        useActions: false,
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: PrintButtonBarWindows(
                                    invoice: invoice, isPO: isPO),
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
                                          returned: <CartItem>[],
                                          isSupplier: true,
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
                                                  : () => printerC.printReceipt(
                                                      invoice,
                                                      isSupplier: true,
                                                      isPO: isPO),
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
  const PrintButtonBarWindows(
      {super.key, required this.invoice, this.isPO = false});
  final InvoiceModel invoice;
  final bool isPO;

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
                  // Obx(() {
                  //   return Container(
                  //     width: 180,
                  //     margin: const EdgeInsets.all(8.0),
                  //     decoration: BoxDecoration(
                  //       border: Border.all(color: Colors.black, width: 1),
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     child: CheckboxListTile(
                  //       title: Row(
                  //         children: [
                  //           Icon(
                  //             Symbols.delivery_truck_speed,
                  //             color: Theme.of(Get.context!).primaryColor,
                  //           ),
                  //           const SizedBox(width: 8),
                  //           const Text(
                  //             'Surat Jalan',
                  //             style: TextStyle(
                  //               fontSize: 16,
                  //               color: Colors.black,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       value: printerC.isPrintTransport.value,
                  //       onChanged: (bool? value) {
                  //         printerC.setPrintTransport(value);
                  //       },
                  //       activeColor: Theme.of(Get.context!).primaryColor,
                  //       checkboxShape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(4),
                  //       ),
                  //       contentPadding: const EdgeInsets.symmetric(
                  //           horizontal: 6, vertical: 0),
                  //       dense: true,
                  //       visualDensity: VisualDensity.compact,
                  //     ),
                  //   );
                  // }),
                  // SizedBox(width: 4),
                  ElevatedButton.icon(
                    onPressed: printerC.selectedPrinter.value == null
                        ? null
                        : () => printerC.printReceipt(invoice,
                            isSupplier: true, isPO: isPO),
                    icon: const Icon(Symbols.print, fill: 1),
                    label: const Text('Cetak'),
                  ),
                ],
              ),
            );
    });
  }
}
