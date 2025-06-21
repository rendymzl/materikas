// // Helper function to generate invoice bytes
// import 'dart:typed_data';

// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../../../infrastructure/dal/services/auth_service.dart';
// import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
// import '../../../infrastructure/models/invoice_model/invoice_model.dart';
// import '../../../infrastructure/utils/display_format.dart';

// import 'print_controller.dart';
// import 'printerenum.dart';

// Future<void> generateReceiptBlue(InvoiceModel invoice) async {
//   final AuthService authService = Get.find<AuthService>();
//   final PrinterController printerController = Get.put(PrinterController());
//   // late final account = sideMenuC.account.value;
//   late final store = authService.store.value;
//   // final profile = await CapabilityProfile.load();
//   // final generator = Generator(PaperSize.mm80, profile);

//   // ByteData bytesAsset =
//   //     await rootBundle.load('assets/icon/logo-materikas-transparent.png');
//   // Uint8List imageBytesFromAsset = bytesAsset.buffer
//   //     .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);

//   var bluetooth = printerController.bluePrint;
//   bluetooth.printNewLine();
//   bluetooth.printCustom(
//       store!.name.value, Size.boldMedium.val, Align.center.val);
//   bluetooth.printCustom(store.address.value, Size.bold.val, Align.center.val);

//   // Print phone and telp
//   String phone = store.phone.value;
//   String telp = store.telp.value;
//   String slash = (phone.isNotEmpty && telp.isNotEmpty) ? '/' : '';

//   bluetooth.printCustom('$phone $slash $telp', Size.bold.val, Align.center.val);

//   // bluetooth.printCustom(
//   //   '$phone $slash $telp',
//   //   0,
//   //   1, // 1 = Center Align
//   // );

//   bluetooth.printNewLine();
//   bluetooth.printCustom("HEADER", Size.boldMedium.val, Align.center.val);
//   bluetooth.printNewLine();
//   // bluetooth.printImage(file.path); //path of your image/logo
//   bluetooth.printNewLine();
//   // bluetooth.printImageBytes(imageBytesFromAsset); //image from Asset
//   bluetooth.printNewLine();
//   // bluetooth.printImageBytes(imageBytesFromNetwork); //image from Network
//   bluetooth.printNewLine();
//   bluetooth.printLeftRight("LEFT", "RIGHT", Size.medium.val);
//   bluetooth.printLeftRight("LEFT", "RIGHT", Size.bold.val);
//   bluetooth.printLeftRight("LEFT", "RIGHT", Size.bold.val,
//       format: "%-15s %15s %n"); //15 is number off character from left or right
//   bluetooth.printNewLine();
//   bluetooth.printLeftRight("LEFT", "RIGHT", Size.boldMedium.val);
//   bluetooth.printLeftRight("LEFT", "RIGHT", Size.boldLarge.val);
//   bluetooth.printLeftRight("LEFT", "RIGHT", Size.extraLarge.val);
//   bluetooth.printNewLine();
//   bluetooth.print3Column("Col1", "Col2", "Col3", Size.bold.val);
//   bluetooth.print3Column("Col1", "Col2", "Col3", Size.bold.val,
//       format:
//           "%-10s %10s %10s %n"); //10 is number off character from left center and right
//   bluetooth.printNewLine();
//   bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", Size.bold.val);
//   bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", Size.bold.val,
//       format: "%-8s %7s %7s %7s %n");
//   bluetooth.printNewLine();
//   bluetooth.printCustom("čĆžŽšŠ-H-ščđ", Size.bold.val, Align.center.val,
//       charset: "windows-1250");
//   bluetooth.printLeftRight("Številka:", "18000001", Size.bold.val,
//       charset: "windows-1250");
//   bluetooth.printCustom("Body left", Size.bold.val, Align.left.val);
//   bluetooth.printCustom("Body right", Size.medium.val, Align.right.val);
//   bluetooth.printNewLine();
//   bluetooth.printCustom("Thank You", Size.bold.val, Align.center.val);
//   bluetooth.printNewLine();
//   bluetooth.printQRcode(
//       "Insert Your Own Text to Generate", 200, 200, Align.center.val);
//   bluetooth.printNewLine();
//   bluetooth.printNewLine();
//   // Print horizontal line
//   bluetooth.printCustom(
//     "-------------------------------",
//     0,
//     1,
//   );

//   // Print Invoice ID dan Tanggal
//   bluetooth.printCustom(invoice.invoiceId!, Size.bold.val, Align.center.val);
//   bluetooth.printCustom(
//       DateFormat('dd-MM-y, HH:mm', 'id').format(invoice.createdAt.value!),
//       Size.bold.val,
//       Align.center.val);
//   bluetooth.printCustom(
//       'Kasir: ${invoice.account.value.name}', Size.bold.val, Align.center.val);
//   // bluetooth.printLeftRight(
//   //     invoice.invoiceId!,
//   //     DateFormat('dd-MM-y, HH:mm', 'id').format(invoice.createdAt.value!),
//   //     Size.medium.val);
//   bluetooth.printNewLine();
//   // Print Informasi Pelanggan dan Kasir
//   // bluetooth.printLeftRight(
//   //     'Pelanggan: ${invoice.customer.value!.name}', 'Kasir:', Size.bold.val);

