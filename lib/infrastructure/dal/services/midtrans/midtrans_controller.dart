import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:webview_windows/webview_windows.dart';

import '../../../../presentation/global_widget/billing_widget/billing_controller.dart';
import '../../../../presentation/global_widget/menu_widget/menu_controller.dart';

import '../../../../presentation/global_widget/otp/otp_controller.dart';
import '../../../../presentation/global_widget/popup_page_widget.dart';
import '../../../navigation/routes.dart';
import '../account_service.dart';
import '../auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../billing_service.dart';

class MidtransController extends GetxController {
  final AuthService authC = Get.find();
  final OtpController otpC = Get.put(OtpController());
  final AccountService accountSecvice = Get.find();
  final BillingService billingService = Get.find();
  late final BillingController billingController = Get.find();
  final MenuWidgetController menuC = Get.find();
  final String _serverKey = dotenv.env['MIDTRANS_SERVER']!;
  final String _clientKey = dotenv.env['MIDTRANS_CLIENT']!;
  var isLoading = false.obs;
  var paymentStatus = ''.obs;
  // var selectedPackage = 'flexible'.obs;
  var snap = ''.obs;
  // late final totalAmount = billingService.getBillAmount();
  // late final billId = billingService.billing.value?.billingNumber;

  Timer? timer;
  final webviewController = WebviewController().obs;
  // late final box = Hive.openBox('midtrans').obs;

  final features = {
    'flexible': [
      {
        'feature': "Transaksi",
        'sub_feature': [
          {"feature": "Biaya 1% /transaksi", "active": true},
        ],
      },
      {
        'feature': "Laporan",
        'sub_feature': [
          {"feature": "Laporan harian", "active": true},
          {"feature": "Laporan mingguan", "active": false},
          {"feature": "Laporan bulanan", "active": false},
          {"feature": "Laporan tahunan", "active": false},
        ],
      },
      {
        'feature': "Manajemen Kasir",
        'sub_feature': [
          {"feature": "Tambah kasir", "active": false},
          {"feature": "Pengaturan akses kasir", "active": false},
        ],
      },
      {
        'feature': "Support",
        'sub_feature': [
          {"feature": "Support hari dan jam kerja", "active": true},
        ],
      },
    ],
    'subscription': [
      {
        'feature': "Transaksi",
        'sub_feature': [
          {"feature": "Menghilangkan biaya transaksi", "active": true},
        ],
      },
      {
        'feature': "Laporan",
        'sub_feature': [
          {"feature": "Laporan harian", "active": true},
          {"feature": "Laporan mingguan", "active": true},
          {"feature": "Laporan bulanan", "active": true},
          {"feature": "Laporan tahunan", "active": true},
        ],
      },
      {
        'feature': "Manajemen Kasir",
        'sub_feature': [
          {"feature": "Tambah hingga 3 kasir", "active": true},
          {"feature": "Pengaturan akses kasir", "active": true},
        ],
      },
      {
        'feature': "Support",
        'sub_feature': [
          {"feature": "Support hari dan jam kerja", "active": true},
        ],
      },
    ],
    'full': [
      {
        'feature': "Transaksi",
        'sub_feature': [
          {"feature": "Menghilangkan biaya transaksi", "active": true},
        ],
      },
      {
        'feature': "Laporan",
        'sub_feature': [
          {"feature": "Laporan harian", "active": true},
          {"feature": "Laporan mingguan", "active": true},
          {"feature": "Laporan bulanan", "active": true},
          {"feature": "Laporan tahunan", "active": true},
        ],
      },
      {
        'feature': "Manajemen Kasir",
        'sub_feature': [
          {"feature": "Tambah Kasir tanpa batas", "active": true},
          {"feature": "Pengaturan akses kasir", "active": true},
        ],
      },
      {
        'feature': "Support",
        'sub_feature': [
          {"feature": "Support 24/7 dan prioritas", "active": true},
        ],
      },
    ]
  };

  final price = {
    'flexible': 1 / 100,
    'subscription': 299000,
    'full': 3490000,
  };

  final oldPrice = {
    'flexible': 2 / 100,
    'subscription': 499000,
    'full': 6990000,
  };

