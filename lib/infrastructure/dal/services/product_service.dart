import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:materikas/infrastructure/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../domain/core/interfaces/product_repository.dart';
import '../../models/log_stock_model.dart';
import '../database/powersync.dart';

Future<List<ProductModel>> convertToModel(
    List<Map<String, dynamic>> result) async {
  return result.map((e) => ProductModel.fromJson(e)).toList();
}

class ProductService extends GetxService implements ProductRepository {
  final lastCode = ''.obs;
  final productsLenght = 0.obs;

  // final offset = 0.obs;
  // final limit = 50.obs;
  // final search = ''.obs;
  // final hasMore = true.obs;
  // final isLowStock = false.obs;

  final products = <ProductModel>[].obs;
  final isReady = false.obs;
  // final isLowStock = false.obs;

  @override
  void onInit() {
    super.onInit();
    once(products, (_) => isReady.value = true);
  }

  String getQuery() {
    return '''
        SELECT
            p.id,
            p.product_id,
            p.store_id,
            p.created_at,
            p.featured,
            p.product_name,
            p.unit,
            p.cost_price,
            p.sell_price1,
            p.sell_price2,
            p.sell_price3,
            p.stock,
            p.stock_min,
            p.sold,
            p.barcode,
            p.image_url,
            p.last_updated,
            p.last_sold,
            p.category,
            p.attributes,
            p.stock + COALESCE(ls.total_amount, 0) AS current_stock
        FROM 
            products p
        LEFT JOIN (
            SELECT 
                log_stock.product_uuid,
                SUM(
                    CASE 
                        WHEN log_stock.created_at > p.last_updated 
                        AND log_stock.label NOT IN ('Stok Awal', 'Update') 
                        THEN log_stock.amount 
                        ELSE 0 
                    END
                ) AS total_amount
            FROM 
                log_stock
            INNER JOIN 
                products p ON log_stock.product_uuid = p.id
            GROUP BY 
                log_stock.product_uuid
        ) ls ON p.id = ls.product_uuid
         GROUP BY 
            p.id, p.product_id, p.store_id, p.created_at, p.featured, p.product_name, 
            p.unit, p.cost_price, p.sell_price1, p.sell_price2, p.sell_price3, 
            p.stock, p.stock_min, p.sold, p.barcode, p.image_url, 
            p.last_updated, p.last_sold
        ORDER BY product_name ASC
        LIMIT 300
        ''';
  }

  @override
  Future<void> subscribe() async {
    try {
      var stream = db.watch(getQuery()).map((data) => data.toList());

      stream.listen((datas) async {
        products.value = await compute(convertToModel, datas);
        // products.sort((a, b) => b.lastSold!.compareTo(a.lastSold!));
        lastCode.value = await getLastCodeProduct();
        productsLenght.value = await getTotalProduct();
      });
    } on PostgrestException catch (e) {
      debugPrint(e.message);
      rethrow;
    }
  }

  Future<int> getTotalProduct() async {
    try {
      String query = '''
        SELECT COUNT(*) as count FROM products
        ''';
      var result = await db.getAll(query);
      var count = result.first['count'] as int;

      return count;
    } on PostgrestException catch (e) {
      debugPrint(e.message);
      rethrow;
    }
  }

  Future<String> getLastCodeProduct() async {
    try {
      String query = '''
        SELECT product_id FROM products ORDER BY product_id DESC LIMIT 1
        ''';
      var result = await db.getAll(query);
      if (result.isEmpty) return '';
      return result.first['product_id'] as String;
    } on PostgrestException catch (e) {
      debugPrint(e.message);
      rethrow;
    }
  }

