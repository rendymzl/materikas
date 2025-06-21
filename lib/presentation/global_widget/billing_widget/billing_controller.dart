import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/billing_service.dart';
import '../../../infrastructure/dal/services/invoice_service.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/models/store_model.dart';
import '../../../infrastructure/utils/display_format.dart';

class BillingController extends GetxController {
  late final AuthService authService = Get.find();
  late final BillingService billingService = Get.find();
  late final InvoiceService invoiceService = Get.find();

  final billInvoice = Rx<List<InvoiceModel>>([]);
  final path = ''.obs;
  final GlobalKey _globalKey = GlobalKey();

  @override
  void onInit() async {
    super.onInit();
    billInvoice.value =
        await invoiceService.getBillInvoice(billingService.selectedMonth.value);
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
  Future<Widget> buildReceipt(String package, {int price = 0}) async {
    final store = authService.store.value;
    final billing = await billingService.getBilling();
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => ListView(
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(
                                  'assets/icon/logo-materikas-text-transparent.png',
                                  height: 15),
                              // Text(
                              //   'Materikas',
                              //   style: const TextStyle(
                              //     fontFamily: 'Courier',
                              //     fontSize: 18,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                              Text(
                                '0813 8025 3313',
                                style: const TextStyle(
                                  // fontFamily: 'Courier',
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Divider(thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: buildText(
                                    '${package == 'flexible' ? billing?.billingNumber : 'INV-${DateTime.now().millisecondsSinceEpoch}'}',
                                    bold: true),
                              ),
                              Expanded(
                                child: buildText(
                                  DateFormat('dd-MM-y, HH:mm', 'id')
                                      .format(DateTime.now()),
                                  align: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildText('Pelanggan: ${store!.name.value}'),
                              // buildText(
                              //     'Kasir: ${invoice.account.value.name}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildText('No Telp: ${store.phone.value}'),
                              // buildText(
                              //     'Kasir: ${invoice.account.value.name}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildText('Alamat: ${store.address.value}'),
                              // buildText(
                              //     'Kasir: ${invoice.account.value.name}'),
                            ],
                          ),
                          const SizedBox(height: 30),
                          const Divider(thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildText('Tagihan', bold: true),
                              buildText('Harga', bold: true),
                            ],
                          ),
                          const Divider(thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildText(package == 'flexible'
                                  ? billing?.billingName ?? ''
                                  : 'Paket $package'),
                              buildText('Rp${currency.format(price)}'),
                            ],
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildText(''),
                                buildText('LUNAS', bold: true)
                              ]),
                          const SizedBox(height: 30),
                          const Text(
                            'Terimakasih telah menggunakan layanan Materikas!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              // fontFamily: 'Courier',
                              fontSize: 12,
                            ),
                          ),
                          // const SizedBox(height: 50),
                          // Image.asset(
                          //     'assets/icon/logo-materikas-text-transparent.png',
                          //     height: 15),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget buildText(String text, {bool bold = false, TextAlign? align}) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        // fontFamily: 'Courier',
        fontSize: 12,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
  // Widget buildHiddenReceipt() {
  //   return RepaintBoundary(
  //     key: _globalKey,
  //     child: Container(
  //       padding: const EdgeInsets.all(16.0),
  //       decoration: BoxDecoration(
  //         border: Border.all(color: Colors.grey),
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Struk Pembayaran',
  //             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //           ),
  //           SizedBox(height: 10),
  //           _buildReceiptDetail('Nomor Invoice', 'INV-001'),
  //           _buildReceiptDetail('Tanggal', '16-10-2024'),
  //           _buildReceiptDetail('Nama Pelanggan', 'Rendy Wardana'),
  //           _buildReceiptDetail('Total Pembayaran', 'Rp 500.000'),
  //           _buildReceiptDetail('Metode Pembayaran', 'Transfer Bank'),
  //           SizedBox(height: 10),
  //           Center(
  //               child: Text('Terima Kasih!', style: TextStyle(fontSize: 16))),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildReceiptDetail(String title, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 5.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
  //         Text(value),
  //       ],
  //     ),
  //   );
  // }
}
