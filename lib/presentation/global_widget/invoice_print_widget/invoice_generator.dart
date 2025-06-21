import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/models/print_column_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import 'generator.dart';

var divider = Uint8List.fromList(
    '------------------------------------------------------------------------------------------------'
        .codeUnits);

var halfDivider = Uint8List.fromList(
    '----------------------------------------------------------'.codeUnits);

var space = Uint8List.fromList([27, 74, 24]);

final AuthService authService = Get.find<AuthService>();
final store = authService.store.value;

Future<List<int>> generateInvoiceBytes(InvoiceModel invoice) async {
  List<CartItem> filterPurchase(InvoiceModel invoice) {
    List<CartItem> workerData = invoice.purchaseList.value.items
        .where((p) => p.quantity.value > 0)
        .map((purchased) => purchased)
        .toList();
    return workerData;
  }

  String getPaymentTypes(InvoiceModel invoice) {
    String paymentTypes = '';
    if (invoice.payments.isNotEmpty) {
      for (var payment in invoice.payments) {
        if (payment.amountPaid > 0) {
          if (paymentTypes.isNotEmpty) {
            paymentTypes += ', ';
          }
          paymentTypes += payment.method!;
        }
      }
    }
    return paymentTypes.isEmpty ? 'Cash' : paymentTypes;
  }

  List<CartItem> purchase = filterPurchase(invoice);

  Generator generator = Generator();
  List<int> bytes = [];

  bytes += halfDivider;
  bytes += generator.newLine();

//! DETAIL INVOICE
  bytes += generator.row([
    PrintColumn(
      text: 'No. Invoice',
      bold: true,
      width: 20,
    ),
    PrintColumn(
      text: ':${invoice.invoiceId!}',
      bold: true,
      width: 30,
    ),
    PrintColumn(
      text: '',
      width: 5,
    ),
    PrintColumn(
      text: 'Kepada Yth.',
      width: 30,
      bold: true,
    ),
    PrintColumn(text: '', width: 10),
  ]);

  bytes += generator.row([
    PrintColumn(
      text: 'Tgl. Penjualan',
      width: 20,
      bold: true,
    ),
    PrintColumn(
      text: ':${DateFormat('dd MMMM yyyy', 'id').format(
        invoice.createdAt.value!,
      )}',
      width: 30,
      bold: true,
    ),
    PrintColumn(
      text: '',
      width: 5,
      bold: true,
    ),
    PrintColumn(
      text: invoice.customer.value != null ? invoice.customer.value!.name : '',
      width: 30,
      bold: true,
    ),
    PrintColumn(text: '', width: 10),
  ]);

  bytes += generator.row([
    PrintColumn(
      text: 'Jenis Transaksi',
      width: 20,
      bold: true,
    ),
    PrintColumn(
      text: ':${getPaymentTypes(invoice)}',
      width: 30,
      bold: true,
    ),
    PrintColumn(
      text: '',
      width: 5,
    ),
    PrintColumn(
      text: invoice.customer.value != null
          ? invoice.customer.value!.address!
          : '',
      width: 30,
      bold: true,
    ),
    PrintColumn(text: '', width: 10),
  ]);

  bytes += space;
//! barang
  bytes += generator.divider();
  bytes += generator.row([
    PrintColumn(text: 'No', width: 3, bold: true),
    PrintColumn(text: 'Nama Barang', width: 42, bold: true),
    PrintColumn(text: 'Uk', width: 13, bold: true),
    PrintColumn(text: 'Qty', width: 8, bold: true),
    PrintColumn(text: 'Harga', width: 11, align: 'right', bold: true),
    PrintColumn(text: 'Jumlah', width: 13, align: 'right', bold: true),
  ]);
  bytes += generator.divider();

  for (var i = 0; i < purchase.length; i++) {
    var item = purchase[i];
    if (item.quantity.value > 0) {
      bytes += generator.row([
        PrintColumn(text: '${i + 1}', width: 3, bold: true),
        PrintColumn(text: item.product.productName, width: 42, bold: true),
        PrintColumn(text: item.product.unit, width: 13, bold: true),
        PrintColumn(
            text: number.format(item.quantity.value), width: 8, bold: true),
        PrintColumn(
            text: currency.format(item.getPrice(invoice.priceType.value)),
            width: 11,
            align: 'right',
            bold: true),
        PrintColumn(
            text: currency.format(item.getSubBill(invoice.priceType.value)),
            width: 13,
            align: 'right',
            bold: true),
      ]);
    }
  }
  bytes += generator.divider();
  bytes += generator.row([
    PrintColumn(
        text: store!.textPrint != null && store!.textPrint!.isNotEmpty
            ? store!.textPrint![0]
            : '',
        width: 62),
    PrintColumn(text: 'Grand Total', width: 15, bold: true),
    PrintColumn(
        text: currency.format(invoice.totalBill),
        width: 13,
        align: 'right',
        bold: true),
  ]);

  if (store!.textPrint != null && store!.textPrint!.length > 1) {
    for (var i = 1; i < store!.textPrint!.length; i++) {
      bytes += generator.row([
        PrintColumn(text: store!.textPrint![i], width: 62),
        PrintColumn(text: '', width: 15, bold: true),
        PrintColumn(text: '', width: 13, align: 'right', bold: true),
      ]);
    }
  }

  // bytes += generator.row([
  //   PrintColumn(text: 'Transfer BCA 1671979538 A/N Santori Alam', width: 62),
  //   PrintColumn(text: '', width: 15, bold: true),
  //   PrintColumn(text: '', width: 13, align: 'right', bold: true),
  // ]);

  for (var i = 0; i < 14 - purchase.length; i++) {
    bytes += space;
  }

  bytes += generator.row([
    PrintColumn(
      text: '',
      width: 5,
    ),
    PrintColumn(
      text: 'Customer',
      width: 20,
      align: 'center',
      bold: true,
    ),
    PrintColumn(
      text: '',
      width: 5,
    ),
    PrintColumn(
      text: 'Admin',
      width: 20,
      align: 'center',
      bold: true,
    ),
    PrintColumn(
      text: '',
      width: 5,
    ),
    PrintColumn(
      text: 'Driver',
      width: 20,
      align: 'center',
      bold: true,
    ),
    PrintColumn(
      text: '',
      width: 5,
    ),
  ]);

  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  bytes += space;
  generator.cut();

  return bytes;
}
