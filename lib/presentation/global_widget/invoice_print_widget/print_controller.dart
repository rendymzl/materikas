// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
// import 'package:flutter_thermal_printer/utils/printer.dart';

// import '../../../infrastructure/dal/services/auth_service.dart';
// import '../../../infrastructure/dal/services/store_service.dart';
// import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
// import '../../../infrastructure/models/invoice_model/invoice_model.dart';
// import '../../../infrastructure/models/printer_setting_model.dart';
// import '../../../infrastructure/utils/hive_boxex.dart';
// import 'invoice_generator.dart';
// import 'print_transport_inv.dart';
// import 'receipt_generator.dart';
// import 'transport_print_generator.dart';

// class PrinterController extends GetxController {
//   final AuthService _authService = Get.find<AuthService>();
//   final StoreService _storeService = Get.find<StoreService>();
//   final printMethod = ['receipt', 'invoice'].obs;
//   final selectedPrintMethod = ''.obs;
//   final paperSize = ['58mm', '72mm', '80mm', '>100mm'].obs;
//   final selectedPaperSize = ''.obs;
//   final connectingDevice = ''.obs;
//   final message = ''.obs;
//   var connected = false.obs;
//   var isLoading = false.obs;

//   final flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;
//   var devices = <Printer>[].obs;
//   late final selectedDevice = Rx<Printer?>(null);

//   StreamSubscription<List<Printer>>? _devicesStreamSubscription;

//   final textPromo = TextEditingController();

//   late ScrollController scrollController = ScrollController();
//   late final account = _authService.account.value;
//   late final store = _authService.store.value;

//   final isPrinting = false.obs;

//   late InvoiceModel invoice;

//   @override
//   void onInit() async {
//     print('init printer c 1');
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
//       await startScan();
//     });
//     print('init printer c 2');
//     await connectLastPrinter();
//     print('init printer c 3');
//     if (Platform.isAndroid) {
//       setPrintMethod('receipt');
//     }

//     super.onInit();
//   }

//   // Get Printer List
//   Future<void> startScan() async {
//     isLoading.value = true;
//     _devicesStreamSubscription?.cancel();
//     await flutterThermalPrinterPlugin.getPrinters(connectionTypes: [
//       ConnectionType.USB,
//       ConnectionType.BLE,
//     ]);

//     _devicesStreamSubscription =
//         flutterThermalPrinterPlugin.devicesStream.listen((List<Printer> event) {
//       devices.value = event;
//       devices
//           .removeWhere((element) => element.name == null || element.name == '');
//     });
//     print('Jumlah device: ${devices.length}');
//     isLoading.value = false;
//   }

//   stopScan() {
//     flutterThermalPrinterPlugin.stopScan();
//   }

//   Future<void> connectLastPrinter() async {
//     print('asdasdasdsadasdasd');
//     final PrinterSettingModel? savedPrinter = await HiveBox.getPrinter();
//     print('asdasdasdsadasdasd ${savedPrinter}');

//     if (savedPrinter != null) {
//       print(
//           'asdasdasdsadasdasd ${savedPrinter.name} ${savedPrinter.address} ${savedPrinter.method} ${savedPrinter.paperSize}');
//     }

//     if (savedPrinter?.name != null && savedPrinter?.address != null) {
//       selectedPrintMethod.value = savedPrinter?.method ?? '';
//       selectedPaperSize.value = savedPrinter?.paperSize ?? '';
//       print('asdasdasdsadasdasd devices lenght ${devices.length}');
//       if (savedPrinter != null) {
//         await connect(Printer(
//           name: savedPrinter.name,
//           address: savedPrinter.address,
//           connectionType: savedPrinter.connectionType,
//         ));
//       }
//     }
//   }

//   Future<void> connect(Printer device) async {
//     message.value = 'Menghubungkan Printer...';
//     try {
//       if (selectedDevice.value != null) {
//         await disconnect(selectedDevice.value!);
//       }
//       print('connectinga');
//       var conn = await flutterThermalPrinterPlugin.connect(device);
//       print('deviceeeee ${conn}');

