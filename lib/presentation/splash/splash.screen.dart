import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../infrastructure/dal/database/sync_status.dart';
import 'controllers/splash.controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.init();

    return Scaffold(
      appBar: StatusAppBar(title: 'Materikas'),
      body: Obx(
        () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Menampilkan CircularProgressIndicator hanya saat belum sinkron
              if (!controller.authService.hasSynced.value) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 8),
                const Text('Menghubungkan Akun...'),
              ] else ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 48),
                const SizedBox(height: 8),
                const Text('Akun Terhubung!'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
