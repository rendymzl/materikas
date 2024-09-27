import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../global_widget/app_dialog_widget.dart';
import 'controllers/splash.controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    controller.init();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            controller.isConnected.value
                ? AppDialog.show(
                    title: 'Keluar',
                    content: 'Keluar dari aplikasi?',
                    confirmText: "Ya",
                    cancelText: "Tidak",
                    confirmColor: Colors.grey,
                    cancelColor: Get.theme.primaryColor,
                    onConfirm: () => controller.signOut(),
                    onCancel: () => Get.back(),
                  )
                : await Get.defaultDialog(
                    title: 'Error',
                    middleText:
                        'Tidak ada koneksi internet untuk mengeluarkan akun.',
                    confirm: TextButton(
                      onPressed: () {
                        Get.back();
                        Get.back();
                      },
                      child: const Text('OK'),
                    ),
                  );
          },
          icon: const Icon(Symbols.logout),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.checkStats(),
            icon: const Icon(Symbols.logout),
          ),
        ],
      ),
      body: Obx(
        () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              Text(controller.loadingStatus.value)
            ],
          ),
        ),
      ),
    );
  }
}
