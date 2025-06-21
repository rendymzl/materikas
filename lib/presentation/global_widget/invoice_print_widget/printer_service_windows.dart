import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class PrintService {
  static const MethodChannel _channel =
      MethodChannel('com.example.flutter_print_image/print');

  Future<void> printImage(String imagePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final fullPath = '${dir.path}/$imagePath';
    try {
      await _channel.invokeMethod('printImage', fullPath);
    } on PlatformException catch (e) {
      print('Failed to print image: ${e.message}');
    }
  }
}
