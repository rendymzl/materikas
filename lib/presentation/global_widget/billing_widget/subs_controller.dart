import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:powersync/powersync.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../infrastructure/dal/services/account_service.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/internet_service.dart';
import '../../../infrastructure/models/invoice_model/subs_package_model.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../../infrastructure/utils/hive_boxex.dart';
import '../popup_page_widget.dart';
import 'restart_app_page.dart';
import 'success_popup.dart';

class SubsController extends GetxController {
  final AuthService authC = Get.find();

  final showPopupSubs = false.obs;

  final page = 'select'.obs;
  final isLoading = false.obs;
  // final isSendLoading = false.obs;
  final loadingPercentage = 0.obs;
  late WebViewController webViewC;

  Rx<SubscriptionPackage?> selectedPackage = Rx<SubscriptionPackage?>(null);
  final packages = <SubscriptionPackage>[].obs;
  // final List<SubscriptionPackage> packages = [
  //   // SubscriptionPackage(
  //   //     name: "tes 1 Bulan",
  //   //     durationInMonths: 1,
  //   //     price: 500,
  //   //     priceBeforeDiscount: 500,
  //   //     note: 'Tes'),
  //   SubscriptionPackage(
  //       name: "1 Bulan",
  //       durationInMonths: 1,
  //       price: 149000,
  //       priceBeforeDiscount: 149000,
  //       note: ''),
  //   SubscriptionPackage(
  //       name: "3 Bulan",
  //       durationInMonths: 3,
  //       price: 297000,
  //       priceBeforeDiscount: 447000,
  //       note: 'Biaya perbulan hanya Rp.99.000!'),
  //   SubscriptionPackage(
  //       name: "12 Bulan",
  //       durationInMonths: 12,
  //       price: 990000,
  //       priceBeforeDiscount: 1782000,
  //       note: 'Bayar 10 Bulan, dapat 12 Bulan!'),
  // ];


  var paymentDone = false.obs;
  var orderId = ''.obs;
  var snapUrl = ''.obs;
  var selectedPackageName = ''.obs;
  var paymentStatus = ''.obs;

  Future<List<SubscriptionPackage>> getPackages() async {
    try {
      final response =
          await Supabase.instance.client.from('subscription_packages').select();

      // if (response.hasError) {
      //   throw response.error!;
      // }

      final List<Map<String, dynamic>> data = response;
      return data.map((e) => SubscriptionPackage.fromMap(e)).toList();
    } catch (e) {
      // Handle error appropriately, e.g., log the error or display an error message.
      print('Error fetching subscription packages: $e');
      rethrow; // Re-throw the error to be handled by the calling function.
    }
  }

  void init() async {
    isLoading(true);
    snapUrl.value = '';
    orderId.value = '';
    if (Get.find<InternetService>().isConnected.value) {
      packages.value = await getPackages();
    }
    selectedPackage.value = null;
    page('select');
    orderId.value = await HiveBox.getMidtrans('order_id');
    snapUrl.value = await HiveBox.getMidtrans('snap_url');
    selectedPackageName.value = await HiveBox.getMidtrans('package');

    print('alalalalalalalal ${selectedPackageName.value}');

    selectedPackage.value = packages.firstWhereOrNull(
        (package) => package.name == selectedPackageName.value);

    print('orderId ${orderId.value}');
    if (orderId.value.isNotEmpty) {
      startTimer(orderId.value);
      await Future.delayed(const Duration(seconds: 1));
      page('payment');
    }

    print('alalalalalalalal ${snapUrl.value}');
    print('alalalalalalalal ${orderId.value}');

    isLoading(false);
    ever(Get.find<InternetService>().isConnected, (_) async {
      if (Get.find<InternetService>().isConnected.value) {
        packages.value = await getPackages();
      }
    });
  }

  void selectPackage(SubscriptionPackage package) {
    selectedPackage.value = package;
  }

  void goToPaymentPage() async {
    isLoading(true);
    orderId.value = 'notEmpty';
    await createPayment();
    page('payment');
    await Future.delayed(const Duration(seconds: 1));
    isLoading(false);
  }

  final String _serverKey = dotenv.env['MIDTRANS_SERVER']!;
  final String _clientKey = dotenv.env['MIDTRANS_CLIENT']!;

