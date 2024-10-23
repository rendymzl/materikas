import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_windows/webview_windows.dart';
import '../../../infrastructure/dal/services/midtrans/midtrans_controller.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../popup_page_widget.dart';
import 'billing_controller.dart';

void paymentBillingPopup() async {
  final BillingController billingController = Get.find();
  final MidtransController midtransC = Get.find();

  var orderId = billingController.authService.box.get('order_id');

  if (orderId == null) {
    midtransC.isLoading.value = true;
    midtransC.initiatePayment('flexible');
    await Future.delayed(const Duration(seconds: 1));
    midtransC.isLoading.value = false;
  } else if (orderId != null) {
    await midtransC.checkPaymentStatus(orderId);
    if (midtransC.paymentStatus.value.toLowerCase().contains('kadaluarsa')) {
      midtransC.cancelPayment();
    }
    print('midtransC.snap.isEmpty ${midtransC.snap.isEmpty}');
    if (midtransC.snap.isEmpty) {
      midtransC.isLoading.value = true;
      midtransC.initiatePayment('flexible');
      await Future.delayed(const Duration(seconds: 1));
      midtransC.isLoading.value = false;
    }
    midtransC.startTimer(orderId);
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Pembayaran berhasil.':
        return Colors.green;
      case 'Menunggu pembayaran.':
        return Colors.orange;
      case 'Pembayaran ditolak.':
        return Colors.red;
      case 'Pembayaran dibatalkan.':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  showPopupPageWidget(
    title:
        'Pembayaran ${getMonthName(billingController.billingService.selectedMonth.value.month)} ${billingController.billingService.selectedMonth.value.year}',
    height: MediaQuery.of(Get.context!).size.height * (0.8),
    width: MediaQuery.of(Get.context!).size.width * (0.3),
    content: Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: MediaQuery.of(Get.context!).size.height * 0.9,
        child: Obx(
          () => (midtransC.isLoading.value)
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Webview(
                  midtransC.webviewController.value,
                ),
        ),
      ),
    ),
    // buttonList: [
    // ElevatedButton(
    //   style: ElevatedButton.styleFrom(
    //     backgroundColor: Colors.grey[800],
    //     foregroundColor: Theme.of(Get.context!).primaryColor,
    //   ),
    //   onPressed: () async {
    //     await midtransC.onSuccess();
    //     // Get.back();
    //   },
    //   child: const Text('LUNASI TAGIHAN'),
    // ),
    // ElevatedButton(
    //   style: ElevatedButton.styleFrom(
    //     backgroundColor: Colors.grey[200],
    //     foregroundColor: Theme.of(Get.context!).primaryColor,
    //   ),
    //   onPressed: () {
    //     midtransC.cancelPayment();
    //     Get.back();
    //   },
    //   child: const Text('Batalkan Pesanan'),
    // ),
    // Obx(() {
    //   return Expanded(
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         Text(
    //           midtransC.paymentStatus.value,
    //           style: TextStyle(
    //             color: getStatusColor(midtransC.paymentStatus.value),
    //             fontSize: 24,
    //           ),
    //         ),
    //         ElevatedButton(
    //           onPressed: () {
    //             midtransC.cancelPayment();
    //           },
    //           child: const Text('Batalkan Pesanan'),
    //         ),
    //       ],
    //     ),
    //   );
    // }),
    // ],
    onClose: () => midtransC.stopTimer(),
  );
}
