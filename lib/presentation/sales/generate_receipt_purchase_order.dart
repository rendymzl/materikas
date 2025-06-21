// Helper function to generate invoice bytes
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../infrastructure/models/invoice_sales_model.dart';
// import '../../infrastructure/models/purchase_order_model.dart';

Future<List<int>> generateReceiptPurchaseOrder(
    InvoiceSalesModel invoice, String size) async {
  final AuthService authService = Get.find<AuthService>();
  // late final account = storeServices.account;
  late final store = authService.store.value;
  final profile = await CapabilityProfile.load();

  PaperSize getPaperSize(String paperSize) {
    switch (paperSize) {
      case '58mm':
        return PaperSize.mm58;
      case '72mm':
        return PaperSize.mm72;
      case '80mm':
        return PaperSize.mm80;
      case '>100mm':
        return PaperSize.mm80;
      default:
        throw Exception('Ukuran kertas tidak valid');
    }
  }

  final generator = Generator(getPaperSize(size), profile);

  List<int> bytes = [];

  // Add header
  bytes += generator.text(
    store!.name.value,
    styles: const PosStyles(
      align: PosAlign.center,
      bold: true,
      height: PosTextSize.size2,
      width: PosTextSize.size2,
    ),
  );
  bytes += generator.text(
    store.address.value,
    styles: const PosStyles(
      align: PosAlign.center,
    ),
  );
  String phone = store.phone.value;
  String telp = store.telp.value;
  String slash = (phone.isNotEmpty && telp.isNotEmpty) ? '/' : '';
  bytes += generator.text(
    '$phone $slash $telp',
    styles: const PosStyles(
      align: PosAlign.center,
    ),
  );
  bytes += generator.hr();
  bytes += generator.text(
    invoice.purchaseOrder.value ? 'Purchase Order' : 'Invoice Sales',
    styles: const PosStyles(
      bold: true,
      align: PosAlign.center,
    ),
  );
  bytes += generator.hr();

  // Add invoice details
  bytes += generator.row([
    PosColumn(
      text: invoice.invoiceName.value!,
      width: 4,
      styles: const PosStyles(bold: true),
    ),
    PosColumn(
      text: DateFormat('dd-MM-y, HH:mm', 'id').format(
        invoice.createdAt.value!,
      ),
      width: 8,
      styles: PosStyles(align: PosAlign.right),
    ),
  ]);
  bytes += generator.row([
    PosColumn(
      text: '${invoice.sales.value!.name}',
      width: 6,
    ),
    PosColumn(
      text: '',
      width: 6,
    ),
  ]);
  bytes += generator.text(
    '${invoice.sales.value!.phone}',
    styles: const PosStyles(
        // align: PosAlign.center,
        ),
  );
  bytes += generator.text(
    '${invoice.sales.value!.address}',
    styles: const PosStyles(
        // align: PosAlign.center,
        ),
  );
  bytes += generator.feed(1);

  // Add items
  bytes += generator.hr();
  bytes += generator.row([
    PosColumn(
      text: 'No',
      width: 2,
      styles: const PosStyles(bold: true),
    ),
    PosColumn(
      text: 'Nama Barang',
      width: 6,
      styles: const PosStyles(bold: true),
    ),
    PosColumn(
      text: invoice.purchaseOrder.value ? '' : 'Harga',
      width: 4,
      styles: const PosStyles(bold: true, align: PosAlign.right),
    ),
  ]);
  bytes += generator.hr();
  List<CartItem> purchase = invoice.purchaseList.value.items;

  for (var i = 0; i < purchase.length; i++) {
    var item = purchase[i];
    var costPrice = currency.format(item.product.costPrice.value);
    if (item.quantity.value > 0) {
      bytes += generator.row([
        PosColumn(
          text: '${i + 1}',
          width: 1,
        ),
        PosColumn(
          text: item.product.productName,
          width: 11,
        ),
        // PosColumn(
        //   text: '',
        //   width: 4,
        // ),
      ]);
      bytes += generator.row([
        PosColumn(
          text:
              '${invoice.purchaseOrder.value ? '' : costPrice} x ${number.format(item.quantity.value)} ${item.product.unit}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text:
              invoice.purchaseOrder.value ? '' : currency.format(item.subCost),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
        // PosColumn(
        //   text: '',
        //   width: 4,
        //   styles: const PosStyles(align: PosAlign.right),
        // ),
      ]);
    }
  }
  bytes += generator.hr();
  if (!invoice.purchaseOrder.value) {
    bytes += generator.row([
      PosColumn(
        text: 'SUBTOTAL HARGA',
        width: 8,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: currency.format(invoice.subtotalCost),
        width: 4,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Total diskon:',
        width: 8,
      ),
      PosColumn(
        text: invoice.totalDiscount > 0
            ? '-${currency.format(invoice.totalDiscount)}'
            : '0',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    for (var i = 0; i < invoice.payments.length; i++) {
      bytes += generator.row([
        PosColumn(
          text:
              'Pembayaran ${(!invoice.isDebtPaid.value || invoice.payments.length > 1) ? '${i + 1}' ' (${DateFormat('dd MMM y', 'id').format(invoice.payments[i].date!)})' : ''}',
          width: 8,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: currency.format(invoice.totalPaidByIndex(i) == invoice.totalCost
              ? invoice.payments[i].amountPaid
              : invoice.payments[i].finalAmountPaid),
          width: 4,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
      ]);
    }
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
        text: invoice.remainingDebt <= 0 ? 'Kembalian:' : 'Kurang Bayar:',
        width: 8,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: currency.format(invoice.remainingDebt * -1),
        width: 4,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);
  }
  bytes += generator.feed(2);
  bytes += generator.text(
    'Dicetak: ${date.format(DateTime.now())}',
    styles: const PosStyles(
      align: PosAlign.center,
    ),
  );
  // Add totals
  // bytes += generator.hr();
  bytes += generator.feed(3);

  return bytes;
}