  // Fungsi untuk mendapatkan Snap Token dari Midtrans
  Future<String> getMidtransSnapToken({
    required String orderId,
    required int grossAmount,
    required String packageName,
    required String customerName,
    required String customerPhone,
  }) async {
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
      "enabled_payments": ["credit_card", "gopay", "bank_transfer", "qris"],
    });

    final response = await http.post(
      Uri.parse(midtransUrl),
      headers: headers,
      body: body,
    );
    print('response ${response.body}');
    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return responseData['token'];
    } else {
      throw Exception('Failed to get Snap token');
    }
  }

  // late final Box<dynamic> box;

  Future<void> checkPaymentStatus(String orderId) async {
    final String midtransUrl = 'https://api.midtrans.com/v2/$orderId/status';

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
      print(transactionStatus);
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
          cancelPayment();
          break;
        case 'expire':
          paymentStatus.value = 'Pembayaran kadaluarsa.';
          cancelPayment();
          break;
        case 'cancel':
          paymentStatus.value = 'Pembayaran dibatalkan.';
          cancelPayment();
          break;
        default:
          paymentStatus.value = 'Pilih metode pembayaran.';
      }
    } else {
      paymentStatus.value = 'Gagal memeriksa status pembayaran.';
    }
  }

  // Fungsi untuk memulai pembayaran
  Future<void> initiatePayment(String selectedCard) async {
    final totalAmount = await billingService.getBillAmount();
    final billing = await billingService.getBilling();
    final billId = billing?.billingNumber;
    isLoading.value = true;
    // selectedPackage.value = selectedCard;

    var orderId = await authC.box.get('order_id');
    var snapToken = await authC.box.get('snap_token');
    String? package = await authC.box.get('package');
    try {
      print('orderId $orderId');
      print('selectedCard $selectedCard');
      print('package $package');
      print('selectedCard $selectedCard');
      if (orderId == null || ((package ?? '') != selectedCard)) {
        orderId = 'order-id-${DateTime.now().millisecondsSinceEpoch}';
        // Mengambil Snap Token
        snapToken = await getMidtransSnapToken(
          orderId: orderId,
          packageName:
              selectedCard == 'flexible' ? (billId ?? '') : selectedCard,
          grossAmount: selectedCard == 'flexible'
              ? (totalAmount).toInt()
              : price[selectedCard]! as int,
          customerName: authC.account.value!.name,
          customerPhone: authC.store.value!.phone.value,
          // customerEmail: 'johndoe@example.com',
        );
        authC.box.put('snap_token', snapToken);
        authC.box.put('order_id', orderId);
        authC.box.put('package', selectedCard.toString());
        startTimer(orderId);
      }
      print('snapToken $snapToken');
      print('snap ${snap.value}');
      // URL Snap Midtrans
      final String snapUrl =
          'https://app.midtrans.com/snap/v2/vtweb/$snapToken';

      // final Uri snapUrl =
      //     Uri.parse('https://app.midtrans.com/snap/v2/vtweb/$snapToken');
      snap.value = snapUrl;
      await webviewController.value.initialize();
      // webviewController.value.url.listen((url) {
      //   // debugPrint();
      //   // // Deteksi URL yang digunakan Midtrans untuk redirect status transaksi
      //   // if (url.contains('transaction_status=settlement')) {
      //   //   // Transaksi berhasil
      //   //   paymentController.onTransactionSuccess();
      //   // } else if (url.contains('transaction_status=pending')) {
      //   //   // Transaksi pending
      //   //   paymentController.onTransactionPending();
      //   // } else if (url.contains('transaction_status=deny') ||
      //   //     url.contains('transaction_status=cancel') ||
      //   //     url.contains('transaction_status=expire')) {
      //   //   // Transaksi gagal atau dibatalkan
      //   //   paymentController.onTransactionFailed();
      //   // }
      // });

      print('load webview');
      // print(getWebViewVersion());
      webviewController.value.loadUrl(snapUrl);

      // Membuka URL di browser
      // if (await canLaunchUrl(snapUrl)) {
      //   await launchUrl(snapUrl);
      //   startTimer(orderId);
      // } else {
      //   throw 'Could not launch $snapUrl';
      // }
    } catch (e) {
      paymentStatus.value = 'Pembayaran gagal: $e';
    } finally {
      isLoading.value = false;
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
    isLoading.value = true;
    stopTimer();
    String? package = await authC.box.get('package');
    // var updatedAccount = AccountModel.fromJson(authC.account.value!.toJson());
    // billingService.isExpired.value = false;

    authC.account.value!.accountType = package!;
    authC.account.value!.isActive = true;
    isLoading.value = true;
    if (package == 'flexible') {
      await billingService.payBill();
    } else if (package == 'subscription') {
      if (authC.account.value!.endDate?.isBefore(DateTime.now()) ?? true) {
        authC.account.value!.startDate = DateTime.now();
        authC.account.value!.endDate =
            DateTime.now().add(const Duration(days: 31));
      } else {
        authC.account.value!.startDate = authC.account.value!.endDate;
        authC.account.value!.endDate =
            authC.account.value!.endDate!.add(const Duration(days: 31));
      }
    } else if (package == 'full') {
      authC.account.value!.endDate = null;
    }

    await authC.box.delete('order_id');
    await authC.box.delete('snap_token');
    await authC.box.delete('package');

    accountSecvice.update(authC.account.value!);

    await showPopupPageWidget(
        barrierDismissible: true,
        title: 'Pembayaran Berhasil',
        height: MediaQuery.of(Get.context!).size.height * (0.8),
        width: MediaQuery.of(Get.context!).size.width * (0.3),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<Widget>(
            future: billingController.buildReceipt(package,
                price: price[package] is int
                    ? price[package]!.toDouble()
                    : price[package]! as double),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SizedBox(
                  height: MediaQuery.of(Get.context!).size.height * 0.50,
                  child: snapshot.data!,
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        // onClose: () async {},
        buttonList: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(Get.context!).primaryColor),
            onPressed: () async {
              var path =
                  await billingController.generateAndSaveReceiptInBackground();

              await otpC.successImage(authC.store.value!.phone.value,
                  path: path);
              Get.back();
            },
            child: const Text('ok', style: TextStyle(color: Colors.white)),
          ),
        ]);

    Get.defaultDialog(
      barrierDismissible: true,
      title: 'Restart Aplikasi',
      middleText: 'Silahkan tutup aplikasi kemudian buka kembali.',
    );
    // Get.offAllNamed(Routes.SPLASH);
  }

  void cancelPayment() async {
    snap.value = '';
    await webviewController.value.stop();
    await cancelMidtransTransaction(await authC.box.get('snap_token'));
    await authC.box.delete('order_id');
    await authC.box.delete('snap_token');
    await authC.box.delete('package');
    stopTimer();
  }

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
}
