// Helper function to generate invoice bytes
import 'dart:io';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../profile/logo_widget_controller.dart';
// import 'print_ble_controller.dart';
// import 'print_controller.dart';

Future<List<int>> generateReceiptBytes(InvoiceModel invoice, String size,
    bool printDate, bool isPrintTransport, bool isSupplier,
    {bool isPO = false}) async {
  final AuthService authService = Get.find<AuthService>();

  print('isPrintTransportisPrintTransportisPrintTransport $isPrintTransport');

  List<CartItem> filterReturn(InvoiceModel invoice) {
    List<CartItem> workerData = invoice.purchaseList.value.items
        .where((p) => p.quantityReturn.value > 0)
        .map((purchased) => purchased)
        .toList();
    return workerData;
  }

  PaperSize getPaperSize(String paperSize) {
    switch (paperSize) {
      case '58 mm':
        return PaperSize.mm58;
      case '72mm':
        return PaperSize.mm72;
      case '80 mm':
        return PaperSize.mm80;
      case '>100mm':
        return PaperSize.mm80;
      default:
        throw Exception('Ukuran kertas tidak valid');
    }
  }

  final PaperSize paperSize = getPaperSize(size);

  // late final account = sideMenuC.account.value;
  late final store = authService.store.value;
  final profile = await CapabilityProfile.load();
  final generator = Generator(paperSize, profile);

  List<int> bytes = [];

  final logoController = Get.put(LogoWidgetController(store!), tag: store.id);
  await Future.delayed(const Duration(seconds: 2));
  print('logoController.fileExists.value ${logoController.fileExists.value}');

  if (logoController.fileExists.value &&
      logoController.photoPath.value.isNotEmpty) {
    try {
      final file = File(logoController.photoPath.value);
      final imageBytes = await file.readAsBytes();
      img.Image? decodedImage = img.decodeImage(imageBytes);

      if (decodedImage != null) {
        // 🔹 Perkecil gambar (resize ke lebar max 250 px, tinggi menyesuaikan)
        final resizedImage = img.copyResize(decodedImage, width: 150);

        // 🔹 Ubah gambar menjadi grayscale
        final grayscaleImage = img.grayscale(resizedImage);

        // 🔹 Konversi gambar ke format printer
        bytes.addAll(generator.image(grayscaleImage));
      } else {
        print('Failed to decode image');
      }
    } catch (e) {
      print('Error loading logo image: $e');
    }
  }

  // Add header
  bytes += generator.text(
    store.name.value,
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

  if (isPrintTransport) {
    bytes += generator.text(
      isPO ? 'Purchase Order' : 'SURAT JALAN',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.feed(1);
  }

  // Add invoice details
  bytes += generator.row([
    PosColumn(
      text: invoice.invoiceId!,
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
      text: '${size == '80mm' ? 'Nama:' : ''}  ${invoice.customer.value!.name}',
      width: 6,
    ),
    PosColumn(
      text: isSupplier ? '' : 'Kasir: ${invoice.account.value.name}',
      width: 6,
      styles: PosStyles(align: PosAlign.right),
    ),
  ]);
  bytes += generator.text(
    '${size == '80mm' ? 'No.Telp:' : ''} ${invoice.customer.value!.phone}',
    styles: const PosStyles(),
  );
  bytes += generator.text(
    '${size == '80mm' ? 'Alamat:' : ''} ${invoice.customer.value!.address}',
    styles: const PosStyles(),
  );
  bytes += generator.feed(1);

  // Add items
  // if (invoice.isReturn) {
  //   bytes += generator.text(
  //     '-- Pesanan Awal --',
  //     styles: const PosStyles(bold: true),
  //   );
  // }

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
      text: isPrintTransport ? 'Qty' : 'Harga',
      width: 4,
      styles: const PosStyles(bold: true, align: PosAlign.right),
    ),
  ]);
  bytes += generator.hr();
  var filteredPurchase = invoice.purchaseList.value.items
      .where((item) => item.quantity.value > 0)
      .toList();
  for (var i = 0; i < filteredPurchase.length; i++) {
    var item = filteredPurchase[i];
    bytes += generator.row([
      PosColumn(
        text: '${i + 1}',
        width: 1,
      ),
      PosColumn(
        text: item.product.productName,
        width: isPrintTransport ? 6 : 10,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: isPrintTransport
            ? '${number.format(item.purchaseQuantity)} ${item.product.unit}'
            : '',
        width: isPrintTransport ? 5 : 1,
      ),
    ]);
    if (!isPrintTransport) {
      bytes += generator.row([
        PosColumn(
          text:
              '${currency.format(isSupplier ? item.product.costPrice.value : item.product.getPrice(invoice.priceType.value).value)} x ${number.format(item.purchaseQuantity)} ${item.product.unit}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
        // PosColumn(
        //   text: '${number.format(item.purchaseQuantity)} ${item.product.unit}',
        //   width: 4,
        // ),
        PosColumn(
          text: currency.format(isSupplier
              ? item.product.costPrice.value * item.quantity.value
              : item.getSubPurchase(invoice.priceType.value)),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    // }
  }

  // Add totals
  bytes += generator.hr();
  if (!isPrintTransport) {
    if (invoice.isReturn) {
      bytes += generator.row([
        PosColumn(
          text: 'Subtotal:',
          width: 8,
        ),
        PosColumn(
          text: currency.format(invoice.subtotalBill),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      bytes += generator.feed(2);
      bytes += generator.text(
        '-- Barang yang direturn --',
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
        ),
      );

      bytes += generator.hr();
      List<CartItem> returned = filterReturn(invoice);
      if (invoice.returnList.value != null) {
        returned.addAll(invoice.returnList.value!.items);
      }
      for (var i = 0; i < returned.length; i++) {
        var item = returned[i];
        if (item.quantityReturn.value > 0) {
          bytes += generator.row([
            PosColumn(
              text: '${i + 1}',
              width: 1,
            ),
            PosColumn(
              text: item.product.productName,
              width: 11,
              styles: PosStyles(align: PosAlign.left),
            ),
          ]);
          bytes += generator.row([
            PosColumn(
              text:
                  '${currency.format(item.product.getPrice(invoice.priceType.value).value)} x ${number.format(item.quantityReturn.value)} ${item.product.unit}',
              width: 6,
              styles: const PosStyles(align: PosAlign.right),
            ),
            PosColumn(
              text: currency.format(item.getReturn(invoice.priceType.value)),
              width: 6,
              styles: const PosStyles(align: PosAlign.right),
            ),
          ]);
        }
      }

      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(
          text: 'Subtotal return:',
          width: 8,
        ),
        PosColumn(
          text: invoice.isReturn
              ? '-${currency.format((invoice.totalReturn))}'
              : '0',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: 'Biaya return:',
          width: 8,
        ),
        PosColumn(
          text: currency.format(invoice.returnFee.value),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: '',
          width: 8,
        ),
        PosColumn(
          text: '----------',
          width: 4,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: 'Total return:',
          width: 8,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: '-${currency.format(invoice.totalReturnFinal)}',
          width: 4,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
      ]);

      bytes += generator.feed(2);
      bytes += generator.hr();
    }

    bytes += generator.row([
      PosColumn(
        text: 'SUBTOTAL HARGA',
        width: 8,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: currency.format(
            isSupplier ? invoice.subtotalCost : invoice.subTotalPurchase),
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
    if (invoice.totalOtherCosts > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'Biaya lainnya:',
          width: 8,
        ),
        PosColumn(
          text: invoice.totalOtherCosts > 0
              ? currency.format(invoice.totalOtherCosts)
              : '0',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    if (invoice.isReturn) {
      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(
          text: 'Tagihan sebelum return:',
          width: 8,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: currency.format(invoice.totalPurchase),
          width: 4,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
      ]);

      bytes += generator.row([
        PosColumn(
          text: 'Total return:',
          width: 8,
          // styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: currency.format(invoice.totalReturnFinal),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      bytes += generator.hr();

      bytes += generator.row([
        PosColumn(
          text: 'Tagihan setelah return:',
          width: 8,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: currency.format(invoice.totalBill),
          width: 4,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
      ]);
    }

    for (var i = 0; i < invoice.payments.length; i++) {
      bytes += generator.row([
        PosColumn(
          text:
              'Pembayaran ${(!invoice.isDebtPaid.value || invoice.payments.length > 1) ? '${i + 1}' ' (${DateFormat('dd MMM y', 'id').format(invoice.payments[i].date!)})' : ''}',
          width: 8,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: currency.format(invoice.totalPaidByIndex(i) == invoice.totalBill
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
        text: currency.format(
            (isSupplier ? invoice.remainingCost : invoice.remainingDebt) * -1),
        width: 4,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);

    bytes += generator.feed(2);
    if (!isSupplier) {
      for (var i = 0; i < store.textPrint!.length; i++) {
        bytes += generator.text(
          store.textPrint![i],
          styles: const PosStyles(
            align: PosAlign.center,
          ),
        );
        bytes += generator.feed(1);
      }
    }
  }
  if (printDate) {
    bytes += generator.feed(2);
    bytes += generator.text(
      'dicetak: ${date.format(DateTime.now())}',
      styles: const PosStyles(
        align: PosAlign.center,
      ),
    );
  }

  bytes += generator.feed(3);
  bytes += generator.cut();

  return bytes;
}
