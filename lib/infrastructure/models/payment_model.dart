import 'dart:convert';

import 'package:get/get.dart';
import 'package:powersync/sqlite3_common.dart' as sqlite;

class PaymentModel {
  String? method;
  double amountPaid;
  double remain;
  double finalAmountPaid;
  DateTime? date;

  PaymentModel({
    this.method,
    this.amountPaid = 0,
    this.remain = 0,
    this.finalAmountPaid = 0,
    this.date,
  });

  PaymentModel.fromJson(Map<String, dynamic> json)
      : method = json['method'],
        amountPaid = json['amount_paid']?.toDouble() ?? 0.0,
        remain = json['remain']?.toDouble() ?? 0.0,
        finalAmountPaid = json['final_amount_paid']?.toDouble() ?? 0.0,
        date = json['date'] != null
            ? DateTime.parse(json['date']).toLocal()
            : null;

  PaymentModel.fromRow(sqlite.Row row)
      : method = row['method'],
        amountPaid = row['amount_paid']?.toDouble() ?? 0.0,
        remain = row['remain']?.toDouble() ?? 0.0,
        finalAmountPaid = row['final_amount_paid']?.toDouble() ?? 0.0,
        date =
            row['date'] != null ? DateTime.parse(row['date']).toLocal() : null;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['method'] = method;
    data['amount_paid'] = amountPaid;
    data['remain'] = remain;
    data['final_amount_paid'] = finalAmountPaid;
    data['date'] = date?.toIso8601String() ?? DateTime.now().toIso8601String();
    print('object $data');
    return data;
  }
}

class PaymentMapModel {
  String? id;
  late RxList<PaymentModel> payments;
  late Rx<DateTime?> createdAt;

  PaymentMapModel({
    this.id,
    DateTime? createdAt,
    List<PaymentModel>? payments,
  })  : createdAt = Rx<DateTime?>(createdAt),
        payments = RxList<PaymentModel>(payments ?? []);

  PaymentMapModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = Rx<DateTime?>(
      json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : null,
    );
    // Handling payments field
    if (json['payments'] != null) {
      // Check if payments is a JSON string
      final dynamic paymentData = json['payments'] is String
          ? jsonDecode(json['payments'])
          : json['payments'];

      // Ensure paymentData is a list
      if (paymentData is List) {
        payments = RxList<PaymentModel>(
          paymentData
              .map((i) => PaymentModel.fromJson(i as Map<String, dynamic>))
              .toList(),
        );
      } else {
        // Handle the case where paymentData is not a list
        payments = RxList<PaymentModel>(
          (jsonDecode(paymentData) as List)
              .map((i) => PaymentModel.fromJson(i as Map<String, dynamic>))
              .toList(),
        );
      }
    } else {
      payments = RxList<PaymentModel>();
    }
  }

  PaymentMapModel.fromRow(sqlite.Row row)
      : id = row['id'],
        createdAt = Rx<DateTime?>(DateTime.parse(row['created_at']).toLocal()),
        payments = RxList<PaymentModel>((row['payments'] as List)
            .map((i) => PaymentModel.fromRow(i))
            .toList());

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['created_at'] = createdAt.value?.toIso8601String();
    data['payments'] = payments.map((item) => item.toJson()).toList();
    return data;
  }
}
