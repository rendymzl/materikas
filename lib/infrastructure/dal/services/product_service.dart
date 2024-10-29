import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:csv/csv.dart';
import 'package:materikas/infrastructure/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/core/interfaces/product_repository.dart';
import '../database/powersync.dart';

class ProductService extends GetxService implements ProductRepository {
  final updatedCount = 0.obs;
  final lastCode = ''.obs;
  final productsLenght = 0.obs;

  @override
  Future<void> subscribe() async {
    try {
      var stream =
          db.watch('SELECT * FROM products').map((data) => data.toList());

      stream.listen((update) {
        updatedCount.value++;
        lastCode.value = ProductModel.fromRow(update.last).productId;
        productsLenght.value = update.length;
      });
    } on PostgrestException catch (e) {
      debugPrint(e.message);
      rethrow;
    }
  }

  Future<List<ProductModel>> fetch({
    int offset = 0,
    int limit = 25,
    String search = '',
    bool isLowStockFilter = false,
  }) async {
    if (search.isEmpty) {
      if (isLowStockFilter) {
        try {
          var result = await db.getAll('''
        SELECT * FROM products
        ORDER BY stock ASC
        LIMIT ? OFFSET ?
        ''', [limit, offset]);
          var listProducts =
              result.map((e) => ProductModel.fromRow(e)).toList();
          return listProducts;
        } on PostgrestException catch (e) {
          debugPrint(e.message);
          rethrow;
        }
      } else {
        try {
          var result = await db.getAll('''
        SELECT * FROM products
        ORDER BY product_name ASC
        LIMIT ? OFFSET ?
        ''', [limit, offset]);
          var listProducts =
              result.map((e) => ProductModel.fromRow(e)).toList();
          return listProducts;
        } on PostgrestException catch (e) {
          debugPrint(e.message);
          rethrow;
        }
      }
    } else {
      if (isLowStockFilter) {
        try {
          var result = await db.getAll('''
        SELECT * FROM products
        WHERE product_name LIKE ?
        ORDER BY stock ASC
        LIMIT ? OFFSET ?
        ''', ['%${search.toLowerCase()}%', limit, offset]);
          var listProducts =
              result.map((e) => ProductModel.fromRow(e)).toList();
          return listProducts;
        } on PostgrestException catch (e) {
          debugPrint(e.message);
          rethrow;
        }
      } else {
        try {
          var result = await db.getAll('''
        SELECT * FROM products
        WHERE product_name LIKE ?
        ORDER BY product_name ASC
        LIMIT ? OFFSET ?
        ''', ['%${search.toLowerCase()}%', limit, offset]);
          var listProducts =
              result.map((e) => ProductModel.fromRow(e)).toList();
          return listProducts;
        } on PostgrestException catch (e) {
          debugPrint(e.message);
          rethrow;
        }
      }
    }
  }

  @override
  Future<void> insert(ProductModel product) async {
    await db.execute(
      '''
    INSERT INTO products(
      id, store_id, product_id, created_at, barcode, featured, product_name, 
      unit, cost_price, sell_price1, sell_price2, sell_price3, 
      stock, stock_min, sold
    ) VALUES(uuid(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        product.storeId,
        product.productId,
        product.createdAt?.toIso8601String(),
        product.barcode,
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
        product.barcode,
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
      ];
    }).toList();

    await db.executeBatch(
      '''
    INSERT INTO products(
      id, store_id, product_id, created_at, barcode, featured, product_name, 
      unit, cost_price, sell_price1, sell_price2, sell_price3, 
      stock, stock_min, sold
    ) VALUES(uuid(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
        barcode = ?, 
        featured = ?, 
        product_name = ?, 
        unit = ?, 
        cost_price = ?, 
        sell_price1 = ?, 
        sell_price2 = ?, 
        sell_price3 = ?, 
        stock = ?, 
        stock_min = ?, 
        sold = ?
      WHERE id = ?
      ''',
      [
        updatedProduct.storeId,
        updatedProduct.productId,
        updatedProduct.createdAt?.toIso8601String(),
        updatedProduct.barcode,
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
        product.barcode,
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
        product.id,
      ];
    }).toList();

    await db.executeBatch(
      '''
    UPDATE products SET
      store_id = ?, 
      product_id = ?, 
      created_at = ?, 
      barcode = ?, 
      featured = ?, 
      product_name = ?, 
      unit = ?, 
      cost_price = ?, 
      sell_price1 = ?, 
      sell_price2 = ?, 
      sell_price3 = ?, 
      stock = ?, 
      stock_min = ?, 
      sold = ?
    WHERE id = ?
    ''',
      parameterSets,
    );
  }

  @override
  Future<void> delete(String id) async {
    await db.execute('DELETE FROM products WHERE id = ?', [id]);
  }

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
}
