import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'midtrans_controller.dart';

class PaymentPage extends StatelessWidget {
  final MidtransController paymentController = Get.put(MidtransController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Midtrans Payment with GetX'),
      ),
      body: Center(
        child: Obx(() {
          // Menampilkan loader saat pembayaran sedang diproses
          if (paymentController.isLoading.value) {
            return CircularProgressIndicator();
          } else {
            return ElevatedButton(
              onPressed: () {
                paymentController.initiatePayment();
              },
              child: Text('Bayar dengan Midtrans'),
            );
          }
        }),
      ),
    );
  }
}
