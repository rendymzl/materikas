import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../presentation/global_widget/menu_widget/menu_controller.dart';
import '../../../models/account_model.dart';
import '../../../navigation/routes.dart';
import '../account_service.dart';
import '../auth_service.dart';

class MidtransController extends GetxController {
  final AuthService authC = Get.find();
  final AccountService accountSecvice = Get.find();
  final MenuWidgetController menuC = Get.find();
  final String _serverKey = 'SB-Mid-server-MYOdrOQCgmToNnPJVWHdjH6C';
  final String _clientKey = 'SB-Mid-client-GdsheqK_dzgfTgeN';
  var isLoading = false.obs;
  var paymentStatus = ''.obs;
  var selectedPackage = 'monthly'.obs;
  Timer? timer;
  // late final box = Hive.openBox('midtrans').obs;

  final packages = {
    'monthly': 99000,
    'yearly': 990000,
    'full': 2990000,
  };

  // Fungsi untuk mendapatkan Snap Token dari Midtrans
  Future<String> getMidtransSnapToken({
    required String orderId,
    required int grossAmount,
    required String customerName,
    // required String customerEmail,
  }) async {
    const String midtransUrl =
        'https://app.sandbox.midtrans.com/snap/v1/transactions';

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
        // "email": customerEmail,
      },
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
    final String midtransUrl =
        'https://api.sandbox.midtrans.com/v2/$orderId/status';

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
          print('selamat berhasil');
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
          paymentStatus.value = 'Menunggu pembayaran.';
      }
    } else {
      paymentStatus.value = 'Gagal memeriksa status pembayaran.';
    }
  }

  // Fungsi untuk memulai pembayaran
  Future<void> initiatePayment(String selectedCard) async {
    isLoading.value = true;
    selectedPackage.value = selectedCard;

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
          grossAmount: packages[selectedCard]!,
          customerName: authC.account.value!.name,
          // customerEmail: 'johndoe@example.com',
        );
        authC.box.put('snap_token', snapToken);
        authC.box.put('order_id', orderId);
        authC.box.put('package', selectedCard.toString());
      }
      // URL Snap Midtrans
      final Uri snapUrl = Uri.parse(
          'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken');

      // Membuka URL di browser
      if (await canLaunchUrl(snapUrl)) {
        await launchUrl(snapUrl);
        startTimer(orderId);
      } else {
        throw 'Could not launch $snapUrl';
      }
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
    if (package == 'monthly') {
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
    await authC.box.delete('order_id');
    await authC.box.delete('snap_token');
    await authC.box.delete('package');
    Get.offAllNamed(Routes.SPLASH);
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
