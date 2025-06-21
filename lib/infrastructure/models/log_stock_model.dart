import 'package:powersync/sqlite3_common.dart' as sqlite;

class LogStock {
  String? id;
  String? productId;
  String? productName;
  String? storeId;
  DateTime? createdAt;
  String? label;
  double amount;
  double? balance;
  String productUuid;
  String? unit;

  LogStock({
    this.id,
    this.productId,
    this.productName,
    this.storeId,
    this.label,
    this.amount = 0,
    this.createdAt,
    this.balance,
    required this.productUuid,
    this.unit,
  });

  LogStock.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        productId = json['product_id'],
        productName = json['product'],
        storeId = json['store_id'],
        label = json['label'],
        amount = double.parse(json['amount'] ?? '0'),
        balance =
            json['balance'] != null ? double.parse(json['balance']) : null,
        createdAt = json['created_at'] != null
            ? DateTime.parse(json['created_at']).toLocal()
            : null,
        productUuid = json['product_uuid'],
        unit = json['unit'];

  LogStock.fromRow(sqlite.Row row)
      : id = row['id'],
        productId = row['product_id'],
        productName = row['product'],
        storeId = row['store_id'],
        label = row['label'],
        amount = row['amount']?.toDouble() ?? 0.0,
        balance = row['balance']?.toDouble(),
        createdAt = row['created_at'] != null
            ? DateTime.parse(row['created_at']).toLocal()
            : null,
        productUuid = row['product_uuid'],
        unit = row['unit'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    if (productId != null) data['product_id'] = productId;
    if (productName != null) data['product'] = productName;
    if (storeId != null) data['store_id'] = storeId;
    if (label != null) data['label'] = label;
    data['amount'] = amount;
    data['balance'] = balance;
    data['created_at'] =
        createdAt?.toIso8601String() ?? DateTime.now().toIso8601String();
    data['product_uuid'] = productUuid;
    if (unit != null) data['unit'] = unit;
    return data;
  }
}
