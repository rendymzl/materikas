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
    data['date'] = date != null ? date!.toIso8601String() : DateTime.now();
    return data;
  }
}
