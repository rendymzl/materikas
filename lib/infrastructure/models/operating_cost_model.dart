import 'package:powersync/sqlite3_common.dart' as sqlite;

import '../../domain/core/entities/operating_cost.dart';

class OperatingCostModel extends OperatingCost {
  OperatingCostModel({
    super.id,
    super.storeId,
    super.createdAt,
    super.name,
    super.amount,
    super.note,
  });

  OperatingCostModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeId = json['store_id'];
    createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at']).toLocal()
        : null;
    name = json['name'];
    amount = json['amount'];
    note = json['note'];
  }

  OperatingCostModel.fromRow(sqlite.Row row) {
    id = row['id'];
    storeId = row['store_id'];
    createdAt = row['created_at'] != null
        ? DateTime.parse(row['created_at']).toLocal()
        : null;
    name = row['name'];
    amount = row['amount'];
    note = row['note'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['store_id'] = storeId;
    if (createdAt != null) data['created_at'] = createdAt?.toIso8601String();
    data['name'] = name;
    data['amount'] = amount;
    data['note'] = note;
    return data;
  }
}