//   // bluetooth.printLeftRight('No Telp: ${invoice.customer.value!.phone}',
//   //     invoice.account.value.name, Size.bold.val);

//   // bluetooth.printCustom("No Telp: ${invoice.customer.value!.phone}",
//   //     Size.bold.val, Align.left.val);

//   bluetooth.printCustom("Pelanggan: ${invoice.customer.value!.name}",
//       Size.bold.val, Align.left.val);
//   bluetooth.printCustom("No Telp: ${invoice.customer.value!.phone}",
//       Size.bold.val, Align.left.val);
//   bluetooth.printCustom("Alamat: ${invoice.customer.value!.address}",
//       Size.bold.val, Align.left.val);

//   // bluetooth.printCustom(
//   //   'Pelanggan: ${invoice.customer.value!.name}',
//   //   1,
//   //   0, // Left align
//   // );
//   // bluetooth.printCustom(
//   //   'Kasir: ${invoice.account.value.name}',
//   //   1,
//   //   0, // Left align
//   // );

//   // Print No Telp dan Alamat Pelanggan
//   // bluetooth.printCustom(
//   //   'No Telp: ${invoice.customer.value!.phone}',
//   //   1,
//   //   0, // Left align
//   // );
//   // bluetooth.printCustom(
//   //   'Alamat: ${invoice.customer.value!.address}',
//   //   1,
//   //   0, // Left align
//   // );

//   bluetooth.printNewLine();

//   // Print Horizontal Line
//   bluetooth.printCustom(
//     "-------------------------------",
//     1,
//     1, // Center align
//   );

//   // Print Kolom Barang (No, Nama Barang, Harga)
//   bluetooth.printCustom(
//     "No   Nama Barang       Harga",
//     1,
//     0, // Left align
//   );
//   bluetooth.printCustom(
//     "-------------------------------",
//     1,
//     1, // Center align
//   );

//   // Loop untuk Mencetak Barang yang Dibeli
//   var filteredPurchase = invoice.purchaseList.value.items
//       .where((item) => item.quantity.value > 0)
//       .toList();

//   for (var i = 0; i < filteredPurchase.length; i++) {
//     var item = filteredPurchase[i];

//     // Cetak Nama Barang
//     bluetooth.printCustom(
//       '${i + 1}. ${item.product.productName}',
//       1,
//       0, // Left align
//     );

//     // Cetak Harga, Kuantitas, dan Total
//     // bluetooth.printCustom(
//     //   '${currency.format(item.product.getPrice(invoice.priceType.value).value)} x ${number.format(item.purchaseQuantity)} ${item.product.unit}',
//     //   1,
//     //   0, // Left align
//     // );
//     bluetooth.printLeftRight(
//         '${currency.format(item.product.getPrice(invoice.priceType.value).value)} x ${number.format(item.purchaseQuantity)} ${item.product.unit}',
//         currency.format(item.getSubPurchase(invoice.priceType.value)),
//         Size.bold.val);

//     // bluetooth.printCustom(
//     //   currency.format(item.getSubPurchase(invoice.priceType.value)),
//     //   1,
//     //   2, // Right align
//     // );
//   }

//   // Cetak garis horizontal
//   bluetooth.printCustom("-------------------------------", 1, 1);

//   if (invoice.isReturn) {
//     // Subtotal sebelum return
//     bluetooth.printCustom("Subtotal:", 1, 0);
//     bluetooth.printCustom(currency.format(invoice.subtotalBill), 1, 2);

//     bluetooth.printNewLine();
//     bluetooth.printCustom('-- Barang yang direturn --', 1, 1);
//     bluetooth.printCustom("-------------------------------", 1, 1);

//     List<CartItem> returned = printerController.filterReturn(invoice);
//     if (invoice.returnList.value != null) {
//       returned.addAll(invoice.returnList.value!.items);
//     }

//     for (var i = 0; i < returned.length; i++) {
//       var item = returned[i];
//       if (item.quantityReturn.value > 0) {
//         bluetooth.printCustom('${i + 1}. ${item.product.productName}', 1, 0);
//         bluetooth.printCustom(
//             '${currency.format(item.product.getPrice(invoice.priceType.value).value)} x ${number.format(item.quantityReturn.value)} ${item.product.unit}',
//             1,
//             0);
//         bluetooth.printCustom(
//             currency.format(item.getReturn(invoice.priceType.value)), 1, 2);
//       }
//     }

//     bluetooth.printCustom("-------------------------------", 1, 1);

//     // Subtotal return
//     bluetooth.printCustom("Subtotal return:", 1, 0);
//     bluetooth.printCustom('-${currency.format(invoice.totalReturn)}', 1, 2);

//     // Biaya return
//     bluetooth.printCustom("Biaya return:", 1, 0);
//     bluetooth.printCustom(currency.format(invoice.returnFee.value), 1, 2);

