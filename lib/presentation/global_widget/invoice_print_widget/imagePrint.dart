import 'dart:convert';
import 'dart:io';

import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/models/store_model.dart';
import '../../../infrastructure/utils/display_format.dart';
// import 'dart:typed_data';

// import 'package:flutter/services.dart';
// import 'package:image/image.dart' as img;

// Fungsi untuk mengirim data gambar ke printer secara langsung
Future<void> printImageWithText(
  String imagePath,
  String printerName,
  InvoiceModel invoice,
  StoreModel store,
  bool printDate, {
  String? storeName,
  String? storeAddress,
  String? storePhone,
  bool smallPaper = false,
  bool isPrintTransport = false,
  bool isSupplier = false,
  bool isPO = false,
}) async {
  print('isPO $isPO');
  try {
    // Menyiapkan gambar dan teks
    // final ByteData data = await rootBundle.load(imagePath);
    // final Uint8List imgBytes = data.buffer.asUint8List();
    // final img.Image image = img.decodeImage(imgBytes)!;

    // String exePath =
    //     '${Directory(Platform.resolvedExecutable).parent.path}/printImage/bin/Release/net8.0/win-x64/publish/PrintImage.exe';
    String exePath =
        '${Directory(Platform.resolvedExecutable).parent.path}/data/flutter_assets/assets/printer/PrintImage.exe';

    List<String> arguments = [];

    arguments.add(imagePath); //0
    arguments.add(printerName); //1
    arguments.add(storeName ?? ''); //2
    arguments.add(storeAddress ?? ''); //3
    arguments.add(storePhone ?? ''); //4
    arguments.add(jsonEncode(invoice.toJson())); //5
    arguments.add(jsonEncode(store.toJson())); //6
    arguments.add(currency
        .format(isSupplier ? invoice.subtotalCost : invoice.subtotalBill)); //7
    arguments.add(invoice.totalDiscount > 0
        ? '-${currency.format(invoice.totalDiscount)}'
        : ''); //8
    arguments.add(invoice.totalOtherCosts > 0
        ? currency.format(invoice.totalOtherCosts)
        : ''); //9
    arguments
        .add(invoice.remainingDebt <= 0 ? 'Kembalian:' : 'Kurang Bayar:'); //10
    arguments.add(currency.format(
        (isSupplier ? invoice.remainingCost : invoice.remainingDebt) *
            -1)); //11
    arguments
        .add(printDate ? 'dicetak: ${date.format(DateTime.now())}' : ''); //12
    arguments.add(smallPaper ? 'small' : 'large'); //13
    arguments.add(isPrintTransport ? '1' : '0'); //14
    arguments.add(isSupplier ? '1' : '0'); //15
    arguments.add(isPO ? '1' : '0'); //16
    // print('argument Lenght ${arguments.length}');

    ProcessResult result = await Process.run(exePath, arguments);

    if (result.stdout.isNotEmpty) {
      print("Output: ${result.stdout}");
    }
    if (result.stderr.isNotEmpty) {
      print("Error: ${result.stderr}");
    }

    // Cek apakah proses berhasil
    if (result.exitCode == 0) {
      print('Printing succeeded');
    } else {
      print('Printing failed: ${result.stderr}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
