import 'dart:convert';

import 'package:get/get.dart';
import 'package:powersync/sqlite3_common.dart' as sqlite;

import '../../domain/core/entities/product.dart';
import '../dal/database/powersync.dart';
// import '../dal/services/product_service.dart';
import '../utils/display_format.dart';
import 'log_stock_model.dart';

class ProductModel extends Product {
  ProductModel({
    super.id,
    required super.storeId,
    required super.productId,
    super.createdAt,
    super.barcode,
    super.imageUrl,
    super.featured,
    required super.productName,
    required super.unit,
    required super.costPrice,
    required super.sellPrice1,
    super.sellPrice2,
    super.sellPrice3,
    required super.stock,
    super.logStock,
    required super.stockMin,
    super.sold,
    super.lastUpdated,
    super.currentStock,
    super.lastSold,
    super.category,
    super.attributes,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    print('DEBUGDATA ${json['product_id']}');
    print('DEBUGDATA ===');
    print('DEBUGDATA ls_created_at ${json['ls_created_at']}');
    print('DEBUGDATA last_updated ${json['last_updated']}');
    // print('last sold parse ${DateTime.parse(json['last_sold'])}');
    var logStockData = <LogStock>[].obs;
    if (json['log_stock'] != null) {
      // Check if payments is a JSON string
      final dynamic data = json['log_stock'] is String
          ? jsonDecode(json['log_stock'])
          : json['log_stock'];

      // Ensure paymentData is a list
      if (data is List) {
        logStockData = RxList<LogStock>(
          data
              .map((i) => LogStock.fromJson(i as Map<String, dynamic>))
              .toList(),
        );
      } else {
        // Handle the case where paymentData is not a list
        logStockData = RxList<LogStock>(
          (jsonDecode(data) as List)
              .map((i) => LogStock.fromJson(i as Map<String, dynamic>))
              .toList(),
        );
        // payments = RxList<PaymentModel>();
      }
    } else {
      logStockData = RxList<LogStock>([]);
    }

    return ProductModel(
      id: json['id'],
      storeId: json['store_id'],
      productId: json['product_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : null,
      barcode: json['barcode'],
      imageUrl:
          json['image_url'] != null ? (json['image_url'] as String).obs : null,
      featured: json['featured'] != null ? json['featured'] == 1 : null,
      productName: json['product_name'],
      unit: json['unit'],
      costPrice: ((json['cost_price'] is int
              ? json['cost_price'].toDouble()
              : json['cost_price']) as double)
          .obs,
      sellPrice1: ((json['sell_price1'] is int
              ? json['sell_price1'].toDouble()
              : json['sell_price1']) as double)
          .obs,
      sellPrice2: json['sell_price2'] != null
          ? ((json['sell_price2'] is int
                  ? json['sell_price2'].toDouble()
                  : json['sell_price2']) as double)
              .obs
          : RxDouble(0),
      sellPrice3: json['sell_price3'] != null
          ? ((json['sell_price3'] is int
                  ? json['sell_price3'].toDouble()
                  : json['sell_price3']) as double)
              .obs
          : RxDouble(0),
      stock: ((json['stock'] is int ? json['stock'].toDouble() : json['stock'])
              as double)
          .obs,
      logStock: logStockData,
      stockMin: json['stock_min'] != null
          ? RxDouble((json['stock_min'] is int
              ? json['stock_min'].toDouble()
              : json['stock_min']) as double)
          : RxDouble(10),
      sold: json['sold'] != null
          ? RxDouble((json['sold'] is int
              ? json['sold'].toDouble()
              : json['sold']) as double)
          : RxDouble(0),
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated']).toLocal()
          : null,
      currentStock: json['current_stock'] != null
          ? RxDouble((json['current_stock'] is int
              ? json['current_stock'].toDouble()
              : json['current_stock']) as double)
          : null,
      lastSold: json['last_sold'] != null
          ? DateTime.parse(json['last_sold']).toLocal()
          : null,
      category: json['category'],
      attributes: json['attributes'] != null
          ? Map<String, String>.from(json['attributes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'store_id': storeId,
        'product_id': productId,
        'created_at': createdAt?.toIso8601String(),
        if (id != null) 'featured': featured! ? 1 : 0,
        'barcode': barcode,
        'image_url': imageUrl?.value,
        'product_name': productName,
        'unit': unit,
        'cost_price': costPrice.value,
        'sell_price1': sellPrice1.value,
        'sell_price2': sellPrice2?.value,
        'sell_price3': sellPrice3?.value,
        'stock': stock.value,
        'stock_min': stockMin.value,
        'sold': sold?.value,
        'last_updated': lastUpdated?.toIso8601String(),
        'current_stock': currentStock?.value,
        'last_sold': lastSold?.toIso8601String(),
        'category': category,
        'attributes': attributes,
      };

  factory ProductModel.fromRow(sqlite.Row row) {
    // print('current_stock ${row['product_name']}');
    // print('current_stock ${row['last_updated']}');
    // print('current_stock ${row['current_stock']}');
    var logStockData = <LogStock>[].obs;
    if (row['log_stock'] != null) {
      // Check if payments is a row string
      final dynamic data = row['log_stock'] is String
          ? jsonDecode(row['log_stock'])
          : row['log_stock'];

      // Ensure paymentData is a list
      if (data is List) {
        logStockData = RxList<LogStock>(
          data
              .map((i) => LogStock.fromJson(i as Map<String, dynamic>))
              .toList(),
        );
      } else {
        // Handle the case where paymentData is not a list
        logStockData = RxList<LogStock>(
          (jsonDecode(data) as List)
              .map((i) => LogStock.fromJson(i as Map<String, dynamic>))
              .toList(),
        );
        // payments = RxList<PaymentModel>();
      }
    } else {
      logStockData = RxList<LogStock>();
    }
    return ProductModel(
      id: row['id'],
      storeId: row['store_id'],
      productId: row['product_id'],
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at']).toLocal()
          : null,
      barcode: row['barcode'],
      imageUrl:
          row['image_url'] != null ? (row['image_url'] as String).obs : null,
      featured: row['featured'] != null ? row['featured'] == 1 : null,
      productName: row['product_name'],
      unit: row['unit'],
      costPrice: ((row['cost_price'] is int
              ? row['cost_price'].toDouble()
              : row['cost_price']) as double)
          .obs,
      sellPrice1: RxDouble(row['sell_price1'].toDouble()),
      sellPrice2: RxDouble(row['sell_price2'].toDouble()),
      sellPrice3: RxDouble(row['sell_price3'].toDouble()),
      stock: ((row['stock'] is int ? row['stock'].toDouble() : row['stock'])
              as double)
          .obs,
      logStock: logStockData,
      stockMin: row['stock_min'] != null
          ? RxDouble((row['stock_min'] is int
              ? row['stock_min'].toDouble()
              : row['stock_min']) as double)
          : RxDouble(10),
      sold: RxDouble(row['sold'].toDouble()),
      lastUpdated: row['last_updated'] != null
          ? DateTime.parse(row['last_updated']).toLocal()
          : null,
      currentStock: row['current_stock'] != null
          ? RxDouble((row['current_stock'] is int
              ? row['current_stock'].toDouble()
              : row['current_stock']) as double)
          : null,
      lastSold: row['last_sold'] != null
          ? DateTime.parse(row['last_sold']).toLocal()
          : null,
      category: row['category'],
      attributes: row['attributes'] != null
          ? Map<String, String>.from(row['attributes'])
          : null,
    );
  }

  String getCurrency(double priceValue) {
    return currency.format(priceValue);
  }

  String getNumber(double doubleValue) {
    return number.format(doubleValue);
  }

  RxDouble getPrice(int priceType) {
    switch (priceType) {
      case 1:
        return sellPrice1;
      case 2:
        return (sellPrice2 != null && sellPrice2 != 0.0.obs)
            ? sellPrice2!
            : sellPrice1;
      case 3:
        return (sellPrice3 != null && sellPrice3 != 0.0.obs)
            ? sellPrice3!
            : sellPrice1;
      default:
        return sellPrice1;
    }
  }

  RxDouble get finalStock {
    return currentStock ?? stock;
  }

  static Future<void> addImage(String imageId, String id) async {
    await db.execute(
        'UPDATE products SET image_url = ? WHERE id = ?', [imageId, id]);
  }
}



// Future<void> insertLog() async {
//     // final logStock = LogStock();
//     await db.execute(
//       '''
//     INSERT INTO log_stock (
//       id, product_id, product, store_id, label, amount, created_at
//     ) VALUES(uuid(), ?, ?, ?, ?, ?, ?)
//     ''',
//       [
//         productId,
//         productName,
//         storeId,
//         'Stok Awal',
//         stock.value,
//         createdAt,
//       ],
//     );
//   }