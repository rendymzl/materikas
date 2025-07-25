import 'dart:async';
import 'dart:convert';
import 'dart:math';
// import 'dart:typed_data';
// import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// import '../billing_widget/billing_controller.dart';

class OtpController extends GetxController {
  // final BillingController billingC = Get.put(BillingController());
  final verified = false.obs;
  final countdown = 0.obs;
  final isResendDisabled = false.obs;
  final otp = 'null'.obs;

  final otpFieldC = TextEditingController();

  Future<void> startResendCountdown() async {
    isResendDisabled.value = true;
    countdown.value = 60;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      countdown.value--;
      if (countdown.value == 0) {
        isResendDisabled.value = false;
        timer.cancel();
      }
    });
  }

  void otpValidator(String value) {
    if (value.length == 4) {
      verified.value = value == otp.value;
      if (verified.value) Get.back();
    }
  }

  Future<void> sendOtp(String chatId) async {
    const String endpoint = 'http://82.112.236.54:3000/client/sendMessage/ABCD';
    otp.value = (Random().nextInt(9000) + 1000).toString();

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'chatId': '$chatId@c.us',
          'contentType': 'string',
          'content':
              'Kode OTP Anda adalah: $otp,\n\n\nSimpan nomor ini untuk menghubungi kami. \nJika ada pertanyaan silahkan tanyakan dinomor ini',
        }),
      );

      if (response.statusCode == 200) {
        startResendCountdown();
      } else {
        Get.defaultDialog(
          title: 'Info',
          content: const Text('Gagal mengirim OTP'),
        );
      }
    } catch (e) {
      Get.defaultDialog(
        title: 'Error',
        content: const Text('Gagal mengirim OTP'),
      );
    }

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'chatId': '6281802127920@c.us',
          'contentType': 'string',
          'content': '$chatId sedang mendaftar',
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Berhasil');
      } else {
        debugPrint(e.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> successMessage(String chatId) async {
    chatId = chatId.startsWith('0') ? chatId.replaceFirst('0', '62') : chatId;
    const String endpoint = 'http://82.112.236.54:3000/client/sendMessage/ABCD';
    try {
      await http.post(
        Uri.parse(endpoint),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'chatId': '$chatId@c.us',
          'contentType': 'string',
          'content':
              'Pembayaran berhasil! Terima kasih telah menggunakan layanan Materikas.',
        }),
      );

      // if (response.statusCode == 200) {
      //   startResendCountdown();
      // } else {
      //   Get.defaultDialog(
      //     title: 'Info',
      //     content: const Text('Gagal mengirim OTP'),
      //   );
      // }
    } catch (e) {
      Get.defaultDialog(
        title: 'Error',
        content: const Text('Gagal mengirim pesan'),
      );
    }
  }

  Future<void> successImage(String chatId, {String path = ''}) async {
    chatId = chatId.startsWith('0') ? chatId.replaceFirst('0', '62') : chatId;
    const String endpoint = 'http://82.112.236.54:3000/client/sendMessage/ABCD';
    try {
      // var path = billingC.path.value;

      if (path.isNotEmpty) {
        await http.post(
          Uri.parse(endpoint),
          headers: {
            'accept': '*/*',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'chatId': '$chatId@c.us',
            "contentType": "MessageMedia",
            "content": {
              "mimetype": "image/jpeg",
              "data": path,
              "filename": "Invoice.jpg"
            }
          }),
        );
        // if (response.statusCode == 200) {
        //   Get.defaultDialog(
        //     title: 'Info',
        //     content: const Text('Pesan berhasil dikirim'),
        //   );
        // } else {
        //   Get.defaultDialog(
        //     title: 'Error',
        //     content: const Text('Gagal mengirim pesan'),
        //   );
        // }
      }
      //  else {
      // Get.defaultDialog(
      //   title: 'Error',
      //   content: const Text('Gagal membuat gambar'),
      // );
      // }
      await successMessage(chatId);
    } catch (e) {
      Get.defaultDialog(
        title: 'Error',
        content: const Text('Gagal mengirim pesan'),
      );
    }
  }
}
