// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:materikas/infrastructure/dal/services/invoice_sales_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/core/interfaces/sales_repository.dart';
// import '../../models/invoice_sales_model.dart';
import '../../models/sales_model.dart';
import '../database/powersync.dart';

Future<List<SalesModel>> convertToModel(List<Map<String, dynamic>> maps) async {
  return maps.map((e) => SalesModel.fromJson(e)).toList();
}

class SalesService extends GetxService implements SalesRepository {
  // final InvoiceSalesService _invoiceSalesService =
  //     Get.put(InvoiceSalesService());

  final sales = <SalesModel>[].obs;
  final foundSales = <SalesModel>[].obs;
  final lastSalesId = 'SL0'.obs;

  // @override
  // void onInit() {
  //   super.onInit();
  // }

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
          print('salesSubstringList ${a.toJson()}');
          int aNumber = 0;
          int bNumber = 0;
          
          if (a.salesId != null && a.salesId!.startsWith('SL')) {
            aNumber = int.parse(a.salesId!.substring(2));
          }
          
          if (b.salesId != null && b.salesId!.startsWith('SL')) {
            bNumber = int.parse(b.salesId!.substring(2));
          }
          
          return aNumber.compareTo(bNumber);
        });
        
        String lastId = 'SL0';
        if (salesSubstringList.isNotEmpty) {
          var lastSales = salesSubstringList.lastWhere(
            (sales) => sales.salesId != null && sales.salesId!.startsWith('SL'),
            orElse: () => SalesModel(salesId: 'SL0')
          );
          lastId = lastSales.salesId!;
        }
        lastSalesId.value = lastId;
      } else {
        foundSales.value = sales.where((sales) {
          return sales.name!.toLowerCase().contains(salesName.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Future<void> subscribe() async {
    try {
      var stream = db
          .watch('SELECT * FROM sales')
          .map((data) => data.map((e) => SalesModel.fromJson(e)).toList());

      stream.listen((update) async {
        sales.assignAll(update);


        // sales.map((sl) async {
        //   List<InvoiceSalesModel> salesInvoices =
        //       await _invoiceSalesService.fetchBySalesId(sl.id ?? '');
        //   await sl.getTotalDebt(salesInvoices);
        // });
        //         foundSales.assignAll(sales);
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
