// import 'dart:io';
// import 'dart:typed_data';

// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:image/image.dart';
// import '../../../infrastructure/dal/services/auth_service.dart';
// import '../../../infrastructure/models/invoice_model/invoice_model.dart';
// import 'package:thermal_printer/esc_pos_utils_platform/esc_pos_utils_platform.dart';
// import 'package:image/image.dart' as img;

// import '../../profile/logo_widget_controller.dart';

// Future<List<int>> tesGenerateInvoiceBytes(InvoiceModel invoice) async {
//   final profile = await CapabilityProfile.load();
//   final generator = Generator(PaperSize.mm80, profile);

//   // Pastikan menggunakan List<int> biasa yang dapat berubah panjangnya
//   List<int> bytes = [];

//   // Mengambil logo dari controller
//   final AuthService authService = Get.find<AuthService>();
//   late final store = authService.store.value;
//   final controller = Get.put(LogoWidgetController(store!), tag: store.id);

//   await Future.delayed(const Duration(seconds: 1));

//   File imageFile = File(controller.photoPath.value);
//   final Uint8List imageBytes = await imageFile.readAsBytes();
//   final img.Image image = img.decodeImage(imageBytes)!;

//   // Menghitung rasio dan meresize gambar untuk disesuaikan dengan ukuran printer
//   var ratio = image.width / image.height;
//   var resizedWidth = 150; // Lebar gambar yang lebih kecil
//   var resizedHeight =
//       (resizedWidth / ratio).round(); // Menyesuaikan tinggi berdasarkan rasio

//   // Memastikan ukuran gambar lebih kecil
//   img.Image resizedImage =
//       img.copyResize(image, width: resizedWidth, height: resizedHeight);

//   // Konversi gambar menjadi hitam putih (monokrom) untuk printer dot matrix
//   img.Image monochromeImage = img.grayscale(resizedImage);

//   // Thresholding: manual konversi ke hitam-putih berdasarkan nilai threshold
//   img.Image binarizedImage = thresholdToMonochrome(monochromeImage, 128);

//   // Menambahkan gambar ke dalam bytes
//   bytes.addAll(generator.imageRaster(binarizedImage));

//   // Feed dan Cut
//   bytes.addAll(generator.feed(2));
//   bytes.addAll(generator.cut());

//   return bytes;
// }

// // Fungsi untuk mengonversi gambar ke gambar monokrom berdasarkan threshold
// img.Image thresholdToMonochrome(img.Image image, int threshold) {
//   for (int y = 0; y < image.height; y++) {
//     for (int x = 0; x < image.width; x++) {
//       PixelUint8 pixel = image.getPixel(x, y) as int;

//       // Mengambil komponen RGB dari pixel
//       int red = img.uint32ToRed(pixel);
//       int green = img.uint32ToGreen(pixel);
//       int blue = img.uint32ToBlue(pixel);

//       // Menghitung brightness rata-rata
//       int brightness = (red + green + blue) ~/ 3;

//       // Jika kecerahan lebih tinggi dari threshold, set pixel menjadi putih (255), sebaliknya hitam (0)
//       image.setPixel(
//           x,
//           y,
//           brightness > threshold
//               ? img.ColorInt8.rgb(255, 255, 255)
//               : img.ColorInt8.rgb(0, 0, 0));
//     }
//   }
//   return image;
// }
