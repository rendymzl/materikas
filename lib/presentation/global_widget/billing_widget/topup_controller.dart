import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
// import 'package:webview_windows/webview_windows.dart';
// import 'package:webview_flutter/webview_flutter.dart' as webview_android;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../infrastructure/dal/services/account_service.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/billing_service.dart';
import '../../../infrastructure/dal/services/store_service.dart';
import '../../../infrastructure/models/topup_value_model.dart';
import '../../../infrastructure/utils/hive_boxex.dart';
import '../otp/otp_controller.dart';
import '../popup_page_widget.dart';
import 'billing_controller.dart';

class TopupController extends GetxController {
  final AuthService authC = Get.find();
  final StoreService storeService = Get.find();
  final AccountService accountSecvice = Get.find();
  final BillingService billingService = Get.find();
  late final BillingController billingController = Get.find();
  final OtpController otpC = Get.put(OtpController());
  final String _serverKey = dotenv.env['MIDTRANS_SERVER']!;
  final String _clientKey = dotenv.env['MIDTRANS_CLIENT']!;

  final selectedPrice = Rxn<TopupValueModel>(null);
  // final webviewController = WebviewController().obs;
  // final webviewAndroidController = webview_android..obs;
  late WebViewController webViewC;
  var snapUrl = ''.obs;
  var orderId = ''.obs;
  var package = ''.obs;
  var price = 0.obs;

  final loadingPercentage = 0.obs;
  var isLoading = false.obs;
  var isLoadingReceipt = false.obs;
  var paymentStatus = ''.obs;
  var isPaymentExist = false.obs;
  final paymentSuccess = false.obs;

  void setSnapUrl(String url) {
    snapUrl.value = url;
  }

  void updateLoading(bool value) {
    isLoading.value = value;
  }

  // Daftar nominal
  List<TopupValueModel> priceList = [
    // TopupValueModel(2000, 2000000, 500, note: 'TEST'),
    TopupValueModel(2000, 2000000, 20000),
    TopupValueModel(5000, 5000000, 50000),
    TopupValueModel(10000, 10000000, 100000, note: 'PILIHAN POPULAR!'),
    TopupValueModel(20000, 20000000, 200000),
    TopupValueModel(50000, 50000000, 500000),
    TopupValueModel(100000, 100000000, 1000000),
    TopupValueModel(200000, 200000000, 2000000),
    TopupValueModel(10000000, 10000000000, 3500000, note: 'PILIHAN TERBAIK!'),
    // TopupValueModel(10000000, 10000000000, 500, note: 'PILIHAN TERBAIK!'),
  ];

  // Fungsi untuk memilih nominal
  void selectNominal(int index) {
    // Reset semua pilihan
    for (var item in priceList) {
      item.isSelected = false;
    }
    // Set nominal yang dipilih
    priceList[index].isSelected = true;
    selectedPrice.value = priceList[index];
  }

  Future<void> initPayment() async {
    snapUrl.value = await HiveBox.getMidtrans('snap_url');
    orderId.value = await HiveBox.getMidtrans('order_id');

    try {
      if (snapUrl.value.isEmpty || selectedPrice.value!.price != price.value) {
        orderId.value = 'order-id-${DateTime.now().millisecondsSinceEpoch}';
        // Mengambil Snap Token
        var snapToken = await getMidtransSnapToken(
          orderId: orderId.value,
          packageName: selectedPrice.value!.amount > 200000
              ? 'Token Unlimited'
              : 'Token: ${selectedPrice.value!.amount}',
          grossAmount: selectedPrice.value!.price,
          customerName: authC.account.value!.name,
          customerPhone: authC.store.value!.phone.value,
          // customerEmail: 'johndoe@example.com',
        );
        snapUrl.value = 'https://app.midtrans.com/snap/v2/vtweb/$snapToken';
        await HiveBox.saveMidtrans('snap_url', snapUrl.value);
        await HiveBox.saveMidtrans('order_id', orderId.value);
        await HiveBox.saveMidtrans('price', price.value);

        startTimer(orderId.value);
      }
      paymentPage();
    } catch (e) {
      paymentStatus.value = 'Pembayaran gagal: $e';
    }
  }

