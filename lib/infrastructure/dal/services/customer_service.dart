import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/core/interfaces/customer_repository.dart';
import '../../models/customer_model.dart';
import '../database/powersync.dart';

Future<List<CustomerModel>> convertToModel(
    List<Map<String, dynamic>> maps) async {
  return maps.map((e) => CustomerModel.fromJson(e)).toList();
}

class CustomerService extends GetxService implements CustomerRepository {
  late final customers = <CustomerModel>[].obs;
  late final foundCustomers = <CustomerModel>[].obs;
  late final lastCustomersId = 'CST0'.obs;

  // @override
  // void onInit() async {
  //   super.onInit();
  // }

  void search(String searchValue) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (searchValue.isEmpty) {
        List<CustomerModel> customersList = [];
        customersList.addAll(customers);
        customersList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
        List<CustomerModel> subList = customersList.take(200).toList()
          ..sort((a, b) => b.name.compareTo(a.name));
        foundCustomers.clear();
        foundCustomers.addAll(subList);
        customersList.sort((a, b) {
          int aNumber = int.parse(a.customerId!.substring(3));
          int bNumber = int.parse(b.customerId!.substring(3));
          return aNumber.compareTo(bNumber);
        });
        lastCustomersId.value =
            customersList.isEmpty ? 'CST0' : customersList.last.customerId!;
      } else {
        foundCustomers.value = customers
            .where((customer) =>
                customer.name.toLowerCase().contains(searchValue.toLowerCase()))
            .toList()
          ..sort((a, b) => b.name.compareTo(a.name));
      }
    });
  }

  @override
  Future<void> subscribe() async {
    try {
      var stream =
          db.watch('SELECT * FROM customers').map((data) => data.toList());

      stream.listen((update) async {
        customers.assignAll(await compute(convertToModel, update));
        search('');
      });
    } on PostgrestException catch (e) {
      debugPrint(e.message);
      rethrow;
    }
  }

  @override
  Future<void> insert(CustomerModel customer) async {
    await db.execute(
      '''
    INSERT INTO customers(
      id, customer_id, created_at, name, phone, address, note_address, store_id, deposit
    ) VALUES(uuid(), ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        customer.customerId,
        customer.createdAt?.toIso8601String(),
        customer.name,
        customer.phone,
        customer.address,
        customer.noteAddress,
        customer.storeId,
        customer.deposit,
      ],
    );
  }

  @override
  Future<void> update(CustomerModel customer) async {
    print('deposit inserted ${customer.deposit}');
    await db.execute(
      '''
    UPDATE customers SET
      customer_id = ?, 
      created_at = ?, 
      name = ?, 
      phone = ?, 
      address = ?, 
      note_address = ?, 
      store_id = ?,
      deposit = ?
    WHERE id = ?
    ''',
      [
        customer.customerId,
        customer.createdAt?.toIso8601String(),
        customer.name,
        customer.phone,
        customer.address,
        customer.noteAddress,
        customer.storeId,
        customer.deposit,
        customer.id,
      ],
    );
  }

  @override
  Future<void> delete(String id) async {
    await db.execute(
      'DELETE FROM customers WHERE id = ?',
      [id],
    );
  }
}
