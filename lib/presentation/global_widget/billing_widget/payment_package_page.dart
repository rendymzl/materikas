import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'subs_controller.dart';

Widget paymentPackageWidget() {
  final controller = Get.find<SubsController>();
  return Stack(
    alignment: AlignmentDirectional.topCenter,
    children: [
      Container(
        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: WebView(
          initialUrl: controller.snapUrl.value,
          onPageStarted: (url) {
            controller.loadingPercentage.value = 0;
          },
          onProgress: (progress) {
            controller.loadingPercentage.value = progress;
          },
          onPageFinished: (url) {
            controller.loadingPercentage.value = 100;
          },
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            controller.webViewC = webViewController;
          },
          javascriptChannels: <JavascriptChannel>{
            controller.blobDataChannel(),
          },
          navigationDelegate: (NavigationRequest request) {
            final host = Uri.parse(request.url).toString();
            if (host.contains('gojek://') ||
                host.contains('shopeeid://') ||
                host.contains('//wsa.wallet.airpay.co.id/') ||
                // This is handle for sandbox Simulator
                host.contains('/gopay/partner/') ||
                host.contains('/shopeepay/') ||
                host.contains('/pdf')) {
              controller.launchInExternalBrowser(Uri.parse(request.url));
              return NavigationDecision.prevent;
            }
            if (host.startsWith('blob:')) {
              controller.fetchBlobData(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      ),
      Obx(() => controller.loadingPercentage.value < 100
          ? LinearProgressIndicator(
              value: controller.loadingPercentage.value / 100.0,
            )
          : SizedBox.shrink()),
    ],
  );
}
