import 'dart:convert';

import 'package:get/get.dart';
import 'package:powersync/sqlite3_common.dart' as sqlite;

class Cashier {
  String? id;
  DateTime createdAt;
  String name;
  String password;
  RxList<String> accessList;

  Cashier({
    this.id,
    required this.createdAt,
    required this.name,
    required this.password,
    required this.accessList,
  });

  factory Cashier.fromJson(Map<String, dynamic> json) {
    late RxList<String> accessList;
    if (json['access_list'] != null) {
      final dynamic accessData = json['access_list'] is String
          ? jsonDecode(json['access_list'])
          : json['access_list'];

      if (accessData is List) {
        accessList = RxList<String>(
          accessData.map((i) => i as String).toList(),
        );
      } else {
        accessList = RxList<String>(
          (jsonDecode(accessData) as List).map((i) => i as String).toList(),
        );
      }
    } else {
      accessList = RxList<String>([]);
    }

    return Cashier(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      name: json['name'],
      password: json['password'],
      accessList: accessList,
    );
  }

  factory Cashier.fromRow(sqlite.Row row) {
    late RxList<String> accessList;
    if (row['access_list'] != null) {
      final dynamic accessData = row['access_list'] is String
          ? jsonDecode(row['access_list'])
          : row['access_list'];

      if (accessData is List) {
        accessList = RxList<String>(
          accessData.map((i) => i as String).toList(),
        );
      } else {
        accessList = RxList<String>(
          (jsonDecode(accessData) as List).map((i) => i as String).toList(),
        );
      }
    } else {
      accessList = RxList<String>([]);
    }

    return Cashier(
      id: row['id'],
      createdAt: DateTime.parse(row['created_at']).toLocal(),
      name: row['name'],
      password: row['password'],
      accessList: accessList,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt.toIso8601String();
    data['name'] = name;
    data['password'] = password;
    data['access_list'] = accessList.map((item) => item.toString()).toList();
    return data;
  }
}
