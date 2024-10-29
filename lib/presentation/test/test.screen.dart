import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/test.controller.dart';

class TestScreen extends GetView<TestController> {
  const TestScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // final account = controller.account.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('TestScreen'),
        centerTitle: true,
      ),
      body: Center(child: Text('data')
          // Obx(
          //   () => !controller.isLoading.value
          //       ? Column(
          //           children: [
          //             Text(
          //               'Akun: ${controller.account.value?.name ?? 'Tidak ada data'}',
          //               style: const TextStyle(fontSize: 20),
          //             ),
          //             Text(
          //               'Store: ${controller.store.value?.name.value ?? 'Tidak ada data'}',
          //               style: const TextStyle(fontSize: 20),
          //             ),
          //             Text(
          //               'Total Invoice: ${controller.lenght.value}',
          //               style: const TextStyle(fontSize: 20),
          //             ),
          //           ],
          //         )
          //       : const CircularProgressIndicator(),
          // ),
          ),
    );
  }
}