  Future<void> paymentPage() async {
    // if (Platform.isWindows) {
    //   await webviewController.value.initialize();
    //   await webviewController.value.loadUrl(snapUrl.value);
    // }
    // if (Platform.isAndroid) {
    //   if (WebViewPlatform.instance != null) {
    //    await WebViewPlatform.instance!.initialize();
    //   }
    // }
    // webViewController
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..setNavigationDelegate(
    //     NavigationDelegate(
    //       onProgress: (int progress) {
    //         // Update loading bar.
    //       },
    //       // onPageStarted: (String url) {},
    //       // onPageFinished: (String url) {},
    //       // onHttpError: (HttpResponseError error) {},
    //       // onWebResourceError: (WebResourceError error) {},
    //       // onNavigationRequest: (NavigationRequest request) {
    //       //   if (request.url.startsWith('https://www.youtube.com/')) {
    //       //     return NavigationDecision.prevent;
    //       //   }
    //       //   return NavigationDecision.navigate;
    //       // },
    //     ),
    //   )..addJavaScriptChannel(name, onMessageReceived: onMessageReceived)
    //   ..loadRequest(Uri.parse(snapUrl.value));
    isPaymentExist.value = snapUrl.isNotEmpty;
  }

  Future<String> getMidtransSnapToken({
    required String orderId,
    required int grossAmount,
    required String packageName,
    required String customerName,
    required String customerPhone,
  }) async {
    package.value = packageName;
    const String midtransUrl = 'https://app.midtrans.com/snap/v1/transactions';

    final headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode(_serverKey))}',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final body = jsonEncode({
      "transaction_details": {
        "order_id": orderId,
        "gross_amount": grossAmount,
      },
      "customer_details": {
        "first_name": customerName,
        "phone": customerPhone,
        // "email": customerEmail,
      },
      "item_details": [
        {
          "id": "1",
          "name": packageName,
          "price": grossAmount,
          "quantity": 1,
          "brand": "Materikas",
          "category": "App Cashier",
          "created_at": DateTime.now().toLocal().toIso8601String(),
          "updated_at": DateTime.now().toLocal().toIso8601String(),
        }
      ],
      "enabled_payments": [
        "credit_card",
        "gopay",
        "bank_transfer",
        "qris",
        "bca_va",
        "other_qris"
      ],
    });

    final response = await http.post(
      Uri.parse(midtransUrl),
      headers: headers,
      body: body,
    );
    // print('response ${response.body}');
    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return responseData['token'];
    } else {
      throw Exception('Failed to get Snap token');
    }
  }

  // Fungsi konfirmasi pembelian
  void confirmPurchase() async {
    var selectedNominal = priceList.firstWhere((item) => item.isSelected,
        orElse: () => TopupValueModel(0, 0, 0));
    if (selectedNominal.amount > 0) {
      print('Pembelian sebesar Rp.${selectedNominal.price} dikonfirmasi.');
      await initPayment();
    } else {
      Get.defaultDialog(
        title: 'Pemberitahuan',
        content: Text('Pilih nominal terlebih dahulu.'),
        textConfirm: 'OK',
        onConfirm: () => Get.back(),
      );
    }
  }

  Future<void> checkPaymentStatus(String orderId) async {
    final String midtransUrl = 'https://api.midtrans.com/v2/$orderId/status';
    // print(midtransUrl);
    final headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode(_serverKey))}',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final response = await http.get(
      Uri.parse(midtransUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      String transactionStatus = responseData['transaction_status'] ?? '';
      print(responseData);
      switch (transactionStatus) {
        case 'settlement':
          paymentStatus.value = 'Pembayaran berhasil.';
          await onSuccess();
          break;
        case 'pending':
          paymentStatus.value = 'Menunggu pembayaran.';
          break;
        case 'deny':
          paymentStatus.value = 'Pembayaran ditolak.';
          await cancelPayment();
          break;
        case 'expire':
          paymentStatus.value = 'Pembayaran kadaluarsa.';
          await cancelPayment();
          break;
        case 'cancel':
          paymentStatus.value = 'Pembayaran dibatalkan.';
          await cancelPayment();
          break;
        default:
          paymentStatus.value = 'Pilih metode pembayaran.';
      }
      // if (responseData['status_code'] == '404') {
      //   paymentStatus.value = 'Pembayaran kadaluarsa.';
      //   await cancelPayment();
      // }
    } else {
      paymentStatus.value = 'Gagal memeriksa status pembayaran.';
    }
  }

  Future<void> cancelMidtransTransaction(String orderId) async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$_serverKey:'))}';

    final String url = 'https://api.midtrans.com/v2/$orderId/cancel';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Transaksi berhasil dibatalkan: $responseData');
      } else {
        print('Gagal membatalkan transaksi. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error membatalkan transaksi: $e');
    }
  }

  Future<void> onSuccess() async {
    print('success bossss ');
    isLoading.value = true;
    stopTimer();
    // String? package = await authC.box.get('package');
    // var updatedAccount = AccountModel.fromJson(authC.account.value!.toJson());
    // billingService.isExpired.value = false;
    if (selectedPrice.value!.amount > 200000) {
      authC.account.value!.accountType = 'full';
      authC.account.value!.isActive = true;
      authC.account.value!.token = null;
    }

    if (authC.account.value!.token != null) {
      int tokenFromDb = authC.account.value!.token!;
      authC.account.value!.token = tokenFromDb + selectedPrice.value!.amount;
    }

    // if (package == 'flexible') {
    //   await billingService.payBill();
    // } else if (package == 'subscription') {
    //   if (authC.account.value!.endDate?.isBefore(DateTime.now()) ?? true) {
    //     authC.account.value!.startDate = DateTime.now();
    //     authC.account.value!.endDate =
    //         DateTime.now().add(const Duration(days: 31));
    //   } else {
    //     authC.account.value!.startDate = authC.account.value!.endDate;
    //     authC.account.value!.endDate =
    //         authC.account.value!.endDate!.add(const Duration(days: 31));
    //   }
    // } else if (package == 'full') {
    //   authC.account.value!.endDate = null;
    // }

    await HiveBox.deleteMidtrans('order_id');
    await HiveBox.deleteMidtrans('snap_token');

    await accountSecvice.update(authC.account.value!);
    // await authC.getAccount();
    authC.store(await storeService.getStore(authC.account.value!.storeId!));

    await showPopupPageWidget(
        barrierDismissible: false,
        title: 'Pembayaran Berhasil',
        height: MediaQuery.of(Get.context!).size.height * (0.75),
        width: MediaQuery.of(Get.context!).size.width * (0.3),
        content: Obx(() => Padding(
            padding: const EdgeInsets.all(8.0),
            child: (!paymentSuccess.value)
                ? FutureBuilder<Widget>(
                    future: billingController.buildReceipt(package.value,
                        price: selectedPrice.value!.price),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return SingleChildScrollView(
                          child: SizedBox(
                            height:
                                MediaQuery.of(Get.context!).size.height * 0.55,
                            child: snapshot.data!,
                          ),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  )
                : Center(
                    child: Text('Token sudah di tambahkan, terima kasih.')))),
        // onClose: () async {},
        buttonList: [
          Obx(() => !paymentSuccess.value
              ? isLoadingReceipt.value
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(Get.context!).primaryColor),
                      onPressed: () async {
                        isLoadingReceipt.value = true;
                        var path = await billingController
                            .generateAndSaveReceiptInBackground();

                        await otpC.successImage(authC.store.value!.phone.value,
                            path: path);
                        paymentSuccess.value = true;
                        isLoadingReceipt.value = false;
                        // Get.back();
                      },
                      child: const Text('ok',
                          style: TextStyle(color: Colors.white)),
                    )
              : ElevatedButton(
                  onPressed: () {
                    authC.token.value = authC.account.value!.token;
                    authC.initToken.value = authC.account.value!.token;
                    paymentSuccess.value = false;
                    snapUrl.value = '';
                    isPaymentExist.value = false;
                    Get.back();
                    Get.back();
                  },
                  child: Text('ok'))),
        ]);

    // await Get.defaultDialog(
    //   barrierDismissible: false,
    //   title: 'Restart Aplikasi',
    //   middleText: 'Silahkan tutup aplikasi kemudian buka kembali.',
    // );
    // Get.offAllNamed(Routes.SPLASH);
  }

  Future<void> cancelPayment() async {
    print('membatalkan pembayaran...');
    snapUrl.value = '';
    // await webviewController.value.stop();
    var orderId = await HiveBox.getMidtrans('order_id');
    if (orderId.isNotEmpty) {
      await cancelMidtransTransaction(orderId);
    }
    await HiveBox.deleteMidtrans('order_id');
    await HiveBox.deleteMidtrans('snap_url');

    stopTimer();
    isPaymentExist.value = false;
  }

  Timer? timer;
  void startTimer(String orderId) {
    timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      checkPaymentStatus(orderId);
    });
  }

  void stopTimer() {
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
  }

  JavascriptChannel blobDataChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'BlobDataChannel',
      onMessageReceived: (JavascriptMessage message) async {
        final decodedBytes = base64Decode(message.message);
        final directory = await getApplicationDocumentsDirectory();
        final path = directory.path;
        final file = File('$path/export.csv');
        await file.writeAsBytes(decodedBytes);

        await FileSaver.instance.saveAs(
          name: 'export',
          ext: 'png',
          mimeType: MimeType.png,
          file: file,
        );
      },
    );
  }

  void fetchBlobData(String blobUrl) async {
    final script = '''
      (async function() {
        const response = await fetch('$blobUrl');
        const blob = await response.blob();
        const reader = new FileReader();
        reader.onloadend = function() {
          const base64data = reader.result.split(',')[1];
          BlobDataChannel.postMessage(base64data);
        };
        reader.readAsDataURL(blob);
      })();
    ''';
    webViewC.runJavascript(script);
  }

  Future<void> launchInExternalBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }
}
