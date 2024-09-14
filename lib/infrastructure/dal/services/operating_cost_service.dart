import 'package:get/get.dart';
import 'package:materikas/domain/core/interfaces/operating_cost_repository.dart';
import 'package:materikas/infrastructure/models/operating_cost_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/powersync.dart';

class OperatingCostService extends GetxService
    implements OperatingCostRepository {
  var operatingCosts = <OperatingCostModel>[].obs;
  var foundOperatingCost = <OperatingCostModel>[].obs;

  @override
  Future<void> subscribe(String storeId) async {
    try {
      var stream = db.watch('SELECT * FROM operating_costs WHERE store_id = ?',
          parameters: [
            storeId
          ]).map((data) =>
          data.map((json) => OperatingCostModel.fromJson(json)).toList());

      stream.listen((update) {
        operatingCosts.assignAll(update);
        foundOperatingCost.assignAll(update);
      });
    } on PostgrestException catch (e) {
      print(e.message);
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
