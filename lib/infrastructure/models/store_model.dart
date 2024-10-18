import 'dart:convert';

import 'package:get/get.dart';
import 'package:powersync/sqlite3.dart' as sqlite;

import '../../domain/core/entities/store.dart';
import 'billing_model.dart';

class StoreModel extends Stores {
  StoreModel({
    super.ownerId,
    required super.name,
    required super.address,
    required super.phone,
    required super.telp,
    super.id,
    required super.createdAt,
    super.billings,
    super.promo,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    late RxList<Billing> billings;
    if (json['billings'] != null) {
      final dynamic billingsData = json['billings'] is String
          ? jsonDecode(json['billings'])
          : json['billings'];

      if (billingsData is List) {
        billings = RxList<Billing>(
          billingsData
              .map((i) => Billing.fromJson(i as Map<String, dynamic>))
              .toList(),
        );
      } else {
        billings = RxList<Billing>(
          (jsonDecode(billingsData) as List)
              .map((i) => Billing.fromJson(i as Map<String, dynamic>))
              .toList(),
        );
      }
    } else {
      billings = RxList<Billing>([]);
    }
    return StoreModel(
      id: json['id'],
      ownerId: json['owner_id'],
      createdAt: DateTime.parse(json['created_at']),
      name: RxString(json['name']),
      address: RxString(json['address']),
      phone: RxString(json['phone']),
      telp: RxString(json['telp']),
      billings: billings,
      promo: RxString(json['promo'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['owner_id'] = ownerId;
    data['created_at'] = createdAt.toIso8601String();
    data['name'] = name.value;
    data['address'] = address.value;
    data['phone'] = phone.value;
    data['telp'] = telp.value;
    data['billings'] = billings?.map((item) => item?.toJson()).toList();
    data['promo'] = promo?.value;
    return data;
  }

  factory StoreModel.fromRow(sqlite.Row row) {
    late RxList<Billing> billings;
    if (row['billings'] != null) {
      final dynamic billingsData = row['billings'] is String
          ? jsonDecode(row['billings'])
          : row['billings'];

      if (billingsData is List) {
        billings = RxList<Billing>(
          billingsData
              .map((i) => Billing.fromJson(i as Map<String, dynamic>))
              .toList(),
        );
      } else {
        billings = RxList<Billing>(
          (jsonDecode(billingsData) as List)
              .map((i) => Billing.fromJson(i as Map<String, dynamic>))
              .toList(),
        );
      }
    } else {
      billings = RxList<Billing>([]);
    }
    return StoreModel(
      id: row['id'],
      ownerId: row['owner_id'],
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'])
          : DateTime.now(),
      name: RxString(row['name']),
      address: RxString(row['address']),
      phone: RxString(row['phone']),
      telp: RxString(row['telp']),
      billings: billings,
      promo: RxString(row['promo'] ?? ''),
    );
  }
}
