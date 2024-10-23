import 'dart:io';
import 'dart:typed_data';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thermal_printer/thermal_printer.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/store_service.dart';
import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import 'generate_receipt_blue.dart';
import 'invoice_generator.dart';
import 'print_transport_inv.dart';
import 'receipt_generator.dart';
import 'transport_print_generator.dart';

class PrinterController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final StoreService _storeService = Get.find<StoreService>();
  final printMethod = ['receipt', 'invoice'].obs;
  var devices = <PrinterDevice>[].obs;
  final blueDevices = <BluetoothDevice>[].obs;
  final selectedBlue = Rx<BluetoothDevice?>(null);
  BlueThermalPrinter bluePrint = BlueThermalPrinter.instance;

  final selectedPrintMethod = ''.obs;
  var connected = false.obs;
  final textPromo = TextEditingController();
  late ScrollController scrollController = ScrollController();
  late final account = _authService.account.value;
  late final store = _authService.store.value;

  final isPrinting = false.obs;
  late final selectedDeviceIndex = (-1).obs;

  @override
  void onInit() async {
    ever(devices, (_) async {
      setDefaultPrinter();
    });
    super.onInit();
    // Check if the device is desktop or android
    if (Platform.isAndroid) {
      //! pake print_bluetooth_thermal
      await getBlue();
      // await scan(PrinterType.bluetooth, isBle: true);
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      await scan(PrinterType.usb);
    }
  }

  Future<void> getBlue() async {
    blueDevices.value = await bluePrint.getBondedDevices();
  }

  void setPrintMethod(String method) async {
    selectedPrintMethod.value = method;
  }

  void setDefaultPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final String? name = prefs.getString('default_printer_name');
    final String? address = prefs.getString('default_printer_address');

    if (name != null && address != null) {
      PrinterDevice selectedPrinter =
          PrinterDevice(name: name, address: address);
      // Check if the device is desktop or android
      if (Platform.isAndroid) {
        connect(selectedPrinter, PrinterType.bluetooth, isBle: true);
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        connect(selectedPrinter, PrinterType.usb);
      }
      debugPrint(name);
      debugPrint(address);
      selectedDeviceIndex.value =
          devices.indexWhere((device) => device.name == selectedPrinter.name);
      debugPrint(selectedDeviceIndex.value.toString());
    }
  }

  List<CartItem> filterPurchase(InvoiceModel invoice) {
    List<CartItem> workerData = invoice.purchaseList.value.items
        .where((p) => p.quantity.value > 0)
        .map((purchased) => purchased)
        .toList();
    return workerData;
  }

  List<CartItem> filterReturn(InvoiceModel invoice) {
    List<CartItem> workerData = invoice.purchaseList.value.items
        .where((p) => p.quantityReturn.value > 0)
        .map((purchased) => purchased)
        .toList();
    return workerData;
  }

  void selectedPrinterIndex(int index) async {
    selectedDeviceIndex.value = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_printer_name', devices[index].name);
    await prefs.setString(
        'default_printer_address', devices[index].address.toString());
  }

  void savePromoText() async {
    await Future.delayed(const Duration(milliseconds: 50), () async {
      await scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    });
    store!.promo?.value = textPromo.text;
    await _storeService.update(store!);
  }

  Future<void> scan(PrinterType type, {bool isBle = false}) async {
    devices.clear();
    PrinterManager.instance
        .discovery(type: type, isBle: isBle)
        .listen((device) {
      devices.add(device);
    });
  }

  // Future<void> scanBluetooth(PrinterType type, {bool isBle = false}) async {
  //   devices.clear();
  //   PrinterManager.instance
  //       .discovery(type: type, isBle: isBle)
  //       .listen((device) {
  //     devices.add(device);
  //   });
  // }

  Future<void> connect(PrinterDevice selectedPrinter, PrinterType type,
      {bool reconnect = false, bool isBle = false, String? ipAddress}) async {
    try {
      switch (type) {
        case PrinterType.usb:
          await PrinterManager.instance.connect(
              type: type,
              model: UsbPrinterInput(
                  name: selectedPrinter.name,
                  productId: selectedPrinter.productId,
                  vendorId: selectedPrinter.vendorId));
          break;
        case PrinterType.bluetooth:
          await PrinterManager.instance.connect(
              type: type,
              model: BluetoothPrinterInput(
                  name: selectedPrinter.name,
                  address: selectedPrinter.address!,
                  isBle: isBle,
                  autoConnect: reconnect));
          break;
        case PrinterType.network:
          await PrinterManager.instance.connect(
              type: type,
              model: TcpPrinterInput(
                  ipAddress: ipAddress ?? selectedPrinter.address!));
          break;
        default:
          throw Exception('Unsupported printer type');
      }
      connected.value = true;
    } catch (e) {
      debugPrint('Failed to connect: $e');
    }
  }

  Future<void> disconnect(PrinterType type) async {
    try {
      await PrinterManager.instance.disconnect(type: type);
      connected.value = false;
    } catch (e) {
      debugPrint('Failed to disconnect: $e');
    }
  }

  Future<void> sendBytesToPrint(List<int> bytes, PrinterType type) async {
    try {
      await PrinterManager.instance.send(type: type, bytes: bytes);
    } catch (e) {
      debugPrint('Failed to print: $e');
    }
  }

  // void listenBluetoothState() {
  //   PrinterManager.instance.stateBluetooth.listen((status) {
  //     debugPrint('Bluetooth status: $status');
  //   });
  // }

  Future<void> printReceipt(InvoiceModel invoice) async {
    // Check if the device is desktop or android
    if (Platform.isAndroid) {
      if ((await bluePrint.isConnected)!) {
        // Add header
        await generateReceiptBlue(invoice);
      }
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      if (connected.value) {
        final bytes = await generateReceiptBytes(invoice);
        await sendBytesToPrint(bytes, PrinterType.usb);
      }
    }
  }

  Future<void> printInvoice(InvoiceModel invoice) async {
    // Check if the device is desktop or android
    if (Platform.isAndroid) {
      if ((await bluePrint.isConnected)!) {
        bluePrint.printNewLine();
        bluePrint.printCustom('tes berhasil', 0, 1);
        bluePrint.printNewLine();
        bluePrint.printNewLine();
      }
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      if (connected.value) {
        final bytes = await generateInvoiceBytes(invoice);
        await sendBytesToPrint(bytes, PrinterType.usb);
      }
    }
  }

  Future<void> printTransport(InvoiceModel invoice) async {
    // Check if the device is desktop or android
    if (Platform.isAndroid) {
      if ((await bluePrint.isConnected)!) {
        bluePrint.printNewLine();
        bluePrint.printCustom('tes berhasil', 0, 1);
        bluePrint.printNewLine();
        bluePrint.printNewLine();
      }
      // await sendBytesToPrint(bytes, PrinterType.bluetooth);
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      if (connected.value) {
        final bytes = await generateTransportBytes(invoice);
        await sendBytesToPrint(bytes, PrinterType.usb);
      }
    }
  }

  Future<void> printTransportInv(InvoiceModel invoice) async {
    // Check if the device is desktop or android
    if (Platform.isAndroid) {
      if ((await bluePrint.isConnected)!) {
        bluePrint.printNewLine();
        bluePrint.printCustom('tes berhasil', 0, 1);
        bluePrint.printNewLine();
        bluePrint.printNewLine();
      }
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      if (connected.value) {
        final bytes = await generateTransportInvBytes(invoice);
        await sendBytesToPrint(bytes, PrinterType.usb);
      }
    }
  }

