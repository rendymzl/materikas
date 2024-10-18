import 'package:powersync/sqlite3_common.dart' as sqlite;

class Billing {
  String billingName;
  DateTime? paymentDate;
  String billingNumber;
  double amountPaid;
  bool isPaid;

  Billing({
    required this.billingName,
    this.paymentDate,
    required this.billingNumber,
    required this.amountPaid,
    required this.isPaid,
  });

  factory Billing.fromJson(Map<String, dynamic> json) {
    return Billing(
      billingName: json['billing_name'],
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date']).toLocal()
          : null,
      billingNumber: json['billing_number'],
      amountPaid: json['amount_paid'],
      isPaid: json['is_paid'],
    );
  }

  factory Billing.fromRow(sqlite.Row row) {
    return Billing(
      billingName: row['billing_name'],
      paymentDate: row['payment_date'] != null
          ? DateTime.parse(row['payment_date']).toLocal()
          : null,
      billingNumber: row['billing_number'],
      amountPaid: row['amount_paid'],
      isPaid: row['is_paid'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['billing_name'] = billingName;
    data['payment_date'] = paymentDate?.toIso8601String();
    data['billing_number'] = billingNumber;
    data['amount_paid'] = amountPaid;
    data['is_paid'] = isPaid;
    return data;
  }
}
