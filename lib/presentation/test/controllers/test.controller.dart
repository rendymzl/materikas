import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:materikas/infrastructure/models/payment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../infrastructure/dal/database/powersync.dart';
import '../../../infrastructure/models/account_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/models/store_model.dart';

class TestController extends GetxController {
  final supabaseClient = Supabase.instance.client;
  late final account = Rx<AccountModel?>(null);
  late final store = Rx<StoreModel?>(null);
  // late final paidInvResult = <InvoiceModel>[].obs;
  late final payments = <PaymentMapModel>[].obs;
  // late final payTransfer = <PaymentMapModel>[].obs;
  // late final payDebtCash = <PaymentMapModel>[].obs;
  // late final payDebtTransfer = <PaymentMapModel>[].obs;
  late final cash = 0.0.obs;
  late final transfer = 0.0.obs;
  late final debtCash = 0.0.obs;
  late final debtTransfer = 0.0.obs;

  final isLoading = false.obs;

  @override
  void onInit() async {
    isLoading.value = true;
    await getAccount();
    await getStore();
    // paidInvResult.assignAll(await searchInv('', true));
    Stopwatch stopwatch = Stopwatch()..start();
    var datePicker =
        PickerDateRange(DateTime.now(), DateTime.now().add(Duration(days: 1)));
    payments.assignAll(await getPayment('', datePicker));
    print(payments.length);
    for (var payment in payments) {
      double rcash = 0;
      double rtransfer = 0;
      double rdebtCash = 0;
      double rdebtTransfer = 0;
      for (var pay in payment.payments) {
        DateTime paymentDate =
            DateTime(pay.date!.year, pay.date!.month, pay.date!.day);
        DateTime createdDate = DateTime(payment.createdAt.value!.year,
            payment.createdAt.value!.month, payment.createdAt.value!.day);
        if (paymentDate.isAtSameMomentAs(createdDate)) {
          if (pay.method == 'cash') {
            rcash = pay.finalAmountPaid;
          } else {
            rtransfer = pay.finalAmountPaid;
          }
        } else if (pay.method == 'cash') {
          rdebtCash = pay.finalAmountPaid;
        } else {
          rdebtTransfer = pay.finalAmountPaid;
        }
      }

      cash.value += rcash;
      transfer.value += rtransfer;
      debtCash.value += rdebtCash;
      debtTransfer.value += rdebtTransfer;
    }
    // payments.assignAll(await searchPayment(''));
    stopwatch.stop();
    print('Execution Time: ${stopwatch.elapsedMilliseconds} ms');
    isLoading.value = false;
    super.onInit();
  }

  Future<AccountModel> getAccount() async {
    if (db.currentStatus.connecting == false) {
      while (db.currentStatus.lastSyncedAt == null) {
        await Future.delayed(const Duration(seconds: 2));
        if (db.currentStatus.lastSyncedAt == null) {
          debugPrint(
              'Mencoba koneksi ulang, ${db.currentStatus.downloadError}');
        }
      }
    }
    final row = await db.get('SELECT * FROM accounts WHERE account_id = ?',
        [supabaseClient.auth.currentUser!.id]);
    account.value = AccountModel.fromRow(row);

    return account.value!;
  }

  Future<StoreModel> getStore() async {
    if (db.currentStatus.connecting == false) {
      while (db.currentStatus.lastSyncedAt == null) {
        await Future.delayed(const Duration(seconds: 2));
        if (db.currentStatus.lastSyncedAt == null) {
          debugPrint(
              'Mencoba koneksi ulang, ${db.currentStatus.downloadError}');
        }
      }
    }
    final row = await db.get('SELECT * FROM stores WHERE owner_id = ?',
        [supabaseClient.auth.currentUser!.id]);
    store.value = StoreModel.fromRow(row);

    return store.value!;
  }

  // void searchInvoice(String value) async {
  //   // await getPayment(value);
  //   payments.assignAll();
  //   totalPayment.value = 0;
  //   for (var payment in payments) {
  //     double totalAmountPaid = 0;
  //     for (var pay in payment.payments) {
  //       totalAmountPaid += pay.amountPaid;
  //     }
  //     totalPayment.value += totalAmountPaid;
  //   }
  // }

  // Future<List<InvoiceModel>> searchInv(String searchTerm, bool paid) async {
  //   if (searchTerm.isEmpty) {
  //     List<Map<String, dynamic>> results =
  //         await db.getAll('SELECT * FROM invoices');
  //     return results.map((e) => InvoiceModel.fromJson(e)).toList();
  //   } else {
  //     String query = '''
  //       SELECT * FROM invoices WHERE
  //       (customer LIKE ? OR
  //       invoice_id LIKE ?) AND
  //       is_debt_paid = ?
  //       AND remove_at IS NULL
  //       ''';
  //     List<Map<String, dynamic>> results = await db.getAll(query, [
  //       '%${searchTerm.toLowerCase()}%',
  //       '%${searchTerm.toLowerCase()}%',
  //       paid,
  //     ]);
  //     return results.map((e) => InvoiceModel.fromJson(e)).toList();
  //   }
  // }

  Future<List<PaymentMapModel>> getPayment(
      String searchTerm, PickerDateRange pickerDateRange) async {
    // Stopwatch stopwatch = Stopwatch()..start();
    String query = searchTerm.isEmpty
        ? 'SELECT id, created_at, payments FROM invoices WHERE remove_at IS NULL AND created_at BETWEEN ? AND ?'
        : '''
        SELECT id, created_at, payments FROM invoices WHERE
        remove_at IS NULL AND created_at BETWEEN ? AND ? AND payments LIKE ?
        ''';
    List<Map<String, dynamic>> results = searchTerm.isEmpty
        ? await db.getAll(query, [
            DateFormat('yyyy-MM-dd').format(pickerDateRange.startDate!),
            DateFormat('yyyy-MM-dd').format(pickerDateRange.endDate!),
          ])
        : await db.getAll(query, [
            DateFormat('yyyy-MM-dd').format(pickerDateRange.startDate!),
            DateFormat('yyyy-MM-dd').format(pickerDateRange.endDate!),
            '%${searchTerm.toLowerCase()}%'
          ]);

    // stopwatch.stop();
    // print('Execution Time: ${stopwatch.elapsedMilliseconds} ms');
    return results.map((e) => PaymentMapModel.fromJson(e)).toList();
  }

  // Future<List<PaymentMapModel>> getPayment() async {
  //   List<Map<String, dynamic>> results =
  //       await db.getAll('SELECT * FROM invoices');
  //   return results.map((e) => PaymentMapModel.fromJson(e)).toList();
  // }

  // Future<List<PaymentMapModel>> search() async {
  //   List<Map<String, dynamic>> results =
  //       await db.getAll('SELECT * FROM invoices');
  //   return results.map((e) => PaymentMapModel.fromJson(e)).toList();
  // }
}
