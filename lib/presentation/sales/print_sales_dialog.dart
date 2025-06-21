// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:material_symbols_icons/symbols.dart';
// // import 'package:thermal_printer/thermal_printer.dart';

// import '../../../infrastructure/utils/display_format.dart';
// import '../../infrastructure/models/invoice_sales_model.dart';
// // import '../../infrastructure/models/purchase_order_model.dart';
// import '../global_widget/invoice_print_widget/print_ble_controller.dart';
// import '../global_widget/invoice_print_widget/print_usb_controller.dart';
// import '../global_widget/popup_page_widget.dart';
// import 'print_purchase_order_controller.dart';

// void printInvoiceSalesDialog(InvoiceSalesModel invoice) {
//   final PrintPurchaseOrderController printerController =
//       Get.put(PrintPurchaseOrderController());
//   printerController.connected.value = false;

//   printerController.setDefaultPrinter();

//   showPopupPageWidget(
//     title: 'Print Invoice',
//     height: MediaQuery.of(Get.context!).size.height * (0.85),
//     width: MediaQuery.of(Get.context!).size.width * (0.6),
//     content: Expanded(
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Column(
//                       children: [
//                         if (android)
//                           Column(
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   const Text(
//                                     'Pilih Printer',
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                   IconButton(
//                                     onPressed: () =>
//                                         Get.find<PrinterBluetoothController>()
//                                             .startScan(),
//                                     icon: const Icon(
//                                       Symbols.refresh,
//                                       color: Colors.red,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 12),
//                               Obx(() {
//                                 Get.put(PrinterBluetoothController());
//                                 return DropdownButtonFormField<String>(
//                                   decoration: const InputDecoration(
//                                     labelText: 'Printer',
//                                     border: OutlineInputBorder(),
//                                   ),
//                                   value: Get.find<PrinterBluetoothController>()
//                                       .selectedDevice
//                                       .value
//                                       ?.address,
//                                   items: Get.find<PrinterBluetoothController>()
//                                       .devices
//                                       .map((device) => DropdownMenuItem<String>(
//                                             value: device.address,
//                                             child: Text(
//                                               device.name!,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ))
//                                       .toList(),
//                                   onChanged: Get.find<
//                                               PrinterBluetoothController>()
//                                           .message
//                                           .value
//                                           .toLowerCase()
//                                           .contains('menghubungkan')
//                                       ? null
//                                       : (value) {
//                                           var device = Get.find<
//                                                   PrinterBluetoothController>()
//                                               .devices
//                                               .firstWhereOrNull(
//                                                   (d) => d.address == value);
//                                           if (device != null) {
//                                             print('Menghubungkan Printer...');
//                                             Get.find<
//                                                     PrinterBluetoothController>()
//                                                 .connect(device);
//                                           }
//                                         },
//                                 );
//                               }),
//                               const SizedBox(height: 12),
//                               Obx(() {
//                                 return DropdownButtonFormField<String>(
//                                   decoration: const InputDecoration(
//                                     labelText: 'Ukuran',
//                                     border: OutlineInputBorder(),
//                                   ),
//                                   value: Get.find<PrinterBluetoothController>()
//                                           .selectedPaperSize
//                                           .value
//                                           .isEmpty
//                                       ? null
//                                       : Get.find<PrinterBluetoothController>()
//                                           .selectedPaperSize
//                                           .value,
//                                   items: Get.find<PrinterBluetoothController>()
//                                       .paperSize
//                                       .map((size) => DropdownMenuItem<String>(
//                                             value: size,
//                                             child: Text(size),
//                                           ))
//                                       .toList(),
//                                   onChanged: Get.find<
//                                               PrinterBluetoothController>()
//                                           .message
//                                           .value
//                                           .toLowerCase()
//                                           .contains('menghubungkan')
//                                       ? null
//                                       : (value) {
//                                           Get.find<PrinterBluetoothController>()
//                                               .setPaperSize(value!);
//                                         },
//                                 );
//                               }),
//                             ],
//                           )
//                         else
//                           Column(
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   const Text(
//                                     'Pilih Printer',
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                   IconButton(
//                                     onPressed: () =>
//                                         Get.find<PrinterUsbController>()
//                                             .startScan(),
//                                     icon: const Icon(
//                                       Symbols.refresh,
//                                       color: Colors.red,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 12),
//                               Obx(() {
//                                 Get.put(PrinterUsbController());
//                                 return DropdownButtonFormField<String>(
//                                   decoration: const InputDecoration(
//                                     labelText: 'Printer',
//                                     border: OutlineInputBorder(),
//                                   ),
//                                   value: Get.find<PrinterUsbController>()
//                                       .selectedPrinter
//                                       .value
//                                       ?.name,
//                                   items: Get.find<PrinterUsbController>()
//                                       .devices
//                                       .map((device) => DropdownMenuItem<String>(
//                                             value: device.name,
//                                             child: Text(
//                                               device.name,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ))
//                                       .toList(),
//                                   onChanged: Get.find<PrinterUsbController>()
//                                           .message
//                                           .value
//                                           .toLowerCase()
//                                           .contains('menghubungkan')
//                                       ? null
//                                       : (value) {
//                                           var device =
//                                               Get.find<PrinterUsbController>()
//                                                   .devices
//                                                   .firstWhereOrNull(
//                                                       (d) => d.name == value);
//                                           if (device != null) {
//                                             print('Menghubungkan Printer...');
//                                             Get.find<PrinterUsbController>()
//                                                 .connect(device);
//                                           }
//                                         },
//                                 );
//                               }),
//                               const SizedBox(height: 12),
//                               Obx(() {
//                                 return DropdownButtonFormField<String>(
//                                   decoration: const InputDecoration(
//                                     labelText: 'Ukuran',
//                                     border: OutlineInputBorder(),
//                                   ),
//                                   value: Get.find<PrinterUsbController>()
//                                           .selectedPaperSize
//                                           .value
//                                           .isEmpty
//                                       ? null
//                                       : Get.find<PrinterUsbController>()
//                                           .selectedPaperSize
//                                           .value,
//                                   items: Get.find<PrinterUsbController>()
//                                       .paperSize
//                                       .map((size) => DropdownMenuItem<String>(
//                                             value: size,
//                                             child: Text(size),
//                                           ))
//                                       .toList(),
//                                   onChanged: Get.find<PrinterUsbController>()
//                                           .message
//                                           .value
//                                           .toLowerCase()
//                                           .contains('menghubungkan')
//                                       ? null
//                                       : (value) {
//                                           Get.find<PrinterUsbController>()
//                                               .setPaperSize(value!);
//                                         },
//                                 );
//                               }),
//                             ],
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     Expanded(
//                       child: Obx(
//                         () => ListView(
//                           controller: printerController.scrollController,
//                           shrinkWrap: true,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(12),
//                               child: Column(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       buildHeader(invoice, printerController),
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           buildText('${invoice.invoiceName}',
//                                               bold: true),
//                                           buildText(
//                                               DateFormat('dd-MM-y, HH:mm', 'id')
//                                                   .format(
//                                             invoice.createdAt.value!,
//                                           )),
//                                         ],
//                                       ),
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           buildText(
//                                               '${invoice.sales.value!.name}'),
//                                         ],
//                                       ),
//                                       // const SizedBox(height: 10),
//                                       // buildText('Customer:', bold: true),

//                                       buildText(
//                                           '${invoice.sales.value!.phone}'),
//                                       buildText(
//                                           '${invoice.sales.value!.address}'),
//                                       const SizedBox(height: 10),
//                                       const Divider(thickness: 1),
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Row(
//                                             children: [
//                                               SizedBox(
//                                                   width: 35,
//                                                   child: buildText('No',
//                                                       bold: true)),
//                                               buildText('Nama Barang',
//                                                   bold: true),
//                                             ],
//                                           ),
//                                           if (!invoice.purchaseOrder.value)
//                                             buildText('Harga', bold: true),
//                                         ],
//                                       ),
//                                       const Divider(thickness: 1),
//                                       ListView.builder(
//                                         physics: NeverScrollableScrollPhysics(),
//                                         shrinkWrap: true,
//                                         itemCount: invoice
//                                             .purchaseList.value.items.length,
//                                         itemBuilder: (context, index) {
//                                           var item = invoice
//                                               .purchaseList.value.items[index];
//                                           var costPrice = currency.format(
//                                               item.product.costPrice.value);
//                                           return Column(
//                                             children: [
//                                               Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   Row(
//                                                     children: [
//                                                       SizedBox(
//                                                           width: 35,
//                                                           child: buildText(
//                                                               '${index + 1}')),
//                                                       buildText(
//                                                           '${item.product.productName},'),
//                                                     ],
//                                                   ),
//                                                 ],
//                                               ),
//                                               Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   Row(
//                                                     children: [
//                                                       SizedBox(
//                                                           width: 35,
//                                                           child: buildText('')),
//                                                       buildText(
//                                                           '${invoice.purchaseOrder.value ? '' : costPrice} x ${number.format(item.purchaseQuantity)} ${item.product.unit}'),
//                                                     ],
//                                                   ),
//                                                   if (!invoice
//                                                       .purchaseOrder.value)
//                                                     buildText(currency
//                                                         .format(item.subCost)),
//                                                 ],
//                                               ),
//                                             ],
//                                           );
//                                           // : const SizedBox();
//                                         },
//                                       ),
//                                       const Divider(thickness: 1),
//                                       invoice.purchaseOrder.value
//                                           ? Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.end,
//                                               children: [
//                                                 buildText('----------',
//                                                     bold: true),
//                                               ],
//                                             )
//                                           : Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 buildText('Subtotal:',
//                                                     bold: true),
//                                                 buildText(
//                                                     currency.format(
//                                                         invoice.subtotalCost),
//                                                     bold: true),
//                                               ],
//                                             ),
//                                       if (!invoice.purchaseOrder.value)
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             buildText('Total diskon:'),
//                                             buildText(invoice.totalDiscount > 0
//                                                 ? '-${currency.format(invoice.totalDiscount)}'
//                                                 : '0'),
//                                           ],
//                                         ),
//                                       if (!invoice.purchaseOrder.value)
//                                         ListView.builder(
//                                           physics:
//                                               NeverScrollableScrollPhysics(),
//                                           shrinkWrap: true,
//                                           itemCount: invoice.payments.length,
//                                           itemBuilder: (context, index) {
//                                             return Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 buildText(
//                                                     'Pembayaran ${(!invoice.isDebtPaid.value || invoice.payments.length > 1) ? '${index + 1}' ' (${DateFormat('dd MMM y', 'id').format(invoice.payments[index].date!)})' : ''}',
//                                                     bold: true),
//                                                 buildText(
//                                                     currency.format(invoice
//                                                                 .totalPaidByIndex(
//                                                                     index) ==
//                                                             invoice.totalCost
//                                                         ? invoice
//                                                             .payments[index]
//                                                             .amountPaid
//                                                         : invoice
//                                                             .payments[index]
//                                                             .finalAmountPaid),
//                                                     bold: true),
//                                               ],
//                                             );
//                                           },
//                                         ),
//                                       if (!invoice.purchaseOrder.value)
//                                         const Divider(thickness: 1),
//                                       if (!invoice.purchaseOrder.value)
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             buildText(
//                                                 invoice.remainingDebt <= 0
//                                                     ? 'Kembalian:'
//                                                     : 'Kurang Bayar:',
//                                                 bold: true),
//                                             buildText(
//                                                 currency.format(
//                                                     invoice.remainingDebt * -1),
//                                                 bold: true),
//                                           ],
//                                         ),
//                                       const SizedBox(height: 20),
//                                       Text(
//                                         'Dicetak: ${date.format(DateTime.now())}',
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                           fontFamily: 'Courier',
//                                           fontSize: 12,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 20),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Column(
//                       children: [
//                         if (android)
//                           Obx(() {
//                             final printerC =
//                                 Get.find<PrinterBluetoothController>();
//                             return printerC.message.value
//                                     .toLowerCase()
//                                     .contains('menghubungkan')
//                                 ? const Padding(
//                                     padding: EdgeInsets.all(8.0),
//                                     child: CircularProgressIndicator(),
//                                   )
//                                 : ElevatedButton.icon(
//                                     onPressed:
//                                         printerC.selectedDevice.value == null
//                                             ? null
//                                             : () => printerC
//                                                 .printTransportSales(invoice),
//                                     icon: const Icon(Icons.print),
//                                     label: Text(
//                                         'Cetak ${invoice.purchaseOrder.value ? 'PO' : ''}'),
//                                   );
//                           })
//                         else
//                           Obx(() {
//                             final printerC = Get.find<PrinterUsbController>();
//                             return printerC.message.value
//                                     .toLowerCase()
//                                     .contains('menghubungkan')
//                                 ? const Padding(
//                                     padding: EdgeInsets.all(8.0),
//                                     child: CircularProgressIndicator(),
//                                   )
//                                 : ElevatedButton.icon(
//                                     onPressed:
//                                         printerC.selectedPrinter.value == null
//                                             ? null
//                                             : () => printerC
//                                                 .printTransportSales(invoice),
//                                     icon: const Icon(Icons.print),
//                                     label: Text(
//                                         'Cetak ${invoice.purchaseOrder.value ? 'PO' : ''}'),
//                                   );
//                           }),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// Widget buildHeader(
//     InvoiceSalesModel invoice, PrintPurchaseOrderController controller) {
//   String phone = controller.store!.phone.value;
//   String telp = controller.store!.telp.value;
//   String slash = (phone.isNotEmpty && telp.isNotEmpty) ? '/' : '';
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.center,
//     children: [
//       Text(
//         controller.store!.name.value,
//         style: const TextStyle(
//           fontFamily: 'Courier',
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       Text(
//         controller.store!.address.value,
//         textAlign: TextAlign.center,
//         style: const TextStyle(
//           fontFamily: 'Courier',
//           fontSize: 12,
//         ),
//       ),
//       Text(
//         '$phone $slash $telp',
//         style: const TextStyle(
//           fontFamily: 'Courier',
//           fontSize: 12,
//         ),
//       ),
//       const Divider(thickness: 1),
//       Text(
//         invoice.purchaseOrder.value ? 'Purchase Order' : 'Invoice Sales',
//         // '$phone $slash $telp',
//         style: const TextStyle(
//           fontFamily: 'Courier',
//           fontSize: 12,
//         ),
//       ),
//       const Divider(thickness: 1),
//     ],
//   );
// }

// Widget buildText(String text, {bool bold = false}) {
//   return Text(
//     text,
//     style: TextStyle(
//       fontFamily: 'Courier',
//       fontSize: 12,
//       fontWeight: bold ? FontWeight.bold : FontWeight.normal,
//     ),
//   );
// }
