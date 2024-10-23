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
          () => !controller.isLoading.value
              ? Column(
                  children: [
                    Text(
                      'Akun: ${controller.account.value?.name ?? 'Tidak ada data'}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      'Store: ${controller.store.value?.name.value ?? 'Tidak ada data'}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Expanded(
                    //       child: TextFormField(
                    //         // controller: controller.searchQuery,
                    //         decoration: const InputDecoration(
                    //           hintText: 'Cari Invoice',
                    //           prefixIcon: Icon(Icons.search),
                    //         ),
                    //         onChanged: (value) {
                    //           controller.searchInvoice(value);
                    //         },
                    //       ),
                    //     ),
                    //     // Text(
                    //     //   'Store: ${controller.paidInvResult.length}',
                    //     //   style: const TextStyle(fontSize: 20),
                    //     // ),
                    //   ],
                    // ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Expanded(
                    //       child: TextFormField(
                    //         // controller: controller.searchQuery,
                    //         decoration: const InputDecoration(
                    //           hintText: 'Cari Payment',
                    //           prefixIcon: Icon(Icons.search),
                    //         ),
                    //         onChanged: (value) {
                    //           controller.searchInvoice(value);
                    //         },
                    //       ),
                    //     ),
                    //     Text(
                    //       'Payment: ${controller.payments.length}',
                    //       style: const TextStyle(fontSize: 20),
                    //     ),
                    //   ],
                    // ),
                    Text(
                      'total cash: ${controller.cash.value}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      'total transfer: ${controller.transfer.value}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      'total cashDebt: ${controller.debtCash.value}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      'total transferDebt: ${controller.debtCash.value}',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
