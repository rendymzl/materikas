import 'dart:convert';

import 'package:get/get.dart';
import 'package:powersync/sqlite3_common.dart' as sqlite;

import '../../domain/core/entities/account.dart';
import 'user_model.dart';

class AccountModel extends Account {
  AccountModel({
    required super.id,
    required super.email,
    required super.role,
    required super.accountId,
    required super.createdAt,
    required super.name,
    required super.storeId,
    required super.users,
    required super.password,
    required super.accountType,
    required super.startDate,
    required super.endDate,
    required super.isActive,
    required super.updatedAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    late RxList<Cashier> users;
    if (json['users'] != null) {
      final dynamic usersData =
          json['users'] is String ? jsonDecode(json['users']) : json['users'];

      if (usersData is List) {
        users = RxList<Cashier>(
          usersData
              .map((i) => Cashier.fromJson(i as Map<String, dynamic>))
              .toList(),
        );
      } else {
        users = RxList<Cashier>(
          (jsonDecode(usersData) as List)
              .map((i) => Cashier.fromJson(i as Map<String, dynamic>))
              .toList(),
        );
      }
    } else {
      users = RxList<Cashier>([]);
    }

    return AccountModel(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      accountId: json['account_id'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      name: json['name'],
      storeId: json['store_id'],
      users: users,
      password: json['password'] ?? 'admin',
      accountType: json['account_type'] ?? 'free_trial',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date']).toLocal()
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date']).toLocal()
          : null,
      isActive: json['is_active'] == 1,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
          : DateTime.now(),
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
      'users': users.map((item) => item.toJson()).toList(),
      'password': password,
      'account_type': accountType,
      'start_date': startDate,
      'end_date': endDate,
      'is_active': isActive,
      'updated_at': updatedAt
    };
  }

  factory AccountModel.fromRow(sqlite.Row row) {
    late RxList<Cashier> users;
    if (row['users'] != null) {
      final dynamic usersData =
          row['users'] is String ? jsonDecode(row['users']) : row['users'];

      if (usersData is List) {
        users = RxList<Cashier>(
          usersData
              .map((i) => Cashier.fromJson(i as Map<String, dynamic>))
              .toList(),
        );
      } else {
        users = RxList<Cashier>(
          (jsonDecode(usersData) as List)
              .map((i) => Cashier.fromJson(i as Map<String, dynamic>))
              .toList(),
        );
      }
    } else {
      users = RxList<Cashier>([]);
    }

    return AccountModel(
      id: row['id'] as String?,
      email: row['email'] as String,
      role: row['role'] as String,
      accountId: row['account_id'] as String,
      createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      name: row['name'] as String,
      storeId: row['store_id'] as String?,
      users: users,
      password: row['password'],
      accountType: row['account_type'] ?? 'free_trial',
      startDate: row['start_date'] != null
          ? DateTime.parse(row['start_date']).toLocal()
          : null,
      endDate: row['end_date'] != null
          ? DateTime.parse(row['end_date']).toLocal()
          : null,
      isActive: row['is_active'] == 1,
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at']).toLocal()
          : DateTime.now(),
    );
  }
}
