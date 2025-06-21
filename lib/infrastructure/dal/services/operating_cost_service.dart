import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:materikas/domain/core/interfaces/operating_cost_repository.dart';
import 'package:materikas/infrastructure/models/operating_cost_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../database/powersync.dart';

Future<List<OperatingCostModel>> convertToModel(
    List<Map<String, dynamic>> maps) async {
  return maps.map((e) => OperatingCostModel.fromJson(e)).toList();
}

class OperatingCostService extends GetxService
    implements OperatingCostRepository {
  // final operatingCosts = <OperatingCostModel>[].obs;
  final updatedCount = 0.obs;
  Future<List<OperatingCostModel>> searchInvoicesByPickerDateRange(
      PickerDateRange? dateRange) async {
    if (dateRange != null) {
      return await getByDate(dateRange);
    } else {
      return [];
    }
  }

  // List<OperatingCostModel> sortByDate(
  //     List<OperatingCostModel> operatingCostList) {
  //   operatingCostList.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  //   return operatingCostList;
  // }

  @override
  Future<void> subscribe() async {
    try {
      var stream = db.watch('SELECT store_id FROM operating_costs LIMIT 1');

      stream.listen((update) {
        updatedCount.value++;
      });
    } on PostgrestException catch (e) {
      debugPrint(e.message);
      rethrow;
    }
  }

  Future<List<OperatingCostModel>> getByDate(
      PickerDateRange pickerDateRange) async {
    try {
      final data = await db.getAll(
        'SELECT * FROM operating_costs WHERE created_at BETWEEN ? AND ? ORDER BY created_at DESC',
        [
          DateFormat('yyyy-MM-dd').format(pickerDateRange.startDate!),
          DateFormat('yyyy-MM-dd').format(pickerDateRange.endDate!),
        ],
      );
      return await compute(convertToModel, data);
    } on PostgrestException catch (e) {
      debugPrint(e.message);
      rethrow;
    }
  }

  @override
  Future<void> insert(OperatingCostModel operatingCost) async {
    await db.execute(
      '''
    INSERT INTO operating_costs(
      id, store_id, created_at, name, amount, note
    ) VALUES(uuid(), ?, ?, ?, ?, ?)
    ''',
      [
        operatingCost.storeId,
        operatingCost.createdAt?.toIso8601String(),
        operatingCost.name,
        operatingCost.amount,
        operatingCost.note,
      ],
    );
  }

  @override
  Future<void> update(OperatingCostModel updateOperatingCost) async {
    await db.execute(
      '''
    UPDATE operating_costs SET
      store_id = ?, 
      created_at = ?, 
      name = ?, 
      amount = ?, 
      note = ?
    WHERE id = ?
    ''',
      [
        updateOperatingCost.storeId,
        updateOperatingCost.createdAt?.toIso8601String(),
        updateOperatingCost.name,
        updateOperatingCost.amount,
        updateOperatingCost.note,
        updateOperatingCost.id,
      ],
    );
  }

  @override
  Future<void> delete(String id) async {
    await db.execute(
      '''
    DELETE FROM operating_costs WHERE id = ?
    ''',
      [id],
    );
  }
}
