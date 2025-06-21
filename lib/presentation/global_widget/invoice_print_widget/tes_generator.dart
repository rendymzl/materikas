import 'dart:async';
import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui';
// import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';

// import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
// import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:get/get.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
// import 'package:esc_pos_printer/esc_pos_printer.dart';
// import 'package:thermal_printer/esc_pos_utils_platform/esc_pos_utils_platform.dart';
import 'package:image/image.dart' as img;
// import 'package:esc_pos_utils/esc_pos_utils.dart';

import '../../profile/logo_widget_controller.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<List<int>> tesGenerateInvoiceBytes(InvoiceModel invoice) async {
  // final doc = pw.Document();
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm80, profile);

  // Pastikan menggunakan List<int> biasa yang dapat berubah panjangnya
  List<int> bytes = <int>[];
  final ByteData data = await rootBundle.load('assets/logo.png');
  final Uint8List imgBytes = data.buffer.asUint8List();
  final img.Image image = img.decodeImage(imgBytes)!;
// Using `ESC *`
  // generator.image(image);
// Using `GS v 0` (obsolete)
  // generator.imageRaster(image);
// Using `GS ( L`
  // generator.imageRaster(image);
  // Menghitung rasio dan meresize gambar untuk disesuaikan dengan ukuran printer
  var ratio = image.width / image.height;
  var resizedWidth = 150; // Lebar gambar yang lebih kecil
  var resizedHeight =
      (resizedWidth / ratio).round(); // Menyesuaikan tinggi berdasarkan rasio

  // Memastikan ukuran gambar lebih kecil
  img.Image resizedImage =
      img.copyResize(image, width: resizedWidth, height: resizedHeight);

  // for (var pixel in image) {
  //   int brightness = (pixel.r + pixel.g + pixel.b) ~/ 3;
  //   int newColor = brightness > 128 ? 255 : 0;
  //   pixel
  //     ..r = newColor
  //     ..g = newColor
  //     ..b = newColor;
  // }
  bytes.addAll(generator.image(image));

  // // Bitmap bitmap = Bitmap.fromHeadless(resizedWidth, resizedHeight, imageBytes);

  // Bitmap bitmap = Bitmap.fromHeadless(100, 100, imageBytes);
  // Uint8List pixels = bitmap.content;

  // int threshold = 128; // Nilai threshold (0-255)
  // for (int i = 0; i < pixels.length; i += 3) {
  //   int brightness =
  //       (pixels[i] + pixels[i + 1] + pixels[i + 2]) ~/ 3; // Rata-rata RGB
  //   int newColor = brightness > threshold ? 255 : 0; // Putih atau hitam

  //   // Set warna baru (monokrom)
  //   pixels[i] = newColor; // Red
  //   pixels[i + 1] = newColor; // Green
  //   pixels[i + 2] = newColor; // Blue
  // }

  // Bitmap bwBitmap = Bitmap.fromHeadless(bitmap.width, bitmap.height, pixels);

  // // Uint8List? bwImageBytes = bwBitmap.buildHeaded();
  // var outputImage = await bwBitmap.buildImage();
  // img.enc(bwBitmap);

  // // img.Image.from(outputImage as img.Image);

  // // Menambahkan gambar ke dalam bytes
  // bytes.addAll(generator.imageRaster(img.Image.fromBytes(
  //     width: outputImage.width,
  //     height: outputImage.height,
  //     bytes: outputImage.readAsBytes())));

  // Feed dan Cut
  bytes.addAll(generator.feed(2));
  bytes.addAll(generator.cut());

  return bytes;
}

// img.Image convertToMonochrome(img.Image src) {
//   src.toUint8List()
//   for (int y = 0; y < src.height; y++) {
//     for (int x = 0; x < src.width; x++) {
//       img.Pixel pixel = src.getPixel(x, y);
//       int grayscale = getLuminance(pixel);
//       int threshold = 128; // Sesuaikan ambang batasnya
//       src.setPixel(x, y, grayscale < threshold ? 0xFF000000 : 0xFFFFFFFF);
//     }
//   }
//   return src;
// }
