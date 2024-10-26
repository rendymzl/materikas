// Helper function to generate invoice bytes
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import 'print_controller.dart';

Future<void> generateTransportBlue(InvoiceModel invoice) async {
  final AuthService authService = Get.find<AuthService>();
  final PrinterController printerController = Get.put(PrinterController());
  // late final account = sideMenuC.account.value;
  late final store = authService.store.value;
  // final profile = await CapabilityProfile.load();
  // final generator = Generator(PaperSize.mm80, profile);

  var bluetooth = printerController.bluePrint;

  bluetooth.printCustom(
    store!.name.value,
    2,
    1, // 1 = Center Align, 2 = Right Align
  );
  bluetooth.printCustom(
    store.address.value,
    0,
    1, // 1 = Center Align
  );

  // Print phone and telp
  String phone = store.phone.value;
  String telp = store.telp.value;
  String slash = (phone.isNotEmpty && telp.isNotEmpty) ? '/' : '';
  bluetooth.printCustom(
    '$phone $slash $telp',
    0,
    1, // 1 = Center Align
  );

  // Print horizontal line
  bluetooth.printNewLine();
  bluetooth.printCustom(
    "-----------------------------",
    0,
    1,
  );
  bluetooth.printCustom(
    "SURAT JALAN",
    0,
    1,
  );
  bluetooth.printCustom(
    "-----------------------------",
    0,
    1,
  );

  // Print Invoice ID dan Tanggal
  bluetooth.printCustom(
    invoice.invoiceId!,
    1,
    0, // Left align
  );
  bluetooth.printCustom(
    DateFormat('dd-MM-y, HH:mm', 'id').format(invoice.createdAt.value!),
    1,
    2, // Right align
  );

  // Print Informasi Pelanggan dan Kasir
  bluetooth.printCustom(
    'Pelanggan: ${invoice.customer.value!.name}',
    1,
    0, // Left align
  );
  bluetooth.printCustom(
    'Kasir: ${invoice.account.value.name}',
    1,
    0, // Left align
  );

  // Print No Telp dan Alamat Pelanggan
  bluetooth.printCustom(
    'No Telp: ${invoice.customer.value!.phone}',
    1,
    0, // Left align
  );
  bluetooth.printCustom(
    'Alamat: ${invoice.customer.value!.address}',
    1,
    0, // Left align
  );

  bluetooth.printNewLine();

  // Print Horizontal Line
  bluetooth.printCustom(
    "-----------------------------",
    1,
    1, // Center align
  );

  // Print Kolom Barang (No, Nama Barang, Harga)
  bluetooth.printCustom(
    "No               Nama Barang",
    1,
    0, // Left align
  );
  bluetooth.printCustom(
    "-----------------------------",
    1,
    1, // Center align
  );

  // Loop untuk Mencetak Barang yang Dibeli
  var filteredPurchase = invoice.purchaseList.value.items
      .where((item) => item.quantity.value > 0)
      .toList();

  for (var i = 0; i < filteredPurchase.length; i++) {
    var item = filteredPurchase[i];

    // Cetak Nama Barang
    bluetooth.printCustom(
      '${i + 1}. ${item.product.productName}',
      1,
      0, // Left align
    );

    // Cetak Harga, Kuantitas, dan Total
    bluetooth.printCustom(
      '${number.format(item.purchaseQuantity)} ${item.product.unit}',
      1,
      0, // Left align
    );
  }

  // Cetak garis horizontal
  bluetooth.printCustom("-----------------------------", 1, 1);

  if (invoice.isReturn) {
    // Subtotal sebelum return
    bluetooth.printNewLine();
    bluetooth.printCustom('-- Barang yang direturn --', 1, 1);
    bluetooth.printCustom("-----------------------------", 1, 1);

    List<CartItem> returned = printerController.filterReturn(invoice);
    if (invoice.returnList.value != null) {
      returned.addAll(invoice.returnList.value!.items);
    }

    for (var i = 0; i < returned.length; i++) {
      var item = returned[i];
      if (item.quantityReturn.value > 0) {
        bluetooth.printCustom('${i + 1}. ${item.product.productName}', 1, 0);
        bluetooth.printCustom(
            '${number.format(item.quantityReturn.value)} ${item.product.unit}',
            1,
            0);
      }
    }

    bluetooth.printCustom("-----------------------------", 1, 1);
  }

  bluetooth.printNewLine();
  bluetooth.printNewLine();
  bluetooth.printNewLine();

  // You can now continue adding items or details to the receipt

  // Finish printing
  bluetooth.paperCut();
}
