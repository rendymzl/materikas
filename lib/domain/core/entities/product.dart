import 'package:get/get.dart';

import '../../../infrastructure/models/log_stock_model.dart';

class Product {
  String? id;
  String storeId;
  String productId;
  DateTime? createdAt;
  DateTime? lastUpdated;
  String? barcode;
  RxString? imageUrl;
  bool? featured;
  String productName;
  String unit;
  RxDouble costPrice;
  RxDouble sellPrice1;
  RxDouble? sellPrice2;
  RxDouble? sellPrice3;
  RxDouble stock;
  List<LogStock>? logStock;
  RxDouble stockMin;
  RxDouble? sold;
  RxDouble? currentStock;
  DateTime? lastSold;
  final String? category;
  final Map<String, String>? attributes;

  Product({
    this.id,
    required this.storeId,
    required this.productId,
    required this.createdAt,
    this.lastUpdated,
    this.barcode,
    this.imageUrl,
    this.featured,
    required this.productName,
    required this.unit,
    required this.costPrice,
    required this.sellPrice1,
    this.sellPrice2,
    this.sellPrice3,
    required this.stock,
    this.logStock,
    required this.stockMin,
    this.sold,
    required this.currentStock,
    this.lastSold,
    this.category,
    this.attributes,
  });
}
