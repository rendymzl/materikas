import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_updater/auto_updater.dart';
import 'package:intl/intl.dart';
import 'package:materikas/ensure_webview2.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';

import 'infrastructure/dal/database/powersync.dart';
import 'infrastructure/dal/database/powersync_attachment.dart';
import 'infrastructure/dal/database/supabase.dart';
import 'infrastructure/models/invoice_model/invoice_model.dart';
import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';
import 'infrastructure/theme/app_theme.dart';

// @pragma('vm:entry-point')
// void isolatePaidStream(SendPort sendPort) async {
//   print('listenPaid: Start isolatePaidStream');
//   final invoicePaidStream = db.watch('''
//   SELECT
//     invoices.id,
//     invoices.store_id,
//     invoices.invoice_id,
//     invoices.created_at,
//     invoices.account,
//     invoices.customer,
//     invoices.purchase_list,
//     invoices.return_list,
//     invoices.after_return_list,
//     invoices.price_type,
//     invoices.discount,
//     invoices.tax,
//     invoices.return_fee,
//     invoices.remove_product,
//     invoices.debt_amount,
//     invoices.app_bill_amount,
//     invoices.is_debt_paid,
//     invoices.is_app_bill_paid,
//     invoices.other_costs,
//     invoices.init_at,
//     invoices.remove_at,
//       '[' || GROUP_CONCAT(
//       '{ "id": "' || payments.id || '"' ||
//       ', "invoice_id": "' || payments.invoice_id || '"' ||
//       ', "store_id": "' || payments.store_id || '"' ||
//       ', "invoice_created_at": "' || payments.invoice_created_at || '"' ||
//       ', "date": "' || payments.date || '"' ||
//       ', "method": "' || payments.method || '"' ||
//       ', "final_amount_paid": ' || payments.final_amount_paid ||
//       ', "remain": ' || payments.remain ||
//       ', "amount_paid": ' || payments.amount_paid ||
//       '}', ', '
//     ) || ']' AS payments
//   FROM
//     invoices
//   LEFT JOIN
//     payments ON invoices.invoice_id = payments.invoice_id
//   WHERE
//     invoices.created_at BETWEEN ? AND ?
//     AND invoices.remove_at IS NULL
//     AND invoices.is_debt_paid = 1
//   GROUP BY
//     invoices.invoice_id
//   ORDER BY
//     invoices.created_at DESC;
//     ''', parameters: [
//     DateFormat('yyyy-MM-dd').format(DateTime.now()),
//     DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 1))),
//   ]).map((data) => data.toList());

//   invoicePaidStream.listen((datas) async {
//     var dataModel = datas.map((e) => InvoiceModel.fromJson(e)).toList();
//     sendPort.send(dataModel);

//   });
// }

WebViewEnvironment? webViewEnvironment;

class MyInAppBrowser extends InAppBrowser {
  MyInAppBrowser({super.webViewEnvironment});

  @override
  Future onBrowserCreated() async {
    print("Browser Created!");
  }

  @override
  Future onLoadStart(url) async {
    print("Started $url");
  }

  @override
  Future onLoadStop(url) async {
    print("Stopped $url");
  }

  @override
  void onReceivedError(WebResourceRequest request, WebResourceError error) {
    print("Can't load ${request.url}.. Error: ${error.description}");
  }

  @override
  void onProgressChanged(progress) {
    print("Progress: $progress");
  }

  @override
  void onExit() {
    print("Browser closed!");
  }
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // if (runWebViewTitleBarWidget(args)) {
  //   return;
  // }

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    final availableVersion = await WebViewEnvironment.getAvailableVersion();
    assert(availableVersion != null,
        'Failed to find an installed WebView2 Runtime or non-stable Microsoft Edge installation.');

    webViewEnvironment = await WebViewEnvironment.create(
        settings: WebViewEnvironmentSettings(
            userDataFolder: 'C:/Users/Public/Documents/Materikas'));
  }

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  var initialRoute = await Routes.initialRoute;

  if (Platform.isWindows) {
    // await ensureWebView2Installed();
    String feedURL = 'https://api.menantikan.com/releases/appcast.xml';
    await autoUpdater.setFeedURL(feedURL);

    // await autoUpdater.checkForUpdates(inBackground: true);
    // await autoUpdater.setScheduledCheckInterval(3600);

    windowManager.waitUntilReadyToShow(null, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setMinimumSize(const Size(800, 600));
    });
  }

  await dotenv.load(fileName: ".env");
  // await loadSupabase();
  await openDatabase();
  await Hive.initFlutter();
  if (dotenv.get('SUPABASE_BUCKET').isNotEmpty) {
    await initializeAttachmentQueue(db);
  }

  runApp(Main(initialRoute));
}

class Main extends StatelessWidget {
  final String initialRoute;
  const Main(this.initialRoute, {super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Materikas',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('en', 'US'),
      supportedLocales: const [
        Locale('id'),
      ],
      defaultTransition: Transition.noTransition,
      theme: appTheme,
      initialRoute: initialRoute,
      getPages: Nav.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
