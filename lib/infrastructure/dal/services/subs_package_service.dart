// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import '../../../domain/core/interfaces/customer_repository.dart';
// import '../../models/customer_model.dart';
// import '../../models/invoice_model/subs_package_model.dart';
// import '../database/powersync.dart';

// Future<List<CustomerModel>> convertToModel(
//     List<Map<String, dynamic>> maps) async {
//   return maps.map((e) => CustomerModel.fromJson(e)).toList();
// }

// class SubsPackageService extends GetxService {
//   final supabaseClient = Supabase.instance.client;
//   // Future<void> subscribe() async {
//   //   try {
//   //     var stream =
//   //         db.watch('SELECT * FROM customers').map((data) => data.toList());

//   //     stream.listen((update) async {
//   //       customers.assignAll(await compute(convertToModel, update));
//   //       search('');
//   //     });
//   //   } on PostgrestException catch (e) {
//   //     debugPrint(e.message);
//   //     rethrow;
//   //   }
//   // }

//   Future<void> get() async {
//     try {
//       final row = await db.get('SELECT * FROM accounts WHERE account_id = ?',
//           [supabaseClient.auth.currentUser!.id]);
//      var account = SubscriptionPackage.fromMap(row);
//     } catch (e) {
//       retryCount++;
//       if (retryCount < maxRetries) {
//         await Future.delayed(retryDelay);
//       } else {
//         print('retryCount ${retryCount}');
//         // Handle the error appropriately, e.g., throw an exception or return a default value.
//         throw Exception(
//             'Gagal mengambil data akun setelah beberapa kali percobaan: $e');
//       }
//     }
//   }

//   Future<void> insert(CustomerModel customer) async {
//     await db.execute(
//       '''
//     INSERT INTO customers(
//       id, customer_id, created_at, name, phone, address, note_address, store_id, deposit
//     ) VALUES(uuid(), ?, ?, ?, ?, ?, ?, ?, ?)
//     ''',
//       [
//         customer.customerId,
//         customer.createdAt?.toIso8601String(),
//         customer.name,
//         customer.phone,
//         customer.address,
//         customer.noteAddress,
//         customer.storeId,
//         customer.deposit,
//       ],
//     );
//   }

//   Future<void> update(CustomerModel customer) async {
//     print('deposit inserted ${customer.deposit}');
//     await db.execute(
//       '''
//     UPDATE customers SET
//       customer_id = ?, 
//       created_at = ?, 
//       name = ?, 
//       phone = ?, 
//       address = ?, 
//       note_address = ?, 
//       store_id = ?,
//       deposit = ?
//     WHERE id = ?
//     ''',
//       [
//         customer.customerId,
//         customer.createdAt?.toIso8601String(),
//         customer.name,
//         customer.phone,
//         customer.address,
//         customer.noteAddress,
//         customer.storeId,
//         customer.deposit,
//         customer.id,
//       ],
//     );
//   }

//   Future<void> delete(String id) async {
//     await db.execute(
//       'DELETE FROM customers WHERE id = ?',
//       [id],
//     );
//   }
// }