//! tes print
  String padRight(String text, int length) {
    if (text.length < length) {
      return text.padRight(length);
    } else {
      return '${text.substring(0, length - 1)} ';
    }
  }

  String padLeft(String text, int length) {
    if (text.length < length) {
      return text.padLeft(length);
    } else {
      return text.substring(0, length);
    }
  }

  String printRow(List<String> columns, List<int> widths,
      {List<bool>? rightAlign}) {
    String row = '';
    for (int i = 0; i < columns.length; i++) {
      String columnText = columns[i];
      int columnWidth = widths[i];

      if (rightAlign != null && rightAlign[i]) {
        row += padLeft(columnText, columnWidth);
      } else {
        row += padRight(columnText, columnWidth);
      }
    }
    return '$row\n';
  }

  Future<List<int>> generateTesBytes() async {
    // final profile = await CapabilityProfile.load();
    // final generator = Generator(PaperSize.mm80, profile);

    List<int> bytes = [];

    // Font besar dan bold
    bytes += Uint8List.fromList([27, 97, 0]); // ESC a 0 untuk align left
    bytes +=
        Uint8List.fromList([27, 33, 48]); // ESC ! 48 untuk ukuran font besar
    bytes += Uint8List.fromList([27, 69, 1]); // ESC E 1 untuk bold
    bytes += Uint8List.fromList('TB. ARCA NUSANTARA\n'.codeUnits);
    bytes += Uint8List.fromList([27, 69, 0]); // ESC E 0 untuk normal (non-bold)
    bytes += Uint8List.fromList([27, 33, 0]); // ESC ! 0 untuk ukuran font

    // Font normal
    bytes += Uint8List.fromList('Font Normal\n'.codeUnits);
    // Feed 2 lines
    bytes += Uint8List.fromList([27, 74, 24]); // ESC J n untuk feed 24 dot
    // // Bold text
    // bytes += Uint8List.fromList([27, 69, 1]); // ESC E 1 untuk bold
    // bytes += Uint8List.fromList('Bold Text\n'.codeUnits);
    // bytes += Uint8List.fromList([27, 69, 0]); // ESC E 0 untuk normal (non-bold)

    // // Align left
    // bytes += Uint8List.fromList([27, 97, 0]); // ESC a 0 untuk align left
    // bytes += Uint8List.fromList([27, 69, 0]); // ESC E 0 untuk normal (non-bold)
    // bytes += Uint8List.fromList('Align Left\n'.codeUnits);

    // // Align center
    // bytes += Uint8List.fromList([27, 97, 1]); // ESC a 1 untuk align center
    // bytes += Uint8List.fromList('Align Center\n'.codeUnits);

    // // Align right
    // bytes += Uint8List.fromList([27, 97, 2]); // ESC a 2 untuk align right
    // bytes += Uint8List.fromList('Align Right\n'.codeUnits);

    // Divider full width
    // bytes += Uint8List.fromList([27, 97, 1]);
    bytes += Uint8List.fromList(
        '--------------------------------------------------------------------------------'
            .codeUnits);
    // bytes += Uint8List.fromList([27, 97, 0]); // ESC a 0 untuk align left

    // Row example
    // int maxWidth = 210; // Lebar maksimum printer dalam mm
    // int charWidth = 1; // Lebar karakter dalam mm (asumsi)
    List<bool> productRightAlign = [false, false, false, true, true, true];
    List<int> productColumnWidths = [
      3, //No.
      32, //Nama Barang
      13, //Harga Satuan
      10, //Jumlah
      9, //Diskon
      13 //Total Harga
    ];
    bytes += Uint8List.fromList(printRow([
      'No',
      'Nama Barang',
      'Harga Satuan',
      'Jumlah',
      'Diskon',
      'Total Harga'
    ], productColumnWidths, rightAlign: productRightAlign)
        .codeUnits);

    bytes += Uint8List.fromList(printRow([
      '1',
      'afduner botol kartingdeng deng deng deng',
      '1.000.000',
      '3000 pcs',
      '900.000',
      '10.000'
    ], productColumnWidths, rightAlign: productRightAlign)
        .codeUnits);
    bytes += Uint8List.fromList(printRow([
      '2',
      'afduner botol kartingdeng ',
      '100.000',
      '30 pcs',
      '80.000',
      '1.000.000'
    ], productColumnWidths, rightAlign: productRightAlign)
        .codeUnits);
    bytes += Uint8List.fromList(printRow([
      '3',
      'afduner botol kartingdeng deng ',
      '1.000',
      '3000 lmbr',
      '',
      '100.000.000'
    ], productColumnWidths, rightAlign: productRightAlign)
        .codeUnits);

    // Divider full width
    // bytes += Uint8List.fromList([27, 97, 1]);
    bytes += Uint8List.fromList(
        '-------------------------------------------------------------------------------\n'
            .codeUnits);
    // bytes += Uint8List.fromList([27, 97, 0]); // ESC a 0 untuk align left

    return bytes;
  }

  Future<void> printTes() async {
    if (!connected.value) {
      debugPrint("Printer not connected");
      return;
    }
    // final profiles = await CapabilityProfile.getAvailableProfiles();
    // debugPrint(profiles.toString());
    final bytes = await generateTesBytes();
    isPrinting.value = true;

    // Check if the device is desktop or android
    if (Platform.isAndroid) {
      await sendBytesToPrint(bytes, PrinterType.bluetooth);
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      await sendBytesToPrint(bytes, PrinterType.usb);
    }
    isPrinting.value = false;
  }
}
