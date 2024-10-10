import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'otp_controller.dart';

Future<bool> otpPopup(String chatId) async {
  OtpController controller = Get.put(OtpController());
  controller.verified.value = false;
  // controller.otpFieldC.text = controller.otp.value;
  chatId = chatId.replaceFirst('0', '62');
  if (!controller.isResendDisabled.value) controller.sendOtp(chatId);
  await Get.defaultDialog(
    title: 'Verifikasi',
    content: Column(
      children: [
        const Text('Masukkan kode OTP yang Anda terima'),
        const SizedBox(height: 10),
        Form(
          key: GlobalKey<FormState>(),
          autovalidateMode: AutovalidateMode.always,
          child: TextFormField(
            controller: controller.otpFieldC,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              LengthLimitingTextInputFormatter(4),
            ],
            decoration: const InputDecoration(
              labelText: "Kode OTP",
              labelStyle: TextStyle(color: Colors.grey),
              floatingLabelStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kode OTP tidak boleh kosong';
              }
              if (value != controller.otp.value && value.length == 4) {
                return 'Kode OTP yang dimasukkan salah';
              }
              return null;
            },
            onChanged: (value) => controller.otpValidator(value),
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => ElevatedButton(
            onPressed: controller.isResendDisabled.value
                ? null // Disable jika countdown sedang berjalan
                : () async {
                    await controller.sendOtp(chatId);
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              controller.isResendDisabled.value
                  ? 'Kirim Ulang (${controller.countdown})' // Tampilkan countdown
                  : 'Kirim Ulang OTP',
            ),
          ),
        ),
      ],
    ),
  );

  return controller.verified.value;
}
