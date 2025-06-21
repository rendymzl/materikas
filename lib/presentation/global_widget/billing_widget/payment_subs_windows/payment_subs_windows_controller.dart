import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';

class BrowserWindowsController extends GetxController {
  final GlobalKey webViewKey = GlobalKey();
  final url = ''.obs;
  final title = ''.obs;
  final progress = 0.0.obs;
  final isOpen = false.obs;
  final isSecure = RxnBool();
  InAppWebViewController? webViewController;

  final log = "Debug Log:\n".obs;

  // Webview? webview;

  @override
  void onClose() {
    isOpen(false);
    super.onClose();
  }

  // @override
  // void onInit() async {
  //   ready(false);
  //   webview = await WebviewWindow.create();
  //   ready(true);

  //   super.onInit();
  // }
  // WebViewEnvironment? webViewEnvironment;

  // @override
  // void onInit() async {
  // ready(false);
  // if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
  //   final availableVersion = await WebViewEnvironment.getAvailableVersion();
  //   assert(availableVersion != null,
  //       'Failed to find an installed WebView2 Runtime or non-stable Microsoft Edge installation.');

  //   webViewEnvironment = await WebViewEnvironment.create(
  //       settings: WebViewEnvironmentSettings(
  //           userDataFolder: 'C:/Users/Public/Documents/Materikas'));
  // }
  // ready(true);
  //   super.onInit();
  // }

  void addToLog(String message) {
    log.value += "$message\n";
  }

  void updateUrl(String newUrl) {
    url.value = newUrl;
    isSecure.value = urlIsSecure(Uri.parse(newUrl));
  }

  void updateTitle(String newTitle) {
    title.value = newTitle;
  }

  void updateProgress(int newProgress) {
    progress.value = newProgress / 100;
  }

  Future<void> handleAction(int item) async {
    switch (item) {
      case 0:
        await InAppBrowser.openWithSystemBrowser(url: WebUri(url.value));
        break;
      case 1:
        InAppWebViewController.clearAllCache;
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          await webViewController?.clearHistory();
        }
        update();
        break;
    }
  }

  static bool urlIsSecure(Uri url) {
    return (url.scheme == "https") || isLocalizedContent(url);
  }

  static bool isLocalizedContent(Uri url) {
    return (url.scheme == "file" ||
        url.scheme == "chrome" ||
        url.scheme == "data" ||
        url.scheme == "javascript" ||
        url.scheme == "about");
  }
}
