import '../../domain/core/entities/customer.dart';
import 'package:powersync/sqlite3_common.dart' as sqlite;

class CustomerModel extends Customer {
  CustomerModel({
    super.id,
    super.customerId,
    super.createdAt,
    required super.name,
    super.phone,
    super.address,
    super.storeId,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      customerId: json['customer_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : null,
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      storeId: json['store_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    if (customerId != null) data['customer_id'] = customerId;
    if (createdAt != null) data['created_at'] = createdAt?.toIso8601String();
    data['name'] = name;
    data['phone'] = phone;
    data['address'] = address;
    if (storeId != null) data['store_id'] = storeId;
    return data;
  }

  factory CustomerModel.fromRow(sqlite.Row row) {
    return CustomerModel(
      id: row['id'],
      customerId: row['customer_id'],
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at']).toLocal()
          : null,
      name: row['name'],
      phone: row['phone'],
      address: row['address'],
      storeId: row['store_id'],
    );
  }
}
