import 'package:powersync/sqlite3_common.dart' as sqlite;

import '../../domain/core/entities/account.dart';

class AccountModel extends Account {
  AccountModel({
    required super.id,
    required super.email,
    required super.role,
    required super.accountId,
    required super.createdAt,
    required super.name,
    required super.storeId,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      accountId: json['account_id'],
      createdAt: DateTime.parse(json['created_at']),
      name: json['name'],
      storeId: json['store_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'account_id': accountId,
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'store_id': storeId,
    };
  }

  factory AccountModel.fromRow(sqlite.Row row) {
    return AccountModel(
      id: row['id'] as String?,
      email: row['email'] as String,
      role: row['role'] as String,
      accountId: row['account_id'] as String,
      createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      name: row['name'] as String,
      storeId: row['store_id'] as String?,
    );
  }
}
