// import 'dart:async';
// import 'dart:typed_data';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:get/get.dart';
// // import 'package:pdf/pdf.dart';
// // import 'package:pdf/widgets.dart' as pw;

// import '../../../infrastructure/utils/display_format.dart';
// import '../invoice_print_widget/print_ble_controller.dart';
// import '../invoice_print_widget/print_usb_controller.dart';
// // import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';

// class PrintResiController extends GetxController {
//   // final bluetooth = FlutterThermalPrinter.instance;
//   var selectedPdfPaths = <String>[].obs;
//   var isLoading = false.obs;

//   // Fungsi untuk memilih file PDF (multi-file)
//   Future<void> pickPdfFiles() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf'],
//       allowMultiple: true,
//     );

//     if (result != null) {
//       selectedPdfPaths.value =
//           result.paths.where((path) => path != null).cast<String>().toList();
//     } else {
//       Get.snackbar("Error", "Tidak ada file PDF yang dipilih!");
//     }
//   }

//   // Fungsi untuk mencetak file PDF
//   Future<void> printPdfs() async {
//     if (selectedPdfPaths.isEmpty) {
//       Get.snackbar("Error", "Pilih minimal satu file PDF terlebih dahulu!");
//       return;
//     }

//     isLoading.value = true;

//     try {
//       List<Uint8List> allImages = [];
//       for (String path in selectedPdfPaths) {
//         // Konversi setiap file PDF ke gambar
//         List<Uint8List> images = await _convertPdfToImages(path);
//         allImages.addAll(images);
//       }

//       if (allImages.isEmpty) {
//         throw Exception("Gagal mengonversi PDF ke gambar!");
//       }
//       // Cetak semua gambar ke printer thermal
//       await _printImages(allImages);
//       Get.snackbar("Sukses", "Semua file PDF berhasil dicetak!");
//     } catch (e) {
//       print(e);
//       Get.snackbar("Error", e.toString());
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // Konversi PDF ke gambar
//   Future<List<Uint8List>> _convertPdfToImages(String pdfPath) async {
//     // Menggunakan package flutter_pdfview untuk membaca pdf
//     final Completer<PDFViewController> _controller =
//         Completer<PDFViewController>();
//     int? pages = 0;
//     int? currentPage = 0;
//     bool isReady = false;
//     String errorMessage = '';

//     PDFView(
//       filePath: pdfPath,
//       enableSwipe: true,
//       swipeHorizontal: true,
//       autoSpacing: false,
//       pageFling: false,
//       onRender: (pagesR) {
//         pages = pagesR;
//         isReady = true;
//       },
//       onError: (error) {
//         print(error.toString());
//       },
//       onPageError: (page, error) {
//         print('$page: ${error.toString()}');
//       },
//       onViewCreated: (PDFViewController pdfViewController) {
//         _controller.complete(pdfViewController);
//       },
//     );

//     List<Uint8List> images = [];

//     for (int i = 1; i <= pages; i++) {
//       final image = await _controller.re(pdfPath, i);
//       images.add(image.bytes);
//     }
//     await controller.dispose();

//     return images;
//   }

//   // Fungsi untuk mencetak gambar ke printer thermal
//   Future<void> _printImages(List<Uint8List> images) async {
//     android
//         ? Get.put(PrinterBluetoothController()).printResi(images)
//         : Get.put(PrinterUsbController()).printResi(images);
//   }
// }
