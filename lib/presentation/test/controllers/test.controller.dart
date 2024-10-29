import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../infrastructure/dal/database/powersync.dart';
import '../../../infrastructure/models/account_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/models/store_model.dart';

class TestController extends GetxController {
  // final supabaseClient = Supabase.instance.client;
  // late final account = Rx<AccountModel?>(null);
  // late final store = Rx<StoreModel?>(null);
  // late final invoices = <InvoiceModel>[].obs;
  // final lenght = 0.obs;
  // final changeCount = 0.obs;

  // final isLoading = false.obs;

  // @override
  // void onInit() async {
  //   isLoading.value = true;
  //   await getAccount();
  //   await getStore();
  //   final startTime = DateTime.now();
  //   // invoices.value = await getAllInvoices();
  //   await subscribe();
  //   final endTime = DateTime.now();
  //   final duration = endTime.difference(startTime);
  //   print(
  //       'Waktu pengambilan dan perubahan ke model: ${duration.inMilliseconds} ms');
  //   isLoading.value = false;
  //   super.onInit();
  // }

  // Future<AccountModel> getAccount() async {
  //   if (db.currentStatus.connecting == false) {
  //     while (db.currentStatus.lastSyncedAt == null) {
  //       await Future.delayed(const Duration(seconds: 2));
  //       if (db.currentStatus.lastSyncedAt == null) {
  //         debugPrint(
  //             'Mencoba koneksi ulang, ${db.currentStatus.downloadError}');
  //       }
  //     }
  //   }
  //   final row = await db.get('SELECT * FROM accounts WHERE account_id = ?',
  //       [supabaseClient.auth.currentUser!.id]);
  //   account.value = AccountModel.fromRow(row);

  //   return account.value!;
  // }

  // Future<StoreModel> getStore() async {
  //   if (db.currentStatus.connecting == false) {
  //     while (db.currentStatus.lastSyncedAt == null) {
  //       await Future.delayed(const Duration(seconds: 2));
  //       if (db.currentStatus.lastSyncedAt == null) {
  //         debugPrint(
  //             'Mencoba koneksi ulang, ${db.currentStatus.downloadError}');
  //       }
  //     }
  //   }
  //   final row = await db.get('SELECT * FROM stores WHERE owner_id = ?',
  //       [supabaseClient.auth.currentUser!.id]);
  //   store.value = StoreModel.fromRow(row);

  //   return store.value!;
  // }

  // late Stream<List<Map<String, dynamic>>> invoiceJson;

  // Future<void> subscribe() async {
  //   final startTime = DateTime.now();
  //   invoiceJson = db.watch('''
  //     SELECT *
  //     FROM invoices
  //     WHERE remove_at IS NULL AND is_debt_paid = 1
  //     ORDER BY created_at DESC
  //     ''').map((data) => data.toList());

  //   invoiceJson.listen((datas) async {
  //     final endTime = DateTime.now();
  //     await getAllInvoices();
  //     final duration = endTime.difference(startTime);
  //     print('Waktu pengambilan data: ${duration.inMilliseconds} ms');
  //   });
  // }

  // Future<List<InvoiceModel>> getAllInvoices() async {
  //   final startTime = DateTime.now();
  //   List<Map<String, dynamic>> results =
  //       await db.getAll('SELECT * FROM invoices limit 200');
  //   final endTime = DateTime.now();
  //   lenght.value = results.length;
  //   final duration = endTime.difference(startTime);
  //   print('Waktu pengambilan 200 invoice: ${duration.inMilliseconds} ms');
  //   return results.map((e) => InvoiceModel.fromJson(e)).toList();
  // }
}
