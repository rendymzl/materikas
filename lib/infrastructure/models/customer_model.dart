import '../../domain/core/entities/customer.dart';
import 'package:powersync/sqlite3_common.dart' as sqlite;

class CustomerModel extends Customer {
  CustomerModel({
    String? id,
    String? customerId,
    DateTime? createdAt,
    required String name,
    String? phone,
    String? address,
    String? storeId,
  }) : super(
          id: id,
          customerId: customerId,
          createdAt: createdAt,
          name: name,
          phone: phone,
          address: address,
          storeId: storeId,
        );

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
    data['customer_id'] = customerId;
    if (createdAt != null) data['created_at'] = createdAt?.toIso8601String();
    data['name'] = name;
    data['phone'] = phone;
    data['address'] = address;
    data['store_id'] = storeId;
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