  Future<void> createPayment() async {
    try {
      orderId.value = 'order-id-${DateTime.now().millisecondsSinceEpoch}';
      // Mengambil Snap Token
      var snapToken = await getMidtransSnapToken(
        orderId: orderId.value,
        packageName: selectedPackage.value!.name,
        grossAmount: selectedPackage.value!.price.toInt(),
        customerName: authC.account.value!.name,
        customerPhone: authC.store.value!.phone.value,
        // customerEmail: 'johndoe@example.com',
      );
      snapUrl.value = 'https://app.midtrans.com/snap/v2/vtweb/$snapToken';
      await HiveBox.saveMidtrans('order_id', orderId.value);
      await HiveBox.saveMidtrans('snap_url', snapUrl.value);
      await HiveBox.saveMidtrans('package', selectedPackage.value!.name);

      startTimer(orderId.value);
    } catch (e) {
      paymentStatus.value = 'Pembayaran gagal: $e';
    }
  }

  Future<String> getMidtransSnapToken(
      {required String orderId,
      required int grossAmount,
      required String packageName,
      required String customerName,
      required String customerPhone}) async {
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

  Future<void> checkPaymentStatus(String orderId) async {
    final String midtransUrl = 'https://api.midtrans.com/v2/$orderId/status';
    print('alalalalalalalal checkPaymentStatus  $midtransUrl');
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

  Future<void> cancelPayment() async {
    print('membatalkan pembayaran...');
    orderId.value = await HiveBox.getMidtrans('order_id');
    if (orderId.value.isNotEmpty) {
      await cancelMidtransTransaction(orderId.value);
    }
    await HiveBox.deleteMidtrans('order_id');
    await HiveBox.deleteMidtrans('snap_url');
    await HiveBox.deleteMidtrans('package');

    stopTimer();
    orderId.value = '';
    snapUrl.value = '';
    page('select');
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

  JavascriptChannel blobDataChannel() {
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
        document.body.style.zoom = '0.5';"
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

  Future<void> onSuccess() async {
    final AccountService accountSecvice = Get.find();
    print('success bossss ');
    // isLoading.value = true;
    stopTimer();
    stopTimer();
    stopTimer();

    DateTime endDatePrev = authC.account.value!.endDate!.isAfter(DateTime.now())
        ? authC.account.value!.endDate!
        : DateTime.now();

    DateTime endDate = DateTime(
        endDatePrev.year +
            ((endDatePrev.month + selectedPackage.value!.durationInMonths) > 12
                ? 1
                : 0),
        (endDatePrev.month + selectedPackage.value!.durationInMonths) % 12 == 0
            ? 12
            : (endDatePrev.month + selectedPackage.value!.durationInMonths) %
                12,
        endDatePrev.day);

    print('endDatePrev ${endDatePrev}');
    print('endDate ${endDate}');

    authC.account.value!.accountType = 'subscription';
    authC.account.value!.isActive = true;
    authC.account.value!.startDate = DateTime.now();
    authC.account.value!.endDate = endDate;

    await accountSecvice.update(authC.account.value!);

    await successPopup();

    final subscriptionPayment = {
      'id': uuid.v4(),
      'order_id': orderId.value,
      'package_name': selectedPackage.value!.name,
      'owner_id': authC.account.value!.accountId,
      'amount': selectedPackage.value!.price.toInt(),
      'affiliate_commission': (selectedPackage.value!.price * 0.20).toInt(),
      'affiliate_id': authC.account.value!.affiliateId,
      'created_at': DateTime.now().toIso8601String(),
      'affiliate_paid': false,
      'account_name': authC.account.value!.name,
    };

    await Supabase.instance.client
        .from('subscription_payments')
        .insert([subscriptionPayment]);

    orderId.value = '';
    snapUrl.value = '';
    page('select');

    await HiveBox.deleteMidtrans('order_id');
    await HiveBox.deleteMidtrans('snap_url');
    await HiveBox.deleteMidtrans('package');

    await Get.find<InternetService>().onClose();
    Get.offAllNamed(Routes.SPLASH);

    // await restartAppPage();
    // Get.offAllNamed(Routes.SPLASH);
  }
}
