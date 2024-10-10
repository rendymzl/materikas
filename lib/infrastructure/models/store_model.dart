import 'package:get/get.dart';
import 'package:powersync/sqlite3.dart' as sqlite;

import '../../domain/core/entities/store.dart';

class StoreModel extends Stores {
  StoreModel({
    super.ownerId,
    required super.name,
    required super.address,
    required super.phone,
    required super.telp,
    super.id,
    required super.createdAt,
    super.promo,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'],
      ownerId: json['owner_id'],
      createdAt: DateTime.parse(json['created_at']),
      name: RxString(json['name']),
      address: RxString(json['address']),
      phone: RxString(json['phone']),
      telp: RxString(json['telp']),
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
    data['promo'] = promo?.value;
    return data;
  }

  factory StoreModel.fromRow(sqlite.Row row) {
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
      promo: RxString(row['promo'] ?? ''),
    );
  }
}
