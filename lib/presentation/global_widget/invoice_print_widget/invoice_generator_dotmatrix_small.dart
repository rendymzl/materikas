// import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/models/print_column_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import 'generator.dart';

Future<List<int>> generateStrukDotMatrix(
    InvoiceModel invoice, bool printDate) async {
  final AuthService authService = Get.find<AuthService>();

  List<CartItem> filterPurchase(InvoiceModel invoice) {
    List<CartItem> workerData = invoice.purchaseList.value.items
        .where((p) => p.quantity.value > 0)
        .map((purchased) => purchased)
        .toList();
    return workerData;
  }

  // String getPaymentTypes(InvoiceModel invoice) {
  //   String paymentTypes = '';
  //   if (invoice.payments.isNotEmpty) {
  //     for (var payment in invoice.payments) {
  //       if (payment.amountPaid > 0) {
  //         if (paymentTypes.isNotEmpty) {
  //           paymentTypes += ', ';
  //         }
  //         paymentTypes += payment.method!;
  //       }
  //     }
  //   }
  //   return paymentTypes.isEmpty ? 'Cash' : paymentTypes;
  // }

  List<CartItem> purchase = filterPurchase(invoice);

  Generator generator = Generator();
  List<int> bytes = [];

  // generator.setFontGlobal('A');
  // bytes += halfDivider;paperSize: 32

  // bytes += generator.newLine(); // bytes += generator.newLine();

  late final store = authService.store.value;

  generator.setFontGlobal('large');
  //! Header
  bytes += generator.row([
    PrintColumn(
      text: store!.name.value,
      width: 16,
      align: 'center',
      // size: 'large',
      bold: true,
    ),
  ]);

  generator.setFontGlobal('C');

  bytes += generator.row([
    PrintColumn(
      text: store.address.value,
      width: 32,
      align: 'center',
      bold: true,
    ),
  ]);

  String phone = store.phone.value;
  String telp = store.telp.value;
  String slash = (phone.isNotEmpty && telp.isNotEmpty) ? '/' : '';

  bytes += generator.row([
    PrintColumn(
      text: '$phone $slash $telp',
      width: 32,
      align: 'center',
      bold: true,
    ),
  ]);

  bytes += generator.divider(paperSize: 32);
  bytes += generator.newLine();

//! DETAIL INVOICE
  bytes += generator.row([
    PrintColumn(
      text: invoice.invoiceId!,
      bold: true,
      width: 14,
    ),
    PrintColumn(
      text: DateFormat('dd-MM-y, HH:mm', 'id').format(
        invoice.createdAt.value!,
      ),
      bold: true,
      align: 'right',
      width: 18,
    ),
  ]);

  bytes += generator.row([
    PrintColumn(
      text: invoice.customer.value!.name,
      width: 16,
      bold: true,
    ),
    PrintColumn(
      text: 'Kasir: ${invoice.account.value.name}',
      align: 'right',
      width: 16,
      bold: true,
    ),
  ]);

  bytes += generator.row([
    PrintColumn(
      text: invoice.customer.value!.phone ?? '',
      width: 32,
      bold: true,
    ),
  ]);

  bytes += generator.row([
    PrintColumn(
      text: invoice.customer.value!.address ?? '',
      width: 32,
      bold: true,
    ),
  ]);

  bytes += generator.space();
  //! barang
  bytes += generator.divider(paperSize: 32);
  bytes += generator.newLine();
  bytes += generator.row([
    PrintColumn(text: 'No', width: 4, bold: true),
    PrintColumn(text: 'Nama Barang', width: 14, bold: true),
    PrintColumn(text: 'Harga', width: 14, align: 'right', bold: true),
  ]);
  bytes += generator.divider(paperSize: 32);
  bytes += generator.newLine();

  for (var i = 0; i < purchase.length; i++) {
    var item = purchase[i];

    if (item.quantity.value > 0) {
      bytes += generator.row([
        PrintColumn(text: '${i + 1}', width: 4, bold: true),
        PrintColumn(text: item.product.productName, width: 28, bold: true),
      ]);
      bytes += generator.row([
        PrintColumn(text: '', width: 4, bold: true),
        PrintColumn(
            text:
                '${currency.format(item.product.getPrice(invoice.priceType.value).value)} x ${number.format(item.purchaseQuantity)} ${item.product.unit}',
            width: 14,
            bold: true),
        PrintColumn(
            text: currency.format(item.getSubPurchase(invoice.priceType.value)),
            width: 14,
            align: 'right',
            bold: true),
      ]);
    }
  }

  bytes += generator.divider(paperSize: 32);
  bytes += generator.newLine();

  bytes += generator.row([
    PrintColumn(
      text: 'SUBTOTAL HARGA',
      width: 16,
      bold: true,
    ),
    PrintColumn(
      text: currency.format(invoice.subTotalPurchase),
      align: 'right',
      width: 16,
      bold: true,
    ),
  ]);
  bytes += generator.row([
    PrintColumn(
      text: 'Total diskon:',
      width: 16,
      bold: true,
    ),
    PrintColumn(
      text: invoice.totalDiscount > 0
          ? '-${currency.format(invoice.totalDiscount)}'
          : '0',
      align: 'right',
      width: 16,
      bold: true,
    ),
  ]);

  if (invoice.totalOtherCosts > 0) {
    bytes += generator.row([
      PrintColumn(
        text: 'Biaya lainnya:',
        width: 16,
        bold: true,
      ),
      PrintColumn(
        text: invoice.totalOtherCosts > 0
            ? currency.format(invoice.totalOtherCosts)
            : '0',
        align: 'right',
        width: 16,
        bold: true,
      ),
    ]);
  }

  for (var i = 0; i < invoice.payments.length; i++) {
    bytes += generator.row([
      PrintColumn(
        text:
            'Pembayaran ${(!invoice.isDebtPaid.value || invoice.payments.length > 1) ? '${i + 1}' ' (${DateFormat('dd MMM y', 'id').format(invoice.payments[i].date!)})' : ''}',
        width: 16,
        bold: true,
      ),
      PrintColumn(
        text: currency.format(invoice.totalPaidByIndex(i) == invoice.totalBill
            ? invoice.payments[i].amountPaid
            : invoice.payments[i].finalAmountPaid),
        align: 'right',
        width: 16,
        bold: true,
      ),
    ]);
  }

  bytes += generator.divider(paperSize: 32);
  bytes += generator.newLine();

  bytes += generator.row([
    PrintColumn(
      text: invoice.remainingDebt <= 0 ? 'Kembalian:' : 'Kurang Bayar:',
      width: 16,
      bold: true,
    ),
    PrintColumn(
      text: currency.format(invoice.remainingDebt * -1),
      align: 'right',
      width: 16,
      bold: true,
    ),
  ]);
  bytes += generator.space();
  bytes += generator.space();
  // bytes += generator.row([
  //   PrintColumn(
  //     text: 'Barang yang sudah dibeli',
  //     width: 32,
  //     bold: true,
  //     align: 'center',
  //   ),
  // ]);
  // bytes += generator.row([
  //   PrintColumn(
  //     text: 'tidak dapat ditukar/dikembalikan!',
  //     width: 32,
  //     bold: true,
  //     align: 'center',
  //   ),
  // ]);

  for (var i = 0; i < store.textPrint!.length; i++) {
    PrintColumn(
      text: store.textPrint![i],
      width: 32,
      bold: true,
      align: 'center',
    );
    bytes += generator.space();
  }

  // bytes += generator.row([
  //   PrintColumn(
  //     text: 'Terimakasih atas pembelian anda!',
  //     width: 32,
  //     bold: true,
  //     align: 'center',
  //   ),
  // ]);

  if (printDate) {
    bytes += generator.space();
    bytes += generator.space();
    bytes += generator.row([
      PrintColumn(
        text: 'dicetak: ${date.format(DateTime.now())}',
        width: 32,
        bold: true,
        align: 'center',
      ),
    ]);
  }

  bytes += generator.space();
  bytes += generator.space();
  bytes += generator.space();
  bytes += generator.space();
  bytes += generator.space();
  bytes += generator.space();
  bytes += generator.space();
  bytes += generator.space();
  bytes += generator.space();
  bytes += generator.space();
  generator.cut();

  return bytes;
}