  Future<List<ProductModel>> fetch({
    String search = '',
    bool isLowStock = false,
    int offset = 30,
    int limit = 30,
  }) async {
    print('offset ${offset}');
    print('limit ${limit}');
    try {
      var datas = await db.getAll('''
       SELECT
            p.id,
            p.product_id,
            p.store_id,
            p.created_at,
            p.featured,
            p.product_name,
            p.unit,
            p.cost_price,
            p.sell_price1,
            p.sell_price2,
            p.sell_price3,
            p.stock,
            p.stock_min,
            p.sold,
            p.barcode,
            p.image_url,
            p.last_updated,
            p.last_sold,
            p.category,
            p.attributes,
            p.stock + COALESCE(ls.total_amount, 0) AS current_stock
        FROM 
            products p
        LEFT JOIN (
            SELECT 
                log_stock.product_uuid,
                SUM(
                    CASE 
                        WHEN log_stock.created_at > p.last_updated 
                        AND log_stock.label NOT IN ('Stok Awal', 'Update') 
                        THEN log_stock.amount 
                        ELSE 0 
                    END
                ) AS total_amount
            FROM 
                log_stock
            INNER JOIN 
                products p ON log_stock.product_uuid = p.id
            GROUP BY 
                log_stock.product_uuid
        ) ls ON p.id = ls.product_uuid
        ${search.isNotEmpty ? "WHERE p.product_name LIKE ?" : ""}
        GROUP BY 
            p.id, p.product_id, p.store_id, p.created_at, p.featured, p.product_name, 
            p.unit, p.cost_price, p.sell_price1, p.sell_price2, p.sell_price3, 
            p.stock, p.stock_min, p.sold, p.barcode, p.image_url, 
            p.last_updated, p.last_sold
        ${isLowStock ? "ORDER BY (current_stock - stock_min) ASC" : "ORDER BY p.product_name ASC"}
        LIMIT ? OFFSET ?;
        ''', [
        if (search.isNotEmpty) '%${search.toLowerCase()}%',
        limit,
        offset,
      ]);

      return await compute(convertToModel, datas);
    } on PostgrestException catch (e) {
      debugPrint(e.message);
      rethrow;
    }
  }

  // Future<void> firstStock() async {
  //   try {
  //     String query = '''
  //       SELECT
  //       products.id,
  //       products.product_id,
  //       products.store_id,
  //       products.created_at,
  //       products.featured,
  //       products.product_name,
  //       products.unit,
  //       products.cost_price,
  //       products.sell_price1,
  //       products.sell_price2,
  //       products.sell_price3,
  //       products.stock,
  //       products.stock_min,
  //       products.sold,
  //       products.barcode,
  //       products.image_url,
  //       products.last_updated,
  //       products.last_sold,
  //           '[' || GROUP_CONCAT(
  //           '{ "id": "' || log_stock.id || '"' ||
  //           ', "created_at": "' || log_stock.created_at || '"' ||
  //           ', "store_id": "' || log_stock.store_id || '"' ||
  //           ', "product": "' || log_stock.product || '"' ||
  //           ', "label": "' || log_stock.label || '"' ||
  //           ', "amount": "' || log_stock.amount || '"' ||
  //           ', "product_id": "' || log_stock.product_id || '"' ||
  //           ', "product_uuid": "' || log_stock.product_uuid || '"' ||
  //           '}', ', '
  //         ) || ']' AS log_stock
  //       FROM products
  //       LEFT JOIN log_stock ON products.id = log_stock.product_uuid
  //       GROUP BY products.product_id
  //       ''';
  //     var datas = await db.getAll(query);
  //     var listProducts = await compute(convertToModel, datas);

  //     var logs = <LogStock>[];
  //     for (var product in listProducts) {
  //       var log = LogStock(
  //         productId: product.productId,
  //         productUuid: product.id!,
  //         productName: product.productName,
  //         storeId: product.storeId,
  //         label: 'Update',
  //         amount: product.stock.value,
  //         createdAt: DateTime.now(),
  //       );
  //       logs.add(log);
  //     }
  //     await insertListLog(logs);
  //     // return listProducts;
  //   } on PostgrestException catch (e) {
  //     debugPrint(e.message);
  //     rethrow;
  //   }
  // }