//     // Total return
//     bluetooth.printCustom("Total return:", 1, 0);
//     bluetooth.printCustom(
//         '-${currency.format(invoice.totalReturnFinal)}', 1, 2);

//     bluetooth.printNewLine();
//     bluetooth.printCustom("-------------------------------", 1, 1);
//   }

//   // Subtotal barang
//   bluetooth.printLeftRight('SUBTOTAL HARGA',
//       currency.format(invoice.subTotalPurchase), Size.bold.val);

//   // bluetooth.printCustom(
//   //     'SUBTOTAL HARGA (${invoice.purchaseList.value.items.length} Barang)',
//   //     1,
//   //     0);
//   // bluetooth.printCustom(currency.format(invoice.subTotalPurchase), 1, 2);

//   // Diskon
//   bluetooth.printLeftRight(
//       'Total diskon:',
//       invoice.totalDiscount > 0
//           ? '-${currency.format(invoice.totalDiscount)}'
//           : '0',
//       Size.bold.val);
//   // bluetooth.printCustom('Total diskon:', 1, 0);
//   // bluetooth.printCustom(
//   //   invoice.totalDiscount > 0
//   //       ? '-${currency.format(invoice.totalDiscount)}'
//   //       : '0',
//   //   1,
//   //   2,
//   // );

//   // Biaya lainnya
//   if (invoice.totalOtherCosts > 0) {
//     bluetooth.printLeftRight('Biaya lainnya:',
//         currency.format(invoice.totalOtherCosts), Size.bold.val);

//     // bluetooth.printCustom('Biaya lainnya:', 1, 0);
//     // bluetooth.printCustom(currency.format(invoice.totalOtherCosts), 1, 2);
//   }

//   if (invoice.isReturn) {
//     bluetooth.printCustom("-------------------------------", 1, 1);
//     bluetooth.printLeftRight('Tagihan sebelum return:',
//         currency.format(invoice.totalPurchase), Size.bold.val);

//     bluetooth.printLeftRight('Total return:',
//         currency.format(invoice.totalReturnFinal), Size.bold.val);

//     // bluetooth.printCustom('Tagihan sebelum return:', 1, 0);
//     // bluetooth.printCustom(currency.format(invoice.totalPurchase), 1, 2);

//     // bluetooth.printCustom('Total return:', 1, 0);
//     // bluetooth.printCustom(currency.format(invoice.totalReturnFinal), 1, 2);

//     bluetooth.printCustom("-------------------------------", 1, 1);

//     bluetooth.printLeftRight('Tagihan setelah return:',
//         currency.format(invoice.totalBill), Size.bold.val);

//     // bluetooth.printCustom('Tagihan setelah return:', 1, 0);
//     // bluetooth.printCustom(currency.format(invoice.totalBill), 1, 2);
//   }

//   // Pembayaran
//   for (var i = 0; i < invoice.payments.length; i++) {
//     bluetooth.printLeftRight(
//         'Pembayaran ${(!invoice.isDebtPaid.value || invoice.payments.length > 1) ? '${i + 1}' ' (${DateFormat('dd MMM y', 'id').format(invoice.payments[i].date!)})' : ''}',
//         currency.format(invoice.totalPaidByIndex(i) == invoice.totalBill
//             ? invoice.payments[i].amountPaid
//             : invoice.payments[i].finalAmountPaid),
//         Size.bold.val);

//     // bluetooth.printCustom(
//     //     'Pembayaran ${(!invoice.isDebtPaid.value || invoice.payments.length > 1) ? '${i + 1}' ' (${DateFormat('dd MMM y', 'id').format(invoice.payments[i].date!)})' : ''}',
//     //     1,
//     //     0);
//     // bluetooth.printCustom(
//     //     currency.format(invoice.totalPaidByIndex(i) == invoice.totalBill
//     //         ? invoice.payments[i].amountPaid
//     //         : invoice.payments[i].finalAmountPaid),
//     //     1,
//     //     2);
//   }

//   // Total kembalian atau kurang bayar
//   bluetooth.printLeftRight(
//       invoice.remainingDebt <= 0 ? 'Kembalian:' : 'Kurang Bayar:',
//       currency.format(invoice.remainingDebt * -1),
//       Size.bold.val);
//   // bluetooth.printCustom(
//   //     invoice.remainingDebt <= 0 ? 'Kembalian:' : 'Kurang Bayar:', 1, 0);
//   // bluetooth.printCustom(
//   //   currency.format(invoice.remainingDebt * -1),
//   //   1,
//   //   2,
//   // );

//   bluetooth.printNewLine();
//   bluetooth.printCustom('Barang yang sudah dibeli', 1, 1);
//   bluetooth.printCustom('tidak dapat ditukar/dikembalikan!', 1, 1);

//   bluetooth.printNewLine();
//   bluetooth.printCustom('Terimakasih atas pembelian anda!', 1, 1);

//   bluetooth.printNewLine();
//   bluetooth.printNewLine();
//   bluetooth.printNewLine();

//   // You can now continue adding items or details to the receipt

//   // Finish printing
//   bluetooth.paperCut();
// }
