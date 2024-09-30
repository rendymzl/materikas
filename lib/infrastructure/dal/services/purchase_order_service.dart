import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/core/interfaces/purchase_order_repository.dart';
import '../../models/purchase_order_model.dart';
import '../database/powersync.dart';

class PurchaseOrderService extends GetxService
    implements PurchaseOrderRepository {
  var purchaseOrder = <PurchaseOrderModel>[].obs;
  var foundPurchaseOrder = <PurchaseOrderModel>[].obs;

  List<PurchaseOrderModel> sortByDate(
      List<PurchaseOrderModel> operatingCostList) {
    operatingCostList
        .sort((a, b) => b.createdAt.value!.compareTo(a.createdAt.value!));
    return operatingCostList;
  }

  @override
  Future<void> subscribe(String storeId) async {
    try {
      var stream = db.watch('SELECT * FROM purchase_orders WHERE store_id = ?',
          parameters: [
            storeId
          ]).map((data) =>
          data.map((json) => PurchaseOrderModel.fromJson(json)).toList());

      stream.listen((update) {
        purchaseOrder.assignAll(update);
        foundPurchaseOrder.assignAll(update);
        sortByDate(foundPurchaseOrder);
      });
    } on PostgrestException catch (e) {
      print(e.message);
      rethrow;
    }
  }

  @override
  Future<void> insert(PurchaseOrderModel purchaseOrder) async {
    await db.execute(
      '''
    INSERT INTO purchase_orders(
      id, store_id, order_id, created_at, purchase_order_list, sales
    ) VALUES(uuid(), ?, ?, ?, ?, ?)
    ''',
      [
        purchaseOrder.storeId,
        purchaseOrder.orderId,
        purchaseOrder.createdAt.value?.toIso8601String(),
        purchaseOrder.purchaseList.value.toJson(),
        purchaseOrder.sales.value,
      ],
    );
  }

  @override
  Future<void> update(PurchaseOrderModel updatedPurchaseOrder) async {
    await db.execute(
      '''
    UPDATE purchase_orders SET
      store_id = ?, 
      order_id = ?, 
      created_at = ?, 
      purchase_order_list = ?, 
      sales = ?, 
    WHERE id = ?
    ''',
      [
        updatedPurchaseOrder.storeId,
        updatedPurchaseOrder.orderId,
        updatedPurchaseOrder.createdAt.value?.toIso8601String(),
        updatedPurchaseOrder.purchaseList.value.toJson(),
        updatedPurchaseOrder.sales.value,
        updatedPurchaseOrder.id,
      ],
    );
  }

  @override
  Future<void> delete(String id) async {
    await db.execute(
      '''
    DELETE FROM purchase_orders WHERE id = ?
    ''',
      [id],
    );
  }
}
