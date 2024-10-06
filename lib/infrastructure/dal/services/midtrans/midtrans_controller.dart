import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MidtransController extends GetxController {
  final String _serverKey = '';
  final String _clientKey = '';
  var isLoading = false.obs;
  var paymentStatus = ''.obs;
  Timer? timer;

  // Fungsi untuk mendapatkan Snap Token dari Midtrans
  Future<String> getMidtransSnapToken({
    required String orderId,
    required double grossAmount,
    required String customerName,
    required String customerEmail,
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
        "email": customerEmail,
      },
      "enabled_payments": ["credit_card", "gopay", "bank_transfer"],
    });

    final response = await http.post(
      Uri.parse(midtransUrl),
      headers: headers,
      body: body,
    );

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
          stopTimer();
          print('selamat berhasil');
          break;
        case 'pending':
          paymentStatus.value = 'Pembayaran sedang menunggu konfirmasi.';
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
  Future<void> initiatePayment() async {
    isLoading.value = true;
    var box = await Hive.openBox('midtrans');
    var orderId = box.get('order_id');
    var snapToken = box.get('snap_token');
    try {
      if (!(orderId?.isNotEmpty ?? false)) {
        orderId = 'order-id-${DateTime.now().millisecondsSinceEpoch}';
        // Mengambil Snap Token
        snapToken = await getMidtransSnapToken(
          orderId: orderId,
          grossAmount: 3999000,
          customerName: 'John Doe',
          customerEmail: 'johndoe@example.com',
        );

        box.put('snap_token', snapToken);
        box.put('order_id', orderId);
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

  Future<void> goToPaymentUrl() async {}

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
