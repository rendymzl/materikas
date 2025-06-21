import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../otp/otp_controller.dart';
import 'subs_controller.dart';

import '../../global_widget/popup_page_widget.dart';

Future<void> successPopup() async {
  final GlobalKey globalKey = GlobalKey();
  final controller = Get.find<SubsController>();
  final authService = Get.find<AuthService>();
  final store = authService.store.value;
  await showPopupPageWidget(
      barrierDismissible: false,
      title: 'Pembayaran Berhasil',
      height: MediaQuery.of(Get.context!).size.height * (0.75),
      width: MediaQuery.of(Get.context!).size.width * (0.3),
      content: RepaintBoundary(
        key: globalKey,
        child: ListView(
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
                      Text(
                        '0813 8025 3313',
                        style: const TextStyle(
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
                        child: buildText(controller.orderId.value, bold: true),
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
                    children: [buildText('Pelanggan: ${store!.name.value}')],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [buildText('No Telp: ${store.phone.value}')],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [buildText('Alamat: ${store.address.value}')],
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
                      buildText(controller.selectedPackage.value!.name),
                      buildText(
                          'Rp${currency.format(controller.selectedPackage.value!.price)}'),
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
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      buttonList: [
        Obx(
          () => ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () async {
                    controller.isLoading(true);
                    // Get.back();
                    // controller.isLoading.value = true;
                    var path =
                        await generateAndSaveReceiptInBackground(globalKey);

                    await Get.put(OtpController()).successImage(
                        authService.store.value!.phone.value,
                        path: path);

                    controller.stopTimer();
                    controller.paymentDone.value = true;
                    Get.back();
                    Get.back();
                  },
            child: const Text('ok'),
          ),
        ),
      ]);
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

Future<String> generateAndSaveReceiptInBackground(GlobalKey globalKey) async {
  try {
    // Tunggu hingga widget sepenuhnya dirender
    RenderRepaintBoundary? boundary =
        globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

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
