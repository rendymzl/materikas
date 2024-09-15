import 'package:get/get.dart';
import 'package:powersync/sqlite3.dart' as sqlite;

import '../../domain/core/entities/store.dart';

class StoreModel extends Stores {
  StoreModel({
    required super.name,
    required super.address,
    required super.phone,
    required super.telp,
    required super.id,
    required super.createdAt,
    super.promo,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      telp: json['telp'],
      promo: json['promo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt.toIso8601String();
    data['name'] = name.value;
    data['address'] = address.value;
    data['phone'] = phone.value;
    data['telp'] = telp.value;
    data['promo'] = promo?.value;
    return data;
  }

  factory StoreModel.fromRow(sqlite.Row row) {
    return StoreModel(
      id: row['id'],
      createdAt: DateTime.parse(row['created_at']),
      name: RxString(row['name']),
      address: RxString(row['address']),
      phone: RxString(row['phone']),
      telp: RxString(row['telp']),
      promo: RxString(row['promo'] ?? ''),
    );
  }
}