  @override
  Future<void> insert(ProductModel product) async {
    await db.execute(
      '''
    INSERT INTO products(
      id, store_id, product_id, created_at, last_updated, barcode, image_url, featured, product_name, 
      unit, cost_price, sell_price1, sell_price2, sell_price3, 
      stock, stock_min, sold, last_sold, category, attributes
    ) VALUES(uuid(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        product.storeId,
        product.productId,
        product.createdAt?.toIso8601String(),
        product.lastUpdated?.toIso8601String(),
        product.barcode,
        product.imageUrl?.value,
        product.featured == true ? 1 : 0,
        product.productName.replaceAll('"', ''),
        product.unit,
        product.costPrice.value,
        product.sellPrice1.value,
        product.sellPrice2?.value,
        product.sellPrice3?.value,
        product.stock.value,
        product.stockMin.value,
        product.sold?.value,
        product.lastSold?.toIso8601String(),
        product.category,
        product.attributes,
      ],
    );
  }

  @override
  Future<void> insertList(List<ProductModel> productList) async {
    final List<List<Object?>> parameterSets = productList.map((product) {
      return [
        product.storeId,
        product.productId,
        product.createdAt?.toIso8601String(),
        product.lastUpdated?.toIso8601String(),
        product.barcode,
        product.imageUrl?.value,
        product.featured == true ? 1 : 0,
        product.productName.replaceAll('"', ''),
        product.unit,
        product.costPrice.value,
        product.sellPrice1.value,
        product.sellPrice2?.value,
        product.sellPrice3?.value,
        product.stock.value,
        product.stockMin.value,
        product.sold?.value,
        product.lastSold?.toIso8601String(),
        product.category,
        product.attributes,
      ];
    }).toList();

    await db.executeBatch(
      '''
    INSERT INTO products(
      id, store_id, product_id, created_at, last_updated, barcode, image_url, featured, product_name, 
      unit, cost_price, sell_price1, sell_price2, sell_price3, 
      stock, stock_min, sold, last_sold, category, attributes
    ) VALUES(uuid(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      parameterSets,
    );
  }

  @override
  Future<void> update(ProductModel updatedProduct) async {
    await db.execute(
      '''
      UPDATE products SET
        store_id = ?, 
        product_id = ?, 
        created_at = ?, 
        last_updated = ?, 
        barcode = ?, 
        image_url = ?, 
        featured = ?, 
        product_name = ?, 
        unit = ?, 
        cost_price = ?, 
        sell_price1 = ?, 
        sell_price2 = ?, 
        sell_price3 = ?, 
        stock = ?, 
        stock_min = ?, 
        sold = ?,
        last_sold = ?,
        category = ?,
        attributes = ?
      WHERE id = ?
      ''',
      [
        updatedProduct.storeId,
        updatedProduct.productId,
        updatedProduct.createdAt?.toIso8601String(),
        updatedProduct.lastUpdated?.toIso8601String(),
        updatedProduct.barcode,
        updatedProduct.imageUrl?.value,
        updatedProduct.featured == true ? 1 : 0,
        updatedProduct.productName,
        updatedProduct.unit,
        updatedProduct.costPrice.value,
        updatedProduct.sellPrice1.value,
        updatedProduct.sellPrice2?.value,
        updatedProduct.sellPrice3?.value,
        updatedProduct.stock.value,
        updatedProduct.stockMin.value,
        updatedProduct.sold?.value,
        updatedProduct.lastSold?.toIso8601String(),
        updatedProduct.category,
        updatedProduct.attributes,
        updatedProduct.id,
      ],
    );
  }

  @override
  Future<void> updateList(List<ProductModel> updatedProductList) async {
    final List<List<Object?>> parameterSets = updatedProductList.map((product) {
      return [
        product.storeId,
        product.productId,
        product.createdAt?.toIso8601String(),
        product.lastUpdated?.toIso8601String(),
        product.barcode,
        product.imageUrl?.value,
        product.featured == true ? 1 : 0,
        product.productName,
        product.unit,
        product.costPrice.value,
        product.sellPrice1.value,
        product.sellPrice2?.value,
        product.sellPrice3?.value,
        product.stock.value,
        product.stockMin.value,
        product.sold?.value,
        product.lastSold?.toIso8601String(),
        product.category,
        product.attributes,
        product.id,
      ];
    }).toList();

    await db.executeBatch(
      '''
    UPDATE products SET
      store_id = ?, 
      product_id = ?, 
      created_at = ?, 
      last_updated = ?, 
      barcode = ?, 
      image_url = ?, 
      featured = ?, 
      product_name = ?, 
      unit = ?, 
      cost_price = ?, 
      sell_price1 = ?, 
      sell_price2 = ?, 
      sell_price3 = ?, 
      stock = ?, 
      stock_min = ?, 
      sold = ?,
      last_sold = ?,
      category = ?,
      attributes = ?
    WHERE id = ?
    ''',
      parameterSets,
    );
  }

  @override
  Future<void> delete(String id) async {
    await db.execute('DELETE FROM products WHERE id = ?', [id]);
  }

  //! LOG STOCK
  Future<List<LogStock>> getLog() async {
    final result = await db.getAll(
      '''
      SELECT * FROM log_stock ORDER BY created_at DESC
    ''',
    );
    return result.map((e) => LogStock.fromRow(e)).toList();
    // WHERE DATE(created_at) >= DATE('now', '-14 days')
  }

  Future<List<LogStock>> getLogNow() async {
    final result = await db.getAll(
      '''
      SELECT * FROM log_stock WHERE DATE(created_at) = DATE('now', 'localtime') ORDER BY created_at DESC
    ''',
    );
    return result.map((e) => LogStock.fromRow(e)).toList();
  }

  Future<List<LogStock>> getLogByDate(PickerDateRange selectedDateRange) async {
    print('logStock startDate ${selectedDateRange.startDate}');
    print('logStock endDate ${selectedDateRange.endDate}');
    final result = await db.getAll('''
      SELECT l.*, p.unit FROM log_stock l 
      LEFT JOIN products p ON l.product_uuid = p.id 
      WHERE DATE(l.created_at) BETWEEN ? AND ? 
      ORDER BY l.created_at DESC
    ''', [
      DateFormat('yyyy-MM-dd').format(selectedDateRange.startDate!),
      DateFormat('yyyy-MM-dd').format(selectedDateRange.endDate!.subtract(Duration(days: 1))),
    ]);
    return result.map((e) => LogStock.fromRow(e)).toList();
  }

  Future<List<LogStock>> getLogByProduct(ProductModel product) async {
    final result = await db.getAll(
      '''
      SELECT * FROM log_stock 
      WHERE product_uuid = ?
      ORDER BY created_at DESC
      ''',
      [product.id],
    );
    print('logStock.lenght ${result.length}');
    print('logStock.lenght ${product.id}');
    //    print('currentStock ${currentStock?.value}');
    var findLog = <LogStock>[];
    if (result.isEmpty || !result.any((a) => a['label'] == 'Stok Awal')) {
      var newLog = LogStock(
        productId: product.productId,
        productUuid: product.id!,
        productName: product.productName,
        storeId: product.storeId,
        label: 'Stok Awal',
        amount: product.stock.value,
        createdAt: product.createdAt,
      );
      findLog.add(newLog);
      await Get.find<ProductService>().insertLog(newLog);
    }

    findLog.addAll(result.map((e) => LogStock.fromRow(e)).toList());

    return findLog;
  }

  // Future<List<LogStock>> getLogById(String id) async {
  //   final result = await db.getAll(
  //     '''
  //     SELECT * FROM log_stock
  //     WHERE product_uuid = ?
  //     ORDER BY created_at DESC
  //     ''',
  //     [id],
  //   );

  //   return result.map((e) => LogStock.fromRow(e)).toList();
  // }

  Future<void> insertLog(LogStock logStock) async {
    await db.execute(
      '''
    INSERT INTO log_stock (
      id, product_id, product_uuid, product, store_id, label, amount, created_at
    ) VALUES(uuid(), ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        logStock.productId,
        logStock.productUuid,
        logStock.productName?.replaceAll('"', ''),
        logStock.storeId,
        logStock.label,
        logStock.amount,
        logStock.createdAt!.toIso8601String(),
      ],
    );
  }

  Future<void> insertListLog(List<LogStock> logStock) async {
    final List<List<Object?>> parameterSets = logStock.map((log) {
      return [
        log.productId,
        log.productUuid,
        log.productName?.replaceAll('"', ''),
        log.storeId,
        log.label,
        log.amount,
        log.createdAt!.toIso8601String(),
      ];
    }).toList();

    await db.executeBatch(
      '''
    INSERT INTO log_stock (
      id, product_id, product_uuid, product, store_id, label, amount, created_at
    ) VALUES(uuid(), ?, ?, ?, ?, ?, ?, ?)
    ''',
      parameterSets,
    );
  }
  //! =======

  @override
  Future<void> backup(String storeId) async {
    final product =
        await db.getAll('SELECT * FROM products WHERE store_id = ?', [storeId]);
    List<String> headers = product.isNotEmpty ? product.columnNames : [];
    // Konversi data ke format CSV
    List<List<dynamic>> csvData = [headers];
    for (var row in product) {
      csvData.add(row.values.toList());
    }
    String csv = const ListToCsvConverter().convert(csvData);
    File file = File('./product.csv'); // Ganti path sesuai kebutuhan
    await file.writeAsString(csv);
  }

  Future<List<ProductModel>> getAllProduct() async {
    try {
      String query = '''
        SELECT * FROM products
        ''';
      var result = await db.getAll(query);

      return await compute(convertToModel, result);
    } on PostgrestException catch (e) {
      debugPrint(e.message);
      rethrow;
    }
  }

  Future<ProductModel> getProductById(String id) async {
    try {
      String query = '''
        SELECT * FROM products WHERE id = ?
        ''';
      var result = await db.getAll(query, [id]);
      var foundProducts = await compute(convertToModel, result);
      return foundProducts.first;
    } on PostgrestException catch (e) {
      debugPrint(e.message);
      rethrow;
    }
  }
}
