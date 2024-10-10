import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class OtpController extends GetxController {
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
      // print(response.body);
      // Get.back();
      if (response.statusCode == 200) {
        startResendCountdown();
        // Get.defaultDialog(
        //   title: 'Info',
        //   content: const Text('OTP telah dikirim'),
        // );
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
  }
}
