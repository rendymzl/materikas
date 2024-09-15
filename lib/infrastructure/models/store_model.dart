import 'package:get/get.dart';
import 'package:powersync/sqlite3.dart' as sqlite;

class StoreModel {
  String? id;
  DateTime? createdAt;
  Rx<String> name;
  Rx<String> address;
  Rx<String> phone;
  Rx<String> telp;
  Rx<String?> promo;
  String ownerId;

  StoreModel({
    this.id,
    this.createdAt,
    required String name,
    required String address,
    String phone = '',
    String telp = '',
    String? promo = '',
    required this.ownerId,
  })  : name = Rx<String>(name),
        address = Rx<String>(address),
        phone = Rx<String>(phone),
        telp = Rx<String>(telp),
        promo = Rx<String>(promo ?? '');

  StoreModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        createdAt = json['created_at'] != null
            ? DateTime.parse(json['created_at']).toLocal()
            : null,
        name = Rx<String>(json['name']),
        address = Rx<String>(json['address']),
        phone = Rx<String>(json['phone']),
        telp = Rx<String>(json['telp']),
        promo = Rx<String>(json['promo'] ?? ''),
        ownerId = json['owner_id'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['created_at'] = createdAt?.toIso8601String();
    data['name'] = name.value;
    data['address'] = address.value;
    data['phone'] = phone.value;
    data['telp'] = telp.value;
    data['promo'] = promo.value;
    data['owner_id'] = ownerId;
    return data;
  }

  StoreModel.fromRow(sqlite.Row row)
      : id = row['id'],
        createdAt = row['created_at'] != null
            ? DateTime.parse(row['created_at']).toLocal()
            : null,
        name = Rx<String>(row['name']),
        address = Rx<String>(row['address']),
        phone = Rx<String>(row['phone']),
        telp = Rx<String>(row['telp']),
        promo = Rx<String>(row['promo'] ?? ''),
        ownerId = row['owner_id'];
}
