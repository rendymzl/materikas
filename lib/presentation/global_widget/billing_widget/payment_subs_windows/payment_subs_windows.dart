import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../main.dart';
import '../subs_controller.dart';
import 'payment_subs_windows_controller.dart';

Widget paymentSubsWindows() {
  final controller = Get.put(BrowserWindowsController());
  final subsC = Get.find<SubsController>();

  Future.delayed(Duration(milliseconds: 300));

  // controller.url.value = subsC.snapUrl.value;

  controller.addToLog("WebView START");
  // controller.addToLog("Initial URL: ${subsC.snapUrl.value}");

  final browser = MyInAppBrowser(webViewEnvironment: webViewEnvironment);
  final settings = InAppBrowserClassSettings(
      browserSettings: InAppBrowserSettings(hideUrlBar: false),
      webViewSettings: InAppWebViewSettings(
          javaScriptEnabled: true, isInspectable: kDebugMode));

  if (!controller.isOpen.value) {
    browser.openUrlRequest(
        urlRequest: URLRequest(url: WebUri(subsC.snapUrl.value)),
        settings: settings);

    controller.isOpen(true);
  }

  return Column(
    children: [
      // Expanded(
      //   child: Stack(
      //     children: [
      //       if (controller.ready.value)
      //         InAppWebView(
      //           key: controller.webViewKey,
      //           initialUrlRequest:
      //               URLRequest(url: WebUri(controller.url.value)),
      //           initialSettings: InAppWebViewSettings(
      //             transparentBackground: true,
      //             safeBrowsingEnabled: true,
      //             isFraudulentWebsiteWarningEnabled: true,
      //           ),
      //           onWebViewCreated: (webController) async {
      //             try {
      //               controller.addToLog("WebView is being created...");
      //               controller.webViewController = webController;
      //               controller.addToLog("WebView created successfully.");
      //               if (!kIsWeb &&
      //                   defaultTargetPlatform == TargetPlatform.android) {
      //                 await webController.startSafeBrowsing();
      //                 controller.addToLog("Safe Browsing started for Android.");
      //               }
      //             } catch (e, stackTrace) {
      //               controller.addToLog("Error during WebView creation: $e");
      //               debugPrint("StackTrace: $stackTrace");
      //             }
      //           },
      //           onLoadStart: (webController, url) {
      //             try {
      //               if (url != null) {
      //                 controller.addToLog("Started loading URL: $url");
      //                 controller.updateUrl(url.toString());
      //               }
      //             } catch (e, stackTrace) {
      //               controller.addToLog("Error during onLoadStart: $e");
      //               debugPrint("StackTrace: $stackTrace");
      //             }
      //           },
      //           onLoadStop: (webController, url) async {
      //             try {
      //               if (url != null) {
      //                 controller.addToLog("Finished loading URL: $url");
      //                 controller.updateUrl(url.toString());
      //               }
      //               final sslCertificate = await webController.getCertificate();
      //               if (sslCertificate != null) {
      //                 controller.addToLog(
      //                     "SSL Certificate issued to: ${sslCertificate.issuedTo}");
      //               } else {
      //                 controller.addToLog("No SSL Certificate found.");
      //               }

      //               controller.isSecure.value = sslCertificate != null ||
      //                   (url != null &&
      //                       BrowserWindowsController.urlIsSecure(url));
      //               controller.addToLog(
      //                   "Connection secure: ${controller.isSecure.value}");
      //             } catch (e, stackTrace) {
      //               controller.addToLog("Error during onLoadStop: $e");
      //               debugPrint("StackTrace: $stackTrace");
      //             }
      //           },
      //           onTitleChanged: (webController, newTitle) {
      //             try {
      //               if (newTitle != null) {
      //                 controller.addToLog("Page title changed: $newTitle");
      //                 controller.updateTitle(newTitle);
      //               }
      //             } catch (e, stackTrace) {
      //               controller.addToLog("Error during onTitleChanged: $e");
      //               debugPrint("StackTrace: $stackTrace");
      //             }
      //           },
      //           onProgressChanged: (webController, progress) {
      //             try {
      //               controller.addToLog("Progress updated: $progress%");
      //               controller.updateProgress(progress);
      //             } catch (e, stackTrace) {
      //               controller.addToLog("Error during onProgressChanged: $e");
      //               debugPrint("StackTrace: $stackTrace");
      //             }
      //           },
      //           shouldOverrideUrlLoading:
      //               (webController, navigationAction) async {
      //             try {
      //               final url = navigationAction.request.url;
      //               if (url != null) {
      //                 controller.addToLog(
      //                   "Navigation request: ${url.toString()}, isForMainFrame: ${navigationAction.isForMainFrame}",
      //                 );
      //               }
      //               if (navigationAction.isForMainFrame &&
      //                   url != null &&
      //                   ![
      //                     'http',
      //                     'https',
      //                     'file',
      //                     'chrome',
      //                     'data',
      //                     'javascript',
      //                     'about'
      //                   ].contains(url.scheme)) {
      //                 if (await canLaunchUrl(url)) {
      //                   controller.addToLog("Launching external URL: $url");
      //                   launchUrl(url);
      //                   return NavigationActionPolicy.CANCEL;
      //                 }
      //               }
      //             } catch (e, stackTrace) {
      //               controller
      //                   .addToLog("Error during shouldOverrideUrlLoading: $e");
      //               debugPrint("StackTrace: $stackTrace");
      //             }
      //             return NavigationActionPolicy.ALLOW;
      //           },
      //         ),
      //       Obx(() => controller.progress.value < 1.0
      //           ? LinearProgressIndicator(value: controller.progress.value)
      //           : Container()),
      //     ],
      //   ),
      // ),
      Expanded(
        child: Center(
          child: ElevatedButton(
            onPressed: () async {
              if (subsC.selectedPackage.value != null) {
                browser.openUrlRequest(
                    urlRequest: URLRequest(url: WebUri(subsC.snapUrl.value)),
                    settings: settings);
              } else {
                ScaffoldMessenger.of(Get.context!).showSnackBar(
                  const SnackBar(
                    content:
                        Text("Silakan pilih paket langganan terlebih dahulu"),
                  ),
                );
              }
            },
            child: const Text('Buka Halaman Pembayaran'),
          ),
        ),
      ),
      // Obx(
      //   () => Container(
      //     color: Colors.grey[200],
      //     height: 150,
      //     child: SingleChildScrollView(
      //       child: Text(controller.log.value),
      //     ),
      //   ),
      // ),
    ],
  );
}
