import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:get/get.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_windows/webview_windows.dart';

import '../../../infrastructure/dal/services/internet_service.dart';
// import '../../../infrastructure/utils/display_format.dart';
import '../../../presentation/global_widget/billing_widget/no_connection_page.dart';
import '../../../presentation/global_widget/billing_widget/payment_package_page.dart';
import '../../../presentation/global_widget/billing_widget/select_package_page.dart';
import '../../../presentation/global_widget/billing_widget/subs_controller.dart';
// import '../../../presentation/global_widget/billing_widget/topup_controller.dart';

class TopupView extends GetView {
  const TopupView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SubsController());
    final internetService = Get.find<InternetService>();
    print('awdawdwad TopupView ${controller.showPopupSubs.value}');
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.showPopupSubs.value
              ? null
              : () {
                  controller.stopTimer();
                  Get.back();
                },
        ),
        title: const Text('Pilih Langganan'),
        // backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            if (controller.showPopupSubs.value)
              Text('Masa Aktif langganan anda telah berakhir.',
                  style: TextStyle(color: Colors.red)),
            if (controller.showPopupSubs.value)
              Text('Silahkan pilih langganan untuk menggunakan aplikasi.',
                  style: TextStyle(color: Colors.red)),
            if (controller.showPopupSubs.value) SizedBox(height: 12),
            Obx(
              () => Expanded(
                child: !internetService.isConnected.value
                    ? noConnectionPage()
                    : controller.isLoading.value
                        ? Center(child: CircularProgressIndicator())
                        : controller.page.value == 'select'
                            ? selectPackageWidget()
                            : paymentPackageWidget(),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Obx(() => internetService.isConnected.value
                    ? Expanded(
                        child: controller.page.value == 'select'
                            ? ElevatedButton(
                                onPressed: () async {
                                  if (controller.selectedPackage.value !=
                                      null) {
                                    controller.goToPaymentPage();
                                  } else {
                                    ScaffoldMessenger.of(Get.context!)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Silakan pilih paket langganan terlebih dahulu"),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Pilih Pembayaran'),
                              )
                            : OutlinedButton(
                                onPressed: () async =>
                                    await controller.cancelPayment(),
                                child: const Text('Ubah Paket'),
                              ),
                      )
                    : const SizedBox()),
                // Obx(() => controller.page.value == 'payment'
                //     ? OutlinedButton(
                //         onPressed: () async => await controller.onSuccess(),
                //         child: const Text('bypass'),
                //       )
                //     : const SizedBox()),
              ],
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// import 'package:get/get.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// // import 'package:webview_windows/webview_windows.dart';

// import '../../../infrastructure/utils/display_format.dart';
// import '../../../presentation/global_widget/billing_widget/topup_controller.dart';

// class TopupView extends GetView {
//   const TopupView({super.key});
//   @override
//   Widget build(BuildContext context) {
//     TopupController controller = Get.put(TopupController());
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             controller.stopTimer();
//             Get.back();
//           },
//         ),
//         title: const Text('Beli Token'),
//         backgroundColor: Colors.white,
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         child: Column(
//           children: [
//             Expanded(
//               child: Obx(() {
//                 var priceList = controller.priceList;
//                 var selectedPrice = controller.selectedPrice.value;
//                 return controller.isPaymentExist.value
//                     ? Stack(
//                         alignment: AlignmentDirectional.topCenter,
//                         children: [
//                           Container(
//                             margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
//                             child: WebView(
//                               initialUrl: controller.snapUrl.value,
//                               onPageStarted: (url) {
//                                 controller.loadingPercentage.value = 0;
//                               },
//                               onProgress: (progress) {
//                                 controller.loadingPercentage.value = progress;
//                               },
//                               onPageFinished: (url) {
//                                 controller.loadingPercentage.value = 100;
//                               },
//                               javascriptMode: JavascriptMode.unrestricted,
//                               onWebViewCreated:
//                                   (WebViewController webViewController) {
//                                 controller.webViewC = webViewController;
//                               },
//                               javascriptChannels: <JavascriptChannel>{
//                                 controller.blobDataChannel(context),
//                               },
//                               navigationDelegate: (NavigationRequest request) {
//                                 final host = Uri.parse(request.url).toString();
//                                 if (host.contains('gojek://') ||
//                                     host.contains('shopeeid://') ||
//                                     host.contains(
//                                         '//wsa.wallet.airpay.co.id/') ||
//                                     // This is handle for sandbox Simulator
//                                     host.contains('/gopay/partner/') ||
//                                     host.contains('/shopeepay/') ||
//                                     host.contains('/pdf')) {
//                                   controller.launchInExternalBrowser(
//                                       Uri.parse(request.url));
//                                   return NavigationDecision.prevent;
//                                 }
//                                 if (host.startsWith('blob:')) {
//                                   controller.fetchBlobData(request.url);
//                                   return NavigationDecision.prevent;
//                                 }
//                                 return NavigationDecision.navigate;
//                               },
//                             ),
//                           ),
//                           // Container(
//                           //   margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
//                           //   height: 30,
//                           //   width: 60,
//                           //   child: ElevatedButton(
//                           //       onPressed: () {
//                           //         Navigator.pop(context);
//                           //       },
//                           //       style: ElevatedButton.styleFrom(
//                           //         backgroundColor: const Color(0xFF0A2852),
//                           //       ),
//                           //       child: const Text('Exit',
//                           //           style: TextStyle(fontSize: 10))),
//                           // ),
//                           Obx(() => controller.loadingPercentage.value < 100
//                               ? LinearProgressIndicator(
//                                   value: controller.loadingPercentage.value /
//                                       100.0,
//                                 )
//                               : SizedBox.shrink()),
//                         ],
//                       )
//                     //  WebViewWidget(controller: controller.webViewController)
//                     // Stack(
//                     //     children: [

//                     //       // controller.webViewController(
//                     //       //   initialUrl: controller.snapUrl.value,
//                     //       //   javascriptMode: JavascriptMode.unrestricted,
//                     //       //   onPageStarted: (_) {
//                     //       //     // Handling page loading
//                     //       //     controller.updateLoading(true);
//                     //       //   },
//                     //       //   onPageFinished: (_) {
//                     //       //     // Handling after page load
//                     //       //     controller.updateLoading(false);
//                     //       //     // if (url != null &&
//                     //       //     //     url
//                     //       //     //         .toString()
//                     //       //     //         .contains('your-redirect-url')) {
//                     //       //     //   Get.back(); // Kembali jika pembayaran selesai
//                     //       //     // }
//                     //       //   },
//                     //       // ),
//                     //       // InAppWebView(
//                     //       //   initialUrlRequest: URLRequest(
//                     //       //       url: WebUri(controller.snapUrl.value)),
//                     //       //   initialSettings: InAppWebViewSettings(
//                     //       //     userAgent:
//                     //       //         "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36",
//                     //       //     javaScriptEnabled: true,
//                     //       //     useOnDownloadStart: true,
//                     //       //     supportZoom: true,
//                     //       //     mediaPlaybackRequiresUserGesture: false,
//                     //       //   ),
//                     //       //   onWebViewCreated: (webViewController) {},
//                     //       //   onLoadStart: (c, url) {
//                     //       //     controller.updateLoading(true);
//                     //       //   },
//                     //       //   onLoadStop: (c, url) async {
//                     //       //     controller.updateLoading(false);
//                     //       //     if (url != null &&
//                     //       //         url
//                     //       //             .toString()
//                     //       //             .contains('your-redirect-url')) {
//                     //       //       Get.back(); // Kembali jika pembayaran selesai
//                     //       //     }
//                     //       //   },
//                     //       // ),
//                     //       if (controller.isLoading.value)
//                     //         Center(child: CircularProgressIndicator())
//                     //     ],
//                     //   )
//                     // Text('data')
//                     : GridView.builder(
//                         gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
//                           maxCrossAxisExtent: 270,
//                           // crossAxisCount: 2,
//                           crossAxisSpacing: 10,
//                           mainAxisSpacing: 10,
//                           childAspectRatio: 1,
//                         ),
//                         itemCount: priceList.length,
//                         itemBuilder: (context, index) {
//                           var nominal = priceList[index];
//                           return GestureDetector(
//                             onTap: () => controller.selectNominal(index),
//                             child: Card(
//                               color: nominal == selectedPrice
//                                   ? Theme.of(context).primaryColor
//                                   : Colors.grey[200],
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       nominal.amount > 200000
//                                           ? 'PAKET SELAMANYA'
//                                           : '${currency.format(nominal.amount)} Token',
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         color: nominal == selectedPrice
//                                             ? Colors.white
//                                             : Colors.black,
//                                       ),
//                                     ),
//                                     Text(
//                                       nominal.amount > 200000
//                                           ? 'Menangani transaksi tanpa token'
//                                           : 'Menangani total transaksi Rp${currency.format(nominal.handleTransaction)}',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         fontStyle: FontStyle.italic,
//                                         color: nominal == selectedPrice
//                                             ? Colors.white
//                                             : Colors.black,
//                                       ),
//                                     ),
//                                     Text(
//                                       'Rp${currency.format(nominal.price)}',
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         color: nominal == selectedPrice
//                                             ? Colors.white
//                                             : Colors.black,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     if (nominal.note != null)
//                                       Text(
//                                         nominal.note!,
//                                         style: TextStyle(
//                                           color: nominal == selectedPrice
//                                               ? Colors.white
//                                               : Theme.of(context).primaryColor,
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//               }),
//             ),
//             SizedBox(height: 12),
//             Obx(() => controller.isPaymentExist.value
//                 ? ElevatedButton(
//                     onPressed: controller.cancelPayment,
//                     child: Text("Batalkan Pesanan"),
//                   )
//                 : ElevatedButton(
//                     onPressed: controller.confirmPurchase,
//                     child: Text("Konfirmasi Pembelian"),
//                   )),
//           ],
//         ),
//       ),
//     );
//   }
// }
