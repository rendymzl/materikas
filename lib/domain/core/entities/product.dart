import 'package:get/get.dart';

class Product {
  String? id;
  String storeId;
  String productId;
  DateTime? createdAt;
  String? barcode;
  bool? featured;
  String productName;
  String unit;
  RxDouble costPrice;
  RxDouble sellPrice1;
  RxDouble? sellPrice2;
  RxDouble? sellPrice3;
  RxDouble stock;
  RxDouble stockMin;
  RxDouble? sold;

  Product({
    this.id,
    required this.storeId,
    required this.productId,
    required this.createdAt,
    this.barcode,
    this.featured,
    required this.productName,
    required this.unit,
    required this.costPrice,
    required this.sellPrice1,
    this.sellPrice2,
    this.sellPrice3,
    required this.stock,
    required this.stockMin,
    this.sold,
  });
}
