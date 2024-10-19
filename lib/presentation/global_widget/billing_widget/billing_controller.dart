import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/billing_service.dart';
import '../../../infrastructure/dal/services/invoice_service.dart';

class BillingController extends GetxController {
  late final AuthService authService = Get.find();
  late final BillingService billingService = Get.find();
  late final InvoiceService invoiceService = Get.find();

  final path = ''.obs;
  final GlobalKey _globalKey = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    // buildHiddenReceipt();

    // Pastikan widget dirender sebelum mencoba akses
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.delayed(Duration(seconds: 1), () async {
        path.value = await generateAndSaveReceiptInBackground();
      });
    });
  }

  Future<String> generateAndSaveReceiptInBackground() async {
    try {
      // Tunggu hingga widget sepenuhnya dirender
      RenderRepaintBoundary? boundary = _globalKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        print('Boundary is null, widget belum dirender.');
        return '';
      }

      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      return base64Encode(pngBytes);
    } catch (e) {
      print('Error: $e');
      return '';
    }
  }

  // Widget struk pembayaran yang tidak akan ditampilkan (Offstage)
  Widget buildHiddenReceipt() {
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Struk Pembayaran',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildReceiptDetail('Nomor Invoice', 'INV-001'),
            _buildReceiptDetail('Tanggal', '16-10-2024'),
            _buildReceiptDetail('Nama Pelanggan', 'Rendy Wardana'),
            _buildReceiptDetail('Total Pembayaran', 'Rp 500.000'),
            _buildReceiptDetail('Metode Pembayaran', 'Transfer Bank'),
            SizedBox(height: 10),
            Center(
                child: Text('Terima Kasih!', style: TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
