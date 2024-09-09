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
        amountPaid = json['amount_paid'].toDouble(),
        remain = json['remain'].toDouble(),
        finalAmountPaid = json['final_amount_paid'].toDouble(),
        date = DateTime.parse(json['date']).toLocal();

  PaymentModel.fromRow(sqlite.Row row)
      : method = row['method'],
        amountPaid = row['amount_paid'].toDouble(),
        remain = row['remain'].toDouble(),
        finalAmountPaid = row['final_amount_paid'].toDouble(),
        date = DateTime.parse(row['date']).toLocal();

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
