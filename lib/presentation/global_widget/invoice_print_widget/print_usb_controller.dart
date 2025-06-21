import 'dart:async';
// import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thermal_printer/thermal_printer.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/store_service.dart';
// import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../../infrastructure/models/printer_setting_model.dart';
import '../../../infrastructure/utils/hive_boxex.dart';
// import '../../profile/logo_widget.dart';
import '../../profile/logo_widget_controller.dart';
import '../../sales/generate_inv_purchase_order.dart';
import '../../sales/generate_receipt_purchase_order.dart';
import 'generate_invoice_preview.dart';
import 'imagePrint.dart';
import 'invoice_generator.dart';
import 'invoice_generator_dotmatrix_small.dart';
import 'print_transport_inv.dart';
// import 'printer_service_windows.dart';
// import 'receipt_generator.dart';
// import 'tes_generator.dart';
import 'receipt_generator.dart';
import 'transport_print_generator.dart';

// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:printing/printing.dart' as logo_print;
// import 'package:print_usb/model/usb_device.dart';
// import 'package:print_usb/print_usb.dart';

// import 'dart:ffi';
// import 'package:ffi/ffi.dart';
// import 'package:win32/win32.dart';
import 'package:path/path.dart' as path;

class PrinterUsbController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final StoreService _storeService = Get.find<StoreService>();
  // final printMethod = ['receipt', 'invoice'].obs;
  final selectedPrintMethod = ''.obs;
  final paperSize = ['58 mm', '80 mm'].obs;
  final paperSizeDuplicate = ['76 mm', '210 mm'].obs;
  var isDuplicate = false.obs;
  var printDate = false.obs;
  var isPrintTransport = false.obs;
  final selectedPaperSize = '58 mm'.obs;
  final connectingDevice = ''.obs;
  final message = ''.obs;
  var connected = false.obs;
  var isReorder = false.obs;
  var isLoading = false.obs;
  var initLoading = false.obs;

  final printerManager = PrinterManager.instance;
  var devices = <PrinterDevice>[].obs;
  late final selectedPrinter = Rx<PrinterDevice?>(null);
  late final logo = Rx<File?>(null);

  StreamSubscription<PrinterDevice>? _devicesStreamSubscription;

  final textPromo = TextEditingController();

  // late ScrollController scrollController = ScrollController();
  late final account = _authService.account.value;
  late final store = _authService.store.value;

  final isPrinting = false.obs;

  late InvoiceModel invoice;

  @override
  void onInit() async {
    initLoading.value = true;
    print('init printer c 1');
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await startScan();
    });
    print('init printer c 2');
    await connectLastPrinter();
    print('init printer c 3');
    print('init printer devices.length ${devices.length}');
    for (var device in devices) {
      print('devices.length name ${device.name}');
      print('devices.length andsress ${device.address}');
      print('devices.length operatingSystem ${device.operatingSystem}');
    }
    logo.value = await loadImg();
    initLoading.value = false;
    super.onInit();
  }

  // Get Printer List
  Future<void> startScan() async {
    isLoading.value = true;
    // Find printers
    _devicesStreamSubscription?.cancel();
    devices.clear();
    _devicesStreamSubscription = PrinterManager.instance
        .discovery(type: PrinterType.usb, isBle: false)
        .listen((device) {
      devices.add(device);
    });
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
    // for (var device in devices) {
    //   print('devices.length ${device.address}');
    // }
  }

  Future<void> connectLastPrinter() async {
    // await HiveBox.deletePrinter();
    print('asdasdasdsadasdasd');
    final PrinterSettingModel? savedPrinter = await HiveBox.getPrinter();
    print('asdasdasdsadasdasd $savedPrinter');

    if (savedPrinter != null) {
      print(
          'asdasdasdsadasdasd ${savedPrinter.name} ${savedPrinter.address} ${savedPrinter.method} ${savedPrinter.paperSize}');

      if (savedPrinter.name.isNotEmpty) {
        selectedPrintMethod.value = savedPrinter.method;
        isDuplicate.value = savedPrinter.method == 'ply';
        selectedPaperSize.value = savedPrinter.paperSize;
        printDate.value = savedPrinter.printDate;
        print('asdasdasdsadasdasd devices lenght ${devices.length}');

        await connect(PrinterDevice(
            name: savedPrinter.name, address: savedPrinter.address));
      }

      // selectedPrintMethod.value = savedPrinter.method;
      // selectedPaperSize.value = savedPrinter.paperSize;
      // print('asdasdasdsadasdasd devices lenght ${devices.length}');

      // await connect(PrinterDevice(
      //     name: savedPrinter.name, address: savedPrinter.address));
    }

    // if (savedPrinter?.name != null && savedPrinter?.address != null) {
    //   selectedPrintMethod.value = savedPrinter?.method ?? '';
    //   selectedPaperSize.value = savedPrinter?.paperSize ?? '';
    //   print('asdasdasdsadasdasd devices lenght ${devices.length}');
    //   if (savedPrinter != null) {
    //     await connect(PrinterDevice(
    //         name: savedPrinter.name, address: savedPrinter.address));
    //   }
    // }
  }

  Future<void> connect(PrinterDevice device) async {
    isLoading.value = true;
    message.value = 'Menghubungkan Printer...';
    connectingDevice.value = device.name;

    // try {
    if (selectedPrinter.value != null &&
        selectedPrinter.value!.name == device.name) {
      message.value = 'Printer sudah terhubung';
      // print('message.value a ${message.value}');
      return;
    }
    if (selectedPrinter.value != null) {
      // print('message.value a ${message.value}');
      await disconnect(selectedPrinter.value!);
    }
    print('message.value a ${device.productId}');
    print('message.value a ${device.name}');
    print('message.value a ${device.address}');
    print('message.value a ${device.vendorId}');
    await printerManager.connect(
      type: PrinterType.usb,
      model: UsbPrinterInput(
        name: device.name,
        productId: device.productId,
        vendorId: device.vendorId,
      ),
    );
    // print('awdawdawdawdwadwa ${device.address!}');
    // selectedDirectPrinter.value = logo_print.Printer(url: device.address!);
    connected.value = true;
    message.value = 'Printer berhasil terhubung';
    selectedPrinter.value = device;
    await setLastPrinter();
    // } catch (e) {
    //   message.value =
    //       'Tidak dapat terhubung ke printer. Silakan coba lagi. Error: $e';
    //   selectedPrinter.value = null;
    //   connectingDevice.value = '';
    // }

    print('message.value: ${message.value}');
    isLoading.value = false;
  }

  Future<void> disconnect(PrinterDevice device) async {
    await PrinterManager.instance.disconnect(type: PrinterType.usb);
    selectedPrinter.value = null;
  }

  Future<void> setLastPrinter() async {
    isLoading.value = true;
    final printerSetting = PrinterSettingModel(
      name: selectedPrinter.value?.name ?? '',
      address: selectedPrinter.value?.address ?? '',
      method: selectedPrintMethod.value,
      paperSize: selectedPaperSize.value,
      printDate: printDate.value,
    );
    // print('asdasdasdsadasdasd saved name ${selectedPrinter.value!.name}}');
    // print(
    //     'asdasdasdsadasdasd saved address ${selectedPrinter.value!.address}}');
    print('asdasdasdsadasdasd saved method ${selectedPrintMethod.value}}');
    print('asdasdasdsadasdasd saved PaperSize ${selectedPaperSize.value}}');
    await HiveBox.savePrinter(printerSetting);
    isLoading.value = false;
  }

  void setPrintMethod(bool? value) async {
    isDuplicate.value = value ?? false;
    selectedPaperSize.value = isDuplicate.value ? '210 mm' : '58 mm';
    selectedPrintMethod.value = isDuplicate.value ? 'ply' : '';
    await setLastPrinter();
  }

  void setPaperSize(String size) async {
    selectedPaperSize.value = size;
    await setLastPrinter();
  }

  void setPrintDate(bool? value) async {
    printDate.value = value ?? false;
    await setLastPrinter();
  }

  void setPrintTransport(bool? value) async {
    isPrintTransport.value = value ?? false;
    await setLastPrinter();
  }

  // List<CartItem> filterPurchase(InvoiceModel invoice) {
  //   List<CartItem> workerData = invoice.purchaseList.value.items
  //       .where((p) => p.quantity.value > 0)
  //       .map((purchased) => purchased)
  //       .toList();
  //   return workerData;
  // }

  // List<CartItem> filterReturn(InvoiceModel invoice) {
  //   List<CartItem> workerData = invoice.purchaseList.value.items
  //       .where((p) => p.quantityReturn.value > 0)
  //       .map((purchased) => purchased)
  //       .toList();
  //   return workerData;
  // }

  void saveBottomText() async {
    store!.promo?.value = textPromo.text;
    await _storeService.update(store!);
    Get.snackbar('Berhasil', 'Teks tambahan berhasil disimpan.');
  }

  Future<void> sendBytesToPrint(List<int> bytes) async {
    try {
      print('mencetak...');
      if (selectedPrinter.value != null || selectedPaperSize.value.isNotEmpty) {
        await PrinterManager.instance.send(
          type: PrinterType.usb,
          bytes: bytes,
        );

        // var isConnected = await selectedDevice.value!.connectionState.first;
        // isConnected.name;
        // print('aaa ${isConnected.name}');
        // if (isConnected.name == 'disconnected') {
        //   message.value =
        //       'Tidak dapat terhubung ke printer. Silakan coba lagi.';
        //   selectedDevice.value = null;
        // }
      } else {
        Get.snackbar(
            'Error',
            selectedPaperSize.value.isEmpty
                ? 'Tidak ada ukuran kertas yang dipilih. Silakan pilih ukuran kertas.'
                : 'Tidak ada printer yang terhubung. Silakan hubungkan printer Anda.');
      }
    } catch (e) {
      Get.snackbar('Gagal mencetak', e.toString());
      debugPrint('Failed to print: $e');
    }
    print('mencetak...................');
  }

  Future<void> printReceipt(InvoiceModel invoice,
      {bool isSupplier = false, bool isPO = false}) async {
    isPrinting(true);

    if (isPO) {
      isPrintTransport.value = isPO;
    }
    final start = DateTime.now();
    if (selectedPrintMethod.value.isEmpty) {
      print(
          'printstart ${selectedPrintMethod.value} ${selectedPaperSize.value}');
      final bytes = await generateReceiptBytes(invoice, selectedPaperSize.value,
          printDate.value, isPrintTransport.value, isSupplier,
          isPO: isPO);
      await sendBytesToPrint(bytes);
    } else if (selectedPaperSize.value == '210 mm') {
      print(
          'printstart ${selectedPrintMethod.value} ${selectedPaperSize.value}');
      await imgPrint(invoice, isSupplier: isSupplier, isPO: isPO);
      // await Future.delayed(const Duration(seconds: 2));
      // final bytes = await generateInvoiceBytes(invoice);
      // await sendBytesToPrint(bytes);
    } else {
      print(
          'printstart e ${selectedPrintMethod.value} ${selectedPaperSize.value}');
      // await captureAndSave();
      await imgPrint(invoice, isSupplier: isSupplier, isPO: isPO);
      // await Future.delayed(const Duration(seconds: 3));
      // final bytes = await generateStrukDotMatrix(invoice, printDate.value);
      // List<int> bytes = [];
      // bytes += Uint8List.fromList('--------------------------------'.codeUnits);
      // await Future.delayed(const Duration(seconds: 1));
      // await sendBytesToPrint(bytes);
    }

    // if (selectedPaperSize.value != '>100mm') {
    //   await imgPrint(invoice, imgOnly: true);
    //   await Future.delayed(const Duration(seconds: 3));

    //   // final bytes =
    //   //     await generateReceiptBytes(invoice, selectedPaperSize.value);
    //   final bytes = await generateStrukDotMatrix(invoice);
    //   await sendBytesToPrint(bytes);
    // } else {
    //   await imgPrint(invoice);
    //   await Future.delayed(const Duration(seconds: 2));
    //   final bytes = await generateInvoiceBytes(invoice);
    //   await sendBytesToPrint(bytes);
    // }
    final end = DateTime.now();
    final difference = end.difference(start);
    isPrinting(false);
    print('Durasi pencetakan: $difference');
  }

  Future<void> printTransport(InvoiceModel invoice) async {
    if (selectedPaperSize.value != '>100mm') {
      final bytes =
          await generateTransportBytes(invoice, selectedPaperSize.value);
      await sendBytesToPrint(bytes);
    } else {
      await imgPrint(invoice);
      await Future.delayed(const Duration(seconds: 2));
      final bytes = await generateTransportInvBytes(invoice);
      await sendBytesToPrint(bytes);
    }
  }

  Future<void> printTransportSales(InvoiceSalesModel invoice) async {
    print('print large size ${selectedPaperSize.value}');
    if (selectedPaperSize.value != '>100mm') {
      final bytes =
          await generateReceiptPurchaseOrder(invoice, selectedPaperSize.value);
      await sendBytesToPrint(bytes);
    } else {
      final bytes = await generateInvPurchaseOrder(invoice);
      await sendBytesToPrint(bytes);
    }
  }

  late final selectedDirectPrinter = Rx<logo_print.Printer?>(null);
  Future<void> imgPrint(
    InvoiceModel invoice, {
    bool imgOnly = false,
    bool isSupplier = false,
    bool isPO = false,
  }) async {
    final logoController =
        Get.put(LogoWidgetController(store!), tag: store!.id);
    // Muat logo dari assets
    // final logoWidget = LogoWidget(store: store!);
    // File? imgLogo = File(logoWidget.imgFile?.path ?? '');
    await Future.delayed(const Duration(seconds: 2));
    print('logoController.fileExists.value ${logoController.fileExists.value}');
    print('isPO $isPO');
    File? imgLogo = logoController.fileExists.value
        ? File(logoController.photoPath.value)
        : null;

    // File? file;

    if (imgLogo != null) {
      Uint8List imgLogoBytes;

      imgLogoBytes = await imgLogo.readAsBytes();

      // final ByteData data = await rootBundle.load('assets/logo.png');
      // final Uint8List imgBytes = data.buffer.asUint8List();
      final img.Image image = img.decodeImage(imgLogoBytes)!;

      // Resize dan konversi gambar menjadi grayscale
      final resizedImage = img.copyResize(image, width: 80, height: 80);
      final grayscaleImage = img.grayscale(resizedImage);
      final bitmapData = img.encodeBmp(grayscaleImage);

      // Simpan gambar dalam format .bmp
      imgLogo = File(path.join(Directory.current.path, 'logo.bmp'));
      await imgLogo.writeAsBytes(bitmapData);
    }
    // Ambil data toko
    String storeName = (store!.name.value).toUpperCase();
    String storeAddress = store!.address.value;
    String phone = store!.phone.value;
    String telp = store!.telp.value;

    // Gabungkan nomor telepon jika ada
    String slash = (phone.isNotEmpty && telp.isNotEmpty) ? '/' : '';
    String storePhone = '$phone $slash $telp';

    // Menggabungkan teks yang ingin dicetak
    // String textToPrint = '$storeName\n$storeAddress\n$storePhone';

    // Untuk mencetak gambar bersama teks di sisi kiri dan kanan
    await printImageWithText(
      imgLogo?.path ?? '',
      selectedPrinter.value!.name,
      invoice,
      store!,
      printDate.value,
      storeName: imgOnly ? null : storeName,
      storeAddress: imgOnly ? null : storeAddress,
      storePhone: imgOnly ? null : storePhone,
      smallPaper: selectedPaperSize.value != '210 mm',
      isPrintTransport: isPO ? isPO : isPrintTransport.value,
      isSupplier: isSupplier,
      isPO: isPO,
    );
  }

  Future<void> printResi(List<Uint8List> images) async {
    for (Uint8List imageBytes in images) {
      await sendBytesToPrint(imageBytes);
    }
  }

  void addText() async {
    if (textPromo.text.trim().isNotEmpty) {
      store!.textPrint!.add(textPromo.text.trim());
      await _storeService.update(store!);
      textPromo.clear();
    }
  }

  Future<void> removeText(int index) async {
    store!.textPrint!.removeAt(index);
    await _storeService.update(store!);
  }

  void reorder(int oldIndex, int newIndex) async {
    isReorder.value = true;
    if (newIndex > oldIndex) newIndex -= 1;
    final item = store!.textPrint!.removeAt(oldIndex);
    store!.textPrint!.insert(newIndex, item);
    await _storeService.update(store!);
    isReorder.value = false;
  }

  Future<File?> loadImg() async {
    final logoController =
        Get.put(LogoWidgetController(store!), tag: store!.id);
    await Future.delayed(const Duration(seconds: 2));
    print('logoController.fileExists.value ${logoController.fileExists.value}');
    File? imgLogo = logoController.fileExists.value
        ? File(logoController.photoPath.value)
        : null;

    if (imgLogo != null) {
      Uint8List imgLogoBytes = await imgLogo.readAsBytes();
      final img.Image image = img.decodeImage(imgLogoBytes)!;
      final resizedImage = img.copyResize(image, width: 80, height: 80);
      final grayscaleImage = img.grayscale(resizedImage);
      final bytes = img.encodePng(grayscaleImage);
      final tempDir = await Directory.systemTemp.create();
      final file = File('${tempDir.path}/logo.png');
      await file.writeAsBytes(bytes);
      return file;
    } else {
      return null;
    }
  }

  Future<void> savePdf(InvoiceModel inv) async {
    try {
      final pdfBytes = await generateInvoice(inv);

      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) return;

      final filePath =
          '$selectedDirectory/invoice_${inv.createdAt.value!.day}_${inv.createdAt.value!.month}_${inv.createdAt.value!.year}_${inv.invoiceId?.substring(0, 6)}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      Get.showSnackbar(GetSnackBar(
        message: 'PDF disimpan di $filePath',
        duration: const Duration(seconds: 2),
      ));
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: 'Gagal menyimpan PDF: $e',
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ));
    }
  }

  GlobalKey globalKey = GlobalKey();
  var imageBytes = Rx<File?>(null);

  Future<void> captureAndSave() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/widget_image.bmp';
      File file = File(imagePath);
      await file.writeAsBytes(pngBytes);
      imageBytes.value = file;
      final img.Image widgetImg = img.decodeImage(pngBytes)!;

      // final bitmapData = img.encodeBmp(widgetImg);
      final resizedImage = img.copyResize(widgetImg, width: 300);
      // final grayscaleImage = img.grayscale(resizedImage);
      final bitmapData = img.encodeBmp(resizedImage);

      File? imgLogo =
          File(path.join(Directory.current.path, 'widget_image.bmp'));
      await imgLogo.writeAsBytes(bitmapData);

      Get.snackbar("Berhasil", "Gambar disimpan di: $imagePath",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
      await Future.delayed(const Duration(seconds: 2));
      await printImageWithText(
        imgLogo.path,
        selectedPrinter.value!.name,
        invoice,
        store!,
        printDate.value,
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan gambar: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }
}
