// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:webview_windows/webview_windows.dart';
// import 'package:your_app/controllers/payment_controller.dart';

// class PaymentWebView extends StatelessWidget {
//   final PaymentController paymentController = Get.find<PaymentController>();

//   final WebviewController _webviewController = WebviewController();

//   @override
//   void initState() {
//     _initializeWebView();
//   }

//   Future<void> _initializeWebView() async {
//     await _webviewController.initialize();
//     _webviewController.url.listen((url) {
//       // Deteksi URL yang digunakan Midtrans untuk redirect status transaksi
//       if (url.contains('transaction_status=settlement')) {
//         // Transaksi berhasil
//         paymentController.onTransactionSuccess();
//       } else if (url.contains('transaction_status=pending')) {
//         // Transaksi pending
//         paymentController.onTransactionPending();
//       } else if (url.contains('transaction_status=deny') ||
//           url.contains('transaction_status=cancel') ||
//           url.contains('transaction_status=expire')) {
//         // Transaksi gagal atau dibatalkan
//         paymentController.onTransactionFailed();
//       }
//     });
//     _webviewController.loadUrl(paymentController.snapUrl.value);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Pembayaran'),
//       ),
//       body: Obx(
//         () => paymentController.snapUrl.isNotEmpty
//             ? Webview(_webviewController)
//             : Center(child: CircularProgressIndicator()),
//       ),
//     );
//   }
// }