//       if (conn) {
//         message.value = 'Printer berhasil terhubung';
//         selectedDevice.value = device;
//         await setLastPrinter();
//       } else {
//         message.value = 'Tidak dapat terhubung ke printer. Silakan coba lagi.';
//         selectedDevice.value = null;
//       }
//     } catch (e) {
//       message.value = 'Tidak dapat terhubung ke printer. Silakan coba lagi.';
//       selectedDevice.value = null;
//     }
//     connectingDevice.value = '';
//   }

//   Future<void> disconnect(Printer device) async {
//     await flutterThermalPrinterPlugin.disconnect(device);
//     selectedDevice.value = null;
//   }

//   Future<void> setLastPrinter() async {
//     final printerSetting = PrinterSettingModel(
//       name: selectedDevice.value?.name ?? '',
//       address: selectedDevice.value?.address ?? '',
//       connectionType: selectedDevice.value?.connectionType,
//       method: selectedPrintMethod.value,
//       paperSize: selectedPaperSize.value,
//     );
//     print('asdasdasdsadasdasd saved 0 $selectedDevice.value}');
//     await HiveBox.savePrinter(printerSetting);
//   }

//   void setPrintMethod(String method) async {
//     selectedPrintMethod.value = method;
//   }

//   void setPaperSize(String size) async {
//     selectedPaperSize.value = size;
//     await setLastPrinter();
//   }

//   List<CartItem> filterPurchase(InvoiceModel invoice) {
//     List<CartItem> workerData = invoice.purchaseList.value.items
//         .where((p) => p.quantity.value > 0)
//         .map((purchased) => purchased)
//         .toList();
//     return workerData;
//   }

//   List<CartItem> filterReturn(InvoiceModel invoice) {
//     List<CartItem> workerData = invoice.purchaseList.value.items
//         .where((p) => p.quantityReturn.value > 0)
//         .map((purchased) => purchased)
//         .toList();
//     return workerData;
//   }

//   void saveBottomText() async {
//     store!.promo?.value = textPromo.text;
//     await _storeService.update(store!);
//     Get.snackbar('Berhasil', 'Teks tambahan berhasil disimpan.');
//   }

//   Future<void> sendBytesToPrint(List<int> bytes) async {
//     try {
//       print('mencetak...');
//       if (selectedDevice.value != null || selectedPaperSize.value.isNotEmpty) {
//         print(selectedDevice.value!.isConnected);
//         await flutterThermalPrinterPlugin.printData(
//           selectedDevice.value!,
//           bytes,
//           longData: true,
//         );

//         var isConnected = await selectedDevice.value!.connectionState.first;
//         isConnected.name;
//         print('aaa ${isConnected.name}');
//         if (isConnected.name == 'disconnected') {
//           message.value =
//               'Tidak dapat terhubung ke printer. Silakan coba lagi.';
//           selectedDevice.value = null;
//         }
//       } else {
//         Get.snackbar(
//             'Error',
//             selectedPaperSize.value.isEmpty
//                 ? 'Tidak ada ukuran kertas yang dipilih. Silakan pilih ukuran kertas.'
//                 : 'Tidak ada printer yang terhubung. Silakan hubungkan printer Anda.');
//       }
//     } catch (e) {
//       Get.snackbar('Gagal mencetak', e.toString());
//       debugPrint('Failed to print: $e');
//     }
//     print('mencetak...................');
//   }

//   Future<void> printReceipt(InvoiceModel invoice) async {
//     if (selectedPaperSize.value != 'Lebar') {
//       final bytes =
//           await generateReceiptBytes(invoice, selectedPaperSize.value);
//       await sendBytesToPrint(bytes);
//     } else {
//       final bytes = await generateInvoiceBytes(invoice);
//       await sendBytesToPrint(bytes);
//     }
//   }

//   Future<void> printTransport(InvoiceModel invoice) async {
//     if (selectedPaperSize.value != 'Lebar') {
//       final bytes =
//           await generateTransportBytes(invoice, selectedPaperSize.value);
//       await sendBytesToPrint(bytes);
//     } else {
//       final bytes = await generateTransportInvBytes(invoice);
//       await sendBytesToPrint(bytes);
//     }
//   }
// }
