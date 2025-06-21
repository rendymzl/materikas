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
      body: Center(
          child: Obx(
        () => controller.isLoading.value
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ElevatedButton(
                  //     onPressed: () {
                  //       controller.insertPaymentsSales();
                  //     },
                  //     child: const Text('Insert Payments Sales'),
                  //   ),
                  //   SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: controller.pickFile,
                    child: Text('Pilih File Excel'),
                  ),
                  Text(
                    controller.file.value == null
                        ? 'Belum ada file yang dipilih'
                        : 'File: ${controller.file.value!.path.split('/').last}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      controller.readAndUploadExcel();
                    },
                    child: const Text('Insert Invoice'),
                  ),
                ],
              ),
      )),
    );
  }
}
