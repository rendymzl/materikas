import 'package:get/get.dart';
import 'package:powersync/sqlite3_common.dart' as sqlite;

import '../../domain/core/entities/product.dart';
import '../utils/display_format.dart';

class ProductModel extends Product {
  ProductModel({
    super.id,
    required super.storeId,
    required super.productId,
    super.createdAt,
    super.barcode,
    super.featured,
    required super.productName,
    required super.unit,
    required super.costPrice,
    required super.sellPrice1,
    super.sellPrice2,
    super.sellPrice3,
    required super.stock,
    required super.stockMin,
    super.sold,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      storeId: json['store_id'],
      productId: json['product_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : null,
      barcode: json['barcode'],
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
      sellPrice2: ((json['sell_price2'] is int
              ? json['sell_price2'].toDouble()
              : json['sell_price2']) as double)
          .obs,
      sellPrice3: ((json['sell_price3'] is int
              ? json['sell_price3'].toDouble()
              : json['sell_price3']) as double)
          .obs,
      stock: ((json['stock'] is int ? json['stock'].toDouble() : json['stock'])
              as double)
          .obs,
      stockMin: json['stock_min'] != null
          ? RxDouble((json['stock_min'] is int
              ? json['stock_min'].toDouble()
              : json['stock_min']) as double)
          : RxDouble(10),
      sold: ((json['sold'] is int ? json['sold'].toDouble() : json['sold'])
              as double)
          .obs,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'store_id': storeId,
        'product_id': productId,
        'created_at': createdAt?.toIso8601String(),
        if (id != null) 'featured': featured! ? 1 : 0,
        'barcode': barcode,
        'product_name': productName,
        'unit': unit,
        'cost_price': costPrice.value,
        'sell_price1': sellPrice1.value,
        'sell_price2': sellPrice2?.value,
        'sell_price3': sellPrice3?.value,
        'stock': stock.value,
        'stock_min': stockMin.value,
        'sold': sold?.value,
      };

  factory ProductModel.fromRow(sqlite.Row row) {
    return ProductModel(
      id: row['id'],
      storeId: row['store_id'],
      productId: row['product_id'],
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at']).toLocal()
          : null,
      barcode: row['barcode'],
      featured: row['featured'] != null ? row['featured'] == 1 : null,
      productName: row['product_name'],
      unit: row['unit'],
      costPrice: ((row['cost_price'] is int
              ? row['cost_price'].toDouble()
              : row['cost_price']) as double)
          .obs,
      sellPrice1: row['sell_price1'].toDouble(),
      sellPrice2: row['sell_price2'].toDouble(),
      sellPrice3: row['sell_price3'].toDouble(),
      stock: ((row['stock'] is int ? row['stock'].toDouble() : row['stock'])
              as double)
          .obs,
      stockMin: row['stock_min'] != null
          ? RxDouble((row['stock_min'] is int
              ? row['stock_min'].toDouble()
              : row['stock_min']) as double)
          : RxDouble(10),
      sold: row['sold'].toDouble(),
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
}
