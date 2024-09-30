import 'dart:convert';

import 'package:get/get.dart';
import 'package:powersync/sqlite3_common.dart' as sqlite;

import 'invoice_model/cart_model.dart';
import 'sales_model.dart';

class PurchaseOrderModel {
  String? id;
  String? storeId;
  String? orderId;
  late Rx<DateTime?> createdAt;
  late Rx<Cart> purchaseList;
  late Rx<SalesModel?> sales;

  PurchaseOrderModel({
    this.id,
    this.storeId,
    this.orderId,
    DateTime? createdAt,
    required Cart purchaseList,
    SalesModel? sales,
  })  : createdAt = Rx<DateTime?>(createdAt),
        purchaseList = Rx<Cart>(purchaseList),
        sales = Rx<SalesModel?>(sales);

  PurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeId = json['store_id'];
    orderId = json['order_id'];
    createdAt = Rx<DateTime?>(DateTime.parse(json['created_at']).toLocal());

    // Handling purchaseList field
    if (json['purchase_order_list'] is String) {
      print('isString');
      final decodedPurchaseList = jsonDecode(json['purchase_order_list']);
      purchaseList = Rx<Cart>(
        Cart.fromJson(
          decodedPurchaseList is String
              ? jsonDecode(decodedPurchaseList) as Map<String, dynamic>
              : decodedPurchaseList as Map<String, dynamic>,
        ),
      );
    } else if (json['purchase_order_list'] is Map<String, dynamic>) {
      print('is not string');
      purchaseList = Rx<Cart>(Cart.fromJson(json['purchase_order_list']));
    }
    if (json['sales'] != null) {
      final decodedSales =
          json['sales'] is String ? jsonDecode(json['sales']) : json['sales'];
      sales = Rx<SalesModel?>(
        SalesModel.fromJson(
          decodedSales is String
              ? jsonDecode(decodedSales) as Map<String, dynamic>
              : decodedSales as Map<String, dynamic>,
        ),
      );
    }
  }

  PurchaseOrderModel.fromRow(sqlite.Row row)
      : id = row['id'],
        storeId = row['store_id'],
        orderId = row['order_id'],
        createdAt = Rx<DateTime?>(DateTime.parse(row['created_at']).toLocal()),
        purchaseList = Rx<Cart>(Cart.fromJson(row['purchase_order_list'])),
        sales = Rx<SalesModel?>(SalesModel.fromJson(row['sales']));

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['store_id'] = storeId;
    data['order_id'] = orderId;
    data['created_at'] = createdAt.value?.toIso8601String();
    data['purchase_order_list'] = purchaseList.value.toJson();
    data['sales'] = sales.value?.toJson();
    return data;
  }
}
