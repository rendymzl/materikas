import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/core/interfaces/sales_repository.dart';
import '../../models/sales_model.dart';
import '../database/powersync.dart';

class SalesService extends GetxService implements SalesRepository {
  final sales = <SalesModel>[].obs;
  final foundSales = <SalesModel>[].obs;
  final lastSalesId = 'SL0'.obs;

  @override
  void onInit() {
    super.onInit();
  }

  void search(String salesName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (salesName.isEmpty) {
        List<SalesModel> salesList = [];
        salesList.addAll(sales);
        salesList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
        List<SalesModel> subList = salesList.take(50).toList();
        foundSales.clear();
        foundSales.addAll(subList);
        List<SalesModel> salesSubstringList = [];
        salesSubstringList.addAll(sales);
        salesSubstringList.sort((a, b) {
          int aNumber = int.parse(a.salesId!.substring(2));
          int bNumber = int.parse(b.salesId!.substring(2));
          return aNumber.compareTo(bNumber);
        });
        lastSalesId.value = salesList.isEmpty ? 'SL0' : salesList.last.salesId!;
      } else {
        foundSales.value = sales.where((sales) {
          return sales.name!.toLowerCase().contains(salesName.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Future<void> subscribe(String storeId) async {
    try {
      var stream = db
          .watch('SELECT * FROM sales WHERE store_id = ?', parameters: [
        storeId
      ]).map((data) => data.map((json) => SalesModel.fromJson(json)).toList());

      stream.listen((update) {
        sales.assignAll(update);
        search('');
        print('sales.length from service ${foundSales.length}');
      });
    } on PostgrestException catch (e) {
      print(e.message);
      rethrow;
    }
  }

  @override
  Future<void> insert(SalesModel sales) async {
    await db.execute(
      '''
    INSERT INTO sales(
      id, sales_id, created_at, name, phone, address, store_id
    ) VALUES(uuid(), ?, ?, ?, ?, ?, ?)
    ''',
      [
        sales.salesId,
        sales.createdAt?.toIso8601String(),
        sales.name,
        sales.phone,
        sales.address,
        sales.storeId,
      ],
    );
  }

  @override
  Future<void> update(SalesModel sales) async {
    await db.execute(
      '''
    UPDATE sales SET
      sales_id = ?, 
      created_at = ?, 
      name = ?, 
      phone = ?, 
      address = ?, 
      store_id = ?
    WHERE id = ?
    ''',
      [
        sales.salesId,
        sales.createdAt?.toIso8601String(),
        sales.name,
        sales.phone,
        sales.address,
        sales.storeId,
        sales.id,
      ],
    );
  }

  @override
  Future<void> delete(String id) async {
    await db.execute(
      'DELETE FROM sales WHERE id = ?',
      [id],
    );
  }
}
