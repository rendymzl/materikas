import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../../../presentation/global_widget/menu_widget/menu_controller.dart';

import '../../../../presentation/global_widget/otp/otp_controller.dart';
import '../../../navigation/routes.dart';
import '../account_service.dart';
import '../auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MidtransController extends GetxController {
  final AuthService authC = Get.find();
  final OtpController otpC = Get.put(OtpController());
  final AccountService accountSecvice = Get.find();
  final MenuWidgetController menuC = Get.find();
  final String _serverKey = dotenv.env['MIDTRANS_SERVER']!;
  final String _clientKey = dotenv.env['MIDTRANS_CLIENT']!;
  var isLoading = false.obs;
  var paymentStatus = ''.obs;
  // var selectedPackage = 'basic'.obs;
  var snap = ''.obs;
  Timer? timer;
  final webviewController = WebviewController().obs;
  // late final box = Hive.openBox('midtrans').obs;

  final features = {
    'basic': [
      {
        'feature': "Fitur Utama",
        'sub_feature': [
          {"feature": "Membuat Transaksi", "active": true},
          {"feature": "Menambahkan Diskon", "active": true},
          {"feature": "Menyimpan Pelanggan", "active": true},
          {"feature": "Piutang", "active": true},
          {"feature": "Return Barang", "active": true},
          {"feature": "Cetak Struk", "active": true},
          {"feature": "Cetak Surat Jalan", "active": true},
          {"feature": "Harga Jual Bervariasi", "active": true},
          {"feature": "Stok Otomatis", "active": true},
          {"feature": "Menyimpan Sales", "active": true},
          {"feature": "Pembelian Barang dari Sales", "active": true},
          {"feature": "Biaya Operasional", "active": true},
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
          {"feature": "1 Kasir", "active": true},
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
    'premium': [
      {
        'feature': "Fitur Utama",
        'sub_feature': [
          {"feature": "Membuat Transaksi", "active": true},
          {"feature": "Menambahkan Diskon", "active": true},
          {"feature": "Menyimpan Pelanggan", "active": true},
          {"feature": "Piutang", "active": true},
          {"feature": "Return Barang", "active": true},
          {"feature": "Cetak Struk", "active": true},
          {"feature": "Cetak Surat Jalan", "active": true},
          {"feature": "Harga Jual Bervariasi", "active": true},
          {"feature": "Stok Otomatis", "active": true},
          {"feature": "Menyimpan Sales", "active": true},
          {"feature": "Pembelian Barang dari Sales", "active": true},
          {"feature": "Biaya Operasional", "active": true},
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
          {"feature": "3 Kasir", "active": true},
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
        'feature': "Fitur Utama",
        'sub_feature': [
          {"feature": "Membuat Transaksi", "active": true},
          {"feature": "Menambahkan Diskon", "active": true},
          {"feature": "Menyimpan Pelanggan", "active": true},
          {"feature": "Piutang", "active": true},
          {"feature": "Return Barang", "active": true},
          {"feature": "Cetak Struk", "active": true},
          {"feature": "Cetak Surat Jalan", "active": true},
          {"feature": "Harga Jual Bervariasi", "active": true},
          {"feature": "Stok Otomatis", "active": true},
          {"feature": "Menyimpan Sales", "active": true},
          {"feature": "Pembelian Barang dari Sales", "active": true},
          {"feature": "Biaya Operasional", "active": true},
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
          {"feature": "Kasir tanpa batas", "active": true},
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

  final monthlyPrice = {
    'basic': 99000,
    'premium': 199000,
    'full': 2990000,
  };

  final yearlyPrice = {
    'basic': 99000 * 10,
    'premium': 199000 * 10,
    'full': 2990000,
  };

  final oldPrice = {
    'basic': 150000,
    'premium': 299000,
    'full': 3990000,
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
          break;
        case 'cancel':
          paymentStatus.value = 'Pembayaran dibatalkan.';
          break;
        default:
          paymentStatus.value = 'Pilih metode pembayaran.';
      }
    } else {
      paymentStatus.value = 'Gagal memeriksa status pembayaran.';
    }
  }

  // Fungsi untuk memulai pembayaran
  Future<void> initiatePayment(String selectedCard, bool isMonthly) async {
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
          packageName: selectedCard,
          grossAmount: isMonthly
              ? monthlyPrice[selectedCard]!
              : yearlyPrice[selectedCard]!,
          customerName: authC.account.value!.name,
          customerPhone: authC.store.value!.phone.value,
          // customerEmail: 'johndoe@example.com',
        );
        authC.box.put('snap_token', snapToken);
        authC.box.put('order_id', orderId);
        authC.box.put('package', selectedCard.toString());
        startTimer(orderId);
      }
      // URL Snap Midtrans
      final String snapUrl =
          'https://app.midtrans.com/snap/v2/vtweb/$snapToken';

      // final Uri snapUrl =
      //     Uri.parse('https://app.midtrans.com/snap/v2/vtweb/$snapToken');

      await webviewController.value.initialize();
      webviewController.value.url.listen((url) {
        // debugPrint();
        // // Deteksi URL yang digunakan Midtrans untuk redirect status transaksi
        // if (url.contains('transaction_status=settlement')) {
        //   // Transaksi berhasil
        //   paymentController.onTransactionSuccess();
        // } else if (url.contains('transaction_status=pending')) {
        //   // Transaksi pending
        //   paymentController.onTransactionPending();
        // } else if (url.contains('transaction_status=deny') ||
        //     url.contains('transaction_status=cancel') ||
        //     url.contains('transaction_status=expire')) {
        //   // Transaksi gagal atau dibatalkan
        //   paymentController.onTransactionFailed();
        // }
      });

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
      snap.value = 'https://app.midtrans.com/snap/v2/vtweb/$snapToken';
    } catch (e) {
      paymentStatus.value = 'Pembayaran gagal: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onSuccess() async {
    stopTimer();
    String? package = await authC.box.get('package');
    // var updatedAccount = AccountModel.fromJson(authC.account.value!.toJson());
    menuC.expired.value = false;

    authC.account.value!.accountType = package!;
    authC.account.value!.isActive = true;
    if (package == 'basic') {
      if (authC.account.value!.endDate!.isBefore(DateTime.now())) {
        authC.account.value!.startDate = DateTime.now();
        authC.account.value!.endDate =
            DateTime.now().add(const Duration(days: 31));
      } else {
        authC.account.value!.startDate = authC.account.value!.endDate;
        authC.account.value!.endDate =
            authC.account.value!.endDate!.add(const Duration(days: 31));
      }
    } else if (package == 'yearly') {
      if (authC.account.value!.endDate!.isBefore(DateTime.now())) {
        authC.account.value!.startDate = DateTime.now();
        authC.account.value!.endDate =
            DateTime.now().add(const Duration(days: 365));
      } else {
        authC.account.value!.startDate = authC.account.value!.endDate;
        authC.account.value!.endDate =
            authC.account.value!.endDate!.add(const Duration(days: 365));
      }
    } else if (package == 'full') {
      authC.account.value!.endDate = null;
    }

    accountSecvice.update(authC.account.value!);
    await otpC.successMessage(authC.store.value!.phone.value);
    await authC.box.delete('order_id');
    await authC.box.delete('snap_token');
    await authC.box.delete('package');
    Get.offAllNamed(Routes.SPLASH);
  }

  void cancelPayment() async {
    snap.value = '';
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
